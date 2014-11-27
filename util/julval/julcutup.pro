FUNCTION julcutup, st, filename=filename
; tronconne une structure de type julval a partir d'un fichier contenant les dates deb/fin
IF NOT KEYWORD_SET(filename) THEN print,"Need filename info"
data = read_cutinfo(filename)
Nd   = N_ELEMENTS(data.jmin)
stc  = create_julval(1,/NAN)
FOR i=0,Nd-1 DO BEGIN
   st1 = julcut(st,dmin=data[i].jmin,dmax=data[i].jmax)
   stc = concat_julval(stc,st1)
ENDFOR
   stc = finite_st(stc)
RETURN, stc
END