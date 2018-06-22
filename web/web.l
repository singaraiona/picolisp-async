# Web.l Picolisp mini-framework
# (c) 2012 José I. Romero
# Parts from @lib/http.l by Alexander Burger (c) 2012 Expat License

# *StatusPrefix should be HTTP/version for an HTTP server response
(default *StatusPrefix "Status: ")

(de urlDecode (X)
   (setq X (split X "="))
   (cons (ht:Pack (car X)) (ht:Pack (cadr X))) )

# HTTP Response
(de res (Typ . "Prg")
   (prinl *StatusPrefix (or *HTTPStatus "200 OK") "^M")
   (prinl "Content-type: " (or Typ "text/plain; charset=utf-8") "^M")
   (and *Chunked (prinl "Transfer-Encoding: chunked^M"))
   (for H "*Headers"
      (prinl (car H) ": " (glue ", " (cdr H)) "^M") )
   (httpCookies)
   (prinl "^M")
   (ht:Out *Chunked (run "Prg")) )

# Get/set a header
(de header (N . @)
   (cond
      ((not (args)) (cdr (assoc *Headers)))
      ((assoc N "*Headers") (conc @ (rest)))
      (T (push '"*Headers" (cons N (rest)))) ) )

# Set the HTTP status
(de status (S)
   (setq *HTTPStatus S) )

# Cache control headers
(de no-cache ()
   (header "Cache-control" "private" "no-store" "no-cache") )

(de max-age (N)
   (header "Cache-control" (pack "max-age=" N)) )

# Write all the outstanding http cookies.
(de httpCookies ()
   (mapc
      '((L)
         (prin "Set-Cookie: "
            (ht:Fmt (pop 'L)) "=" (ht:Fmt (pop 'L))
            "; path=" (or (pop 'L) "/") )
         (and (pop 'L) (prin "; expires=" @))
         (and (pop 'L) (prin "; domain=" @))
         (and (pop 'L) (prin "; secure"))
         (and (pop 'L) (prin "; HttpOnly"))
         (prinl) )
      "*Cookies" ) )

# Get/set a cookie
# (cookie 'name ['value 'expires 'domain 'secure 'httponly])
(de cookie (N . @)
   (cond
      ((not (args)) (cdr (assoc N *Cookies)))
      ((assoc N "*Cookies") (con @ (rest)))
      (T (push '"*Cookies" (cons N (rest)))) ) )

(de get-query (Name)
   (default *Query (mapcar urlDecode (split *QueryString "&" ";")))
   (cdr (assoc Name *Query)) )

(de get-form-data ()
   (use (@X)
      (cond
         ((match '(~(chop "multipart/form-data; boundary=") @X) *ContType)
          (setq
             *MPartLim (append '(- -) @X)
             *MPartEnd (append *MPartLim '(- -)) )
          (make (_htMultipart)) )
         (*ContLen (mapcar urlDecode (split (ht:Read @) "&" ";"))) ) ) )

(de _htSet ("Var" Val)
   (link (list (ht:Pack "Var") Val))
   Val )

# rfc1867 multipart/form-data
(de _htMultipart ()
   (use (L @X @N @V)
      (setq L (line))
      (while (= *MPartLim L)
         (unless (match '(~(chop "Content-Disposition: form-data; name=") . @X) (line))
            (throw "http") )
         (while (line))
         (cond
            ((not (member ";" @X))
               (match '("\"" @X "\"") @X)
               (_htSet @X
                  (pack
                     (make
                        (until
                           (or
                              (= *MPartLim (setq L (line)))
                              (= *MPartEnd L) )
                           (when (eof)
                              (throw "http") )
                           (when (made)
                              (link "^J") )
                           (link (trim L)) ) ) ) ) )
            ((match '(@N ~(chop "; filename=") . @V) @X)
               (match '("\"" @N "\"") @N)
               (match '("\"" @V "\"") @V)
               (if (_htSet @N (tmp (pack (stem @V '/ "\\"))))
                  (let F @
                     (unless (out F (echo (pack "^M^J" *MPartLim)))
                        (call 'rm "-f" F) ) )
                  (out "/dev/null" (echo (pack "^M^J" *MPartLim))) )
               (setq L (if (= "-" (car (line))) *MPartEnd *MPartLim)) ) ) ) ) )

(de get-form (Name)
   (default *Form (get-form-data))
   (cdr (assoc Name *Form)) )

(de httpStat (N Str)
   (status (pack N " " Str))
   (header "Content-length" (+ 68 (length N) (* 2 (length Str))))
   (res "text/html"
      (prinl "<html>")
      (prinl "<head><title>" N " " Str "</title></head>")
      (prinl "<body><h1>" Str "</h1></body>")
      (prinl "</html>") ) )

(de noContent ()
   (httpStat 204 "No Content") )

(de redirect @
   (header "Location" (pass pack))
   (httpStat 303 "See Other") )

(de forbidden ()
   (httpStat 403 "No Permission")
   (throw "http") )

(de http404 ()
   (httpStat 404 "Not Found") )

(de *Mimes
   (`(chop "html") "text/html; charset=utf-8")
   (`(chop "au") "audio/basic" 3600)
   (`(chop "wav") "audio/x-wav" 3600)
   (`(chop "mp3") "audio/x-mpeg" 3600)
   (`(chop "gif") "image/gif" 3600)
   (`(chop "tif") "image/tiff" 3600)
   (`(chop "tiff") "image/tiff" 3600)
   (`(chop "bmp") "image/bmp" 3600)
   (`(chop "png") "image/png" 3600)
   (`(chop "jpg") "image/jpeg" 3600)
   (`(chop "jpeg") "image/jpeg" 3600)
   (`(chop "txt") "text/octet-stream" 1 T)
   (`(chop "csv") "text/csv; charset=utf-8" 1 T)
   (`(chop "css") "text/css" 3600)
   (`(chop "js") "application/x-javascript" 3600)
   (`(chop "ps") "application/postscript" 1)
   (`(chop "pdf") "application/pdf" 1)
   (`(chop "zip") "application/zip" 1)
   (`(chop "jar") "application/java-archive" 3600)
   (`(chop "ttf") "font/truetype" 3600)
   (`(chop "woff") "application/font-woff" 3600)
   (`(chop "woff2") "application/font-woff" 3600)
   (`(chop "eot") "application/vnd.ms-fontobject" 3600) )

(de rfc3339-stamp (Dat Tim)
   (let D (date Dat)
      (pack
         (day Dat *Day) ", "
         (pad 2 (caddr D)) " "
         (get *Mon (cadr D)) " "
         (car D) " "
         (tim$ Tim T) " GMT^M" ) ) )

(de strip-path (P)
   (let RPath ()
      (for D (split (chop P) "/")
         (case (pack D)
            (("" "."))
            (".." (pop 'RPath))
            (T (push 'RPath @)) ) )
      (glue "/" (flip RPath)) ) )

(de send-file (File)
   (ifn (info File)
      (http404)
      (let (I @ Typ (assoc (stem (chop File) ".") *Mimes))
         (header "Content-length" (car I))
         (header "Last-modified" (rfc3339-stamp (cadr I) (cddr I)))
         (max-age (or (caddr Typ) 600))
         (res (or (cadr Typ) "application/octet-stream")
            (in File (echo)) ) ) ) )

# Default request handling system

# (dh lst . prg) -> handler
# Define an url handler
# The first argument is an url pattern to match, the second is a prg
# body to run when the request url matches the pattern. For proper
# operation, define the patterns from the most general to the most
# particular.
(de dh X
   (push '*Handlers
      (cons
         (list 'match
            (cons 'quote
               (mapcan '[(S) (if (pat? S) (cons @) (chop S))] (car X)) )
            '*PathInfo )
         (cdr X) ) ) )

# By default we have an unconditonal handler with a 404 error
(default *Handlers '((T (http404)) ) )

(de req-handler ()
   # Adapt/decode variables
   (or (= "/" (car *PathInfo)) (push '*PathInfo "/"))
   (off "*Headers" "*Cookies")
   (cond
      ((member (pack (cadr (split *PathInfo "/"))) *AllowDir)
         (send-file (pack (pwd) "/" *PathInfo)) )
      (T (eval (cons 'cond *Handlers))) ) )

