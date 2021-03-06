# epoll - I/O event notification facility wrapper
# ---
(setq *EPOLL_CTL_ADD 1)
(setq *EPOLL_CTL_DEL 2)
(setq *EPOLL_CTL_MOD 3)
(setq *O_NONBLOCK	2048)
(setq *F_GETFL 3)
(setq *F_SETFL 4)
(setq *SIZE_OF_EVENT 12)
(setq *EPOLLIN 1)
(setq *EPOLLOUT 4)
(setq *EPOLLERR 8)
(setq *EPOLLHUP 16)
(setq *EPOLLONESHOT (>> -30 1))
(setq *EPOLLET (>> -31 1))

(de std-fcntl (Fd Cmd Arg)
   (native "@" "fcntl" 'I Fd Cmd Arg) )

(de epoll-create (Flags)
   (native "@" "epoll_create" 'I Flags) )

(de epoll-ctl (EpFd Op Fd Evt)
   (native "@" "epoll_ctl" 'I EpFd Op Fd Evt) )

(de epoll-wait (EpFd Evts MaxEvts Timeout)
   (native "@" "epoll_wait" 'I EpFd Evts MaxEvts Timeout) )

(de epoll-event (E L)
   (let Evt (native "@" "malloc" 'N *SIZE_OF_EVENT)
      (if L
         (struct Evt 'N (cons *EPOLLIN 4) (cons E 8))
         (prog
            (std-fcntl E *F_SETFL (| (std-fcntl E *F_GETFL) *O_NONBLOCK))
            (struct Evt 'N (cons (| *EPOLLIN  *EPOLLET
                                    *EPOLLHUP *EPOLLERR ) 4) (cons E 8) ) ) )
      (queue '*Alloc Evt)
      Evt ) )

(de epoll-events-buf (S)
   (native "@" "malloc" 'N (* S *SIZE_OF_EVENT)) )

(de epoll-push (E L)
   (let Evt (epoll-event E L)
      (epoll-ctl *EpollFd *EPOLL_CTL_ADD E Evt) ) )

(de epoll-pop (E)
   (epoll-ctl *EpollFd *EPOLL_CTL_DEL E)
   (del E '*Alloc) )

(de epoll-new (S)
   (setq *EpollSize S)
   (setq *EpollFd (epoll-create S))
   (setq *Evts (epoll-events-buf S))
   (queue '*Alloc *Evts) )

(de epoll-free ()
   (mapc
      '((R) (native "@" "free" NIL R))
      *Alloc ) )

(de epoll-run (U)
   (epoll-wait *EpollFd *Evts *EpollSize (or U 0)) )

(de epoll-get-event (I)
   (let Evts (+ *Evts (* (dec I) *SIZE_OF_EVENT))
      (cadr (struct Evts '(I N))) ) )
