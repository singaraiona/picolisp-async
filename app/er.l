
(class +Document +Entity)
(rel _id (+Sn +IdxFold +String))

(dm sho> (A)
   (ifn A
      (list (cons '_id (: _id)))
      (msg (getl This)) ) )

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