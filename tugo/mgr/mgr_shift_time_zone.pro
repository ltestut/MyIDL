FUNCTION mgr_shift_time_zone, mgr_in, ut=ut, waves=waves
;modify the phase of an mgr

 ;parametres de la structure d'entree
nsta      = N_ELEMENTS(mgr_in)
mgr       = mgr_in

FOR i=0,nsta-1 DO BEGIN
 IF KEYWORD_SET(waves) THEN wlist=waves ELSE wlist = mgr[i].wave[WHERE(mgr[i].wave NE '')]
 FOR j=0,N_ELEMENTS(wlist)-1 DO BEGIN
  idw = WHERE(mgr[i].wave EQ wlist[j],cpt)                                                   
  mgr[i].pha[idw] = greenwich_phase(mgr_in[i].pha[idw],WAVES=wlist[j],ut=ut)
 ENDFOR
ENDFOR

RETURN, mgr
END