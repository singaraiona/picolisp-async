
(setq *RestAllowed '(states))

(de states (Args)
   (make
      (link T)
      (mapc
         '((X) (link (sho> X)))
         (collect '_id '+Document) ) ) )