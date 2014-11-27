PRO plot_along_track_ctoh,stx,cycle=cycle,limit=limit,$
                          d2coast=d2coast,myrange=myrange,allcycle=allcycle,$
                          enhance=enhance,tg=tg,$
                          _EXTRA=_EXTRA
; plot the along track parameter from the COTH netcdf data
; cycle=7 or cycle=[1,28,228]
; /D2COAST                       :use distance to coast as X-axis (defaut is latitude)
; /ALLCYCLE                      :plot all cycle
; enhance=[1,28]
IF NOT KEYWORD_SET(proj)        THEN proj='MERCATOR'
IF N_ELEMENTS(_EXTRA) THEN id  = WHERE(TAG_NAMES(_EXTRA) EQ 'HIRES',hires) ELSE hires=0

 ;set defaut
icyc = 0          ;by default plot the first cycle of the list
fbck = 1          ;by default fill the background to 0
lsty = '+k-1'     ;symbol = ,+,*,.,|,...
                  ;color  = k:black/r:red/w:white/b:blue/g:green/c:cyan/m:magenta/y:yellow
                  ;lstyle = -/solidline,:/dotted,--/dashed,-./dash-dot,-:/dash-dot-dot,__/long-dash,' '/no-line
elsty = '+r-2' 

 ;check bathy parameter and compute the bathy_range
 
IF KEYWORD_SET(allcycle) THEN cycle=stx.cycle 
IF KEYWORD_SET(allcycle) THEN lsty='.k--'

IF KEYWORD_SET(cycle) THEN BEGIN
  ncyc    = N_ELEMENTS(cycle)             ;number of cycle as input
  cyc_arr = INTARR(ncyc)                  ;init index array for valid cycle
  IF (ncyc GE 2) THEN fbck=0              ;if more than 2 cycle switch off the fill_background
  FOR i=0,ncyc-1 DO cyc_arr[i] = WHERE(stx.cycle EQ cycle[i],count) ;fill the index array of valid cycle
  nocyc = WHERE(cyc_arr EQ -1,count,COMPLEMENT=valid)               ;get the valid index => valid
  IF (N_ELEMENTS(valid) EQ 1 AND valid[0] EQ -1) THEN STOP,'No valid cycle' ELSE icyc  = cyc_arr[valid]
  IF (count GE 1) THEN PRINT,"Cycle(s) not found :",stx.cycle[cyc_arr[nocyc]]
  ncyc  = N_ELEMENTS(icyc)
ENDIF

IF KEYWORD_SET(enhance) THEN BEGIN
  necyc    = N_ELEMENTS(enhance)            ;number of cycles to be enhanced
  ecyc_arr = INTARR(necyc)                  ;init index array for valid enhanced-cycle
  FOR i=0,necyc-1 DO ecyc_arr[i] = WHERE(stx.cycle EQ enhance[i],count) ;fill the index array of valid cycle
  nocyc = WHERE(ecyc_arr EQ -1,count,COMPLEMENT=valid)                   ;get the valid index => valid
  IF (N_ELEMENTS(valid) EQ 1 AND valid[0] EQ -1) THEN STOP,'No valid cycle' ELSE iecyc  = ecyc_arr[valid]
  IF (count GE 1) THEN PRINT,"Cycle(s) to be enhanced :",stx.cycle[ecyc_arr[valid]]
  necyc  = N_ELEMENTS(iecyc)
ENDIF


IF KEYWORD_SET(limit) THEN BEGIN
  id     = WHERE(stx.pt.lon GT limit[0] AND stx.pt.lon LT limit[1] AND stx.pt.lat GT limit[2] AND stx.pt.lat LT limit[3],count)
  lon    = stx.pt[id].lon
  lat    = stx.pt[id].lat
ENDIF ELSE BEGIN
  lon    = stx.pt.lon
  lat    = stx.pt.lat
  limit  = [MIN(lon),MAX(lon),MIN(lat),MAX(lat)]
  id     = WHERE(stx.pt.lon GT limit[0] AND stx.pt.lon LT limit[1] AND stx.pt.lat GT limit[2] AND stx.pt.lat LT limit[3],count)
ENDELSE
IF (id[0] EQ -1) THEN STOP,"No data in the specified limit"

ptitle       = stx.pass
track_info   = stx.info+' / '+' Pass N°'+stx.pass+' Cycle='+STRJOIN(STRING(FORMAT='(I03)',stx.cycle[icyc]),'/')
IF KEYWORD_SET(allcycle) THEN track_info   = stx.info+' / '+' Pass N°'+stx.pass+' Cycle=ALL'
dmin         = MIN(stx.pt[id].jul[icyc],MAX=dmax,/NAN)
time_info    = STRING(FORMAT='("Start-End of passage  :",A-18," --> ",A-18)',print_date(dmin,/SINGLE),print_date(dmax,/SINGLE))

IF KEYWORD_SET(d2coast) THEN xabs=stx.pt[id].d2coast    ELSE xabs=lat
IF KEYWORD_SET(d2coast) THEN xtitle='Distance to coast' ELSE xtitle='Latitude'
m = MAP(proj,LIMIT=change2idllimit(limit),HIDE=1,POSITION=[0.15,0.1,0.5,0.5],TITLE=track_info,/CURRENT) ;0:normal/1:bold/2:italic/3:bold&italic
g = MAPGRID()
  ;LABEL_POSITION=0,BOX_COLOR='gray',BOX_AXES=1,BOX_THICK=1,LINESTYLE=1,COLOR='black',THICK=0.2,FONT_STYLE=0,FONT_SIZE=4,$
  ;LATITUDE_MIN =CEIL(limit[0]),LATITUDE_MAX =CEIL(limit[2]) ,$
  ;LONGITUDE_MIN=CEIL(limit[1]),LONGITUDE_MAX=FLOOR(limit[3]),$
  ;GRID_LATITUDE =0.1,GRID_LONGITUDE=0.1,$
  ;/CURRENT)
g.Order,/SEND_TO_BACK
c = MAPCONTINENTS(FILL_COLOR='antique white',/CONTINENTS,HIRES=hires)
s = SYMBOL(lon  ,  lat   ,'+' ,/DATA,  /OVERPLOT)                             ; Map ground track points

 
tide   = stx.pt[id].tide[icyc[0]]
dac    = stx.pt[id].dac[icyc[0]]

ypara      = stx.pt[id].dac[icyc[0]]+stx.pt[id].sla[icyc[0]]
yrange     = [MIN(ypara,/NAN),MAX(ypara,/NAN)]                                              ; compute the parameter range
xrange     = [MIN(xabs,/NAN),MAX(xabs,/NAN)]                                              ; compute the parameter range
IF KEYWORD_SET(myrange) THEN yrange=myrange                  ; choose range
 
p = PLOT(xabs,ypara,lsty,$
         TITLE=ptitle,XTITLE=xtitle,YTITLE=units,YRANGE=yrange,XRANGE=xrange,$
         FILL_BACKGROUND=fbgrd,FILL_LEVEL=0,FILL_COLOR='gainsboro',TRANSPARENCY=80,$
         POSITION=[0.2,0.65,0.8,0.9],/CURRENT)
         
         

;p = PLOT(xabs,ypara,/FILL_BACKGROUND,FILL_LEVEL=0 ,FILL_COLOR='black'   ,FILL_TRANSPARENCY=80,/OVERPLOT)
;p = PLOT(xabs,tide ,/FILL_BACKGROUND,FILL_LEVEL=0 ,FILL_COLOR='blue'  ,FILL_TRANSPARENCY=80,/OVERPLOT)
;p = PLOT(xabs,dac  ,/FILL_BACKGROUND,FILL_LEVEL=0 ,FILL_COLOR='orange',FILL_TRANSPARENCY=80,/OVERPLOT)

FOR i=1,ncyc-1 DO p=PLOT(xabs,stx.pt[id].sla[icyc[i]]+stx.pt[id].dac[icyc[i]],lsty,/OVERPLOT)

IF KEYWORD_SET(enhance) THEN BEGIN
 FOR i=0,N_ELEMENTS(enhance)-1 DO p=PLOT(xabs,stx.pt[id].sla[iecyc[i]]+stx.pt[id].dac[iecyc[i]],elsty,/OVERPLOT)
ENDIF


leg=TEXT(0.1,0.01,time_info,FONT_SIZE=6)
m.Refresh
END