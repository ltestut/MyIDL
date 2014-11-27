FUNCTION select_track, stx, id, replace=replace
; extrait une certain nombre de point de la trace

ntag_info  = N_TAGS(stx)
ntag_pt    = N_TAGS(stx.pt)
s          = SIZE(stx.pt.sla)
ncyc       = s[1]
stx2       = create_stx(N_ELEMENTS(id),ncyc)
FOR i=0,ntag_info-2 DO stx2.(i)=stx.(i)
FOR i=0,ntag_pt-1 DO stx2.pt.(i)=stx.pt[id].(i)
IF KEYWORD_SET(replace) THEN stx=stx2
RETURN, stx2 
END