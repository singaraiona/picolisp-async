# A runtime for writing reliable, asynchronous, and slim applications
# ---
(load "epoll.l")

(setq *ASYNC_MAX_EVENTS 10000)

(de async-clb (E)
   (msg (text "FD: @1 E: @2" (car E) (cadr E))) )

(de async-listen (Port)
   (setq *Sock (port Port))
   (epoll-new *ASYNC_MAX_EVENTS)
   (epoll-push *Sock)
   (loop
      (epoll-run *ASYNC_MAX_EVENTS 'async-clb) ) )

(async-listen 8080)
(epoll-free)