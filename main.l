
(load "async/epoll.l")
(load "async/async.l")
(load "web/web.l")
(load "web/httpd.l")

(de main ()
   (async-new-pool)
   (async-new-listener 8080 http)
   (async-run) )