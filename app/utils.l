
(setq *UUIDSTR (chop "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"))

(de ts ()
   (+ (* 86400 (- (date) (date 1970 1 1))) (time)) )

(seed (ts))

### UUID RFC4122
(de uuidv4 ()
   (pack
      (make
         (mapc
            '((C)
               (let R (| (% (rand) 16) 0)
                  (link
                     (cond
                        ((= "x" C) (lowc (hex R)))
                        ((= "y" C) (lowc (hex (| (& R 3) 8))))
                        (T C) ) ) ) )
            *UUIDSTR ) ) ) )
