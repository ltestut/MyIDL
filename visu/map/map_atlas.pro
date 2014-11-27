PRO map_atlas, geo, limit=limit,  $
                      scale=scale,  $
                      val_range=val_range,val_step=val_step,val_format=val_format,frame=frame,$
                      iso=iso,nocoast=nocoast,no_header=no_header,scan=scan,$
                      ncolors=ncolors,col=col,$
                      proj=proj,$
                      mgr=mgr, track=track, bathy=bathy,  output=output, resolution=resolution, $
                      format=format,buffer=buffer, _EXTRA=_EXTRA
;#######################################################################
;#################### DOCUMENTATION PART : USAGE      ##################
;#######################################################################
; map a atlas 
; VAL_RANGE=1          : choose the val range to be plotted 
; VAL_STEP=1           : choose the val step 
; VAL_FORMAT='(F5.2)'  : choose the val format for isoline 

;/ISO                  : does not plot the main field, only its isoline
;/NOCOAST              : does not display the coastline
;/HIRES                : display the HR coastline
;scan=scan_file        : display the polyline of a file .scan
; FORMAT='(F7.2)'      : give label format (by default '(F6.1)')
; /BUFFER              : send the output to the buffer (to be used for automatic processing)
; ncolor               : choose the number of color of the palette
; col=41               : select the palette number
; resolution=300       : input resolution of output 

;#######################################################################
;#################### CONFIGURATION PART : GRAPHIC PARAMETER ###########
;#######################################################################
 ;title, legend and presentation(transpose(rgb))[*,256]
gen_font     = 14                ;general font_size
red_font     = 10                ;reduced font_size
symsize      = 0.4               ;symbol size
symref       = "-o"              ;solid+circle
txtcolor     = 'dark blue'
 ;map configuration 
map_gridlat  =  1.               ;grid delta latitude 
map_gridlon  =  1.               ;grid delta longitude
 ;isoline configuration 
lshow        = 0                 ;no label default
iso_color    = 'red'           ;isoline color
iso_thick    = 0.1               ;isoline thickness
iso_font     = 6                 ;isoline label font size
col_format   = '(F4.1)'          ;colorbar tickformat
IF KEYWORD_SET(iso) THEN map_hide=1 ELSE map_hide=0
IF KEYWORD_SET(iso) THEN iso_color='black'
IF KEYWORD_SET(iso) THEN lshow=1

 ;color choice
color_ref    = 'Dark Grey'      ;color for the ref circle
color_1      = 'Black'          ;color for the second mgr
color_2      = 'Light Grey'     ;color for the barrplot
color_3      = 'white'          ;color for the track location
color        = [color_ref,color_1,color_2,color_3]

;#######################################################################
;############  COMPUTATION PART : DEFINE&COMPUTE GRAPHIC VARIABLE ######
;#######################################################################
IF NOT KEYWORD_SET(proj)          THEN proj='EQUIRECTANGULAR'
IF NOT KEYWORD_SET(scale)         THEN scale=1.
IF NOT KEYWORD_SET(frame)         THEN frame=1
IF NOT KEYWORD_SET(ncolors)       THEN ncolors=10
IF NOT KEYWORD_SET(aspect_ratio) THEN aspect_ratio=1
IF NOT KEYWORD_SET(val_format)    THEN val_format='(F5.1)'
IF NOT KEYWORD_SET(col) THEN col=0
IF NOT KEYWORD_SET(resolution) THEN resolution=150

 ;limit of the atlas
IF NOT (KEYWORD_SET(limit) OR KEYWORD_SET(zone)) THEN BEGIN
  minlon=MIN(geo.lon, /NAN, MAX=maxlon)
  minlat=MIN(geo.lat, /NAN, MAX=maxlat)  
  limit=[minlon,maxlon,minlat,maxlat]
ENDIF
geo = geocut(geo, limit=limit)
limit=[limit[2],limit[0],limit[3],limit[1]] ;latmin/lonmin/latmax/lonmax
  
 ;recuperation des variables a tracer et calcul du zrange et des niveaux
lon = geo.lon
lat = geo.lat
s   = SIZE(geo.val)
IF (s[0] EQ 3) THEN field=geo.val[*,*,frame] ELSE field=geo.val[*,*] 
full_range = [MIN(field,/NAN),MAX(field,/NAN)]
PRINT,"Field range =",full_range
IF NOT KEYWORD_SET(val_range) THEN val_range=full_range
IF KEYWORD_SET(val_step) THEN na_step = (val_range[1]-val_range[0])/val_step ELSE na_step = ncolors
IF KEYWORD_SET(pha_step) THEN np_step = (pha_range[1]-pha_range[0])/pha_step ELSE np_step = ncolors
val_levels    = val_range[0]+(val_range[1]-val_range[0])/(na_step)*INDGEN(na_step)
isofield           =  field        ; principal field to map
isorange           =  val_range    ; principal field range
isolevels          =  val_levels   ; principal field levels


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;creation de la fenetre graphique
xsize = 1200
ysize = 1000
IF KEYWORD_SET(buffer) THEN w=window(dimensions=[xsize,ysize],/BUFFER) $
                       ELSE w=window(dimensions=[xsize,ysize])
 ;define graphic position and draw legends
p_pos     = [0.1,0.2,0.9,0.9] ;vallitude map position
leg_pos   = [0.5,0.90]          ;legende position
IF NOT KEYWORD_SET(no_header) THEN t_head1=TEXT(leg_pos[0],leg_pos[1],$
         'MODEL = ', TARGET=w,COLOR=txtcolor,FONT_SIZE=gen_font,ALIGNMENT=0.5)
 ;load color table
LOADCT, col, ncolors=na_step, RGB_TABLE=rgb
rgb      = CONGRID(rgb, 256, 3)
;rgb[0,*] = 255 ;redefined the NaN color
rgb=REVERSE(rgb)

;---------------------------------------------------------------------------------
;-----------   VAL  FIELD         ------------------------------------------------
;---------------------------------------------------------------------------------
map_field = IMAGE(BYTSCL(isofield,MIN=isorange[0],MAX=isorange[1],/NAN),$
                  GRID_UNITS='degrees',ASPECT_RATIO=aspect_ratio,/CURRENT,$
                  POSITION=p_pos,AXIS_STYLE=0,$
                  RGB_TABLE=COLORTABLE(0,/REVERSE),HIDE=map_hide)
;map_isofield=CONTOUR(isofield,GRID_UNITS='degrees',/OVERPLOT,$
;                            C_VALUE=isolevels,C_LABEL_SHOW=lshow,FONT_SIZE=iso_font,LABEL_FORMAT=iso_fmta,C_COLOR=iso_color,$
;                            C_THICK=iso_thick)
;0:normal/1:bold/2:italic/3:bold&italic
m1=MAP(proj,LIMIT=limit,POSITION=p_pos,/BOX_AXES,ASPECT_RATIO=aspect_ratio,$
            LABEL_POSITION=1,BOX_COLOR='gray',COLOR='gray',BOX_THICK=1,$ 
            LINESTYLE=2,THICK=0.5,FONT_STYLE=0,FONT_SIZE=red_font,/CURRENT) 
; #################keyword layers
IF NOT KEYWORD_SET(nocoast) THEN c1=MAPCONTINENTS(LIMIT=limit,/CONTINENTS,$
      /COUNTRIES,FILL_COLOR='Antique white',THICK=0.,LINESTYLE=0,_EXTRA=_EXTRA)
IF KEYWORD_SET(mgr)         THEN s=update_symbol_layer(SYMBOL(mgr.lon,mgr.lat,$
                         'o',LABEL_STRING=mgr.name,/DATA,/OVERPLOT),NAME='dot')  
IF KEYWORD_SET(scan)        THEN p=POLYLINE(scan.lon,scan.lat,$
                            CONNECTIVITY=scan.con,TARGET=m1,COLOR='red',/DATA,$
                                                 THICK=2,LINESTYLE=0,/OVERPLOT)
IF NOT KEYWORD_SET(iso)     THEN cb=COLORBAR(TARGET=map_field, /BORDER_ON,$
                                       TITLE='M2 Tidal Misfits (cm)',TAPER=2,$
                                       TICKNAME=STRING(isolevels,FORMAT=col_format),$
                                       TEXTPOS=0,FONT_SIZE=gen_font, $
                                       POSITION=[p_pos[0],0.1+p_pos[1]-0.03,$
                                       p_pos[2],0.1+p_pos[1]-0.01])
                                       
p=POLYGON([70.,76,76.,70.],[25.,25.,8.,8.],/DATA,TARGET=m1,FILL_BACKGROUND=0)                                       
  ;place la legende et un sous-titre
range_text = "Map Range  : val ["+STRING(FORMAT=val_format,full_range[0])+$
   ' <-> '+STRING(FORMAT=val_format,full_range[1])+$
             "]"
IF NOT KEYWORD_SET(no_header) THEN subtitle1  = text(0.01, 0.02, range_text, /normal, font_size=red_font)
;IF (s[0] EQ 3) THEN time_stamp = TEXT(0.50, 0.02, print_date(geo.jul[frame],/SINGLE), /normal, font_size=red_font)

w.refresh
   
IF KEYWORD_SET(output) THEN BEGIN
 w.Save, output, RESOLUTION=resolution
 print,output
ENDIF  
END