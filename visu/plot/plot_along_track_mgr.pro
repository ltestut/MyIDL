PRO plot_along_track_mgr, mgr_in, mgr2_in, normalized=normalized, units=units, scale=scale,$
                                  xaxis=xaxis,xrange=xrange,wave=wave,$
                                  amp_range=amp_range,pha_range=pha_range,$
                                  tatlas=tatlas,limit=limit,$
                                  buffer=buffer,resolution=resolution,output=output
; program to plot a the amplitude of phase of an along track mgr
; mgr2_in           : to overplot an other mgr structure
; xaxis='lon'       : to choose your xaxis (lon,lat)
; xrange=[12.,14.]  : to select sub-range xaxis
; /normalized       : to get normalized ampltidude


 ;title, legend and presentation(transpose(rgb))[*,256]
gen_font     = 8                ;general font_size
red_font     = 6                ;reduced font_size
symsize      = 0.4               ;symbol size
symref       = "-o"              ;solid+circle
fmt_diff     = '(F06.1)'
 ;color choice
ncolors      = 10               ;number of color of the atlas thumbnail               
color_ref    = 'Dark Grey'      ;color for the ref circle
color_1      = 'Black'          ;color for the second mgr
color_2      = 'Light Grey'     ;color for the barrplot
color_3      = 'white'          ;color for the track location
color        = [color_ref,color_1,color_2,color_3]
 ;barrplot
b_da_range=[-10.,10.]
b_dp_range=[-10.,10.]
  
  
IF NOT KEYWORD_SET(scale)      THEN scale      = 1.            ;defaut scale
IF NOT KEYWORD_SET(units)      THEN units      = 'cm'          ;defaut units
IF NOT KEYWORD_SET(xaxis)      THEN xaxis      = 'lat'         ;defaut xaxis
IF NOT KEYWORD_SET(wave)       THEN wave       = 'M2'          ;defaut wave
IF NOT KEYWORD_SET(resolution) THEN resolution = 150.          ;defaut resolution

idx     = WHERE(TAG_NAMES(mgr_in) EQ STRUPCASE(xaxis))
mgr     =  where_mgr(mgr_in,wave=wave)
mgr.amp = mgr.amp*scale
text1   = mgr[0].origine

IF NOT KEYWORD_SET(xrange) THEN xrange  = [MIN(mgr.(idx),/NAN),MAX(mgr.(idx),/NAN)]
idy     = WHERE(mgr.(idx) GE xrange[0] AND mgr.(idx) LE xrange[1])
yr_amp  = [MIN(mgr[idy].amp,/NAN),MAX(mgr[idy].amp,/NAN)]
yr_pha  = [MIN(mgr[idy].pha,/NAN),MAX(mgr[idy].pha,/NAN)]
tamp    = 'Min-Max = '+STRING(FORMAT='(F6.2)',yr_amp[0])+' - '+STRING(FORMAT='(F6.2)',yr_amp[1])
tpha    = 'Min-Max = '+STRING(FORMAT='(F6.2)',yr_pha[0])+' - '+STRING(FORMAT='(F6.2)',yr_pha[1])
IF KEYWORD_SET(amp_range) THEN yr_amp=amp_range 
IF KEYWORD_SET(pha_range) THEN yr_pha=pha_range 

IF N_PARAMS() EQ 2 THEN BEGIN
 idx2     = WHERE(TAG_NAMES(mgr2_in) EQ STRUPCASE(xaxis))
 mgr2     =  where_mgr(mgr2_in,wave=wave)
 mgr2.amp = mgr2.amp*scale
 text2    = mgr2[0].origine
 tmis     = compare_mgr(mgr2,mgr)
 idx_tmis = WHERE(TAG_NAMES(tmis.sta) EQ STRUPCASE(xaxis))
 id_zoom  = WHERE(tmis.sta.(idx_tmis) GE xrange[0] AND tmis.sta.(idx_tmis) LE xrange[1])
 IF KEYWORD_SET(normalized) THEN  mgr2.amp = mgr2.amp/MAX(mgr2.amp)
ENDIF

;#######################################################################
;#################### TATLAS  : CONFIGURATION     ######################
;#######################################################################
IF KEYWORD_SET(tatlas) THEN BEGIN
 LOADCT, 13, ncolors=ncolors, RGB_TABLE=rgb
 rgb      = CONGRID(rgb, 256, 3)
 rgb[0,*] = 255 ;redefined the NaN color   
 lon0     = tatlas.lon                   & lat0    =  tatlas.lat                 ;get original lon,lat
 IF KEYWORD_SET(limit) THEN atlas = tatlas_cut(tatlas,limit=limit,/VERBOSE) ELSE atlas = tatlas
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
;w.refresh, /disable
leg_pos  = [0.5,0.90]
i        = 0
p_pos    = [0.1,0.1,0.85,0.40,0.40]
IF N_PARAMS() EQ 2 THEN p_pos = [0.1,0.1,0.85,0.30,0.40] 
sublabel = 5
nlabel   = N_ELEMENTS(mgr.lat)
xlabel   = INDGEN(nlabel)*sublabel
index    = WHERE(xlabel LE nlabel) 


t_head  = TEXT(leg_pos[0],leg_pos[1],['Track N° : '+mgr[0].name+'/  WAVE = '+STRING(wave)], TARGET=w,COLOR='black',FONT_SIZE=gen_font,ALIGNMENT=0.5)                
t_leg1  = TEXT(leg_pos[0],leg_pos[1]-0.04,text1,TARGET=w,FONT_SIZE=red_font,COLOR=color[0],ALIGNMENT=0.5)               
IF N_PARAMS() EQ 2 THEN t_leg2  = TEXT(leg_pos[0],leg_pos[1]-0.08,text2, TARGET=w,FONT_SIZE=red_font,COLOR=color[1],ALIGNMENT=0.5)

;#######################################################################
;#################### AMPLITUDE PLOT :  ################################
;#######################################################################
p_amp   = PLOT(mgr.(idx),mgr.amp,symref,/DATA,AXIS_STYLE=1,XRANGE=xrange,XTITLE=STRUPCASE(xaxis)+' (deg)',YTITLE='Amplitude (cm)',$
               YMINOR=0,YRANGE=yr_amp,FONT_SIZE=gen_font,$
               SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
               POSITION=[p_pos[0],p_pos[1],p_pos[2],p_pos[3]],/CURRENT)
t_mina  = TEXT(p_pos[0],p_pos[1]-0.06,tamp,/NORMAL,FONT_SIZE=gen_font,COLOR=color_ref,ALIGNMENT=0.)
               
IF N_PARAMS() EQ 2 THEN BEGIN
   p2_amp  = PLOT(mgr2.(idx),mgr2.amp,symref,/DATA,/OVERPLOT,SYM_SIZE=symsize,SYM_COLOR=color_1,SYM_FILLED=1,SYM_FILL_COLOR=color_1,/CURRENT)
   p2_da   = BARPLOT(tmis.sta.(idx_tmis),tmis.sta.wave.da,/CURRENT,AXIS_STYLE=0,XRANGE=xrange,YRANGE=b_da_range,$    
                     COLOR=color_2,FILL_COLOR=color_2,$               
                     POSITION=[p_pos[0],p_pos[3]+0.01,p_pos[2],p_pos[3]+0.11])
   yaxis   = AXIS('Y', TARGET=p2_da,LOCATION=[xrange[1],0], TEXTPOS=1,TICKINTERVAL=5,TICKFONT_SIZE=red_font)
   da_mean = STRCOMPRESS('$\Delta A=$'+STRING(MEAN(tmis.sta[id_zoom].wave.da,/NAN),FORMAT=fmt_diff))
   t_da    = TEXT(p_pos[2]+0.03,p_pos[3]+0.06,da_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)                
   IF KEYWORD_SET(tatlas) THEN BEGIN
      amp_field   = IMAGE(BYTSCL(amp,MIN=yr_amp[0],MAX=yr_amp[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                      GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,AXIS_STYLE=0,$         
                      POSITION=[p_pos[2],p_pos[1],0.99,p_pos[3]],$
                      RGB_TABLE=rgb,/CURRENT)
      track       =  SYMBOL(tmis.sta.lon,tmis.sta.lat,'+',/DATA,TARGET=amp_field,SYM_SIZE=0.2,SYM_COLOR=color_3,/OVERPLOT)
   ENDIF
ENDIF
;#######################################################################
;#################### PHASE PLOT :      ################################
;#######################################################################
p_pha   = PLOT(mgr.(idx),mgr.pha,symref,/DATA,AXIS_STYLE=1,XSTYLE=0,XRANGE=xrange,YTITLE='Phase (deg)',$
               YMINOR=0,YRANGE=yr_pha,FONT_SIZE=gen_font,$
               SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
               POSITION=[p_pos[0],p_pos[1]+p_pos[4],p_pos[2],p_pos[3]+p_pos[4]],/CURRENT)
t_minp  = TEXT(p_pos[0],p_pos[1]+p_pos[4]-0.06,tpha,/NORMAL,FONT_SIZE=gen_font,COLOR=color_ref,ALIGNMENT=0.)               
IF N_PARAMS() EQ 2 THEN BEGIN
  p2_pha   = PLOT(mgr2.(idx),mgr2.pha,symref,/DATA,/OVERPLOT,SYM_SIZE=symsize,SYM_COLOR=color_1,SYM_FILLED=1,SYM_FILL_COLOR=color_1,/CURRENT)
  p2_dp    = BARPLOT(tmis.sta.(idx_tmis),tmis.sta.wave.dp,/CURRENT,AXIS_STYLE=0,XRANGE=xrange,YRANGE=b_dp_range,$    
                     COLOR=color_2,FILL_COLOR=color_2,$ 
                     POSITION=[p_pos[0],p_pos[3]+p_pos[4]+0.01,p_pos[2],p_pos[3]+p_pos[4]+0.11])
  yaxis   = AXIS('Y',TARGET=p2_dp,LOCATION=[xrange[1],0],TEXTPOS=1,TICKINTERVAL=5,TICKFONT_SIZE=red_font)
  dp_mean = STRCOMPRESS('$\Delta P=$'+STRING(MEAN(tmis.sta[id_zoom].wave.dp,/NAN),FORMAT=fmt_diff))
  de_mean = STRCOMPRESS('$\Delta E=$'+STRING(MEAN(tmis.sta[id_zoom].wave.de,/NAN),FORMAT=fmt_diff))
  t_dp    = TEXT(p_pos[2]+0.03,p_pos[3]+p_pos[4]+0.06,dp_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
  t_de    = TEXT(p_pos[2]+0.03,leg_pos[1]-0.08,de_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
  IF KEYWORD_SET(tatlas) THEN BEGIN
     pha_field  = IMAGE(BYTSCL(pha,MIN=yr_pha[0],MAX=yr_pha[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                        GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,AXIS_STYLE=0,$         
                        POSITION=[p_pos[2],p_pos[1]+p_pos[4],0.99,p_pos[3]+p_pos[4]],$
                        RGB_TABLE=rgb,/CURRENT)                
      track       =  SYMBOL(tmis.sta.lon,tmis.sta.lat,'+',/DATA,TARGET=pha_field,SYM_SIZE=0.2,SYM_COLOR=color_3,/OVERPLOT)
  ENDIF
ENDIF
w.Refresh
IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=resolution
ENDIF

END