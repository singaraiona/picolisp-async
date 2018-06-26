#(load "ext/lst.l")
(symbols 'json 'pico)

(de checkJson (X Item)
   (unless (= X Item)
      (quit "Bad JSON" Item) ) )

(de rdJson ()
   (case (read "_")
      ("{"
         (make
            (for (X (rdJson)  (not (= "}" X))  (rdJson))
               (checkJson ":" (rdJson))
               (link (cons X (rdJson)))
               (T (= "}" (setq X (rdJson))))
               (checkJson "," X) ) ) )
      ("["
         (make
            (link "[]")  # Array marker
            (for (X (rdJson)  (not (= "]" X))  (rdJson))
               (link X)
               (T (= "]" (setq X (rdJson))))
               (checkJson "," X) ) ) )
      (T
         (let X @
            (if (and (= "-" X) (format (peek)))
               (- (read))
               X ) ) ) ) )

(de prLst (Lst)
   (prin "[")
   (map
      '((X)
        (prJson (car X))
        (and (cdr X) (prin ", ")) )
      Lst )
   (prin "]") )

(de prObj (Obj)
   (prin "{")
   (map
      '((X)
        (print (caar X))
        (prin ": ")
        (prJson (cdar X))
        (and (cdr X) (prin ", ")) )
      (mapcar
         '((Pair) (cons (sym (cdr Pair)) (car Pair)))
         (getl Obj) ) )
   (prin "}") )

(de prAssoc (Lst)
   (prin "{")
   (while Lst
      (let (El (pop 'Lst) K (car El) V (if (= 1 (length (cdr El))) (last El) (cdr El)) )
         (print (if (str? K) K (sym K)))
         (prin ": ")
         (cond
            ((exlst~assoc? V) (prAssoc V))
            (T (prJson V)) )
         (and Lst (prin ", ")) ) )
   (prin "}") )

(de prJson (Item)  # For simplicity, without indentation
   (cond
      ((atom Item)
       (cond
          ((=T Item) (prin "true"))
          ((not Item) (prin "false"))
          ((or (ext? Item) (box? Item))
           (prObj Item) )
          ((or (str? Item) (num? Item))
           (print Item))
          (T (print (sym Item))) ) )
      ((= "[]" (car Item))
       (prLst (cdr Item)) )
      ((exlst~assoc? Item)
       (prAssoc Item) )
      (T (prLst Item)) ) )


