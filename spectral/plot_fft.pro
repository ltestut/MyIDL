PRO plot_fft, st, st2, st3, title=title, ins=ins, tmin=tmin, tmax=tmax, tname=tname, tmark=tmark, output=output, $
                     wavegroup=wavegroup, data_info=data_info, _EXTRA=_EXTRA, amp=amp, format=format, ps=ps, png=png

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "plot_fft, st, title=title, ins=ins, tmin=0.1, tmax=20, tmark=[0.2,3.4,12], tname=['M2','S2','year'] "
 print, "              wavegroup='year', /data_info, /amp *y in amplitude*"
 print, "                        'month'"
 print, "                        'tide'"
 print, "                        'diurne'"
 print, "                        'semidiurne'"
 print, "                        'tiersdiurne'"
 print, "                        'quartdiurne'"
 print, "                        'sixiemediurne'"
 print, "                        'huitiemediurne'"
 print, 'INPUT:  st       --> de type fft'
 print, 'OUTPUT: fft.ps   --> de type {frq,prd,dse}'
RETURN
ENDIF
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map

; gestion du format de sortie
col           =  cgcolor('white',255) ;initialisation des couleurs de fond&premier plan 
bck_col       =  cgcolor('black',254)
output_format, col, bck_col, ps=ps, png=png, output=output, small=small
!P.REGION=[0.01,0.01,0.99,0.99]
!P.BACKGROUND = bck_col
!X.TICKLEN    = 1
!X.GRIDSTYLE  = 1   


IF (N_ELEMENTS(tmin) EQ 0) THEN tmin = 0.00001
IF (N_ELEMENTS(tmax) EQ 0) THEN tmax = MAX(st.prd,/NAN)
IF (N_ELEMENTS(format) EQ 0) THEN format = '(F8.6)'
IF (N_ELEMENTS(tmark) EQ 0 AND N_ELEMENTS(tname) EQ 0) THEN BEGIN
tmark=[tmin,tmax]
tname=[STRING(tmin,FORMAT=format),STRING(tmax)]
ENDIF

IF KEYWORD_SET(wavegroup) THEN BEGIN
CASE wavegroup OF
   'year':BEGIN
      tname=[string(tmark,FORMAT=format),'year','6m','month','week']
      tmark=[[tmark],8760,6*730,730,168]
      END
   'month':BEGIN
      tname=[string(tmark,FORMAT=format),'month','2w','week','3d']
      tmark=[[tmark],730,2*168,168,3.*24]
      END
   'longperiod':BEGIN
      tname=[string(tmark,FORMAT=format),'Msf','Mf']
      tmark=[[tmark],354.367,327.858]
      END
   'tide':BEGIN
      tname=[string(tmark,FORMAT=format),'M2','S2','N2','K1','K2','O1','2N2','Q1']
      tmark=[[tmark],12.42,12.,12.6576,23.9352,11.9664,25.8192,12.8712,26.868]
      END
   'diurne':BEGIN
      tname=[string(tmark,FORMAT=format),'K1','O1','Q1']
      tmark=[[tmark],23.9352,25.8192,26.868]
      END
   'semidiurne':BEGIN
      tname=[string(tmark,FORMAT=format),'M2','S2','N2','K2','2N2']
      tmark=[[tmark],12.42,12.,12.6576,11.9664,12.8712]
      END
   'tiersdiurne':BEGIN
      tab_cph=[44.0251728527,42.9271397886,43.4761563301,45.0,43.9430355748,45.0410686389,42.8450025107]				      
      tab_hour=360./tab_cph
      tname=[string(tmark,FORMAT=format),'mk3 ','2mk3','m3  ','s3  ','so3 ','sk3 ','mo3']
      tmark=[FLOAT([tmark]),[tab_hour]]
      END
   'quartdiurne':BEGIN
      tab_cph=[57.4238337401,57.9682084399,58.9841042198,59.0662415002,56.8794590399,58.4397295163,60.0,58.9841042138,60.0821372779]				      
      tab_hour=360./tab_cph
      tname=[string(tmark,FORMAT=format),'mn4','m4','ms4','mk4','n4','sn4','s4','3ms4','sk4']
      tmark=[FLOAT([tmark]),[tab_hour]]
      END    
   'sixiemediurne':BEGIN
      tab_cph=[86.4079379600,86.9523126599,87.4238337301,87.9682084277,88.0503457056,88.9841042138,89.0662414917]				      
      tab_hour=360./tab_cph
      tname=[string(tmark,FORMAT=format),'2mn6', 'm6  ','msn6','2Ms6','2Mk6','2sm6','msk6']
      tmark=[FLOAT([tmark]),[tab_hour]]
      END
   'huitiemediurne':BEGIN
      tab_hour=360./116.952312641
      tname=[string(tmark,FORMAT=format),'3ms8']
      tmark=[FLOAT([tmark]),tab_hour]
      END       
   ENDCASE
ENDIF

xr = [tmin,tmax]
tn = N_ELEMENTS(tmark)-1


ydata = st.psd & ymax  = st.psdmax
IF KEYWORD_SET(amp) THEN BEGIN
  ydata = st.amp & ymax  = st.ampmax
ENDIF
PLOT, st.prd, ydata , /DATA, _EXTRA=_EXTRA ,$
 title    = title,  subtitle = ''   ,$
 xtitle   = '',  ytitle   = ''   ,$
 xstyle   = 2 ,  ystyle   = 2    ,$
 xrange   = xr, yrange   = [0.,MAX(ydata,/NAN)],$
; position = [0.1,0.4,0.95,0.95]  ,$
 xticks=tn , xtickv=tmark , xtickname=tname ,$
 xticklen=1. , xgridstyle=1 ,$
 yticklen=1. , ygridstyle=1 ,$
 thick = 1   ,COLOR=col,$
 psym  = 10
;oplot, st.prd,   ydata, color=cgcolor('beige',100), thick=2, psym=10
;oplot, st.prdmax,ymax , color=cgcolor('red',101), psym=1, thick=2
tvlct, 255, 0, 0, (!D.TABLE_SIZE-2)
IF (N_ELEMENTS(st2) NE 0) THEN BEGIN
   y2data = st2.psd
   IF KEYWORD_SET(amp) THEN y2data = st2.amp
oplot, st2.prd,y2data, color=cgcolor('red',253), thick=2, psym=10
ENDIF
IF (N_ELEMENTS(st3) NE 0) THEN BEGIN
   y3data = st3.psd
   IF KEYWORD_SET(amp) THEN y3data = st3.amp
oplot, st3.prd,y3data, color=cgcolor('blue',252), thick=1, psym=10
ENDIF


IF KEYWORD_SET(data_info) THEN BEGIN
xinfo    = REPLICATE(0.1,N_ELEMENTS(st.info))
yinfo    = 0.35-FINDGEN(N_ELEMENTS(st.info))*0.02
XYOUTS,xinfo,yinfo,st.info,CHARSIZE=1.2,/NORMAL
ENDIF

;FIN : print,'OUTPUT ======>',output
IF ((N_ELEMENTS(ps) EQ 1) AND (N_ELEMENTS(ins) EQ 0)) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF
; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map
END
