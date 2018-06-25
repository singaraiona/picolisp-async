### Role ###
(obj ((+Role) nm "Administration") perm `*Perms)
(commit)

### User ###
(obj ((+User) nm "admin") pw `(passwd "admin") nam "Administrator" role `(db 'nm '+Role "Administration"))
(commit)