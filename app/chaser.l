
(setq *RestAllowed '(states first last))

(de first (L) (car L))

(de states (Args)
   (collect '_id '+Document) )