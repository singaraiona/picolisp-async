
(load "epoll.l")
(load "async.l")

(de async-handle (E)
   (msg (assoc E *Hdls)) )

(de main ()
   (async-new-pool)
   (async-spawn (async-new-listener 8080 'async-handle))
   (async-run) )