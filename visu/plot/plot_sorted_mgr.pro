PRO plot_sorted_mgr, mgr_in, mgr2_in, units=units, scale=scale,  $
                                  wave=wave,$
                                  amp_range=amp_range,pha_range=pha_range,pha_treshold=pha_treshold,$
                                  tatlas=tatlas,limit=limit,$
                                  resolution=resolution,buffer=buffer,no_header=no_header,output=output
; program to plot a the amplitude of phase of an along track mgr
; mgr2_in           : to overplot an other mgr structure


 ;title, legend and presentation(transpose(rgb))[*,256]
gen_font     = 12                ;general font_size
red_font     =  8                ;reduced font_size
symsize      = 2.0               ;map symbol size
symco        = 'red'             ;map symbol color
dlon         = 0.                ;map grid delta lon                
dlat         = 0.                ;map grid delta lat                
fmt_adiff    = '(F5.1)'
fmt_pdiff    = '(F5.1)'
 ;color choice
ncolors      = 10               ;number of color of the atlas thumbnail               
color_ref    = 'Dark Grey'          ;color for the ref circle
color_1      = 'Black'          ;color for the second mgr
color_2      = 'Light Grey'     ;color for the barrplot
color_3      = 'red'          ;color for the tg location
color        = [color_ref,color_1,color_2,color_3]
 ;barrplot
nbar       = 1                  ;default
b_da_range = [-10.,10.]         ;anomaly amplitude range
b_da_inter = 10                 ;anomaly amplitude interval
b_dp_range = [-10.,10.]         ;anomaly phase range
b_dp_inter = 10                 ;anomaly phase interval

b_dp_range = [-15.,15.]

  
IF NOT KEYWORD_SET(scale)      THEN scale       = 1.            ;defaut scale
IF NOT KEYWORD_SET(units)      THEN units       = 'cm'          ;defaut units
IF NOT KEYWORD_SET(wave)       THEN wave        = 'M2'          ;defaut wave
IF NOT KEYWORD_SET(resolution) THEN resolution  = 150           ;defaut image resolution

mgr     =  where_mgr(mgr_in,wave=wave)
nsta    = N_ELEMENTS(mgr.name)
mgr.amp = mgr.amp*scale
text1   = mgr[0].origine
IF KEYWORD_SET(pha_treshold) THEN BEGIN
 isup = WHERE(mgr.pha LT pha_treshold,csup)
 IF (csup GE 1) THEN mgr[isup].pha = 360.+mgr[isup].pha
ENDIF
yr_amp  = [MIN(mgr.amp,/NAN),MAX(mgr.amp,/NAN)]
yr_pha  = [MIN(mgr.pha,/NAN),MAX(mgr.pha,/NAN)]
tamp    = 'Min-Max = '+STRING(FORMAT='(F6.2)',yr_amp[0])+' - '+STRING(FORMAT='(F6.2)',yr_amp[1])
tpha    = 'Min-Max = '+STRING(FORMAT='(F6.2)',yr_pha[0])+' - '+STRING(FORMAT='(F6.2)',yr_pha[1])
IF N_PARAMS() EQ 2 THEN BEGIN
 nbar     = 2
 mgr2     =  where_mgr(mgr2_in,wave=wave)
 mgr2.amp = mgr2.amp*scale
 text2    = mgr2[0].origine
 IF KEYWORD_SET(pha_treshold) THEN BEGIN
  isup2 = WHERE(mgr2.pha LT pha_treshold,csup2)
  IF (csup2 GE 1) THEN mgr2[isup2].pha = 360.+mgr2[isup2].pha
 ENDIF
 tmis     = compare_mgr(mgr2,mgr,/NO_REDUCE)
 yr_amp  = [MIN(mgr.amp,/NAN)<MIN(mgr2.amp,/NAN),MAX(mgr.amp,/NAN)>MAX(mgr.amp,/NAN)]
 yr_pha  = [MIN(mgr.pha,/NAN)<MIN(mgr2.pha,/NAN),MAX(mgr.pha,/NAN)>MAX(mgr.pha,/NAN)]
ENDIF

IF KEYWORD_SET(amp_range) THEN yr_amp=amp_range 
IF KEYWORD_SET(pha_range) THEN yr_pha=pha_range 


;#######################################################################
;#################### TATLAS  : CONFIGURATION     ######################
;#######################################################################
IF KEYWORD_SET(tatlas) THEN BEGIN
 LOADCT, 13, ncolors=ncolors, RGB_TABLE=rgb
 rgb      = CONGRID(rgb, 256, 3)
 rgb[0,*] = 255 ;redefined the NaN color   
 lon0     = tatlas.lon                   & lat0    =  tatlas.lat                 ;get original lon,lat
 IF KEYWORD_SET(limit) THEN atlas = tatlas_cut(tatlas,limit=limit)ELSE atlas = tatlas
 glimit   = get_geo_lim(atlas)           & limit   = change2idllimit(glimit)     ;compute limit
 lon      = atlas.lon                    & lat     =  atlas.lat                  ;get lon,lat
 dim_lon  = MAX(lon,/NAN)-MIN(lon,/NAN)  & dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)  ;get image dimension
 dim      = [dim_lon,dim_lat]            & loc     = [MIN(lon,/NAN),MIN(lat)]     ;localisation de l'image
 idw      = WHERE(atlas.wave.name EQ wave, cpt) & IF (cpt LT 1) THEN STOP,'No '+wave+' wave in this taltas'
 amp = atlas.wave[idw].amp*scale         & pha = atlas.wave[idw].pha              ;get amp & pha array
ENDIF

;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  =  1000
ysize  =   600
IF KEYWORD_SET(buffer) THEN w = window(dimensions=[xsize,ysize],/BUFFER) ELSE w = window(dimensions=[xsize,ysize])
;w      = window(dimensions=[xsize,ysize])

;w.refresh, /disable
leg_pos  = [0.3,0.95]
i        = 0
p_pos    = [0.1,0.1,0.84,0.40,0.40]
IF N_PARAMS() EQ 2 THEN p_pos = [0.1,0.1,0.84,0.30,0.40]
ohisto   = 0.02  ;offset for diff histo
hhisto   = 0.1   ;height for diff histo
xohaxis  = 0.03  ;X offset for label diff histo axis
yohaxis  = ohisto+hhisto/2.   ;Y offset for label diff histo axis
sublabel = 5
nlabel   = N_ELEMENTS(mgr.lat)
xlabel   = INDGEN(nlabel)*sublabel
index    = WHERE(xlabel LE nlabel) 

;#######################################################################
;#################### HEADER PART       ################################
;#######################################################################
IF NOT KEYWORD_SET(no_header) THEN BEGIN
 t_head  = TEXT(leg_pos[0],leg_pos[1],['Tide Gauges Stations ('+STRCOMPRESS(nsta)+') /  WAVE = '+STRING(wave)], TARGET=w,COLOR='black',FONT_SIZE=gen_font,ALIGNMENT=0.0)                
 t_leg1  = TEXT(leg_pos[0],leg_pos[1]-0.03,'Origine = '+text1,TARGET=w,FONT_SIZE=gen_font,COLOR=color[0],ALIGNMENT=0.0)               
 IF N_PARAMS() EQ 2 THEN t_leg2  = TEXT(leg_pos[0],leg_pos[1]-0.06,'Origine = '+text2, TARGET=w,FONT_SIZE=gen_font,COLOR=color[1],ALIGNMENT=0.0)
ENDIF

;#######################################################################
;#################### AMPLITUDE PLOT :  ################################
;#######################################################################
 p_amp   = BARPLOT(mgr.amp,NBARS=nbar,INDEX=0,/CURRENT,AXIS_STYLE=0,FILL_COLOR=color_ref,COLOR=color_ref,$
                   YRANGE=yr_amp,$
                   POSITION=[p_pos[0],p_pos[1],p_pos[2],p_pos[3]])
 yax_amp = AXIS('Y', TARGET=p_amp,LOCATION=[-1,0],TITLE='Amplitude (cm)',AXIS_RANGE=yr_amp,MINOR=0)
 
 t_sta   = TEXT(INDGEN(nsta),MAKE_ARRAY(nsta,VALUE=yr_amp[0],/FLOAT),mgr.name,TARGET=p_amp,/DATA,$
               COLOR='black',FONT_SIZE=red_font,ORIENTATION=90.,ALIGNMENT=-0.1)                
 t_mina  = TEXT(p_pos[0],p_pos[1]-0.06,tamp,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.)
               
IF N_PARAMS() EQ 2 THEN BEGIN
   p2_amp  = BARPLOT(mgr2.amp,NBARS=nbar,INDEX=1,/OVERPLOT,AXIS_STYLE=0,FILL_COLOR=color_1,COLOR=color_1)
   yax_amp = AXIS('Y', TARGET=p_amp,LOCATION=[-1,0],TITLE='Amplitude (cm)',AXIS_RANGE=yr_amp,MINOR=0,TICKLEN=0.02)
   xax_amp = AXIS('X', TARGET=p_amp,LOCATION=[0,yr_amp[0]],TITLE='',AXIS_RANGE=[1,nsta],COORD_TRANSFORM=[1,1],$
                     TICKINTERVAL=1, MINOR=0, TICKFONT_SIZE=8)
   p2_da   = BARPLOT(tmis.sta.wave.da,/CURRENT,AXIS_STYLE=0,YRANGE=b_da_range,$    
                     COLOR=color_2,FILL_COLOR=color_2,$               
                     POSITION=[p_pos[0],p_pos[3]+ohisto,p_pos[2],p_pos[3]+hhisto+ohisto])
   yax_da  = AXIS('Y', TARGET=p2_da,LOCATION=[-1,0],TICKINTERVAL=b_da_inter,TITLE='$\Delta A (cm)$',MINOR=0,TICKLEN=0.02,TICKFONT_SIZE=red_font)
   da_mean = STRCOMPRESS('$\Delta A=$'+STRING(MEAN(tmis.sta.wave.da,/NAN),FORMAT=fmt_adiff))
   t_da    = TEXT(p_pos[2]+xohaxis,p_pos[3]+yohaxis,da_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)                
   t_nda   = TEXT(INDGEN(nsta),INDGEN(nsta)*0.,STRCOMPRESS(STRING(tmis.sta.wave.da,FORMAT=fmt_adiff)),/DATA,$
                  TARGET=p2_da,FONT_SIZE=red_font,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.5,ORIENTATION=90.)                
   IF KEYWORD_SET(tatlas) THEN BEGIN
      amp_field   = IMAGE(BYTSCL(amp,MIN=yr_amp[0],MAX=yr_amp[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                      GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,AXIS_STYLE=0,$         
                      POSITION=[p_pos[2],p_pos[1],0.99,p_pos[3]],$
                      RGB_TABLE=rgb,/CURRENT)
      track       =  SYMBOL(tmis.sta.lon,tmis.sta.lat,'+',/DATA,TARGET=amp_field,SYM_SIZE=symsize,SYM_COLOR=color_3,/OVERPLOT)
   ENDIF ELSE BEGIN
     prgr_amp     = PLOT(mgr.amp,mgr2.amp,'+',/CURRENT,AXIS_STYLE=0,COLOR=color_1,SYM_SIZE=symsize,SYM_THICK=2.,XRANGE=yr_amp,YRANGE=yr_amp,$
                         POSITION=[p_pos[2]+0.02,p_pos[1],0.96,p_pos[3]])
     prx_amp      = AXIS('X', TARGET=prgr_amp,LOCATION=[0,yr_amp[0]] ,TITLE='Amplitude vs Amplitude (cm)',TICKFONT_SIZE=red_font,AXIS_RANGE=yr_amp,MINOR=0,TICKLEN=0.02)
     pry_amp      = AXIS('Y', TARGET=prgr_amp,LOCATION=[yr_amp[0],0] ,TITLE='',TICKFONT_SIZE=red_font,AXIS_RANGE=yr_amp,MINOR=0,TICKLEN=0.02,TEXTPOS=0)
     poly_amp     = POLYGON([yr_amp[0],yr_amp[1],yr_amp[1],yr_amp[0]],[yr_amp[0],yr_amp[1],yr_amp[0],yr_amp[0]],$
                    /DATA,TARGET=prgr_amp,FILL_BACKGROUND=0) 
                         
   ENDELSE
ENDIF
;#######################################################################
;#################### PHASE PLOT :      ################################
;#######################################################################
 p_pha   = BARPLOT(mgr.pha,NBARS=nbar,INDEX=0,/CURRENT,AXIS_STYLE=2,FILL_COLOR=color_ref,COLOR=color_ref,$
                  YRANGE=yr_pha,$
                  POSITION=[p_pos[0],p_pos[1]+p_pos[4],p_pos[2],p_pos[3]+p_pos[4]])
 yax_pha = AXIS('Y', TARGET=p_pha,LOCATION=[-1,0],TITLE='Phase (deg)',AXIS_RANGE=yr_pha)
 t_minp  = TEXT(p_pos[0],p_pos[1]+p_pos[4]-0.06,tpha,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.)

IF N_PARAMS() EQ 2 THEN BEGIN
   p2_pha  = BARPLOT(mgr2.pha,NBARS=nbar,INDEX=1,/OVERPLOT,AXIS_STYLE=0,FILL_COLOR=color_1,COLOR=color_1)
   yax_pha = AXIS('Y', TARGET=p_pha,LOCATION=[-1,0],TITLE='Phase (deg)',AXIS_RANGE=yr_pha,MINOR=0)
   xax_pha = AXIS('X', TARGET=p_pha,LOCATION=[0,yr_pha[0]],TITLE='',AXIS_RANGE=[1,nsta],COORD_TRANSFORM=[1,1],$
                     TICKINTERVAL=1, MINOR=0, TICKFONT_SIZE=8)
   
   p2_dp   = BARPLOT(tmis.sta.wave.dp,/CURRENT,AXIS_STYLE=0,YRANGE=b_dp_range,$     
                     COLOR=color_2,FILL_COLOR=color_2,$ 
                     POSITION=[p_pos[0],p_pos[3]+p_pos[4]+ohisto,p_pos[2],p_pos[3]+p_pos[4]+hhisto+ohisto])
  yax_dp  = AXIS('Y',TARGET=p2_dp,LOCATION=[-1,0],TICKINTERVAL=b_dp_inter,TITLE='$\Delta G (deg)$',MINOR=0,TICKLEN=0.02,TICKFONT_SIZE=red_font)
  dp_mean = STRCOMPRESS('$\Delta G=$'+STRING(MEAN(tmis.sta.wave.dp,/NAN),FORMAT=fmt_pdiff))
  de_mean = STRCOMPRESS('$\Delta E=$'+STRING(MEAN(tmis.sta.wave.de,/NAN),FORMAT=fmt_pdiff))
  t_dp    = TEXT(p_pos[2]+xohaxis,p_pos[3]+p_pos[4]+yohaxis,dp_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
  t_ndp   = TEXT(INDGEN(nsta),INDGEN(nsta)*0.,STRCOMPRESS(STRING(tmis.sta.wave.dp,FORMAT=fmt_pdiff)),/DATA,$
                  TARGET=p2_dp,FONT_SIZE=red_font,ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.,ORIENTATION=90.)                
  IF NOT KEYWORD_SET(no_header) THEN t_de    = TEXT(p_pos[2]+xohaxis,p_pos[3]+p_pos[4]+2*yohaxis,de_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
  IF KEYWORD_SET(tatlas) THEN BEGIN
     pha_field  = IMAGE(BYTSCL(pha,MIN=yr_pha[0],MAX=yr_pha[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                        GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,AXIS_STYLE=0,$         
                        POSITION=[p_pos[2],p_pos[1]+p_pos[4],0.99,p_pos[3]+p_pos[4]],$
                        RGB_TABLE=rgb,/CURRENT)                
      track       =  SYMBOL(tmis.sta.lon,tmis.sta.lat,'+',/DATA,TARGET=pha_field,SYM_SIZE=symsize,SYM_COLOR=color_3,/OVERPLOT)
   ENDIF ELSE BEGIN
     prgr_pha     = PLOT(mgr.pha,mgr2.pha,'+',/CURRENT,SYM_SIZE=symsize,SYM_THICK=2.,COLOR=color_1,AXIS_STYLE=0,XRANGE=yr_pha,YRANGE=yr_pha,$
                         POSITION=[p_pos[2]+0.02,p_pos[1]+p_pos[4],0.96,p_pos[3]+p_pos[4]])
     prx_pha     = AXIS('X', TARGET=prgr_pha,LOCATION=[0,yr_pha[0]] ,TICKFONT_SIZE=red_font,TITLE='Phase vs Phase (deg)',AXIS_RANGE=yr_pha,MINOR=0,TICKLEN=0.02)
     pry_pha     = AXIS('Y', TARGET=prgr_pha,LOCATION=[yr_pha[0],0] ,TICKFONT_SIZE=red_font,TITLE='',AXIS_RANGE=yr_pha,MINOR=0,TICKLEN=0.02,TEXTPOS=0)
     poly_pha    = POLYGON([yr_pha[0],yr_pha[1],yr_pha[1],yr_pha[0]],[yr_pha[0],yr_pha[1],yr_pha[0],yr_pha[0]],$
                    /DATA,TARGET=prgr_pha,FILL_BACKGROUND=0) 
   ENDELSE
ENDIF
w.Refresh

IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=resolution
ENDIF

END