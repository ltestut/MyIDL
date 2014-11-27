;######################################################################################################################################################################################
;######################################################################################################################################################################################
;###########################################################          MAP TATLAS                          #############################################################################
;######################################################################################################################################################################################
;######################################################################################################################################################################################
PRO map_tatlas, tatlas1, tatlas2, limit=limit, blank=blank, wave=wave,  $
                      scale=scale,  $
                      amp_range=amp_range,amp_step=amp_step,amp_format=amp_format,$
                      pha_range=pha_range,pha_step=pha_step,pha_format=pha_format,pha_treshold=pha_treshold,$
                      section=section,band=band,longitude=longitude,$
                      ellipse=ellipse,$
                      iso=iso,nocoast=nocoast,nointerp=nointerp,no_header=no_header,kml=kml,$
                      ncolors=ncolors,col=col,$
                      proj=proj,$
                      mgr=mgr, track=track, bathy=bathy,  output=output, resolution=resolution, $
                      resample=resample,$
                      format=format,buffer=buffer, _EXTRA=_EXTRA
;#######################################################################
;#################### DOCUMENTATION PART : USAGE      ##################
;#######################################################################
; map a tidal atlas with a main field shown as a color map and a secondary field shown as isoline
; 
; /blank           : to display everthing execpt the isofield (map and contour)
; 
; WAVE='M2'        : choose the wave to plot
; AMP_STEP=1       : choose the amplitude step 
; PHA_STEP=1       : choose the phase step 

; /NOINTERP        : do not interpolate before differencing the grid

; lat_profile=17.7 : extract the amplitude and phase section at this latitude and show them on an upper plots
; band=[72.,78.] 
; /LONGITUDE


;/ISO              : does not plot the main field, only its isoline
;/NOCOAST          : does not display the coastline
;/HIRES            : display the HR coastline
;  MGR=mgr         : show amp or phase value from mgr
;  TRACK=mgr       : show amp or phase value from atli track data
; FORMAT='(F7.2)'  : give label format (by default '(F6.1)')
; /HIRES           : draw high resolution coastline
; /BUFFER          : send the output to the buffer (to be used for automatic processing)
; ncolor           : choose the number of color of the palette
; col=41           : select the palette number
; resolution=300   : input resolution of output 

; resample=10      : increase resolution of the image by ten 


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
iso_color    = 'white'           ;isoline color
iso_fmta     = '(F5.1)'          ;isoline format for amplitude
iso_fmtp     = '(I4)'            ;isoline format for phase
iso_thick    = 0.5               ;isoline thickness
iso_font     = 10                 ;isoline label font size
col_format   = '(F3.1)'          ;colorbar tickformat
IF KEYWORD_SET(iso) THEN map_hide=1 ELSE map_hide=0
IF KEYWORD_SET(iso) THEN iso_color='dark grey'
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
IF NOT KEYWORD_SET(proj)          THEN proj='MERCATOR'
IF NOT KEYWORD_SET(scale)         THEN scale=1.
IF NOT KEYWORD_SET(ncolors)       THEN ncolors=10
IF NOT KEYWORD_SET(amp_format)    THEN amp_format='(F5.1)'
IF NOT KEYWORD_SET(pha_format)    THEN pha_format='(F5.1)'
IF NOT KEYWORD_SET(wave)          THEN wave='M2'
IF NOT KEYWORD_SET(aspect_ratio) THEN aspect_ratio=1
IF NOT KEYWORD_SET(col) THEN col=0
IF NOT KEYWORD_SET(resolution) THEN resolution=150

IF (scale EQ 100.) THEN col_format   = '(F6.1)'          ;colorbar tickformat

 ;in case of 2 tatlas compute the diff
IF (N_PARAMS() EQ 2) THEN BEGIN
 t1       = tatlas_domain_intersection(tatlas1,tatlas2,T2_OUT=t2,_EXTRA=_EXTRA) ;cut the common domain
 IF NOT KEYWORD_SET(nointerp) THEN t2  = tatlas_interpolate(t2,LON=t1.lon,LAT=t1.lat,/VERBOSE,WAVE=wave)
 atlas_in = tatlas_diff(t1,t2,/ABS) 
 col      = 13  ;predifine the diff color table
ENDIF ELSE BEGIN
 atlas_in = tatlas1
ENDELSE

 ;limit and type of the atlas
IF KEYWORD_SET(limit) THEN BEGIN
 atlas  = tatlas_cut(atlas_in,limit=limit)
 limit  = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 
ENDIF ELSE BEGIN
 atlas  = atlas_in
 limit  = geo_limit(atlas)
ENDELSE

 ;recuperation des variables a tracer et calcul du zrange et des niveaux
lon  = atlas.lon
lat  = atlas.lat
lon0 = MIN(lon,/NAN,MAX=lon_max)
lat0 = MIN(lat,/NAN,MAX=lat_max)
dlon = lon_max-lon0
dlat = lat_max-lat0
idw = WHERE(atlas.wave.name EQ wave, cpt)
IF (cpt LT 1) THEN STOP,'No '+wave+' wave in this taltas'


;############  COMPUTATION PART : AMPLITUDE AND PHASE / ELLIPSE ######################
IF KEYWORD_SET(ellipse) THEN BEGIN
 ug      = rad(atlas.wave[idw].ug)    ;Phi_u angle in radians
 vg      = rad(atlas.wave[idw].vg)    ;Phi_v angle in radians
 ua      = atlas.wave[idw].ua*scale   ;zonal velocity amplitude
 va      = atlas.wave[idw].va*scale   ;meridional velocity amplitude
 camp    = COMPLEX(ua*ua*COS(2*ug)+va*va*COS(2*vg),ua*ua*SIN(2*ug)+va*va*SIN(2*vg),/DOUBLE)
 umax    = SQRT((ua*ua+va*va+ABS(camp))/2.) ;maximum current
 phi_max = -1*ATAN(camp,/PHASE)/2.
 umin = SQRT((ua*ua+va*va-ABS(camp))/2.) ;minimum current
 x1 = ua*ua+va*va                                              ;U2+V2
 x2 = 2*ua*va*SIN(ug-vg) 
 t1 = ATAN((va*COS(vg)-ua*SIN(ug))/(ua*COS(ug)+va*SIN(vg)))
 t2 = ATAN((va*COS(vg)+ua*SIN(ug))/(ua*COS(ug)-va*SIN(vg)))
 ;calcul du 1/2 grand-axe a, du 1/2 petit-axe b et de l'exentircite e de l'ellipse
 a_major=0.5*(SQRT(x1+x2)+SQRT(x1-x2))
 a_minor=0.5*(SQRT(x1+x2)-SQRT(x1-x2))
 e=SQRT(a_major*a_major-a_minor*a_minor)/a_major
 ;calcul de phi
 phi = deg(((t1+t2)/2))
 PRINT," Maximum current range : ",MIN(umax,/NAN),MAX(umax,/NAN)
 PRINT," Minimum current range : ",MIN(umin,/NAN),MAX(umin,/NAN)
 amp  = umax
 pha  = 180.+deg(phi_max)
ENDIF ELSE BEGIN
amp = atlas.wave[idw].amp*scale
pha = atlas.wave[idw].pha
IF KEYWORD_SET(pha_treshold) THEN BEGIN
 isup = WHERE(pha LT pha_treshold,csup)
 IF (csup GE 1) THEN pha[isup] = 360.+pha[isup]
ENDIF
ENDELSE
full_amp = [MIN(amp,/NAN),MAX(amp,/NAN)]
full_pha = [MIN(pha,/NAN),MAX(pha,/NAN)]
IF NOT KEYWORD_SET(amp_range) THEN amp_range=full_amp
IF NOT KEYWORD_SET(pha_range) THEN pha_range=full_pha
IF KEYWORD_SET(amp_step) THEN na_step=CEIL((amp_range[1]-amp_range[0])/amp_step) $
                         ELSE na_step=ncolors
IF KEYWORD_SET(pha_step) THEN np_step=CEIL((pha_range[1]-pha_range[0])/pha_step) $
                         ELSE np_step=ncolors
amp_levels=amp_range[0]+(amp_range[1]-amp_range[0])/(na_step)*INDGEN(na_step)
pha_levels=pha_range[0]+(pha_range[1]-pha_range[0])/(np_step)*INDGEN(np_step)
isofield   =  amp            ;select the principal field to map
isorange   =  amp_range      ;select the principal field range
isolevels  =  amp_levels     ;select the principal field levels
isofield2  =  pha            ;select the secondary field to map
isorange2  =  pha_range      ;select the secondary field range
isolevels2 =  pha_levels     ;select the secondary field levels

 ;compute the mgr_label  
IF KEYWORD_SET(mgr) THEN BEGIN
 mgr_name = STRCOMPRESS(mgr.name,/REMOVE_ALL)
 nsta       = N_ELEMENTS(mgr_name)
 mgr_label  = STRARR(nsta)
 id         = wave_index(mgr,wave)
 FOR i=0,nsta-1 DO mgr_label[i] = STRCOMPRESS(STRING(mgr[i].amp[id[i]]*scale,FORMAT=amp_format))+'/'+STRCOMPRESS(STRING(mgr[i].pha[id[i]],FORMAT=pha_format))
ENDIF
IF KEYWORD_SET(track) THEN BEGIN
 track_name = STRCOMPRESS(track.name,/REMOVE_ALL)
 ;track_name = track.name+'['+STRING(track.lon,FORMAT='(F6.3)')+'--'+STRING(track.lon,FORMAT='(F6.3)')+']'
 nsta       = N_ELEMENTS(track_name)
 track_amp  = STRARR(nsta)
 track_pha  = STRARR(nsta)
 id         = wave_index(track,wave)
 FOR i=0,nsta-1 DO BEGIN
     track_amp[i] = STRCOMPRESS(STRING(track[i].amp[id[i]]*scale,FORMAT=amp_format))
     track_pha[i] = STRCOMPRESS(STRING(track[i].pha[id[i]]      ,FORMAT=pha_format))
 ENDFOR
ENDIF


;############  COMPUTATION PART : SECTION ######################
;---------------------------------------------------------------
IF KEYWORD_SET(section) THEN BEGIN
  IF (NOT KEYWORD_SET(longitude) AND NOT KEYWORD_SET(band)) THEN band=[MIN(lon,/NAN),MAX(lon,/NAN)]
  IF (KEYWORD_SET(longitude) AND NOT KEYWORD_SET(band)) THEN band=[MIN(lat,/NAN),MAX(lat,/NAN)] 
  IF N_ELEMENTS(section) EQ 1 THEN BEGIN
    IF KEYWORD_SET(longitude) THEN indx = WHERE(lon EQ section, cpt) ELSE indx = WHERE(lat EQ section, cpt) 
    IF KEYWORD_SET(longitude) THEN iband = WHERE(lat GT band[0] AND lat LT band[1],cband) ELSE iband = WHERE(lon GT band[0] AND lon LT band[1],cband)
    IF KEYWORD_SET(longitude) THEN xplot = lat[iband] ELSE xplot= lon[iband] 
    IF (cpt NE 0) THEN BEGIN
       IF KEYWORD_SET(longitude) THEN samp = amp[indx,iband[0]:iband[cband-1]] ELSE  samp = amp[iband[0]:iband[cband-1],indx]    ;section for amplitude
       IF KEYWORD_SET(longitude) THEN spha = pha[indx,iband[0]:iband[cband-1]] ELSE  spha = pha[iband[0]:iband[cband-1],indx]    ;section for phase
    ENDIF ELSE BEGIN
      PRINT,'No data for this section'
    ENDELSE 
  ENDIF
  ival    = WHERE(FINITE(samp),nval) 
  IF KEYWORD_SET(longitude) THEN sp_lon=MAKE_ARRAY(nval,VALUE=section,/DOUBLE) ELSE sp_lon  = xplot[ival]
  IF KEYWORD_SET(longitude) THEN sp_lat=xplot[ival]                            ELSE sp_lat  = MAKE_ARRAY(nval,VALUE=section,/DOUBLE) 
ENDIF

;############  COMPUTATION PART : GRIDDING ######################
;---------------------------------------------------------------
IF KEYWORD_SET(resample) THEN BEGIN
 sz                 =  SIZE(amp)
 ix                 = (sz[1]/resample)*INDGEN(resample+1)
 iy                 = (sz[2]/resample)*INDGEN(resample+1)
 lon                = lon0+dlon*INDGEN(resample+1)/resample
 lat                = lat0+dlat*INDGEN(resample+1)/resample
 isofield           =  BILINEAR(amp,ix,iy)  ;select the principal field to map
 isofield2          =  BILINEAR(pha,ix,iy)  ;select the secondary field to map
ENDIF



;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;creation de la fenetre graphique
xsize = 1200
ysize = 1000
IF KEYWORD_SET(buffer) THEN w=window(dimensions=[xsize,ysize],/BUFFER) $
                       ELSE w = window(dimensions=[xsize,ysize])
 ;define graphic position and draw legends
IF KEYWORD_SET(section) THEN BEGIN
  p_pos     = [0.05,0.15,0.45,0.7] ;amplitude map position
  p_pos2    = [0.55,0.15,0.95,0.7] ;phase     map position
ENDIF ELSE BEGIN
  p_pos     = [0.05,0.15,0.45,0.8] ;amplitude map position
  p_pos2    = [0.55,0.15,0.95,0.8] ;phase     map position
ENDELSE
leg_pos   = [0.5,0.90]          ;legende position
IF NOT KEYWORD_SET(no_header) THEN t_head1=TEXT(leg_pos[0],leg_pos[1],$
   'MODEL = '+atlas.info,TARGET=w,COLOR=txtcolor,FONT_SIZE=gen_font,$
    ALIGNMENT=0.5)
t_head2=TEXT(leg_pos[0]    ,leg_pos[1]-0.03 ,wave,$
             TARGET=w,COLOR=txtcolor,FONT_SIZE=gen_font,ALIGNMENT=0.5)
t_amp=TEXT(p_pos[2]-0.2  ,p_pos[3]+0.05   ,'AMPLITUDE'           ,$
             TARGET=w,COLOR=txtcolor,FONT_SIZE=gen_font,ALIGNMENT=0.5)                
t_pha=TEXT(p_pos2[2]-0.2 ,p_pos2[3]+0.05  ,'PHASE'               ,$
             TARGET=w,COLOR=txtcolor,FONT_SIZE=gen_font,ALIGNMENT=0.5)                
 ;load color table
LOADCT, col, ncolors=na_step, RGB_TABLE=rgb
rgb      = CONGRID(rgb, 256, 3)
rgb[0,*] = 255 ;redefined the NaN color

;---------------------------------------------------------------------------------
;-----------   AMPLITUDE  FIELD   ------------------------------------------------
;---------------------------------------------------------------------------------
IF NOT KEYWORD_SET(blank) THEN BEGIN
m1=MAP(proj,LIMIT=limit,POSITION=p_pos,ASPECT_RATIO=aspect_ratio,HIDE=1,/CURRENT) ;0:normal/1:bold/2:italic/3:bold&italic

;map_hide=1 ;;TODO to be changed
;map_field=IMAGE(BYTSCL(isofield,MIN=isorange[0],MAX=isorange[1],/NAN),$
;          MAP_PROJECTION=proj,limit=limit,ASPECT_RATIO=aspect_ratio,/CURRENT,$
;          GRID_UNITS='degrees',IMAGE_LOCATION=[lon0,lat0],IMAGE_DIMENSIONS=[dlon,dlat],$
;          POSITION=p_pos,AXIS_STYLE=0,RGB_TABLE=Colortable(72,/REVERSE),$
;          HIDE=map_hide)


;map_ell       = ELLIPSE(81.2,12.3,MAJOR=a_major[500,500],MINOR=a_minor[500,500],THETA=45.,$
;                                          TARGET=map_field,/DATA)

iso1=CONTOUR(isofield,lon,lat,GRID_UNITS='degrees',MAP_PROJECTION=proj,$
             POSITION=p_pos,OVERPLOT=m1)
iso1.MAPGRID.hide=1
iso1.MIN_VALUE=MIN(isolevels)
iso1.MAX_VALUE=MAX(isolevels)
iso1.C_VALUE=isolevels
iso1.C_LABEL_SHOW=1
iso1.C_THICK=iso_thick
iso1.C_COLOR=iso_color
iso1.LABEL_FORMAT=amp_format
iso1.FONT_SIZE=iso_font
;iso1.RGB_TABLE=COLORTABLE(72,/REVERSE)
;iso1.FILL=0
ENDIF

IF KEYWORD_SET(kml) THEN BEGIN
  iso_amp = CONTOUR(isofield,lon,lat,GRID_UNITS='degrees',MAP_PROJECTION=proj,/OVERPLOT,$
  C_VALUE=isolevels,C_LABEL_SHOW=lshow,FONT_SIZE=iso_font,LABEL_FORMAT=iso_fmta,C_COLOR=iso_color,$
  C_THICK=iso_thick,/FILL,TRANSPARENCY=50)
  m1.save, !kml  
ENDIF
g1=MAPGRID(/BOX_AXES,LABEL_POSITION=0,BOX_COLOR='gray',BOX_THICK=1,LINESTYLE=2,$
            COLOR='grey',THICK=0.5,FONT_STYLE=0,FONT_SIZE=red_font,$
                         GRID_LONGITUDE = 1.,GRID_LATITUDE = 1.,$
                        /CURRENT)

 ;trace le champ de vecteur
;map_vector  = vector(ua, va, lon, lat, GRID_UNITS='deg',/OVERPLOT,TRANSPARENCY=0.,$
;                RGB_TABLE=rgb, AUTO_COLOR=1, HEAD_SIZE=0.3, $
;                X_SUBSAMPLE=10,Y_SUBSAMPLE=10,$
;                MIN_VALUE=0.,MAX_VALUE=20.,$
;                AUTO_RANGE=[0.,10.],$
;                DATA_LOCATION='tail')
                
;v          = VECTOR(ua, va, lon, lat, GRID_UNITS='deg',/OVERPLOT,$
;                  AUTO_COLOR=0, HEAD_SIZE=1.,/HEAD_PROPORTIONAL,CLIP=0,$
;                  X_SUBSAMPLE=20,Y_SUBSAMPLE=20,MIN_VALUE=0.,MAX_VALUE=5.,$
;                  LENGTH_SCALE=2.5,ARROW_THICK=2.,COLOR='gray',$
;                  DATA_LOCATION='tail')

;,$
;                MINOR=a_minor[500,500],MAJOR=a_major[500,500]/DATA)

  ;#################keyword layers
;  If KEYWORD_SET(ellipse) THEN FOR i=0,N_ELEMENTS(lon)-1,10 DO FOR j=0,N_ELEMENTS(lat)-1,10 DO map_ell = ELLIPSE(lon[i], lat[j], FILL_BACKGROUND=0,MAJOR=a[i,j]*scale, MINOR=b[i,j]*scale, THETA=phi[i,j],/DATA)
IF NOT KEYWORD_SET(nocoast) THEN c1=MAPCONTINENTS(FILL_COLOR="antique white",$
                                         LIMIT=limit,/CONTINENTS,_EXTRA=_EXTRA)
IF KEYWORD_SET(mgr) THEN sname=update_symbol_layer(SYMBOL(mgr.lon,mgr.lat,'+',$
                            LABEL_STRING=mgr_name,/DATA,/OVERPLOT),NAME='name')
IF KEYWORD_SET(track) THEN strack=update_symbol_layer(SYMBOL(track.lon,track.lat,'o' ,LABEL_STRING=track_amp,/DATA,/OVERPLOT),NAME='track')
IF KEYWORD_SET(section) THEN sprof=update_symbol_layer(SYMBOL(sp_lon,sp_lat,'+',/DATA,/OVERPLOT),NAME='section')                                     
IF NOT KEYWORD_SET(iso) THEN cb=COLORBAR(TARGET=map_field, /BORDER_ON, TITLE='Amplitude',TAPER=2,$
                                                     TICKNAME=STRING(isolevels,FORMAT=col_format),$
                                                     TEXTPOS=0,FONT_SIZE=gen_font, $
                                                      POSITION=[p_pos[0],p_pos[1]-0.03,p_pos[2],p_pos[1]-0.01])
;---------------------------------------------------------------------------------
;-----------   PHASE  FIELD   ----------------------------------------------------
;---------------------------------------------------------------------------------
IF NOT KEYWORD_SET(blank) THEN BEGIN
m2=MAP(proj,LIMIT=limit,POSITION=p_pos2,ASPECT_RATIO=aspect_ratio,HIDE=1,/CURRENT) ;0:normal/1:bold/2:italic/3:bold&italic

;map_field2=IMAGE(BYTSCL(isofield2,MIN=isorange2[0],MAX=isorange2[1],/NAN),GRID_UNITS='degrees',IMAGE_LOCATION=[lon0,lat0],IMAGE_DIMENSIONS=[dlon,dlat],$
;                            MAP_PROJECTION=proj,limit=limit,$
;                            ASPECT_RATIO=aspect_ratio,/CURRENT,$ 
;                            POSITION=p_pos2,AXIS_STYLE=0,RGB_TABLE=rgb,HIDE=map_hide)
;map_field2.MAPGRID.hide=1

iso2=CONTOUR(isofield2,lon,lat,GRID_UNITS='degrees',MAP_PROJECTION=proj,$
              POSITION=p_pos2,OVERPLOT=m2)
iso2.MAPGRID.hide=1
iso2.MIN_VALUE=MIN(isolevels2)
iso2.MAX_VALUE=MAX(isolevels2)
iso2.C_VALUE=isolevels2
iso2.C_LABEL_SHOW=1
iso2.C_THICK=iso_thick
iso2.C_COLOR=iso_color
iso2.LABEL_FORMAT=pha_format
iso2.FONT_SIZE=iso_font
ENDIF
g2=MAPGRID(/BOX_AXES,LABEL_POSITION=0,BOX_COLOR='gray',BOX_THICK=1,LINESTYLE=2,$
   COLOR='grey',THICK=0.5,FONT_STYLE=0,FONT_SIZE=red_font,$
   GRID_LONGITUDE = 1.,GRID_LATITUDE = 1.,$
   /CURRENT)

  ;#################keyword layers
IF NOT KEYWORD_SET(nocoast) THEN c2=MAPCONTINENTS(FILL_COLOR="antique white",LIMIT=limit,/CONTINENTS,_EXTRA=_EXTRA)
IF KEYWORD_SET(mgr) THEN smgr=update_symbol_layer(SYMBOL(mgr.lon,mgr.lat,'+',$
                      LABEL_STRING=mgr_label,/DATA,/OVERPLOT),NAME='mgr_label')
IF KEYWORD_SET(track)       THEN strack= update_symbol_layer(SYMBOL(track.lon,track.lat,'o' ,LABEL_STRING=track_pha,/DATA,/OVERPLOT),NAME='track')                                   
IF KEYWORD_SET(section)     THEN sprof  = update_symbol_layer(SYMBOL(sp_lon,sp_lat,'+',/DATA,/OVERPLOT),NAME='section')                                     
IF NOT KEYWORD_SET(iso)     THEN cb     = COLORBAR(TARGET=map_field2, /BORDER_ON, TITLE='Phase',TAPER=2,$
                                                     TICKNAME=STRING(isolevels2,FORMAT=col_format),$
                                                     TEXTPOS=0,FONT_SIZE=gen_font, $
                                                     POSITION=[p_pos2[0],p_pos2[1]-0.03,p_pos2[2],p_pos2[1]-0.01])
;#################################################################################
;############               PLOT SECTION PART               ######################
;#################################################################################
IF KEYWORD_SET(section) THEN BEGIN
 p_amp     = PLOT(xplot[ival],samp[ival],symref,/DATA,AXIS_STYLE=2,XRANGE=band,FONT_SIZE=red_font,$
                SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
                YTITLE='Amplitude',YMINOR=0,$
                POSITION=[p_pos[0],p_pos[3]+0.02,p_pos[2],p_pos[3]+0.12],/CURRENT)
 p_pha     = PLOT(xplot[ival],spha[ival],symref,/DATA,AXIS_STYLE=2,XRANGE=band,FONT_SIZE=red_font,$
                SYM_SIZE=symsize,SYM_COLOR=color_ref,SYM_FILLED=1,SYM_FILL_COLOR=color_ref,$
                YTITLE='Phase',YMINOR=0,$
                POSITION=[p_pos2[0],p_pos2[3]+0.02,p_pos2[2],p_pos2[3]+0.12],/CURRENT)
 t_section = TEXT(p_pos[2]+0.01,p_pos[3]+0.14,'SECTION ='+STRING(section,FORMAT=format),/NORMAL,FONT_SIZE=red_font,ALIGNMENT=0.0)                
ENDIF

IF KEYWORD_SET(mgr)   THEN smgr.order, /bring_to_front
IF KEYWORD_SET(mgr)   THEN sname.order, /bring_to_front
IF KEYWORD_SET(track) THEN strack.order, /bring_to_front

  ;place la legende et un sous-titre
range_text = "Map Range                 : Amplitude ["+STRING(FORMAT=amp_format,full_amp[0])+' <-> '+STRING(FORMAT=amp_format,full_amp[1])+$
             "] &  Phase ["+STRING(FORMAT=pha_format,full_pha[0])+' <-> '+STRING(FORMAT=pha_format,full_pha[1])+"]"
IF NOT KEYWORD_SET(no_header) THEN subtitle1  = text(0.01, 0.02, range_text, /normal, font_size=red_font)
IF (N_PARAMS() EQ 2) THEN BEGIN
diff_text = "Amplitude Mean Difference : "+STRING(FORMAT=amp_format,MEAN(atlas.wave.amp,/NAN)*scale)+$
             " &  Phase Mean Difference : "+STRING(FORMAT=pha_format,MEAN(atlas.wave.pha,/NAN))
subtitle2  = text(0.01, 0.04, diff_text, /normal, font_size=red_font)
ENDIF

w.refresh
   
IF KEYWORD_SET(output) THEN BEGIN
 w.Save, output, RESOLUTION=resolution
 print,output
ENDIF  
; old verions with image location

;map_field    d = IMAGE(BYTSCL(isofield,MIN=isorange[0],MAX=isorange[1],/NAN),GRID_UNITS='degrees',ASPECT_RATIO=aspect_ratio,/CURRENT,$
;                            POSITION=p_pos,AXIS_STYLE=0,RGB_TABLE=rgb,HIDE=map_hide)


;map_field2   = IMAGE(BYTSCL(isofield2,MIN=isorange2[0],MAX=isorange2[1],/NAN),$
;                MAP_PROJECTION=proj,LIMIT=limit,/CURRENT,$
;                GRID_UNITS='deg',IMAGE_LOCATION=loc,IMAGE_DIMENSIONS=dim,$
;                ZRANGE=[isorange2[0],isorange2[1]],$
;                POSITION=p_pos2,AXIS_STYLE=2,$
;                RGB_TABLE=rgb,HIDE=map_hide)
 ;change grid properties.
;m1.MAPGRID.BOX_COLOR         = 'gray'
;m1.MAPGRID.FONT_STYLE        = 2 ;0:normal/1:bold/2:italic/3:bold&italic
;m1.MAPGRID.LINESTYLE         = 2 ;0:normal/2:dash/6:none
;m1.MAPGRID.grid_longitude    = map_gridlon
;m1.MAPGRID.grid_latitude     = map_gridlat
;map_field    = IMAGE(BYTSCL(isofield,MIN=isorange[0],MAX=isorange[1],/NAN),$
;                            MAPPROJECTION=m1,MAPGRID=m1.mapgrid,/CURRENT,$
;                            ZRANGE=[isorange[0],isorange[1]],$
;                            POSITION=p_pos,AXIS_STYLE=0,$
;                            RGB_TABLE=rgb,HIDE=map_hide)
;map_isofield = CONTOUR(isofield ,lon,lat,GRID_UNITS='degrees',/OVERPLOT,$
;                            MAPPROJECTION=m1,MAPGRID=m1.mapgrid,$
;                            C_VALUE=isolevels,/C_LABEL_SHOW,FONT_SIZE=iso_font,LABEL_FORMAT='(I4)',C_COLOR=iso_color,$
;                            C_THICK=iso_thick)
; ;dimension et localisation de l'image
;dim_lon = MAX(lon,/NAN)-MIN(lon,/NAN)  ;dimension de l'image en degre
;dim_lat = MAX(lat,/NAN)-MIN(lat,/NAN)
;dim     = [dim_lon,dim_lat]
;loc     = [MIN(lon,/NAN),MIN(lat)]     ;localisation de l'image
END
