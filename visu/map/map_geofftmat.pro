PRO map_geofftmat, Z, X, Y, T, frame=frame, ps=ps, _EXTRA=_extra, nlev=nlev, range=range, pal=pal, limit=limit
; Programme pour tracer des donnees d'une matrice Z[lon,lat]
; X=lon,Y=lat,T=prd
; Si on vaut faire une animation il faut faire une carte en n&b avec loadct,0,NCOLOR=le nombre de niveau (ex:10)
; Si on veut une carte couleur classique il faut specifier pal=numero de palette

; Decomposed color off if device supports it.
; ------------------------------------------
CASE  StrUpCase(!D.NAME) OF
    'X': BEGIN
        Device, Get_Decomposed=thisDecomposed
        Device, Decomposed=0
    ENDCASE
    'WIN': BEGIN
        Device, Get_Decomposed=thisDecomposed
        Device, Decomposed=0
    ENDCASE
    ELSE:
ENDCASE


; Calcul des dimensions de la matrice
; ----------------------------------
  s=SIZE(Z) & zmin=MIN(Z,/NAN,MAX=zmax)
  print,"Valeurs MIN et MAX =",zmin,zmax
  FOR i=0,S[0]-1 DO print,"Taille de la dimension",i+1," = ",s[i+1]
  IF (N_ELEMENTS(frame) EQ 0) THEN frame=0 ; Si pas de frame alors frame =  le premier pas de temps
  IF (S[0] EQ 3) THEN Zplot=TEMPORARY(Z[*,*,frame]) ELSE Zplot=TEMPORARY(Z[*,*]) ; Dans le cas d'une matrice Z(x,y,t) on choisit le pas de temps = a frame

  ERASE                                                ; Erase the windows
  IF (N_ELEMENTS(nlev) EQ 0)  THEN nlev=10             ; Dix niveau de couleurs par defaut
  IF (N_ELEMENTS(range) EQ 0) THEN range = [zmin,zmax] ; Echelle zmin->zmax par defaut
  step  = (range[1]-range[0])/FLOAT(nlev) & lev = INDGEN(nlev)*step + range[0] ; Calcul des niveaux

  IF (N_ELEMENTS(pal) EQ 1)  THEN LOADCT,pal, NCOL=nlev
  axiscolor = fsc_color("white",255)
  backcolor = 0                 ;fsc_color("black",0)
  IF (S[0] EQ 3) THEN titre=STRCOMPRESS('Periode : '+T[frame]+' H') ELSE titre=STRCOMPRESS('min')


IF KEYWORD_SET(ps) THEN BEGIN
SET_PLOT,'PS'
CD,cur=root
plotfile=  root+'/idl.ps'
DEVICE, /PORTRAIT, /COLOR, filename=plotfile, $
        FONT_SIZE=10, XSIZE=15., YSIZE=15.
ENDIF

 IF (N_ELEMENTS(limit) EQ 0) THEN BEGIN
 limit=[min(Y),min(X),max(Y),max(X)]
 ENDIF ELSE BEGIN
 CASE limit OF
 'ker': limit=[-65,35,-30,100]
 ENDCASE
 ENDELSE

; Carte global mercator
; ---------------------
MAP_SET,/MERCATOR, /GRID, /NOERASE, /ISOTROPIC, LIMIT=limit, $
  POSITION=[0.1,0.1,0.9,0.8], $
  COLOR=axiscolor

  CONTOUR,Zplot,X,Y,/OVERPLOT,$
    ;MIN_VALUE=range[0], MAX_VALUE=range[1],$
    LEVELS=lev,$
    C_COLORS=INDGEN(nlev), $
    /CELL_FILL

;  CONTOUR,Zplot,X,Y,/OVERPLOT,LEVELS=lev


  MAP_CONTINENTS, /COASTS, /OVERPLOT, /HIRES, MLINETHICK=0.5

;  MAP_SET,-90,0,0,/STEREO, /NOERASE, /NOBORDER,/ISOTROPIC, LIMIT=limit, POSITION=[0.1,0.1,0.9,0.8], /GRID,/LABEL
 MAP_GRID,/BOX_AXES, LABEL=2
;MAP_SET,/MERCATOR, /GRID, /LABEL, /NOERASE, /ISOTROPIC, LIMIT=[-70,35,-30,100], $
;  POSITION=[0.1,0.1,0.9,0.8],TITLE = titre ,$
;  COLOR=axiscolor


  COLORBAR,RANGE=range, NCOLORS=nlev, Divisions=ncol, TITLE=titre, _EXTRA=_EXTRA

; Restore Decomposed state if necessary.
;;CASE StrUpCase(!D.NAME) OF
;;    'X': BEGIN
;;        Device, Decomposed=thisDecomposed
;;    ENDCASE
;;    'WIN': BEGIN
;;        Device, Decomposed=thisDecomposed
;;    ENDCASE
;;    ELSE:
;;ENDCASE

IF KEYWORD_SET(ps) THEN BEGIN
DEVICE,/CLOSE_FILE
SET_PLOT,'X'
print,"PLOT DANS ===> ",plotfile
ENDIF


END
