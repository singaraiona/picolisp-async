
(load "async/epoll.l")
(load "async/async.l")

(de http (S)
   (in S
      (while (line T)
         (msg @) )
      (async-stop S) ) )

(de main ()
   (async-new-pool)
   (async-new-listener 8080 http)
   (async-run) )