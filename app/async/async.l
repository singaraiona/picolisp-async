# A runtime for writing reliable, asynchronous, and slim applications
# ---
(setq *ASYNC_MAX_EVENTS 10000)

(de async-handle (E)
   (let? U (assoc E *Hdls)
      ((cdr U) (car U)) ) )

(de async-spawn (E F L)
   (queue '*Hdls (cons E F))
   (epoll-push E L) )

(de async-listener (E F)
   (queue '*Hdls (cons E F))
   (epoll-push E) )

(de async-stop (E)
   (del (assoc E *Hdls) '*Hdls)
   (epoll-pop E)
   (close E) )

(de async-new-pool ()
   (epoll-new *ASYNC_MAX_EVENTS) )

(de async-run ()
   (loop
      (for N (epoll-run)
         (let E (epoll-get-event N)
            (async-handle E) ) ) ) )

(de async-new-listener "Args"
   (let (P (eval (pop '"Args"))
         F (pop '"Args") )
      (async-spawn
         (port P)
         (list '(E)
            (list 'let 'S '(accept E)
               (list 'async-spawn 'S F) ) )
         T ) ) )

(de async-ps1 ()
   (prin "[chaser]: ")
   (flush) )

(de async-new-console ()
   (async-ps1)
   (async-spawn
      0
      'async-repl ) )

(de async-repl (S)
   (let? E
      (in S (eval (car (str (line T)))))
      (println '-> E) )
   (async-ps1) )
