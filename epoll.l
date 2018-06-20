# epoll - I/O event notification facility wrapper
# ---
(setq *EPOLL_CTL_ADD 1)
(setq *EPOLL_CTL_DEL 2)
(setq *EPOLL_CTL_MOD 3)
(setq *O_NONBLOCK	4)
(setq *F_GETFL 3)
(setq *F_SETFL 4)
(setq *SIZE_OF_EVENT 12)
(setq *EPOLLIN 1)
(setq *EPOLLONESHOT (>> -30 1))
(setq *EPOLLET (>> -31 1))

(de epoll-create (Flags)
   (native "@" "epoll_create" 'I Flags) )

(de epoll-ctl (EpFd Op Fd Evt)
   (native "@" "epoll_ctl" 'I EpFd Op Fd Evt) )

(de epoll-wait (EpFd Evts MaxEvts Timeout)
   (native "@" "epoll_wait" 'I EpFd Evts MaxEvts Timeout) )

(de epoll-event (E)
   (let Evt (native "@" "malloc" 'N *SIZE_OF_EVENT)
      (struct Evt 'N (cons (| *EPOLLIN *EPOLLET) 4) (cons E 8))
      (queue '*Alloc Evt)
      Evt ) )

(de epoll-events-buf (S)
   (native "@" "malloc" 'N (* S *SIZE_OF_EVENT)) )

(de epoll-push (E)
   (let Evt (epoll-event E)
      (epoll-ctl *EpollFd *EPOLL_CTL_ADD E Evt) ) )

(de epoll-pop (E)
   (epoll-ctl *EpollFd *EPOLL_CTL_DEL E NIL) )

(de epoll-new (S)
   (setq *EpollFd (epoll-create S))
   (setq *Evts (epoll-events-buf S))
   (queue '*Alloc *Evts) )

(de epoll-free ()
   (mapc
      '((R) (native "@" "free" NIL R))
      *Alloc ) )

(de epoll-run (S F)
   (for E (epoll-wait *EpollFd *Evts S 0)
      (let Ev (struct *Evts '(I N))
         (F Ev) ) ) )
