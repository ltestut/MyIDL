PRO map_geomat_old, geo,  frame=frame, $
               range=range,$
               grid=grid, mark=mark, footprint=footprint, _EXTRA=_EXTRA
; Programme pour tracer les donnees d'une structure de type geomat 
; Si on vaut faire une animation il faut faire une carte en n&b avec loadct,0,NCOLOR=le nombre de niveau (ex:10)
; Si on veut une carte couleur classique il faut specifier pal=numero de palette

; map_geomat,
; on peut passer les mot-cle limit=[0,360,-50,-20] ou zone='spa'

 ;save the current plot state
bang_p    = !P
bang_x    = !X
bang_Y    = !Y
bang_Z    = !Z
bang_Map  = !Map
bang_nlev = !ncol_map 

  ;init des parametres de sortie de la carte (ps, png, windows)
open_output_format,/VERBOSE,_EXTRA=_EXTRA

 ; definition de limite geographiques de la zone de tracage
ulimit=geo_limit(geo,/VERBOSE,_EXTRA=_EXTRA)

 ; on coupe la matrice sur la zone de tracage
geoc  = geocut(geo,/VERBOSE,_EXTRA=_EXTRA)

 ;calcul de certains parametres de la matrice 
st    = SIZE(geo.val)                    ;taille de la matrice totale
zmin  = MIN(geo.val,/NAN,MAX=zmax)       ;min/max du champ total
IF (N_ELEMENTS(frame) EQ 0) THEN frame=0 ;si pas de frame alors frame =  le premier pas de temps
IF (N_TAGS(geoc) EQ 4) THEN BEGIN
 geop = TEMPORARY(geoc.val[*,*,frame]) ; Dans le cas d'une matrice Z(x,y,t) on choisit le pas de temps = a frame
 titre = STRCOMPRESS('Date :  '+print_date(geo.jul[frame],/SINGLE))
ENDIF ELSE BEGIN 
 geop = TEMPORARY(geoc.val[*,*])           
 titre = ''
ENDELSE
sp    = SIZE(geop)                   ;taille du champ affichee                                
zpmin = MIN(geop,/NAN,MAX=zpmax)     ;min/max du champ affiche
IF (N_ELEMENTS(range) EQ 0) THEN range = [zpmin,zpmax]   ; echelle zmin->zmax par defaut
step  = (range[1]-range[0])/FLOAT(!ncol_map) 
lev   = INDGEN(!ncol_map)*step + range[0]              ; calcul des niveaux
  
 ;tracage de la carte
POS = [0.1,0.1,0.9,0.8] ; position de la zone de tracage
ERASE                                                                        ; erase the windows
;tv,BYTSCL(geop)
MAP_SET,/MERCATOR, /GRID, /NOERASE, /ISOTROPIC,  LIMIT=ulimit, POSITION=POS

wimg = Map_Image(geop, xstart, ystart, xsize, ysize,$
        LatMin=MIN(geo.lat,/NAN), LatMax=MAX(geo.lat,/NAN), LonMin=MIN(geo.lon,/NAN), LonMax=MAX(geo.lon,/NAN),$
        /COMPRESS,/BILINEAR)

sw=SIZE(wimg)        
PRINT,'MATRICE   geo  : NX=',st[1],' Ny=',st[2],' zmin= ',zmin,'/zmax=',zmax
PRINT,'MATRICE   geop : NX=',sp[1],' Ny=',sp[2],' zmin= ',zpmin,'/zmax=',zpmax
PRINT,'MAP_IMAGE wimg : NX=',sw[1],' Ny=',sw[2],' zmin= ',MIN(wimg),'/zmax=',MAX(wimg)

;wimg = MAP_PATCH(geop,geo.lon,geo.lat, XSTART=xstart, YSTART=ystart, XSIZE=xsize, YSIZE=ysize,$
;        LAT0=MIN(geo.lat,/NAN), LAT1=MAX(geo.lat,/NAN), LON0=MIN(geo.lon,/NAN), LON1=MAX(geo.lon,/NAN),$
;        /TRIANGULATE,MISSING=FSC_Color('black'),MAX_VALUE=zmax)


;TVSCL, wimg, xstart, ystart, XSize=xsize, YSize=ysize,$
    TOP=!ncol_map-1

;TVIMAGE,wimg,xstart,ystart,XSize=xsize, YSize=ysize,/SCALE

CONTOUR,geop,geoc.lon,geoc.lat,/OVERPLOT,XSTYLE=1,YSTYLE=1,$
    LEVELS=lev,$
    C_COLORS=INDGEN(!ncol_map), $
    /CELL_FILL
;
; pour tracer des contours
; ----------------------
CONTOUR,geop,geoc.lon,geoc.lat,/OVERPLOT,$
        LEVELS=lev,COLOR=FSC_Color('grey')

;MAP_CONTINENTS, /COASTS, /OVERPLOT, /FILL_CONTINENTS, MLINETHICK=0.5,$
                COLOR=FSC_Color('grey')
;MAP_CONTINENTS, /COASTS, /OVERPLOT, /HIRES, COLOR=cgcolor("grey",253), ORIENTATION=45
  

;  MAP_SET,-90,0,0,/STEREO, /NOERASE, /NOBORDER,/ISOTROPIC, LIMIT=limit, POSITION=[0.1,0.1,0.9,0.8], /GRID,/LABEL
MAP_GRID,/BOX_AXES, LABEL=2
 ;palette de couleur
COLORBAR,RANGE=range, NCOLORS=!ncol_map, TITLE=titre, FORMAT='(F8.2)', _EXTRA=_EXTRA

IF KEYWORD_SET(grid) THEN BEGIN
   s     = SIZE(geop)
   ncol  = s[1]
   id    = WHERE(FINITE(geop))
   icol  = id MOD ncol
   irow  = id/ncol
   PLOTS,geo.lon[icol], geo.lat[irow], psym=1, $
   COLOR=cgcolor("gray",253), CLIP=POS, _EXTRA=_EXTRA
;   pour tracer les numero de col et ligne de la grille
;   --------------------------------------------------
;   XYOUTS,geo.lon[icol], geo.lat[irow], '('+STRCOMPRESS(icol,/REMOVE_ALL)+','+STRCOMPRESS(irow,/REMOVE_ALL)+')', CHARSIZE=0.5
ENDIF


IF KEYWORD_SET(mark) THEN BEGIN
IF NOT KEYWORD_SET(footprint) THEN footprint=0.3
tvcircle, footprint, mark[0], mark[1], /FILL, /DATA, COLOR=cgcolor('black',252)
ENDIF


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
