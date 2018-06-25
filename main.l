
(load "async/epoll.l")
(load "async/async.l")
(load "web/web.l")
(load "web/httpd.l")

(dh ("/")
  (res "application/json" (prinl "{\"a\": 12}")) )

(de main ()
  (server (or (format (sys "PORT")) 8080)) )