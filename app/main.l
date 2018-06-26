(de *Prompt "[chaser]")

(load "@lib/adm.l" "@lib/math.l" "@lib/too.l" "@lib/json.l")
(load "app/er.l" "app/async/epoll.l" "app/async/async.l"
      "app/web/web.l" "app/web/httpd.l" "app/rest.l"
      "app/chaser.l" )

(setq
   *Pool "db/app/"
   *Blob "db/app/blob/"
   *Salt (16 . "$6$@1$") )

(setq *DBFILE "db/chaser.db")

(permission
   RoleAdmin ,"Role Administration"
   UserAdmin ,"User Administration"
   Password  ,"Password"
   Create ,"Create" )

(de main ()
  (call "mkdir" "-p" "db/app/" *Blob)
  (pool *DBFILE)
  (load "app/init.l")
  (server (or (format (sys "PORT")) 8080) T) )
