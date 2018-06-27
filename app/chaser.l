
(setq *RestAllowed '(states first last))

(setq *CheckUpdate
   '((Obj)
      (nond
         ((get Obj 'type) (rest-bad (rest-err "update_error" "document must have type field")))
         (NIL
            (or
               (get Obj 'ts)
               (put Obj 'ts (ts)) ) ) ) ) )

(de first (L) (car L))

(de states (Args)
   (collect '_id '+Document) )