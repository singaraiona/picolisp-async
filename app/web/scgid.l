# SCGI server for Web.l
# (c) 2012 Jose I. Romero

(de server (P)
   (setq P (port P))
   (gc)
   (loop
      (setq *Sock (listen P))
      (and reload (reload))
      (NIL (fork) (close P))
      (close *Sock) )
   (scgi *Sock)
   (bye) )

(de scgi (S)
   (off *Host *Referer *Agent *Headers *Cookies *ContType)
   (zero *ContLen)
   (in S
      (let H (split
                (mapcar pack
                   (ht:Read (prog1 (format (till ":" T)) (ht:Read 1))) )
                NIL )  
         (setq *RawSCGI H)  
         (while H
            (let (K (pop 'H) V (pop 'H)) 
               (case (pack K)
                  ("SERVER_PROTOCOL" (setq *Http1 (format (tail -1 V))))
                  ("REQUEST_METHOD" (setq *ReqMethod (pack V)))
                  ("PATH_INFO" (setq *PathInfo V))
                  ("REQUEST_URI" (setq *ReqUri V))
                  ("QUERY_STRING" (setq *QueryString V))
                  ("HTTP_COOKIE" (setq *Cookies V) )
                  ("CONTENT_LENGTH" (setq *ContLen (format V)))
                  ("CONTENT_TYPE" (setq *ContType V))
                  ("HTTP_HOST" (setq *Host V))
                  ("HTTP_USER_AGENT" (setq *Agent V))
                  ("HTTP_REFERER" (setq *Referer V))
                  ("REMOTE_ADDR" (setq *RemoteAddr V))
                  (T
                     (when (pre? "HTTP_" @)
                        (push '*Headers
                           (cons
                              (pack (replace (tail -5 (chop (lowc @))) "_" "-"))
                              V ) ) ) ) ) ) ) ) 
      (ht:Read 1) #Drop comma
      (out S (req-handler)) ) )