
(seed "!#$QWERT*(&^GF")
(setq *UUIDSTR (chop "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"))

(de ts ()
   (+ (* 86400 (- (date) (date 1970 1 1))) (time)) )

### UUID RFC4122
(de uuidv4 ()
   (pack
      (make
         (mapc
            '((C)
               (let R (| (% (rand) 16) 0)
                  (link
                     (cond
                        ((= "x" C) (hex R))
                        ((= "y" C) (hex (| (& R 3) 8)))
                        (T C) ) ) ) )
            *UUIDSTR ) ) ) )
