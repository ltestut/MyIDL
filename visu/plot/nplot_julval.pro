FUNCTION update_plot_layer, layer, name=name 
; function to configure the symbol plot and update
CASE (name) OF
  'p1'   : BEGIN
           layer.COLOR               = 'black'
           layer.THICK               = 1.0
 
  END
  'p2'    : BEGIN
           layer.COLOR               = 'red'
  END
  'p3'    : BEGIN
           layer.COLOR               = 'red'
  END

  'trend' : BEGIN
           layer.LINESTYLE           = 0
           layer.COLOR               = 'gray'
           layer.THICK               = 2.
  END
ENDCASE

;LINESTYLE
;0   'solid' or '-'(dash)
;1   'dot' or ':'(colon)
;2   'dash' or '--' (double dashes)
;3   'dash dot' or '-.'
;4   'dash dot dot dot' or '-:'
;5   'long dash' or '__' (double underscores)
;6   'none' or ' ' (space)
RETURN,layer
END

FUNCTION nplot_julval, st, st2, st3, st4, st5,$
                 tmin=tmin, tmax=tmax,  scale=scale, no_info=no_info, trend=trend, $
                 raxis=raxis,$ 
                 output=output, resolution=resolution, buffer=buffer, ext=ext, _EXTRA=_EXTRA
                 
IF NOT KEYWORD_SET(scale)      THEN scale=1.
IF NOT KEYWORD_SET(resolution) THEN resolution=150
IF NOT KEYWORD_SET(ext)        THEN ext='png'

 ;gestion des dates de debut et fin et de l'axe des temps
dmin = MIN(st.jul,/NAN,MAX=dmax)               ;calcul des dates min et max de la structure
IF KEYWORD_SET(tmin) THEN dmin=cal2jul(tmin)   ;
IF KEYWORD_SET(tmax) THEN dmax=cal2jul(tmax)
date_label=default_time_axis(tmin, tmax, dmin, dmax) ;renvoie le date_label par defaut
;date_label=LABEL_DATE(DATE_FORMAT = ['%'])


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;creation de la fenetre graphique
xsize = 1200
ysize = 700
csize = 12.          ;texte size for the cartouche
cname = "Helvetica"  ;texte font name for the cartouche
IF KEYWORD_SET(buffer) THEN w     = window(dimensions=[xsize,ysize],/BUFFER) ELSE w = window(dimensions=[xsize,ysize])

pos=[0.15,0.35,0.95,0.90]
IF KEYWORD_SET(no_info) THEN pos=[0.15,0.15,0.95,0.90]

p        = update_plot_layer(PLOT(st.jul, st.val*scale,/CURRENT,/ANTIALIAS,$
           XRANGE=[dmin,dmax],POSITION=pos,XTICKFORMAT='LABEL_DATE',XTICKUNITS=['Year'],XTICKINTERVAL = 1.,$
           $            
           _EXTRA=_EXTRA),NAME='p1')


IF NOT KEYWORD_SET(no_info) THEN BEGIN
 info      = info_st(st,tmin=tmin,tmax=tmax,SCALE=scale)
 xinfo     = REPLICATE(0.1,N_ELEMENTS(info.str))
 yinfo     = 0.25-FINDGEN(N_ELEMENTS(info.str))*0.05
 cartouche = text(xinfo, yinfo, info.str, FONT_NAME=cname,FONT_SIZE=csize, FONT_COLOR='black',/NORMAL)
ENDIF

IF KEYWORD_SET(trend) THEN BEGIN
 lin_fit  = info_st(st,tmin=tmin,tmax=tmax,SCALE=scale,/fit)
 pfit     = update_plot_layer(PLOT(st.jul,lin_fit,/CURRENT,/OVERPLOT),NAME='trend')
ENDIF

; ajout de courbe supplementaire
IF (N_ELEMENTS(st2) GT 0) THEN BEGIN
  p2  = update_plot_layer(PLOT(st2.jul,st2.val*scale,/CURRENT,/OVERPLOT),NAME='p2')
  IF NOT KEYWORD_SET(no_info) THEN BEGIN
     info       = info_st(st2,tmin=tmin,tmax=tmax,SCALE=scale)
     xinfo      = REPLICATE(0.1,N_ELEMENTS(info.str))
     yinfo      = 0.225-FINDGEN(N_ELEMENTS(info.str))*0.05
     cartouche2 = text(xinfo, yinfo, info.str, FONT_NAME=cname,FONT_SIZE=csize, FONT_COLOR='blue',/NORMAL)
  ENDIF
  IF KEYWORD_SET(trend) THEN BEGIN
     lin_fit2  = info_st(st2,tmin=tmin,tmax=tmax,SCALE=scale,/fit)
     pfit      = update_plot_layer(PLOT(st2.jul,lin_fit2,/CURRENT,/OVERPLOT),NAME='trend')
  ENDIF
ENDIF
IF (N_ELEMENTS(st3) GT 0) THEN p3  = update_plot_layer(PLOT(st3.jul,st3.val*scale,/CURRENT,/OVERPLOT),NAME='p3')

IF KEYWORD_SET(output) THEN BEGIN
 w.Save, output+'.'+ext, RESOLUTION=resolution
 print,output
ENDIF  

RETURN,p
END