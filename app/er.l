
(class +Document +Entity)
(rel _id (+Key +Number))

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