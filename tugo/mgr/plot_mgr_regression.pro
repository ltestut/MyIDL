FUNCTION plot_mgr_regression, mgr_x, mgr_y, wave=wave, scale=scale, $
                              amp_range=amp_range,pha_range=pha_range,$
                              selection=selection ,$
                              head_title=head_title,$
                              output=output

; program to plot a regression plot of 2 mgr for amplitude and phase 
; mgr should have been reduce to the same number before plotting
; selection  : give a hash containing ('color',index)


 ;title, legend and presentation(transpose(rgb))[*,256]
proj_embed   = 'Geographic'
gen_font     = 12                ;general font_size
x_title      = 'OBSERVATION'
y_title      = 'MODEL'
 ;color choice
color_ref    = 'Dark Grey'      ;color for the ref circle
color_1      = 'Royal Blue'     ;color for the correlation lines and labels
color_2      = 'Grey'           ;color for the rms circle and labels
color_3      = 'Dark Orange'    ;color for the rms circle and labels
color        = [color_ref,color_1,color_2,color_3]
  
IF NOT KEYWORD_SET(scale)      THEN scale        = 100.            ;defaut scale
IF NOT KEYWORD_SET(wave)       THEN wave         = 'M2'            ;defaut wave
IF NOT KEYWORD_SET(head_title) THEN head_title   = 'Regression'
IF KEYWORD_SET(selection)      THEN color_selection = selection.Keys()
 
mgr1   =  where_mgr(mgr_x,wave=wave)
mgr2   =  where_mgr(mgr_y,wave=wave)

nd     = N_ELEMENTS(mgr1.name)
lon    = mgr1.lon
lat    = mgr1.lat
a1     = FLTARR(nd) & p1 = FLTARR(nd) 
a2     = FLTARR(nd) & p2 = FLTARR(nd)
a1     = mgr1.amp*scale & p1 = mgr1.pha
a2     = mgr2.amp*scale & p2 = mgr2.pha
glimit  = get_mgr_limit(mgr1)
a_range = [MIN(a1)<MIN(a2),MAX(a1)>MAX(a2)]
p_range = [0,360] ;[MIN(p1)<MIN(p2),MAX(p1)>MAX(p2)]
IF KEYWORD_SET(amp_range) THEN a_range=amp_range
IF KEYWORD_SET(pha_range) THEN p_range=pha_range

;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  = 1200
ysize  =  800
w      = window(dimensions=[xsize,ysize])
w.refresh, /disable

t        = TEXT(0.45,0.7,head_title,/NORMAL,$
            TARGET=w,$
            ALIGNMENT=0.0,FONT_SIZE=gen_font)

m        = MAP(proj_embed,LIMIT=change2idllimit(glimit),POSITION=[0.1,0.7,0.45,0.9],LABEL_SHOW=0,/CURRENT)
c        = MAPCONTINENTS(FILL_COLOR="antique white",/COUNTRIES)
p        = PLOT(lon,lat,/DATA, AXIS_STYLE=1,LINESTYLE=6,SYMBOL='+',/OVERPLOT)
IF KEYWORD_SET(selection) THEN FOR i=0,selection.count()-1 DO p = PLOT(lon[selection[color_selection[i]]],lat[selection[color_selection[i]]],$
          /DATA, AXIS_STYLE=1,LINESTYLE=6,SYMBOL='+',COLOR=color_selection[i],/OVERPLOT)

 ; plot amplitude regression
p_amp    = PLOT(a1,a2,'o',TITLE=wave+' AMPLITUDE',FONT_SIZE=gen_font,$
                POSITION=[0.05,0.2,0.45,0.6],/CURRENT,$
                COLOR=color_ref,$
                XRANGE=a_range,YRANGE=a_range,$
                XTITLE='OBSERVATION',YTITLE='MODEL',$
                XTICKFONT_SIZE=10,YTICKFONT_SIZE=10)
poly_amp = POLYGON([a_range[0],a_range[1],a_range[1],a_range[0]],[a_range[0],a_range[1],a_range[0],a_range[0]],$
                    /DATA,TARGET=p_amp,FILL_BACKGROUND=0) 
        ; color selected station
        IF KEYWORD_SET(selection) THEN FOR i=0,selection.count()-1 DO psa = SYMBOL(a1[selection[color_selection[i]]],a2[selection[color_selection[i]]],'circle',/DATA,$
                 SYM_SIZE=1.0,SYM_THICK=2.0,SYM_COLOR=color_selection[i],/OVERPLOT)

 ;plot phase regression 
p_pha    = PLOT(p1,p2,'o',TITLE=wave+' PHASE',FONT_SIZE=gen_font,$
               POSITION=[0.55,0.2,0.95,0.6],/CURRENT,$
               COLOR=color_ref,$
               XRANGE=p_range,YRANGE=p_range,$
               XTITLE=x_title,YTITLE=y_title,$
               XTICKVALUES=INDGEN(6)*60,YTICKVALUES=INDGEN(6)*60,$
               XTICKFONT_SIZE=10,YTICKFONT_SIZE=10)
poly_pha = POLYGON([p_range[0],p_range[1],p_range[1],p_range[0]], [p_range[0],p_range[1],p_range[0],p_range[0]], $
                   /DATA,TARGET=p_pha,FILL_BACKGROUND=0);, $
        ; color selected station
          IF KEYWORD_SET(selection) THEN FOR i=0,selection.count()-1 DO psp = SYMBOL(p1[selection[color_selection[i]]],p2[selection[color_selection[i]]],'circle',/DATA,$
                 SYM_SIZE=1.0,SYM_THICK=2.0,SYM_COLOR=color_selection[i],/OVERPLOT)

;p_samp.order,/BRING_TO_FRONT
;poly_amp.order, /SEND_TO_BACK
;poly_pha.order, /SEND_TO_BACK
w.refresh
IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=120
ENDIF
RETURN,w
END