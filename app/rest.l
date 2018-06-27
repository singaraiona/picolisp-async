
(de query-arg (P E)
   (if E
      (= E (get-query P))
      (get-query P) ) )

(de proc-item (F A)
   (if
      (setq Exe (getd (car (str F))))
      (prog
         (ifn (member F *RestAllowed) (throw 'rest (httpStat 403 "Not allowed.")))
         (Exe A) )
      (or
         (getDocument F)
         (throw 'rest (http404)) ) ) )

(de proc-reply (R)
   (setq Flds (query-arg "include_fields" "true"))
   (setq Inc (query-arg "include_doc" "true"))
   (res "text/json"
      (if
         (atom R)
         (prog
            (printJson (sho> R Flds Inc))
            (prinl) )
         (prog
            (prin "[")
            (printJson (sho> (car R))))
            (mapc
               '((X)
                  (prin ",")
                  (printJson (sho> X Flds Inc)))
               (cdr R) )
            (prinl "]") ) ) )

(de proc-db (Url)
   (if
      (catch 'rest
         (mapc
            '((X)
               (and X
                  (setq *LastRes (proc-item (pack X) *LastRes)) )
               NIL )
            Url ) )
      (apply res @)
      (proc-reply *LastRes) ) )

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
   (httpStat 403 "Not implemented yet.") )

(de proc-put ()
   (let (Doc (parseJson (caar (get-form-data)) T)
         Obj (_doc Doc) )
      (commit)
      (proc-reply (sho> Obj)) ) )

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
   (httpStat 403 "Not implemented yet.") )

(de proc-request ()
   (case *ReqMethod
      ("GET" (proc-get))
      ("POST" (proc-post))
      ("PUT" (proc-put))
      ("DELETE" (proc-delete))
      (T (httpStat 403 "Invalid request method.")) ) )