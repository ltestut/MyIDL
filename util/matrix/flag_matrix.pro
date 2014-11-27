FUNCTION flag_matrix,H,seuil=seuil, less=less, equal=equal, nfinite=nfinite, quick=quick, verbose=verbose
; flag a 2D or 3D (time) matrix, above, under or at a certain treshold
;   index = icol + (irow * ncol)
;   icol = [3,6,8]
;   irow = [2,3,7]

;       icol
; irow  0   1   2   3   4   5   6   7   8
;      -----------------------------------------
;   0 | -   -   -   -   -   -   -   -   - (8)  
;   1 | -   -   -   -   -   -   -   -   - (17)
;   2 | -   -   -   X   -   -   -   -   - (26)
;   3 | -   -   -   -   -   -   X   -   - (35)
;   4 | -   -   -   -   -   -   -   -   - (44)
;   5 | -   -   -   -   -   -   -   -   - (53)
;   6 | -   -   -   -   -   -   -   -   - (62)
;   7 | -   -   -   -   -   -   -   -   X (71)
;   8 | -   -   -   -   -   -   -   -   - (80)
;
;index = [21,33,71]

diminit = SIZE(H,/DIMENSIONS)
IF (N_ELEMENTS(diminit) EQ 3) THEN H = REFORM(H, diminit[0]*diminit[1], diminit[2], /OVERWRITE )
dim    = SIZE(H,/DIMENSIONS)

IF KEYWORD_SET(less) THEN BEGIN
   index = WHERE(H LE seuil ,nbr_tot)
ENDIF ELSE IF KEYWORD_SET(equal) THEN BEGIN
   index = WHERE(H EQ equal ,nbr_tot) 
ENDIF ELSE IF KEYWORD_SET(nfinite) THEN BEGIN
   index = WHERE(FINITE(H) EQ 0 ,nbr_tot) 
ENDIF ELSE BEGIN
   index = WHERE(H GE seuil ,nbr_tot)
ENDELSE
icol  = index MOD dim[0]
irow  = index/dim[0]
IF (nbr_tot GT 0) THEN H(icol,irow)=!VALUES.F_NAN
IF (N_ELEMENTS(diminit) EQ 3) THEN H = REFORM(H, diminit, /OVERWRITE )
RETURN, H

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,"Matrix Dimension         = ",diminit
 PRINT,"Flag value               = ",seuil
 PRINT,"Nbre flagged values      = ",nbr_tot
ENDIF

END