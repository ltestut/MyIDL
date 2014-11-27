PRO map_matrix, Z, range=range, cont=cont, _EXTRA=_EXTRA
 ;save the current plot state
bang_p    = !P
bang_x    = !X
bang_Y    = !Y
bang_Z    = !Z
bang_Map  = !Map
bang_nlev = !ncol_map 

  ;init des parametres de sortie de la carte (ps, png, windows)
open_output_format,/VERBOSE,_EXTRA=_EXTRA

 ;return the dimension of the matrix to plot
s=SIZE(Z) & zmin=MIN(Z,/NAN,MAX=zmax)
FOR i=0,S[0]-1 DO print,"Taille de la dimension",i+1," = ",s[i+1]
print,"Valeurs ZMIN/ZMAX =",zmin,zmax

 ;set the defaults value for color
IF (N_ELEMENTS(range) EQ 0) THEN range = [zmin,zmax]   ; Echelle zmin->zmax par defaut
step  = (range[1]-range[0])/FLOAT(!ncol_map) & lev = INDGEN(!ncol_map)*step + range[0] ; Calcul des niveaux

print,!P.BACKGROUND
print,!P.COLOR

;/!\ Il y a un probleme avec le TVSCALE de D. Fanning qui force le decompose=1 dans la routine
;avec un test sur le type de background qui est de type 'LONG' ce qui entraine un decomposed=1
;je ne comprend pas pourquoi. Ce test est actif dans la boucle if /ERASE


TVSCALE, BYTSCL(Z,/NAN),/AXES,$
         /KEEP_ASPECT_RATIO,$
         POSITION=thispos,MARGIN=0.1,$
         BACKGROUND=!P.BACKGROUND,ACOLOR=!P.COLOR,$
          NCOLORS=!ncol_map


;TVIMAGE, BYTSCL(Z,/NAN),/ERASE,/AXES,/KEEP_ASPECT_RATIO,$
;         POSITION=thispos,MARGIN=0.1,$
;         BACKGROUND=!P.BACKGROUND,ACOLOR=!P.COLOR
;         TOP=!ncol_map-1
;xstart, ystart, XSize=xsize, YSize=ysize,$



;CONTOUR,Z, LEVELS=lev, C_COLORS=INDGEN(!ncol_map), $
;           POSITION=[0.1,0.1,0.9,0.8], XSTYLE=1, YSTYLE=1,/CELL_FILL

IF KEYWORD_SET(cont) THEN BEGIN
  CONTOUR,Z,/OVERPLOT, NLEVELS=!ncol_map,XSTYLE=1,YSTYLE=1,$
          POSITION=thispos
ENDIF          

;COLORBAR, RANGE=range, NCOLORS=!ncol_map,DIVISIONS=10,$
;          FORMAT='(F8.2)',_EXTRA=_EXTRA

close_output_format,/verb,_EXTRA=_EXTRA

; Restore the previous plot and map system variables
; --------------------------------------------------
!P        = bang_p
!X        = bang_x
!Y        = bang_y
!Z        = bang_z
!Map      = bang_map
!ncol_map = bang_nlev
END
