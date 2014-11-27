PRO map_xtrack,stx,  limit=limit, proj=proj, scale=scale, symsize=simsize, $
                       title=title,$
                       ncolors=ncolors, range=range, fill_val=fill_val, $
                       bathy=bathy, mgr=mgr, $
                       quick=quick,num=num,$      
                       output=output, _EXTRA=_EXTRA
; programme pour tracer les donnees d'une structure de type xtrack du ctoh 
; issue de read_xtrack_ncdf

 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj)    THEN proj='mercator'
IF NOT KEYWORD_SET(symsize) THEN symsize=1.
IF NOT KEYWORD_SET(scale)   THEN scale=1.
IF NOT KEYWORD_SET(ncolors) THEN ncolors=8
IF NOT KEYWORD_SET(limit)   THEN limit = get_seg_lim(stx.pt) 
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

;gestion de la table de couleur
LOADCT, 13, NColors=ncolors, RGB_TABLE=rgb
rgb   = CONGRID(rgb, 256, 3)
symco = 'black' ;couleur par defaut des pts le long de la trace

 ;plot rapide en mode direct graphique 
IF KEYWORD_SET(quick) THEN BEGIN
 MAP_SET, /MERCATOR, /ISOTROPIC, /GRID, POSITION=[0.1,0.16,0.9,0.9], LIMIT=limit,_EXTRA=_EXTRA ;, /NOERASE
 MAP_CONTINENTS, /COASTS, /OVERPLOT, FILL_CONTINENTS=2, LIMIT=limit, COLOR=cgColor("Yellow", !D.Table_Size-4), ORIENTATION=45
 MAP_GRID,/BOX_AXES,LABEL=2
 PLOTS, stx.pt.lon, stx.pt.lat, PSYM=1, SYMSIZE=2, COLOR=cgColor("Yellow", !D.Table_Size-4)
IF KEYWORD_SET(num) THEN FOR i=0,N_ELEMENTS(stx.pt.lat)-1 DO XYOUTS, stx.pt[i].lon, stx.pt[i].lat, STRCOMPRESS(STRING(i),/REMOVE_ALL),/DATA
GOTO, JUMP
ENDIF

 ;creation de la fenetre graphique
xsize = 1800
ysize = 1400
w     = window(dimensions=[xsize,ysize])
w.refresh, /disable

IF KEYWORD_SET(bathy) THEN BEGIN
 zvalue=[5,10,20,50,100,150,500]
 b  = CONTOUR(bathy.val,bathy.lon,bathy.lat,GRID_UNITS='deg',/OVERPLOT,$
               C_VALUE=zvalue,C_LABEL_SHOW=1,$
               C_COLOR='red')
ENDIF

m  = MAP(proj,LIMIT=limit,FILL_COLOR='white',$  
         TRANSPARENCY=0,LABEL_SHOW=1,/BOX_AXES,$
         TITLE=title,/CURRENT)
g  = MAPGRID(GRID_LONGITUDE = 0.2,GRID_LATITUDE = 0.2, LINESTYLE='dash',COLOR='grey')
c  = MAPCONTINENTS(FILL_COLOR="antique white",TRANSPARENCY=0,_EXTRA=_EXTRA)

 ;ajout des positions de maregraphes
IF KEYWORD_SET(mgr) THEN BEGIN
 FOR i=0,N_ELEMENTS(mgr.lon)-1 DO BEGIN
  mgr_label = STRCOMPRESS(mgr[i].name,/REMOVE_ALL)
  IF KEYWORD_SET(wave) THEN BEGIN
  id   = WHERE(mgr[i].wave EQ wave,count)
   IF (count GE 1) THEN mgr_label = mgr[i].name+'('+wave+'='$
 +STRCOMPRESS(STRING(mgr[i].amp[id]*scale,FORMAT='(F5.1)'))+'/'$
 +STRCOMPRESS(STRING(mgr[i].pha[id],FORMAT='(F5.1)'))+')'
   irange=CEIL((mgr[i].amp[id]*scale - range[0])/(ABS(range[1]-range[0])/255.))
   symco=TRANSPOSE(rgb[irange,*])
  ENDIF  
smgr = SYMBOL(mgr[i].lon,mgr[i].lat,'circle',/DATA,$
      TARGET=m,$
      SYM_SIZE=0.8,SYM_THICK=1.0,SYM_COLOR='Black',$
      SYM_FILLED=1,SYM_FILL_COLOR='Red',$
      SYM_TRANSPARENCY=0,$
      LABEL_STRING=mgr_label,LABEL_FONT_SIZE=12.,LABEL_COLOR='black',$
      LABEL_POSITION='Right',LABEL_SHIFT=[1.,0],LABEL_FILL_BACKGROUND=0,LABEL_TRANSPARENCY=0,$
      /OVERPLOT)
ENDFOR
ENDIF


p   = PLOT(stx.pt.lon,stx.pt.lat,/DATA,$
            AXIS_STYLE=1,LINESTYLE=6,$
            SYMBOL='+',$
            SYM_SIZE=simsize,SYM_THICK=0.1,SYM_COLOR='Black',$
            SYM_FILLED=1,SYM_FILL_COLOR='Black',$
            SYM_TRANSPARENCY=0,$
            /OVERPLOT)


IF KEYWORD_SET(fill_val) THEN BEGIN
 i_fill = WHERE(TAG_NAMES(stx.pt) EQ STRUPCASE(fill_val),cpt_fill)
 IF ((cpt_fill) EQ 1) THEN val=stx.pt.(i_fill)
 IF NOT KEYWORD_SET(range) THEN range=[MIN(val,/NAN),MAX(val,/NAN)] 
 zrange   = CEIL((val - range[0])/(ABS(range[1]-range[0])/255.))
 levels   = range[0]+(range[1]-range[0])/(ncolors-1)*INDGEN(ncolors)
 symco    = TRANSPOSE(rgb[zrange,*])
 p.RGB_table   = rgb
 p.VERT_COLORS = symco
 
; cb        = Colorbar(Target=p,$
;                       /BORDER_ON, $
;                       POSITION=[0.1, 0.88, 0.9, 0.93],$
;                       TICKNAME=STRING(levels,FORMAT='(F6.1)'))

scaledData = BytScl(DIST(10,10), /NAN, TOP=(NColors-1), MIN=range[0], MAX=range[1])
fakeImage = Image(scaledData, RGB_Table=rgb, /Current, /Hide)
 ;cb = COLORBAR(TARGET=fakeImage)
cb = Colorbar(Target=fakeImage,$
 /BORDER_ON, $
      POSITION=[0.1, 0.88, 0.9, 0.93],$
      TICKNAME=STRING(levels,FORMAT='(F6.1)'))

 ;,$
;                       /BORDER_ON, $
;                       POSITION=[0.1, 0.88, 0.9, 0.93],$
;                       TICKNAME=STRING(levels,FORMAT='(F6.1)'))


ENDIF


;FOR i=0,N_ELEMENTS(stx.pt.lon)-1 DO BEGIN
; label = STRCOMPRESS(i,/REMOVE_ALL)
; print,label
; IF KEYWORD_SET(wave) THEN BEGIN
;  id   = WHERE(mgr[i].wave EQ wave,count)
;  IF (count GE 1) THEN mgr_label = mgr[i].name+'('+wave+'='$
;+STRCOMPRESS(STRING(mgr[i].amp[id]*scale,FORMAT='(F5.1)'))+'/'$
;+STRCOMPRESS(STRING(mgr[i].pha[id],FORMAT='(F5.1)'))+')'
;  irange=CEIL((mgr[i].amp[id]*scale - range[0])/(ABS(range[1]-range[0])/255.))
;  symco=TRANSPOSE(rgb[irange,*])
; ENDIF
;s   = SYMBOL(stx.pt[i].lon,stx.pt[i].lat,'circle',/DATA,$
;      TARGET=m,$
;      SYM_SIZE=1.0,SYM_THICK=1.0,SYM_COLOR='red',$
;      SYM_FILLED=1,SYM_FILL_COLOR=symco[i],$
;      SYM_TRANSPARENCY=0.5,$
;      LABEL_STRING=label,LABEL_FONT_SIZE=10.,LABEL_COLOR='red',$
;      LABEL_POSITION='Left',LABEL_FILL_BACKGROUND=0,LABEL_TRANSPARENCY=10,$
;      /OVERPLOT)
;ENDFOR


;t = TEXT(stx.pt.lon,stx.pt.lat,STRCOMPRESS(INDGEN(N_ELEMENTS(stx.pt.lon)),/REMOVE_ALL),$
;         TARGET=p,/DATA, ALIGNMENT=0.2,ORIENTATION=0., $
;         FONT_SIZE=10,COLOR='black',/OVERPLOT)



;m.save,'mgr.kml'
m.order, /SEND_TO_BACK
g.Order, /SEND_TO_BACK
;c.Order, /BRING_TO_FRONT
p.Order, /BRING_TO_FRONT
c.order, /SEND_BACKWARD
w.refresh
IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=300
ENDIF
JUMP: PRINT,'Quick'
END