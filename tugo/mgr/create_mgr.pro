FUNCTION create_mgr, nsta, nwave
; creer une structure de type mgr (format de sortie de l'analyse harmonique)
; nsta  : nombre de station contenu dans le mgr (par defaut = 1)
; nwave : nombre maximum d'ondes (par defaut = 8)

IF (N_PARAMS() LT 1) THEN nsta=1  ;par defaut
IF (N_PARAMS() LT 2) THEN nwave=8 ;par defaut

 ;on creer une structure pour une station a nwave 
tmp = {name:'', origine:'', enr:'', val:'', lat:0.0D, lon:0.0D, nwav:0, filename:'', $
       code:INTARR(nwave), wave:STRARR(nwave), amp:FLTARR(nwave), pha:FLTARR(nwave)}

 ;on replicate cette structure autant de fois qu'il y a de stations                
str = replicate(tmp,nsta)

RETURN, str
END 