FUNCTION jultie, st, filename=filename, tozero=tozero
; ajoute des biais sur des periodes de temps definie dans le fichier
; ou renvoie un signal centre sur zero par troncon 
IF NOT KEYWORD_SET(filename) THEN print,"Need filename info"
data = read_tieinfo(filename)
Nd   = N_ELEMENTS(data.jmin)
stc  = create_julval(1,/NAN)

FOR i=0,Nd-1 DO BEGIN
   st_cut = julcut(st,dmin=data[i].jmin,dmax=data[i].jmax)
   IF KEYWORD_SET(tozero) THEN data[i].offset=-MEAN(st_cut.val,/NAN)
   st1    = op_julval(st_cut,add=data[i].offset)
   stc    = concat_julval(stc,st1)
ENDFOR
   stc = finite_st(stc)
RETURN, stc
END