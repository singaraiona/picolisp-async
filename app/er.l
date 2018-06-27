
(class +Document +Entity)
(rel _id (+Sn +IdxFold +String))

(dm sho> (Flds Inc)
   (ifn Flds
      (list (cons '_id  (: _id)))
      (make
         (mapc
            '((X)
               (link
                  (cons
                     (cdr X)
                     (if
                        (ext? (car X))
                        (sho> (car X) Inc Inc)
                        (car X) ) ) ) )
            (getl This) ) ) ) )

### Same as (obj) but evaluates fields
(de new-obj Lst
   (let (ReqLst (pop 'Lst)
         ReqCls (pop 'ReqLst)
         l1 (make (link ReqCls)
                  (while ReqLst
                     (link (pop 'ReqLst))
                     (link (eval (pop 'ReqLst))) ) )
         Obj (apply request l1) )
      (while Lst
         (put> Obj (pop 'Lst) (eval (pop 'Lst))) )
   Obj ) )

(de getDocument (Id)
   (pilog
      (quote
         @Id Id
         (select (@@)
            ((_id +Document @Id))
               (same @Id @@ _id) ) )
      @@ ) )