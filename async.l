# A runtime for writing reliable, asynchronous, and slim applications
# ---
(setq *ASYNC_MAX_EVENTS 10000)

(de async-handle (E)
   (msg (assoc E *Hdls)) )
   #(let S (accept (cadr E))
   #   (msg S)
   #   (epoll-push S)
   #   (out S (prin "Ok"))
   #   (close S) ) )

(de async-spawn (E F)
   (queue '*Hdls (cons E F))
   (epoll-push E) )

(de async-new-pool ()
   (epoll-new *ASYNC_MAX_EVENTS) )

(de async-run ()
   (loop
      (for N (epoll-run)
         (let E (epoll-get-event N)
            (async-handle E) ) ) ) )

(de async-new-listener (P F)
   (async-spawn (port P) F) )

