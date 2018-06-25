# Pcgi server component

(de server (P)
   (setq *Port (port P))
   (gc)
   (task *Port
      (setq *Sock (listen *Port))
      (unless (fork)
         (off *Run)
         (close *Port)
         (pcgi *Sock)
         (bye) )
      (close *Sock) ) )

(de pcgi (S)
   (in S
      (while (read)
         (set @ (chop (read))) )
      (out S (req-handler)) ) )
