
(de bad "Args"
  (throw 'rest (eval (pop '"Args"))) )

(de ok "Args"
   (res "text/json" (eval (pop '"Args"))) )

(de query-arg (P E)
   (if E
      (= E (get-query P))
      (get-query P) ) )

(de proc-item (F A)
   (if
      (setq Exe (getd (car (str F))))
      (prog
         (ifn (member F *RestAllowed) (bad (httpStat 403 "Not allowed.")))
         (Exe A) )
      (or
         (getDocument F)
         (throw 'rest (http404)) ) ) )

(de proc-reply (R)
   (use @Flds @Inc)
   (setq @Flds (query-arg "include_fields" "true"))
   (setq @Inc (query-arg "include_doc" "true"))
   (ok
      (if
         (atom R)
         (prog
            (printJson (sho> R @Flds @Inc))
            (prinl) )
         (prog
            (prin "[")
            (printJson (sho> (car R))))
            (mapc
               '((X)
                  (prin ",")
                  (printJson (sho> X @Flds @Inc)))
               (cdr R) )
            (prinl "]") ) ) )

(de proc-db (Url)
   (mapc
      '((X)
         (and X
            (setq *LastRes (proc-item (pack X) *LastRes)) )
         NIL )
      Url )
   *LastRes )

(de proc-url (Url)
   (send-file
      (pack "static/" (or (pack Url) "index.html")) ) )

(de proc-get ()
   (let U (cdr (split *PathInfo "/"))
      (case
         (pack (car U))
         ("db" (proc-db (cdr U)))
         (T (proc-url U)) ) ) )

(de proc-post ()
   (bad (httpStat 403 "Not implemented yet.")) )

(de proc-put ()
   (let (Doc (parseJson (caar (get-form-data)) T)
         Obj (_doc Doc) )
         (commit)
         Obj ) )

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

(de proc-delete ()
   (bad (httpStat 403 "Not implemented yet.")) )

(de proc-request ()
   (catch 'rest
      (let? R
         (case *ReqMethod
            ("GET" (proc-get))
            ("POST" (proc-post))
            ("PUT" (proc-put))
            ("DELETE" (proc-delete))
            (T (bad (httpStat 403 "Invalid request method."))) )
      (proc-reply R) ) )
   (apply res @) )
