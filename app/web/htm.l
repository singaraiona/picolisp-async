# Monkey-patch xhtml.l
(load "@lib/xhtml.l")
#(mapc undef '(html))
(def 'sesId prog) # Url sesId not implemented
(def 'baseHRef nil) # Not necessary, call depends on *Port and *Host
(def 'srcUrl prog) # Override this for another source URL

(setq "css" (car (fish '((X) (= X "css")) html)))

(de <html> Prg
   (prinl "<!DOCTYPE html>")
   (prinl "<html>")
   (run Prg 2)
   (prinl "</html>") )
(de <title> Prg (tag 'title NIL 2 Prg))
(de <head> Prg (tag 'head NIL 2 Prg))
(de <body> (Attr . Prg) (tag 'body Attr 2 Prg))
(setq <css> "css")
(de <javascript> (JS . @)
   (when JS
      (prinl "<script type=\"text/javascript\" src=\"" (srcUrl JS) "\"></script>") )
   (when (rest)
      (prinl "<script type=\"text/javascript\">" @ "</script>") ) )


# Html response
(de res-html (Ttl Css Attr . Prg)
   (res "text/html; charset=utf-8"
      (prinl "<!DOCTYPE html>")
      (prinl "<html lang=\"" (or *Lang "en") "\">")
      (prinl "<head>")
      (prinl "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">")
      (and Ttl (<tag> 'title NIL Ttl) (prinl))
      (and *Host *Port (prinl "<base href=\"" (baseHRef) "\"/>"))
      (when Css
         (if (atom Css) ("css" Css) (mapc "css" Css)) )
      (mapc javascript *JS)
      (prinl "</head>")
      (tag 'body Attr 2 Prg)
      (prinl "</html>") ) )

(off <form> <field> <area> <select>)
(de <form> (Attr Url Multi . Prg)
   (prin "<form action=\"" Url "\" " (when Multi "enctype=\"multipart/form-data\"") "method=\"post\">")
   (tag 'div Attr 2 Prg)
   (prinl "</form>") )

(de <field> (Type Name Value Class Flg)
   (prin "<input type=\"" Type "\" ")
   (and Name (prin " name=\"" Name "\" "))
   (prin " value=\"")
   (ht:Prin Value)
   (prin "\" ")
   (and Class (prin " class=\"" Class "\" "))
   (and Flg (prin " disabled=\"disabled\""))
   (prinl ">") )

(de <area> (Name Value Cols Rows)
   (prin "<textarea name=\"" Name "\""
      (and Cols (pack " cols=\"" @ "\"")) 
      (and Rows (pack " rows=\"" @ "\"")) 
      ">" )
   (ht:Prin Value)
   (prinl "</textarea>") )

(de <select> (Name Value Lst Flg)
   (prin "<select name=\"" Name "\"")
   (prin '>)
   (for "X" Lst
      (let "V" (if (atom "X") "X" (car "X"))
         (prin
            "<option"
            (pack " value=\"" "V" "\"")
            (cond
               ((= "V" Value) " selected=\"selected\"")
               (Flg " disabled=\"disabled\"") )
            '> )
         (ht:Prin (if (pair "X") (cdr "X") "V")) )
      (prin "</option>") )
   (prinl "</select>") )