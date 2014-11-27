FUNCTION create_section, N, nsec=nsec
; creer une structure de type section qui contient tous les fichiers section.*
; des sorties de tUGO

my_str={name:'', origine:'', filename:'',$
        jul:DBLARR(N), val:FLTARR(N)}

IF KEYWORD_SET(nsec) THEN my_str=replicate(my_str, nsec)
RETURN, my_str
END