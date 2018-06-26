
(de proc-item (F A)
   (if
      (setq Exe (getd (car (str F))))
      (prog
         (ifn (member F *RestAllowed) (throw 'rest (httpStat 403 "Not allowed.")))
         (Exe A) )
      (if
         (getDocument F)
         (sho> @)
         (throw 'rest (http404)) ) ) )

(de proc-reply (R)
   (res "text/json"
      (prog
         (printJson R)
         (prinl) ) ) )

(de proc-get ()
   (if
      (catch 'rest
         (mapc
            '((X)
               (setq *LastRes (proc-item (pack X) *LastRes))
               NIL )
            (cdr (split *PathInfo "/")) ) )
      (apply res @)
      (proc-reply *LastRes) ) )

(de proc-post ()
   (httpStat 403 "Not implemented yet.") )

(de _prop (P)
   (cond
      ((atom P) P)
      ((=T (car P))
         (make
            (mapc
               '((X) (link (_prop X)))
               (cdr P) ) ) )
      (T (_doc P)) ) )

(de _doc (Doc)
   (let Obj (new-obj ((+Document)
      _id (or (cdr (assoc '_id Doc))
         (uuidv4) ) ) )
      (mapc
         '((X)
            (put Obj (car (str (car X))) (_prop (cdr X))) )
         Doc )
      Obj ) )

(de proc-put ()
   (let (Doc (parseJson (caar (get-form-data)) T)
         Obj (_doc Doc) )
      (commit)
      (proc-reply (sho> Obj)) ) )

(de proc-delete ()
   (httpStat 403 "Not implemented yet.") )

(de proc-request ()
   (case *ReqMethod
      ("GET" (proc-get))
      ("POST" (proc-post))
      ("PUT" (proc-put))
      ("DELETE" (proc-delete))
      (T (httpStat 403 "Invalid request method.")) ) )