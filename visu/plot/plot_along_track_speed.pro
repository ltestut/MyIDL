PRO plot_along_track_speed, mgr_in, mgr2_in, scale=scale,$
                                  xaxis=xaxis,xrange=xrange,wave=wave,$
                                  bathy_range=bathy_range,map_range=map_range,pha_range=pha_range,$
                                  speed_range=speed_range,$
                                  geo=geo,limit=limit,$
                                  output=output
; program to plot a the alongtrack velocity speed of a mgr
; mgr2_in           : to overplot an other mgr structure
; xaxis='lon'       : to choose your xaxis (lon,lat)
; xrange=[12.,14.]  : to select sub-range xaxis
; /normalized       : to get normalized ampltidude


 ;title, legend and presentation(transpose(rgb))[*,256]
gen_font     = 12                ;general font_size
red_font     =  8                ;reduced font_size
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
b_da_range=[-5.,5.]
b_dp_range=[-5.,5.]
  
  
IF NOT KEYWORD_SET(scale)     THEN scale    = 1.            ;defaut scale
IF NOT KEYWORD_SET(units)     THEN units    = 'cm'          ;defaut units
IF NOT KEYWORD_SET(xaxis)     THEN xaxis    = 'lat'         ;defaut xaxis
IF NOT KEYWORD_SET(wave)      THEN wave     = 'M2'          ;defaut wave


wave_atlas  = load_tidal_wave_list()                         ;load tidal wave list (Name/frequence/period)
ang_speed   = tidal_wave_info(wave,wave_list=wave_atlas)     ;angular velocity in °/h

idx     = WHERE(TAG_NAMES(mgr_in) EQ STRUPCASE(xaxis))
mgr     =  where_mgr(mgr_in,wave=wave)


;file     = '/data/model_indien_nord/bathy/bathy.grd'
;geo      = grd2geo(file,/XSCAN)
IF KEYWORD_SET(geo) THEN BEGIN
 bathy_leg = geomat2val(geo,LON=mgr.lon,LAT=mgr.lat)
ENDIF
lon     = SHIFT(mgr.lon,1)                       ;shift the lon vector
lat     = SHIFT(mgr.lat,1)                       ;shift the lat vector
pha     = SHIFT(REFORM(mgr.pha),1)               ;shift the phase vector
nd      = N_ELEMENTS(lon)
arc_azimuth,mgr.lon,mgr.lat,lon,lat,d,az,/METERS ;compute distance from previous point
dp      = SMOOTH((REFORM(mgr[1:nd-1].pha)-pha[1:nd-1]),10) ;compute and smooth the phase diff with previous point
speed   = ((ang_speed*d)/dp)/3600. 
depth   = (speed*speed)/9.81

iflag   = WHERE(ABS(speed) GT 300.,cpt) 
if (cpt GT 1) then speed[iflag] = !VALUES.F_NAN
if (cpt GT 1) then depth[iflag] = !VALUES.F_NAN

 ;get the phase minimum
imin  = WHERE(mgr.pha EQ MIN(mgr.pha,/nan),cpt)

text1   = mgr[0].origine
IF NOT KEYWORD_SET(xrange) THEN xrange  = [MIN(mgr.(idx),/NAN),MAX(mgr.(idx),/NAN)]
idy       = WHERE(mgr.(idx) GE xrange[0] AND mgr.(idx) LE xrange[1])
yr_bathy  = [MIN(bathy_leg[idy],/NAN),MAX(bathy_leg[idy],/NAN)]
yr_pha    = [MIN(mgr[idy].pha,/NAN),MAX(mgr[idy].pha,/NAN)]
yr_speed  = [MIN(speed[idy],/NAN),MAX(speed[idy],/NAN)]

IF KEYWORD_SET(bathy_range) THEN yr_bathy=bathy_range 
IF KEYWORD_SET(pha_range) THEN yr_pha=pha_range 
IF KEYWORD_SET(speed_range) THEN yr_speed=pha_range 

IF N_PARAMS() EQ 2 THEN BEGIN
 idx2     = WHERE(TAG_NAMES(mgr2_in) EQ STRUPCASE(xaxis))
 mgr2     =  where_mgr(mgr2_in,wave=wave)
 text2    = mgr2[0].origine
 
ENDIF

;#######################################################################
;#################### TATLAS  : CONFIGURATION     ######################
;#######################################################################
IF KEYWORD_SET(geo) THEN BEGIN
 LOADCT, 13, ncolors=ncolors, RGB_TABLE=rgb
 rgb      = CONGRID(rgb, 256, 3)
 rgb[0,*]   = 255 ;redefined the NaN color
 rgb[255,*] = 255 ;redefined the NaN color
    
 lon0     = geo.lon                      & lat0    =  geo.lat                    ;get original lon,lat
 IF KEYWORD_SET(limit) THEN field = geocut(geo,limit=limit) ELSE field = geocut(geo,limit=[MIN(mgr.lon,/NAN),MAX(mgr.lon,/NAN),MIN(mgr.lat,/NAN),MAX(mgr.lat,/NAN)])
 glimit   = get_geo_lim(geo)             & limit   = change2idllimit(glimit)      ;compute limit
 lon      = field.lon                    & lat     =  field.lat                   ;get lon,lat
 dim_lon  = MAX(lon,/NAN)-MIN(lon,/NAN)  & dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)  ;get image dimension
 dim      = [dim_lon,dim_lat]            & loc     = [MIN(lon,/NAN),MIN(lat)]     ;localisation de l'image
 bathy    = field.val
 IF NOT KEYWORD_SET(map_range) THEN map_range=[MIN(bathy,/NAN),MAX(bathy,/NAN)]
ENDIF


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  =  1000
ysize  =   600
w      = window(dimensions=[xsize,ysize])
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
t_leg1  = TEXT(leg_pos[0],leg_pos[1]-0.04,text1,TARGET=w,FONT_SIZE=gen_font,COLOR=color[0],ALIGNMENT=0.5)               
IF N_PARAMS() EQ 2 THEN t_leg2  = TEXT(leg_pos[0],leg_pos[1]-0.08,text2, TARGET=w,FONT_SIZE=gen_font,COLOR=color[1],ALIGNMENT=0.5)

;#######################################################################
;#################### BATHY PLOT :  ################################
;#######################################################################
p_bathy   = PLOT(mgr[1:nd-1].(idx),bathy_leg[1:nd-1],symref,/DATA,AXIS_STYLE=1,XRANGE=xrange,XTITLE=STRUPCASE(xaxis)+' (deg)',YTITLE='Depth (m)',$
               YMINOR=0,YRANGE=yr_bathy,$
               FILL_BACKGROUND=1, FILL_LEVEL=yr_bathy[0],$
               SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
               POSITION=[p_pos[0],p_pos[1],p_pos[2],p_pos[3]],/CURRENT)
p_depth   = PLOT(mgr[1:nd-1].(idx),-1.*depth,symref,/DATA,/OVERPLOT,SYM_SIZE=symsize,SYM_COLOR=color_1,SYM_FILLED=1,SYM_FILL_COLOR=color_1,/CURRENT)

IF N_PARAMS() EQ 2 THEN BEGIN
  p_depth2  = PLOT(mgr2[1:nd-1].(idx),-1.*depth2,symref,/DATA,/OVERPLOT,SYM_SIZE=symsize,SYM_COLOR=color_2,SYM_FILLED=1,SYM_FILL_COLOR=color_1,/CURRENT)
ENDIF
IF KEYWORD_SET(geo) THEN BEGIN
   bathy_field   = IMAGE(BYTSCL(bathy,MIN=map_range[0],MAX=map_range[1],/NAN),MAP_PROJECTION=proj,LIMIT=limit,$
                      GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,AXIS_STYLE=0,$         
                      POSITION=[p_pos[2],p_pos[1],0.99,p_pos[3]],$
                      RGB_TABLE=rgb,/CURRENT)
   track        =  SYMBOL(mgr.lon,mgr.lat,'+',/DATA,TARGET=bathy_field,SYM_SIZE=0.2,SYM_COLOR=color_3,/OVERPLOT)
ENDIF

;#######################################################################
;#################### PHASE PLOT :      ################################
;#######################################################################
p_phase   = PLOT(mgr[1:nd-1].(idx),mgr[1:nd-1].pha,symref,/DATA,AXIS_STYLE=0,XRANGE=xrange,XTITLE=STRUPCASE(xaxis)+' (deg)',YTITLE='Phase (deg)',$
               YMINOR=0,YRANGE=pha_range,$
               SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_1,$
               POSITION=[p_pos[0],p_pos[3]+0.01,p_pos[2],p_pos[3]+0.11],/CURRENT)
yaxis     = AXIS('Y', TARGET=p_phase,LOCATION=[xrange[1],0], TEXTPOS=1,TICKINTERVAL=30,TICKFONT_SIZE=red_font)

;#######################################################################
;#################### SPEED PLOT :      ################################
;#######################################################################
p_speed   = PLOT(mgr[1:nd-1].(idx),speed,symref,/DATA,AXIS_STYLE=1,XSTYLE=0,XRANGE=xrange,YTITLE='Phase Velocity (m/s)',$
               YMINOR=0,YRANGE=yr_speed,$
               SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
               POSITION=[p_pos[0],p_pos[1]+p_pos[4],p_pos[2],p_pos[3]+p_pos[4]],/CURRENT)
;IF N_PARAMS() EQ 2 THEN BEGIN
;  p2_pha   = PLOT(mgr2.(idx),mgr2.pha,symref,/DATA,/OVERPLOT,SYM_SIZE=symsize,SYM_COLOR=color_1,SYM_FILLED=1,SYM_FILL_COLOR=color_1,/CURRENT)
;  p2_dp    = BARPLOT(tmis.sta.(idx_tmis),tmis.sta.wave.dp,/CURRENT,AXIS_STYLE=0,XRANGE=xrange,YRANGE=b_dp_range,$    
;                     COLOR=color_2,FILL_COLOR=color_2,$ 
;                     POSITION=[p_pos[0],p_pos[3]+p_pos[4]+0.01,p_pos[2],p_pos[3]+p_pos[4]+0.11])
;  yaxis   = AXIS('Y',TARGET=p2_dp,LOCATION=[xrange[1],0],TEXTPOS=1,TICKINTERVAL=5,TICKFONT_SIZE=red_font)
;  dp_mean = STRCOMPRESS('$\Delta P=$'+STRING(MEAN(tmis.sta[id_zoom].wave.dp,/NAN),FORMAT=fmt_diff))
;  de_mean = STRCOMPRESS('$\Delta E=$'+STRING(MEAN(tmis.sta[id_zoom].wave.de,/NAN),FORMAT=fmt_diff))
;  t_dp    = TEXT(p_pos[2]+0.03,p_pos[3]+p_pos[4]+0.06,dp_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
;  t_de    = TEXT(p_pos[2]+0.03,leg_pos[1]-0.08,de_mean,/NORMAL,FONT_SIZE=gen_font,ALIGNMENT=0.0)
;ENDIF
w.Refresh
IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=150
ENDIF

END