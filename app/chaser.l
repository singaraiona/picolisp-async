
(setq *RestAllowed '(states first last))

(setq *CheckUpdate
   '((U) (rest-bad (rest-err "asd" "forbidden"))) )

(de first (L) (car L))

(de states (Args)
   (collect '_id '+Document) )