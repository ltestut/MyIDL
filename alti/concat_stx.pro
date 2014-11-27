FUNCTION concat_stx, stx1, stx2

id1     = WHERE(FINITE(stx1.pt.lat),cpt1)   ;nbr de val. fini de stx1 
id2     = WHERE(FINITE(stx2.pt.lat),cpt2)   ;nbr de val. fini de stx2
ntag_pt = N_TAGS(stx1.pt)                   ;nbr de tag des pts de la structure
id1_max = MAX(id1)+1
npt     = cpt1+cpt2                         ;nombre total de points de la nouvelle structure stx
ncy     = N_ELEMENTS(stx1.pt[0].jul)>N_ELEMENTS(stx2.pt[0].jul)
stx     = create_stx(npt,ncy)

 ;on remplit les tags commun
stx.name         = stx2.name
stx.info_cor     = stx2.info_cor
stx.info_rms     = stx2.info_rms
stx.info_trend   = stx2.info_trend

IF (cpt1 GE 1) THEN BEGIN  
 stx.filename = stx1.filename+'/'+stx2.filename 
 stx.trace    = stx1.trace+'/'+stx2.trace 
  FOR i=0,ntag_pt-5 DO stx.pt.(i) = [stx1.pt[id1].(i),     stx2.pt[id2].(i)]
   ;concatenation des dates, sla, tide et dac
   stx.pt[id1].jul   = stx1.pt[id1].jul   &  stx.pt[id2+id1_max].jul   = stx2.pt[id2].jul
   stx.pt[id1].sla   = stx1.pt[id1].sla   &  stx.pt[id2+id1_max].sla   = stx2.pt[id2].sla
   stx.pt[id1].tide  = stx1.pt[id1].tide  &  stx.pt[id2+id1_max].tide  = stx2.pt[id2].tide
   stx.pt[id1].dac   = stx1.pt[id1].dac   &  stx.pt[id2+id1_max].dac   = stx2.pt[id2].dac
ENDIF ELSE BEGIN
   stx = select_track(stx2,id2)
ENDELSE
RETURN, stx
END
