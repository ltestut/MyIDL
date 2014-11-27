PRO plot_taylor_diag, tay_in, rms_circ=rms_circ, normalized=normalized, units=units,$
                                 n_model=n_model, $
                                 moy=moy,$
                                 _EXTRA=_EXTRA
; program to plot a Taylor Diagram from a taylor structure
; rms_circ
; /normalized

;#######################################################################
;######################### GRAPHICAL PART ##############################
;#######################################################################


 ;title, legend and presentation
tay          = select_taylor_pt(tay_in,_EXTRA=_EXTRA)  ;selec and copy the Taylor Structure to work on it 
head_title   = 'Taylor Diagram'
gen_font     = 12                ;general font_size
symsize      = 1.5               ;symbol size
symtrans     = 0                 ;symbol transparency

rms_ref      = tay_in.rms_ref    ;value of the reference rms
fmt_ref      = 'm2'              ;format of the reference rms :Magenta
cor_tab      = [0.0,0.1,0.5,0.6,0.8,0.9,0.95,1.0]   ;correlation label value to plot
angle        = ACOS(cor_tab)
fmt_cor      = '0k:'
rms_circ_def = [0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8]        ;defaut rms circle draw
fmt_rms      = '0k:'
fmt_diff     = '0k:'
 ;color choice
color_ref      = 'Magenta'      ;color for the ref circle
color_cor      = 'Royal Blue'   ;color for the correlation lines and labels
color_rms      = 'Dark Grey'  ;color for the rms circle and labels
color_rms_diff = 'Dark Orange'  ;color for the rms circle and labels



IF NOT KEYWORD_SET(rms_circ)  THEN rms_circ = rms_circ_def  ;defaut rms circle to plot
IF NOT KEYWORD_SET(units)     THEN units    = 'cm'          ;defaut units

IF KEYWORD_SET(normalized) THEN BEGIN
 head_title            = 'Normalized Taylor Diagram' 
 tay.rms_ref           = tay.rms_ref/rms_ref
 tay.model.pt.rms      = tay.model.pt.rms/rms_ref
 tay.model.pt.rms_diff = tay.model.pt.rms_diff/rms_ref
ENDIF
rms_circ = rms_circ*tay.rms_ref
IF NOT KEYWORD_SET(rms_range) THEN rms_range=[0,MAX(rms_circ)]


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  =  800
ysize  =  800
w      = window(dimensions=[xsize,ysize],$
                TITLE=head_title,FONT_SIZE=16)
w.refresh, /disable
t_head = TEXT([0.5,0.5],[0.87,0.84], $
               ['REF = '+tay.name,$
                '$\sigma_{obs} = $'+STRING(rms_ref,FORMAT='(F5.2)')+'  ('+units+')'], $
         TARGET=w,$
         COLOR=color_ref,FONT_SIZE=14,ALIGNMENT=0.5)                

 ;draw the correlation quarter circle and the axis label
p = POLARPLOT(REPLICATE(MAX(rms_range),90),RAD(INDGEN(90)),fmt_cor,$
               AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
               COLOR=color_cor,$
               XTITLE='!c root-mean-square'+'  ('+units+')',YTITLE='root-mean-square'+'  ('+units+')',$
               /CURRENT)
 ;draw the correlation line,the correlation label and the legend
FOR i=0,N_ELEMENTS(angle)-1 DO BEGIN
 p = POLARPLOT([0,MAX(rms_range)],[0,angle[i]],fmt_cor,$
        AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
        COLOR=color_cor,$
        /OVERPLOT)
 t = TEXT(MAX(rms_range)*1.05*COS(angle[i]),MAX(rms_range)*1.05*SIN(angle[i]),STRING(cor_tab[i],FORMAT='(F4.2)'),$
        TARGET=p,/DATA, ALIGNMENT=0.2,VERTICAL_ALIGNMENT=0.,ORIENTATION=deg(angle[i]), $
        COLOR=color_cor,$
        FONT_SIZE=gen_font)
ENDFOR        
 ;draw the rms circle 
FOR i=0,N_ELEMENTS(rms_circ)-2 DO BEGIN
  r_angle  = 20.+6*i
  x        = rms_circ[i]*cos(rad(r_angle))
  y        = rms_circ[i]*SIN(rad(r_angle))
  
  p = POLARPLOT(REPLICATE(rms_circ[i],90),RAD(INDGEN(90)),fmt_rms,$
        AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
        /OVERPLOT)
  t = TEXT(x,y,STRING(rms_circ[i],FORMAT='(F4.2)'),/DATA,$
        TARGET=p, ALIGNMENT=0.2,VERTICAL_ALIGNMENT=0.,ORIENTATION=r_angle-90., $
        COLOR=color_rms,$
        FONT_SIZE=gen_font)
ENDFOR
t = TEXT(MAX(rms_range)*COS(RAD(45)),MAX(rms_range)*SIN(RAD(45)),'CORRELATION',$
        TARGET=p,/DATA, ALIGNMENT=0.5,VERTICAL_ALIGNMENT=0.,ORIENTATION=-45., $
        COLOR=color_cor,$
        FONT_SIZE=gen_font)
 ;draw the rms reference label and reference circle
p = POLARPLOT(REPLICATE(MAX(tay.rms_ref),90),RAD(INDGEN(90)),fmt_ref,$
                AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
                /OVERPLOT)
s = SYMBOL(tay.rms_ref,0.0,'Circle',/DATA,$
             SYM_COLOR=color_ref, SYM_SIZE=2 , SYM_FILLED=1, $
             TARGET=p,$
             /OVERPLOT)
;draw the rms_diff circle 
angle    = rad(INDGEN(180))
rms_diff = rms_circ
FOR i=0,N_ELEMENTS(rms_diff)-1 DO BEGIN
   t_angle = 45+8*i
   x       =  tay.rms_ref+rms_diff[i]*cos(angle)
   y       =  rms_diff[i]*SIN(angle)
   ineg    = WHERE(x LE 0.,cpt_neg)
   theta   = ACOS(-((rms_diff[i]*rms_diff[i]-rms_ref*rms_ref-MAX(rms_range)*MAX(rms_range))/(2*rms_ref*MAX(rms_range))))
   print,deg(theta)
   IF (cpt_neg GE 1) THEN BEGIN
   x[ineg] = !VALUES.F_NAN & y[ineg] = !VALUES.F_NAN 
   ENDIF
   IF FINITE(theta) THEN BEGIN
     ineg   = WHERE(x GE MAX(rms_range)*cos(theta),cpt_neg)
     IF (cpt_neg GE 1) THEN BEGIN
     x[ineg] = !VALUES.F_NAN & y[ineg] = !VALUES.F_NAN 
   ENDIF
   ENDIF
   p_diff = PLOT(x,y,fmt_diff,/DATA,$
               AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
               COLOR=color_rms_diff,$
               /OVERPLOT)
   t_diff = TEXT(x[t_angle],y[t_angle],STRING(rms_diff[i],FORMAT='(F5.1)'),/DATA,$
          TARGET=p_diff,$
          ALIGNMENT=0.5, VERTICAL_ALIGNMENT=0.99,ORIENTATION=90.-t_angle, $
          FONT_SIZE=gen_font,COLOR=color_rms_diff)
ENDFOR
w.refresh

;#######################################################################
;####################  GRAPHICAL PART : DOTS   #########################
;#######################################################################


 ;plot des pts sur le diagrame de Taylor
 IF NOT KEYWORD_SET(n_model) THEN n_model=N_ELEMENTS(tay.model.name)
 FOR i=0,n_model-1 DO BEGIN
 ;on mets la legende des models
 s   = SYMBOL(0.65,0.97-i*0.03,'Circle',$
             TARGET=w,$
             SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
             SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
             SYM_TRANSPARENCY=symtrans,$
             LABEL_STRING=tay.model[i].name,LABEL_FONT_SIZE=gen_font,LABEL_COLOR=tay.model[i].color,$
               /OVERPLOT)

 p   = POLARPLOT(tay.model[i].pt.rms,ACOS(tay.model[i].pt.cor),/DATA,$
               AXIS_STYLE=1,XRANGE=rms_range,YRANGE=rms_range,$
               LINESTYLE=6,$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=symtrans,$
               /OVERPLOT)
; t   = TEXT(tay.model[i].pt.rms*COS(ACOS(tay.model[i].pt.cor)),$
;            tay.model[i].pt.rms*SIN(ACOS(tay.model[i].pt.cor)),$
;            STRCOMPRESS(tay.model[i].pt.num,/REMOVE_ALL),/DATA,$
;            TARGET=p,$
;            ALIGNMENT=0.5, VERTICAL_ALIGNMENT=0.5,ORIENTATION=0., $
;            FONT_SIZE=gen_font,COLOR=tay.model[i].color)               

               
 IF KEYWORD_SET(moy) THEN BEGIN
  s   = SYMBOL(MEAN(tay.model[i].pt.rms,/NAN)*COS(ACOS(MEAN(tay.model[i].pt.cor,/NAN)))$
             ,MEAN(tay.model[i].pt.rms,/NAN)*SIN(ACOS(MEAN(tay.model[i].pt.cor,/NAN))),'Square',/DATA,$
               TARGET=p,$
               SYM_SIZE=symsize*1.5,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=0.5,$
               LABEL_STRING='',LABEL_FONT_SIZE=gen_font,LABEL_COLOR='black',$
               /OVERPLOT)
  PRINT,tay.model[i].name,'   :  MEAN_RMS_DIFF = ',MEAN(tay.model[i].pt.rms_diff,/NAN),' MEAN_COR = ',MEAN(tay.model[i].pt.cor,/NAN)
 ENDIF
ENDFOR


 

p.refresh
;s.refresh

END