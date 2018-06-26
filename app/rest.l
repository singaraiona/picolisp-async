
(de proc-fn (F A)
   (ifn (getd F) (throw 'rest (http404)))
   (ifn (member F *RestAllowed) (throw 'rest (httpStat 403 "Not allowed.")))
   (F A) )

(de proc-get ()
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

(de proc-post ()
   (httpStat 403 "Not implemented yet.") )

(de proc-put ()
   (let (Doc (parseJson (caar (get-form-data)))
         Obj (obj ((+Document) _id (genKey '_id '+Document))) )

         (res "text/json" (printJson Obj)) ) )

(de proc-delete ()
   (httpStat 403 "Not implemented yet.") )

(de proc-request ()
   (case *ReqMethod
      ("GET" (proc-get))
      ("POST" (proc-post))
      ("PUT" (proc-put))
      ("DELETE" (proc-delete))
      (T (httpStat 403 "Invalid request method.")) ) )