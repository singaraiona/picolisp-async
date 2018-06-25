
(de proc-fn (F A)
   (ifn (getd F) (throw 'rest (http404)))
   (ifn (member F *RestAllowed) (throw 'rest (httpStat 403 "Not allowed.")))
   (F A) )

(de proc-request ()
   (if
      (catch 'rest
         (mapc
            '((X)
               (setq *LastRes (proc-fn (car (str (pack X))) *LastRes))
               NIL )
            (cdr (split *PathInfo "/")) ) )
      (apply res @)
      (res "text/json"
         (printJson
            (ifn (pair (car *LastRes))
               (list *LastRes)
               *LastRes ) ) ) ) )
