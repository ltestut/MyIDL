FUNCTION minmax_wave_mgr,mgr,wave=wave
; fontion qui renvoie les valeurs min et max d'amplitude pour une onde donnee

nsta    = N_ELEMENTS(mgr)
amp_tab = MAKE_ARRAY(nsta,/FLOAT,VALUE=!VALUES.F_NAN)
 FOR i=0,nsta-1 DO BEGIN
  iw=WHERE(mgr[i].wave EQ wave,cnt)
  IF (cnt EQ 1) THEN amp_tab[i]= mgr[i].amp[iw]  
 ENDFOR
 range=[MIN(amp_tab,/NAN),MAX(amp_tab,/NAN)]
IF FINITE(range[0,*]) THEN RETURN, range ELSE RETURN, 'Erreur : aucune onde de ce nom'
END