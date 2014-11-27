FUNCTION where_matrix,H,val=val, no=no, nan=nan, replace=replace
; permet de trouver et de remplacer une valeur dans une matrice 2d
s     = SIZE(H)
ncol  = s[1]
H1    = H
IF KEYWORD_SET(nan) THEN BEGIN
   index = WHERE(FINITE(H1),COMPLEMENT=inot,nbr_tot)
   ENDIF ELSE BEGIN
   index = WHERE(H1 EQ val,COMPLEMENT=inot,nbr_tot)
ENDELSE
print,nbr_tot,N_ELEMENTS(inot)
   
IF KEYWORD_SET(no) THEN BEGIN
   icol  = inot MOD ncol
   irow  = inot/ncol
   ;H1(icol,irow)=H1(icol,irow)+JULDAY(1,1,1950,0,0,0)
   ENDIF ELSE BEGIN
   icol  = index MOD ncol
   irow  = index/ncol
   H1(icol,irow)=H1(icol,irow)+JULDAY(1,1,1950,0,0,0)
ENDELSE

IF KEYWORD_SET(replace) THEN H=H1
RETURN,H1
END