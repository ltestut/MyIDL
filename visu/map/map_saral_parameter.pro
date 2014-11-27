FUNCTION define_color
;define used color
col=DICTIONARY()
col.ocean   = 'royal blue'
col.land    = 'red' ;'slate gray'
col.starpt  = 'dark orange'
col.mrg     = 'plum'
col.dist    = 'purple' ;'gainsboro'       ;color of the distance axis
RETURN,col
END

FUNCTION unref_copy,original,noval=noval
; make a true (unreferenced) copy of the hash
; /NOVAL  : doesn't copy the parameter value
cp      = {val:DICTIONARY(),att:DICTIONARY(),info:DICTIONARY()}
IF NOT KEYWORD_SET(noval) THEN cp.val=(original.val)[*]
cp.att    = (original.att)[*]
cp.info   = (original.info)[*]
RETURN,cp
END

FUNCTION saral_user_defined_list
   ;compute some user-defined quantities
   user = ORDEREDHASH('range_c','Range correction',$
      'c_range','Range corrected',$
      'c_range','Range corrected',$
      'ssh','Range corrected',$
      'gotide','Range corrected',$
      'raw_ssh',HASH('unit','unit','legend','legend','comment','comment'))
   RETURN,user
END


FUNCTION test_saral_parameter_type,sat,para=para,hf=hf,silent=silent
   ; test the parameter type either native or user defined
   test = DICTIONARY()
   user = saral_user_defined_list()
   IF NOT KEYWORD_SET(para) THEN STOP,'Need to choose a parameter !!'
   native = WHERE(sat.val.keys() EQ para,/NULL) ; test if para is native
   IF native NE !NULL THEN BEGIN      ; if para is native
      test.exist  = 1
      test.native = 1
      test.hf     = STRMATCH(para, '*40hz', /FOLD_CASE)
   ENDIF ELSE BEGIN
      compound = WHERE(user.keys() EQ para,/NULL)
      IF compound NE !NULL THEN BEGIN ; if para is user defined
         test.exist  = 1
         test.native = 0
         IF KEYWORD_SET(hf) THEN test.hf=1 ELSE test.hf=0
      ENDIF ELSE BEGIN
         test.exist  = 0
         test.native = 0
         test.hf     = 0
      ENDELSE
   ENDELSE
   ; verbose mode
   IF test.exist THEN BEGIN
      IF NOT KEYWORD_SET(SILENT) THEN BEGIN
         PRINT," INPUT PARAMETER :",para
         IF test.native THEN PRINT,"  + is native" ELSE $
            PRINT,"  + is user_defined "
         IF test.hf     THEN PRINT,"  + is hf" ELSE $
            PRINT,"  + is not hf "
      ENDIF
   ENDIF ELSE BEGIN
      PRINT," /!\ PARAMETER DOES NOT EXIT !!"
      RETURN,0
   ENDELSE
   RETURN,test
END


FUNCTION attribut_tag,sat,para=para,verbose=verbose
;retrieve the attribut values for native parameter
attag  =DICTIONARY()
attag.fillvalue    = (sat.att[para])[0]
attag.scale_factor = (sat.att[para])[1]
attag.add_offset   = (sat.att[para])[2]
attag.units        = (sat.att[para])[3]
attag.std_name     = (sat.att[para])[4]
attag.long_name    = (sat.att[para])[5]
attag.comment      = (sat.att[para])[6]
IF KEYWORD_SET(verbose) THEN print,attag
RETURN,attag 
END

FUNCTION text_tag,sat,para=para, hf=hf
dfmt = '(C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2))'
tag  =DICTIONARY()
IF hf THEN BEGIN  ; compute start and end time
 ; find the valid time index  
 itimevalid = WHERE(sat.val['time_40hz'] NE (sat.att['time_40hz'])[0],cvalid)         
 tstart = JULDAY(1,1,2000,0,0,0)+MIN((sat.val['time'])[itimevalid])/(3600.*24.)   
 tend   = JULDAY(1,1,2000,0,0,0)+MAX((sat.val['time'])[itimevalid])/(3600.*24.)   
 tag.mtitle = '40 Hz along-track data'
ENDIF ELSE BEGIN
 tstart = JULDAY(1,1,2000,0,0,0)+(sat.val['time'])[0]/(3600.*24.) ; start 1hz
 tend   = JULDAY(1,1,2000,0,0,0)+(sat.val['time'])[-1]/(3600.*24.); end 1hz
 tag.mtitle = '1 Hz along-track data'
ENDELSE
pass             = STRING(FORMAT='(I04)',sat.info['pass_number'])
cycle            = STRING(FORMAT='(I03)',sat.info['cycle_number'])
tag.track_info   = sat.info['mission_name']+' / '+sat.info['title']+$
                     ' Pass : '+pass+' / Cycle : '+cycle
tag.time='From  '+STRING(tstart,FORMAT=dfmt)+'   to  '+STRING(tend,FORMAT=dfmt)
tag.ref ='Reference '+' Ref:'+sat.info['references']
tag.lencut = 80
tag.ptitle = (sat.att[para])[3]+' : '+(sat.att[para])[4]
tag.fsize  = 6 ; text font size for the legend                        
RETURN,tag
END

FUNCTION get_stat_para,val
; function to return statistical information about a parameter 
ifmt= '(F9.3)'
info= [STRING('-[Ndata=',STRCOMPRESS(STRING(N_ELEMENTS(val)),/REMOVE_ALL),']',$
  '-[Min=',STRCOMPRESS(STRING(MIN(val,/NAN),FORMAT=ifmt),/REMOVE_ALL),']',$
  '-[Max=',STRCOMPRESS(STRING(MAX(val,/NAN),FORMAT=ifmt),/REMOVE_ALL),']',$
  '-[range=',STRCOMPRESS(STRING(MAX(val,/NAN)-MIN(val,/NAN),FORMAT=ifmt),$
                         /REMOVE_ALL),']'),$
STRING('-[Mean=' ,STRCOMPRESS(STRING(MEAN(val,/NAN),FORMAT=ifmt),$
                              /REMOVE_ALL),']',$
  '-[Std=',STRCOMPRESS(STRING(STDDEV(val,/NAN),FORMAT=ifmt),/REMOVE_ALL),']',$
  '-[Med=',STRCOMPRESS(STRING(MEDIAN(val),FORMAT=ifmt),/REMOVE_ALL),']')]
RETURN,info
END

FUNCTION map_saral_direct_graphic, data
bang_p = !P & !P.MULTI=[0,1,3] & !P.FONT=0 & !P.CHARSIZE=1.5 & !P.CHARTHICK=1
IF (N_ELEMENTS(data.lon) GT 500) THEN sym=3    ELSE sym=1 ;
IF (N_ELEMENTS(data.lon) GT 500) THEN fprint=0 ELSE fprint=1 ;no footprint for large data

map_pos   =[0.1,0.1,0.5,0.5]
footp     = 0.2

;TODO find some nice way to handle color code
MAP_SET, /MERCATOR, /ISOTROPIC,POSITION=map_pos,$
                                         LIMIT=change2idllimit(data.limit)
MAP_GRID,/BOX_AXES,LABEL=2,LINESTYLE=2, COLOR=cgColor("dark gray",100)
MAP_CONTINENTS,/COASTS,/OVERPLOT,FILL_CONTINENTS=1,_EXTRA=_EXTRA,$
                                        COLOR=cgColor("light gray",100)
tvcircle, footp, (data.lon)[0],(data.lat)[0],/DATA,/FILL,$
                                        COLOR=cgcolor("orange",252)
IF fprint THEN tvcircle, footp, data.lon, data.lat, /DATA  ; plot footprint on map
PLOTS, data.lon, data.lat, psym=sym         ; plot point on map
;;TODO Pb when to many points and 
IF (data.cland GE 1) THEN BEGIN ; red colored for land footprint and pts
IF fprint THEN tvcircle, footp,(data.lon)[data.land],(data.lat)[data.land],$
                                              COLOR=cgcolor("red",253), /DATA
  PLOTS,(data.lon)[data.land],(data.lat)[data.land],psym=sym,$
                                              COLOR=cgcolor("red",253)
ENDIF
; plot along track data
PLOT,data.lat,data.val,xtitle='lat',ytitle=data.unit,title=data.ptitle,$
      ystyle=3,yrange=data.range,$
      POSITION=[0.2,0.6,0.9,0.9],psym=sym
IF (data.cland GT 1) THEN OPLOT,(data.lat)[data.land],$
                       (data.val)[data.land],COLOR=cgcolor("red",253),psym=sym
XYOUTS,0.1,0.95 ,data.track_info,/NORMAL
XYOUTS,0.2,0.56,(data.stat)[0],/NORMAL
XYOUTS,0.2,0.54,(data.stat)[1],/NORMAL
 ; plot bathy profile
;IF NOT data.hf THEN PLOT,data.lat,bathy,xtitle='latitude',ytitle='m',$
;      title='Bathymetry profile',$
;      ystyle=3,$
;      POSITION=[0.55,0.1,0.9,0.4]

   ; print the comment under the alongtrack plot and the time tag
FOR i=0,(STRLEN(data.comment)/data.lencut)+1 DO XYOUTS,0.5,0.55-i*0.02,$
        STRMID(data.comment,data.lencut*i,data.lencut),/NORMAL
XYOUTS,0.2,0.05,data.time,/NORMAL
XYOUTS,0.5,0.05,'+ rad_surf_type = land',COLOR=cgcolor("red",253),/NORMAL
XYOUTS,0.8,0.05,'First point of track'  ,COLOR=cgcolor("orange",252),/NORMAL
!P = bang_p
RETURN,1
END

FUNCTION reduce_to_limit, sat_in,limit=limit
; return the reduced sat structure and add some keyword
sat      = unref_copy(sat_in,/NOVAL)         ; init unref copy of hash (no val)
lon1hz   = sat_in.val['lon']*(sat_in.att['lon'])[1]  ; apply scale factor
lat1hz   = sat_in.val['lat']*(sat_in.att['lat'])[1]  ; apply scale factor
IF NOT KEYWORD_SET(limit) THEN limit=[MIN(lon1hz),MAX(lon1hz),$
                                      MIN(lat1hz),MAX(lat1hz)]
id = WHERE(lon1hz GT limit[0] AND lon1hz LT limit[1] AND $
           lat1hz GT limit[2] AND lat1hz LT limit[3],count)
arc_azimuth,lon1hz[id],lat1hz[id],lon1hz[id[0]],lat1hz[id[0]],$
            dist1Hz,az1hz,/METERS
IF sat.info.native THEN BEGIN
 sl      = SIZE(sat_in.val['lon_40hz'])               ; size of lon array
 ulon    = REFORM(sat_in.val['lon_40hz'],sl[1]*sl[2]) ; unfold lon array
 ulat    = REFORM(sat_in.val['lat_40hz'],sl[1]*sl[2]) ; unfold lat array
 lon40hz = ulon*(sat_in.att['lon_40hz'])[1]           ; apply scale factor
 lat40hz = ulat*(sat_in.att['lat_40hz'])[1]           ; apply scale factor
 idhf    = WHERE(lon40hz GT limit[0] AND lon40hz LT limit[1]$
             AND lat40hz GT limit[2] AND lat40hz LT limit[3],counthf)
 arc_azimuth,lon40hz[idhf],lat40hz[idhf],lon40hz[idhf[0]],lat40hz[idhf[0]],$
             distance,az,/METERS
ENDIF
 ; reduce the hash table to the given limit for all parameter
IF (count GE 1) THEN FOREACH key,(sat_in.val).keys() DO BEGIN                       
  skey = SIZE(sat_in.val[key]) ; parameter size (1 or 2 for hf data)
  IF (skey[0] EQ 2) THEN sat.val[key]=$
                               (REFORM(sat_in.val[key],skey[1]*skey[2]))[idhf]$
                    ELSE sat.val[key]=(sat_in.val[key])[id]
ENDFOREACH
 ; add keywords to the info dictionary
sat.info.d1hz  = dist1hz
sat.info.d40hz = distance
sat.info.limit = limit
RETURN,sat
END

FUNCTION compute_saral_native_para,sat,para=para,hf=hf,value=value
; function to compute a native parameter according to formula :
;        value = add_offset + scale_factor*parameter

;;TODO
;this routine is a mess ! absolutely not clear and efficient
; should be completely re-think.

data = DICTIONARY()  ;dictionary for output data
If NOT KEYWORD_SET(hf) THEN hf=0
att  = attribut_tag(sat,PARA=para)    ; get the attribut value for this para
tag  = text_tag(sat,PARA=para,hf=hf)  ; get some legend information

IF (sat.att[para])[0] THEN inan  = WHERE(sat.val[para] EQ (sat.att[para])[0],$
                                         cnan)     ; get the non-valid index
IF (sat.att[para])[1] THEN scale = (sat.att[para])[1] ELSE scale=1.                 
IF (sat.att[para])[2] THEN offset= (sat.att[para])[2] ELSE offset=0          
val=offset+scale*(sat.val[para])                   ; compute the value
IF KEYWORD_SET(value) THEN RETURN,val
IF (cnan GE 1)        THEN val[inan]=!VALUES.F_NAN ; flag the _FillValue
IF KEYWORD_SET(hf) THEN BEGIN
   data.lon   = sat.val['lon_40hz']*(sat.att['lon_40hz'])[1]
   data.lat   = sat.val['lat_40hz']*(sat.att['lat_40hz'])[1]
   data.hf    = 1
   surftype   = INTERPOL(sat.val['rad_surf_type'],sat.info.d1hz,sat.info.d40hz)
   data.ocean  = WHERE(FLOOR(surftype) EQ 0) 
   data.land   = WHERE(FLOOR(surftype) EQ 1,cland)
   data.cland  = cland
ENDIF ELSE BEGIN
   data.lon  = sat.val['lon']*(sat.att['lon'])[1]
   data.lat  = sat.val['lat']*(sat.att['lat'])[1]
   data.hf   = 0
   data.land = WHERE(sat.val['rad_surf_type'] EQ 1,cland,COMPLEMENT=iocean)
   data.ocean = iocean
   data.cland = cland
ENDELSE
 
ifmt = '(F9.3)'
st   = STRING(STRING(para,FORMAT='(A-21)')+$
'-[Min/Max='+STRCOMPRESS(STRING(MIN(val,/NAN),FORMAT=ifmt),/REMOVE_ALL)+$
'/'+STRCOMPRESS(STRING(MAX(val,/NAN),FORMAT=ifmt),/REMOVE_ALL)+']'+$
'-[Mean/Rms='+STRCOMPRESS(STRING(MEAN(val,/NAN),FORMAT=ifmt),/REMOVE_ALL)+$
'/'+STRCOMPRESS(STRING(STDDEV(val,/NAN)*100.,FORMAT=ifmt),/REMOVE_ALL)+'cm]'+$
'-[Range='+STRCOMPRESS(STRING((MAX(val,/NAN)-MIN(val,/NAN))*1000.,FORMAT=ifmt)$
,/REMOVE_ALL)+' mm]')
;;TODO simplify the data extraction 
data.limit   = sat.info.limit
data.d1hz    = sat.info.d1hz 
data.d40hz   = sat.info.d40hz 
data.info    = st
data.stat    = get_stat_para(val)
data.val     = val                  ;value over ocean
data.range   = [MIN(data.val,/NAN),MAX(data.val,/NAN)] 
data.unit    = att.units
data.comment = att.comment
data.ptitle  = tag.ptitle
data.time    = tag.time
data.track_info = tag.track_info
data.lencut  = tag.lencut
data.bathy   = sat.val['Bathymetry']
RETURN,data
END



FUNCTION compute_saral_user_parameter, sat, para=para
; compute some important parameter
data       = DICTIONARY()
hfdata     = DICTIONARY()
plist=ORDEREDHASH('alt'       ,  'alt',   $
                 'range'     ,  'range',   $
                 'iono'      ,  'iono_corr_gim',   $
                 'tropo_dry'  ,  'model_dry_tropo_corr',   $
                 'tropo_wet'  ,  'model_wet_tropo_corr',   $
                 'rad_wet'    ,  'rad_wet_tropo_corr',   $
                 'ssb'        ,  'sea_state_bias',   $
                 'stide'      ,  'solid_earth_tide',   $
                 'ptide'      ,  'pole_tide',   $
                 'otide'      ,  'ocean_tide_sol1',   $
                 'ib'         ,  'inv_bar_corr',   $
                 'ib'         ,  'hf_fluctuations_corr',   $
                 'geoid'      ,  'geoid',   $
                 'mss'        ,  'mean_sea_surface',   $
                 'bathy'      ,  'bathymetry')
FOREACH key,plist.keys() DO IF sat.val.haskey(plist[key]) THEN $
   data[key]=compute_saral_native_para(sat,para=plist[key],/VAL)

val     = data.alt-data.range
info    = ''
comment = ''
CASE para OF
   'raw_ssh' :BEGIN
   data.val = data.alt-data.range-data.iono-data.tropo_dry-data.tropo_wet $
             -data.ssb-data.stide-data.ptide
   data.ptitle     = "Instantaneous SSH"
   data.mtitle     = "Main Title"
   data.comment    = 'SSH = Atlitude - Corrected_range - Iono_correction - Tropo_correction(wet+dry) - Sea_State_Bias - Tide(solid+pole)'
   data.info       = 'test'
   data.stat    = get_stat_para(data.val)
   data.range   = [MIN(data.val,/NAN),MAX(data.val,/NAN)]
   data.unit    = ''
   data.time    = 'tag.time'
   data.track_info = 'tag.track_info'
   data.lencut  = 80
              END
'alt-range' :BEGIN
END
ENDCASE


data.limit   = sat.info.limit
data.d1hz    = sat.info.d1hz
data.d40hz   = sat.info.d40hz
data.lon     = sat.val.lon
data.lat     = sat.val.lat
data.land = WHERE(sat.val['rad_surf_type'] EQ 1,cland,COMPLEMENT=iocean)
data.ocean = iocean
data.cland = cland
data.hf    = 0  

RETURN,data
END
;##############################################################################
;###############################  MAIN PROGRAM  ###############################
;##############################################################################
PRO map_saral_parameter, sat_in,  $
           scale=scale, proj=proj,  $
           myrange=myrange, geoidrange=geoidrange,bathyrange=bathyrange,$
           ps=ps, png=png,output=output,$
           resolution=resolution,extension=extension, $
           computed=computed,mrg_loc=mrg_loc,$
           sym=sym,og=og,$
           buffer=buffer, _EXTRA=_EXTRA

;
; para='range'
;##############################################################################
;###################  DEFINITION PART : DEFINE&COMPUTE GRAPHIC VARIABLE  ######
;##############################################################################
IF NOT KEYWORD_SET(scale)       THEN scale=1.
IF NOT KEYWORD_SET(resolution)  THEN resolution=150
IF NOT KEYWORD_SET(extension)   THEN extension='png'
IF NOT KEYWORD_SET(proj)        THEN proj='MERCATOR'
col  = define_color() ;init the color selection
sat  = reduce_to_limit(sat_in,_EXTRA=_EXTRA)
test = test_saral_parameter_type(sat,_EXTRA=_EXTRA)
IF test.native THEN BEGIN
 data = compute_saral_native_para(sat,hf=test.hf,_EXTRA=_EXTRA)
ENDIF ELSE BEGIN
 IF test.hf THEN BEGIN
 ENDIF ELSE BEGIN
 data = compute_saral_user_parameter(sat,_EXTRA=_EXTRA)  ; compute some important parameter
 ENDELSE
ENDELSE
PRINT,FORMAT='(%"Limit : %6.2fE / %6.2fE / %6.2fN / %6.2fN")',data.limit
;IF (SIZE(sat_in.val[para],/N_DIMENSIONS) EQ 2) THEN hf=1 ELSE hf=0


;write_kml_footprint,clon=lon,clat=lat
;##############################################################################
;################  COMPUTATION PART : DEFINE&COMPUTE GRAPHIC VARIABLE #########
;##############################################################################
void  = map_saral_direct_graphic(data) ; rapid plot

IF KEYWORD_SET(myrange) THEN yrange=myrange        ; choose range
IF NOT KEYWORD_SET(bathyrange) THEN bathyrange = [MIN(data.bathy),10]                 

;##############################################################################
;###################### OBJECT GRAPHIC PART : BAKCGROUND ######################
;##############################################################################
IF KEYWORD_SET(og) THEN BEGIN
 xsize = 1200 & ysize = 800
 IF KEYWORD_SET(buffer) THEN w=WINDOW(dimensions=[xsize,ysize],/BUFFER)$
                        ELSE w=WINDOW(dimensions=[xsize,ysize])
;##############################################################################
;############################   MAP    ########################################
;##############################################################################
m=MAP(proj,LIMIT=change2idllimit(data.limit),HIDE=1,POSITION=[0.15,0.1,0.5,0.5],$
        TITLE="data.mtitle",/CURRENT) ;0:normal/1:bold/2:italic/3:bold&italic
g=MAPGRID(LABEL_POSITION=0,BOX_COLOR='gray',BOX_AXES=1,BOX_THICK=1,$
            LINESTYLE=1,COLOR='black',THICK=0.2,FONT_STYLE=0,FONT_SIZE=5,$
             ;LATITUDE_MIN =CEIL(limit[0]),LATITUDE_MAX =CEIL(limit[2]) ,$
             ;LONGITUDE_MIN=CEIL(limit[1]),LONGITUDE_MAX=FLOOR(limit[3]),$
             ;GRID_LATITUDE =0.1,GRID_LONGITUDE=0.1,$
             /CURRENT)
g.Order,/SEND_TO_BACK           
c=MAPCONTINENTS(FILL_COLOR='antique white',/CONTINENTS)
;;FIXME bubbleplot not working
;b=BUBBLEPLOT(sat.info.lon,sat.info.lat,MAGNITUDE=ABS(TS_DIFF(ypara,1)),$
;                                                            FILLED=0,/OVERPLOT)
 ; Add the first point on map
s=SYMBOL((data.lon)[0],(data.lat)[0],'o',/DATA,/OVERPLOT,$
          SYM_COLOR=col.starpt,SYM_SIZE=2,CLIP=0,/SYM_FILLED, $      
          LABEL_STRING='First pt of track',LABEL_FONT_SIZE=6,$
          LABEL_COLOR=col.starpt)
s=SYMBOL(data.lon,data.lat,'+',/DATA,SYM_COLOR=col.ocean,/OVERPLOT)                
IF NOT data.hf AND (data.cland GT 1) THEN $
    s=SYMBOL((data.lon)[data.land], (data.lat)[data.land],'+',$
      SYM_COLOR=col.land,/DATA, /OVERPLOT)
IF KEYWORD_SET(mrg_loc) THEN e=SYMBOL(mrg_loc.lon,mrg_loc.lat,5 ,$
                           SYM_COLOR=col.mrg, /SYM_FILLED,$
                           LABEL_STRING=mrg_loc.name,LABEL_FONT_SIZE=4,$
                           /DATA,/OVERPLOT)

;##############################################################################
;############################   PLOT   ########################################
;##############################################################################
p0 = PLOT(data.lat,data.bathy,AXIS_STYLE=0,XSTYLE=1,YRANGE=bathyrange,$
          /FILL_BACKGROUND,FILL_LEVEL=bathyrange[0],FILL_COLOR='gainsboro',$
          TRANSPARENCY=80,POSITION=[0.2,0.65,0.8,0.9],/CURRENT)
a  = AXIS('Y',AXIS_RANGE=bathyrange,LOCATION='right',TARGET=p0,$
          TITLE='Bathymetry (m)',COLOR='gainsboro')
 ; plot the parameter
p=PLOT(data.lat,data.val,SYMBOL='+',XSTYLE=1,XTITLE='Latitude',TITLE=data.ptitle,$
       YTITLE=data.unit,YRANGE=yrange,POSITION=[0.2,0.65,0.8,0.9],/CURRENT)
;IF (para EQ 'raw_ssh') THEN  p=PLOT(data.lat,data.geoid,COLOR='blue',$
;                                    LINESTYLE=5,/OVERPLOT) 
                                         
IF KEYWORD_SET(mrg_loc) THEN $
 pe = AXIS('X',LOCATION='bottom',color=mrg,text_color=mrg,text_orientation=0.,$
  tickfont_style=2,tickfont_size=4,tickname=mrg_loc.name,$
  tickvalues=mrg_loc.lat,ticklen=1.0,subticklen=0,TARGET=p)
  
;IF NOT data.hf THEN BEGIN
; p['axis3'].delete ; delete the right-axis to let room for bathy axis                                         
; IF (data.cland GT 1) AND (MAX(FINITE(yland)) GT 0) THEN p=PLOT(lat[iland],yland,$
;                                                              'r+',/OVERPLOT) 
;ENDIF
 ;plot the dist-axis if limit is provided
IF KEYWORD_SET(limit) THEN d=PLOT(data.distance/1000.,INDGEN(N_ELEMENTS(distance)),$
                                      /NODATA,XSTYLE=1,XTITLE='Distance (km)',$
                                          COLOR=col.dist,XTICKFONT_SIZE=8.,$
                                         POSITION=[0.2,0.57,0.8,0.65],/CURRENT)
;d['axis1'].delete
;d['axis2'].delete
;d['axis3'].delete
;##############################################################################
;############################ LEGEND  #########################################
;##############################################################################
t=TEXT(0.15,0.95,data.track_info, /NORMAL, TARGET=m,FONT_SIZE=10)
t=TEXT(0.52,0.48,'PARAMETER INFORMATION',/NORMAL,TARGET=m,FONT_SIZE=10) 
FOR i=0,(STRLEN(data.comment)/data.lencut)+1 DO t=TEXT(0.52,0.46-i*0.02, /NORMAL,$
    TARGET=m,STRMID(data.comment,data.lencut*i,data.lencut),FONT_SIZE=6)
t=TEXT(0.52,0.26,'PARAMETER MAIN STATISTICS',/NORMAL,TARGET=m,FONT_SIZE=10)
t=TEXT(0.52,0.22,'',STRING=info_para,/NORMAL,TARGET=m,FONT_STYLE=0,FONT_SIZE=8)
;IF (computed NE 'none') THEN tcorr = TEXT(0.52,0.01,'',/NORMAL,$
;                    STRING=corr_info.toarray(),FONT_SIZE=5,FONT_NAME='courier')
IF NOT data.hf THEN t=TEXT(0.1,0.05,'+ point over land ',/NORMAL,$
                        COLOR=col.land, TARGET=m,FONT_SIZE=tag.fsize)
IF NOT data.hf THEN t=TEXT(0.1,0.03,'+ point over ocean',/NORMAL, $
                         COLOR=col.ocean,TARGET=m,FONT_SIZE=tag.fsize)
t= TEXT(0.1,0.01,data.time, /NORMAL, TARGET=m,FONT_SIZE=tag.fsize)
t= TEXT(0.5,0.01,data.ref ,/NORMAL, TARGET=m,FONT_SIZE=tag.fsize)
IF KEYWORD_SET(output) THEN BEGIN
 save_file=output+'_'+pass+'_'+cycle+'.'+extension
 w.Save, save_file, RESOLUTION=resolution
 print,save_file
ENDIF
ENDIF
END
