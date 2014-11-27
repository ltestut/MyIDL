FUNCTION create_sample, N, nspl=nspl
; creer une structure de type sample qui contient tous les fichiers sample.*
; des sorties de tUGO

my_str={lon:0.0D, lat:0.0D, name:'', origine:'', filename:'',$
        jul:DBLARR(N), h:FLTARR(N), u:FLTARR(N), v:FLTARR(N), pa:FLTARR(N)}

IF KEYWORD_SET(nspl) THEN my_str=replicate(my_str, nspl)
RETURN, my_str
END