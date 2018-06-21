# Web Sockets -- RFC 6455
# (c) 2012 José I. Romero

# Ugly and slow utf8 decoding
(de decode-utf8 (Lst)
   (let (C 0 CP 0 L 0)
      (make
         (while (setq C (pop 'Lst))
            (cond
               # Direct access codepoint
               ((< C 128) (setq CP C L 0))
               # Continuation character
               ((and (= (& C 192) 128) (>= (dec 'L) 0))
                (setq CP (+ (>> -6 CP) (& C 63))) )
               # Sequence starters
               ((= (& C 224) 192) (setq CP (& C 31) L 1))
               ((= (& C 240) 224) (setq CP (& C 15) L 2))
               ((= (& C 248) 240) (setq CP (& C 7) L 3))
               # As per RFC 3629, code points above 0x10FFFF are not valid
               # So we don't bother with longer code sequences
               (T (throw 'utf8)) )
            (if (=0 L)
               (link (char CP)) ) ) ) ) )

# Get a websocket frame
(de ws-frame ()
   (use (C Fin Opcode Mask Size Mkey Payload)
      (setq C (rd 1)
         Fin  (> C 127)
         Opcode (& C 15) )
      (setq C (rd 1)
         Mask (> C 127)
         Size (& C 127) )
      # Unmasked frames are rejected as per RFC
      #(or Mask (throw 'websocket))
      # Extended size?
      (when (>= Size 126)
         (do (prog1 (if (= Size 126) 2 8) (zero Size))
            (setq Size (+ (>> -8 Size) (rd 1))) ) )
      # Get masking key
      (setq Mkey (if Mask (circ (rd 1) (rd 1) (rd 1) (rd 1)) (circ 0 0 0 0)))
      # Unmask payload
      (setq Payload
         (make
            (do Size
               (link (x| (rd 1) (pop 'Mkey))) ) ) )
      (cons Opcode Fin Payload) ) )

(de ws-write (Typ Fin Msg)
   (wr (+ Typ (if Fin 128 0)))
   (let L (size Msg)
      (cond
         ((< L 126) (wr L))
         ((< L `(** 2 16)) (wr 126) (wr (>> 8 L)) (wr (& L 255)))
         ((< L `(** 2 64)) (wr 127) (for X 8 (wr (& 255 (>> (* 8 (- 8 X)) L)))))
         (T (bye)) ) )
   (cond
      ((sym? Msg) (prin Msg))
      ((and (lst? Msg) (num? (car Msg))) (apply wr Msg) )
      ((and (lst? Msg) (sym? (car Msg))) (prin Msg) )
      (T (quit "Bad message data")) )
   (flush) )

(de ws-send @
   (ws-write 1 T (pass pack)) )

(de ws-handshake ()
   (and
      (= (lowc (pack (cdr (assoc "upgrade" *Headers)))) "websocket")
      (sub? "upgrade" (lowc (pack (cdr (assoc "connection" *Headers)))))
      (= (format (cdr (assoc "sec-websocket-version" *Headers))) 13)
      (setq *WsKey (cdr (assoc "sec-websocket-key" *Headers)))

      (pipe
         (out '(openssl "sha1" "-binary")
            (prin *WsKey "258EAFA5-E914-47DA-95CA-C5AB0DC85B11") )
         (pipe
            (out '(base64) (echo))
            (out *Sock
               (prinl "HTTP/1.1 101 Switching protocols^M")
               (prinl "Connection: Upgrade^M")
               (prinl "Upgrade: websocket^M")
               (prinl "Sec-WebSocket-Accept: " (line) "^M")
               (prinl "^M") ) )
         T )
      (t (task *Sock)) ) ) # Disable the other protocols

# Start listening to websocket events
(de ws-start ()
   (off *WsFin *WsPayload *WsOpcode)
   (setq "*OnMessage" "Prg")
   (task *Sock
      (in @
         (let F (ws-frame)
            (case (pop 'F)
               (8 (bye))
               (9 (out *Sock (ws-write 10 (pop 'F) F)))
               (0
                  (setq *WsFin (pop 'F))
                  (if *WsOpcode (conc *WsPayload F)) )
               (NIL (bye))
               (T (setq *WsOpcode @ *WsFin (pop 'F) *WsPayload F)) ) )
         (when *WsFin
            (if (= *WsOpcode 1) (setq *WsPayload (decode-utf8 *WsPayload)))
            (out *Sock (run *WsMsg))
            (off *WsFin *WsPayload *WsOpcode) ) ) ) )
