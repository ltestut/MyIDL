PRO plot_along_track_tay, tay_in, normalized=normalized, units=units,$
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
head_title   = 'Along track correlation and RMS : Track N°'+tay.model[0].trace
gen_font     = 12                ;general font_size
symsize      = 1.                ;symbol size
symtrans     = 0                 ;symbol transparency
rms_ref      = tay_in.rms_ref    ;value of the reference rms
fmt_ref      = 'm2'              ;format of the reference rms :Magenta
fmt_cor      = '0k:'
fmt_rms      = '0k:'
fmt_diff     = '0k:'
 ;color choice
color_ref      = 'Magenta'      ;color for the ref circle
color_cor      = 'Royal Blue'   ;color for the correlation lines and labels
color_rms      = 'Dark Grey'  ;color for the rms circle and labels
color_rms_diff = 'Dark Orange'  ;color for the rms circle and labels

IF NOT KEYWORD_SET(units)     THEN units    = 'cm'          ;defaut units

IF KEYWORD_SET(normalized) THEN BEGIN
 head_title            = 'Normalized '+head_title 
 tay.rms_ref           = tay.rms_ref/rms_ref
 tay.model.pt.rms      = tay.model.pt.rms/rms_ref
 tay.model.pt.rms_diff = tay.model.pt.rms_diff/rms_ref
ENDIF


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  =  800
ysize  =  400
w      = window(dimensions=[xsize,ysize],$
                TITLE=head_title,FONT_SIZE=gen_font)
;w.refresh, /disable
t_head = TEXT([0.5],[0.85], $
               ['Reference OBS = '+tay.name+'  /  '+$
                '$\sigma_{obs} = $'+STRING(rms_ref,FORMAT='(F5.2)')+'  ('+units+')'], $
         TARGET=w,$
         COLOR='black',FONT_SIZE=gen_font,ALIGNMENT=0.5)                

i        = 0
leg_pos  = [0.77,0.95]
p_pos    = [0.10,0.10,0.90,0.40] 
sublabel = 5
nlabel   = N_ELEMENTS(tay.model[i].pt.lat)
xlabel   = INDGEN(nlabel)*sublabel
index    = WHERE(xlabel LE nlabel) 

t   = TEXT(leg_pos[0],leg_pos[1],STRCOMPRESS(tay.model[i].name,/REMOVE_ALL),$
            TARGET=w,$
            FONT_SIZE=gen_font,COLOR=tay.model[i].color)               


p_rms   = PLOT(tay.model[i].pt.lat,tay.model[i].pt.rms_diff,/DATA,$
               AXIS_STYLE=1,XTITLE='Latitude (deg)',YTITLE='RMS DIFF (cm)',$
               YMINOR=0,$
               LINESTYLE=0,COLOR=tay.model[i].color,$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=symtrans,$
               POSITION=[p_pos[0],0.10,p_pos[2],0.40],$
               /CURRENT)

p_cor   = PLOT(tay.model[i].pt.lat,tay.model[i].pt.cor,/DATA,$
               AXIS_STYLE=1,XTITLE='',YTITLE='Correlation',$
               YMINOR=0,$
               LINESTYLE=0,COLOR=tay.model[i].color,$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=symtrans,$
               POSITION=[p_pos[0],0.50,p_pos[2],0.80],$
               /CURRENT)

 ;plot des pts sur le diagrame de Taylor
 IF NOT KEYWORD_SET(n_model) THEN n_model=N_ELEMENTS(tay.model.name)
 FOR i=1,n_model-1 DO BEGIN
 p_cor   = PLOT(tay.model[i].pt.lat,tay.model[i].pt.cor,/DATA,$
               LINESTYLE=0,COLOR=tay.model[i].color,$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=symtrans,$
               OVERPLOT=p_cor)

 p_rms   = PLOT(tay.model[i].pt.lat,tay.model[i].pt.rms_diff,/DATA,$
               LINESTYLE=0,COLOR=tay.model[i].color,$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=tay.model[i].color,$
               SYM_FILLED=1,SYM_FILL_COLOR=tay.model[i].color,$
               SYM_TRANSPARENCY=symtrans,$
               OVERPLOT=p_rms)
t   = TEXT(leg_pos[0],leg_pos[1]-i*0.05,STRCOMPRESS(tay.model[i].name,/REMOVE_ALL),$
            TARGET=w,$
            FONT_SIZE=gen_font,COLOR=tay.model[i].color)               
ENDFOR

;xaxis    = AXIS('X',TARGET=p_cor,TITLE='Point number',$
;               MINOR=0,$
;               LOCATION=[0,1.,0], $
;               TICKFONT_SIZE=10,$
;               TICKVALUES=tay.model[i].pt[xlabel[index]].lat,SHOWTEXT=1,$
;               TICKNAME=STRING(tay.model[i].pt[xlabel[index]].num),$ 
;               TEXTPOS=1,TICKDIR=1,TICKLEN=0.05)
;;RMS   
;xaxis    = AXIS('X',TARGET=p_rms,TITLE='',$
;               MINOR=0,$
;               LOCATION=[0,10.,0], $
;               TICKFONT_SIZE=10,$
;               TICKVALUES=tay.model[i].pt[xlabel[index]].lat,SHOWTEXT=0,$
;               TICKNAME=STRING(tay.model[i].pt[xlabel[index]].num),$ 
;               TEXTPOS=1,TICKDIR=1,TICKLEN=0.05)



END