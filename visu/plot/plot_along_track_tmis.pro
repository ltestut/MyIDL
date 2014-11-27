PRO plot_along_track_tmis, tmis, units=units,$
                                  xaxis=xaxis,wave=wave,$
                                  atlas=atlas,misfits=misfits, $
                                  moy=moy,$
                                  output=output,$
                                 _EXTRA=_EXTRA
; program to plot a the amplitude of phase of an along track

 ;title, legend and presentation
head_title   = 'Along-Track Misfits'
gen_font     = 12                ;general font_size
symref       = 1.                ;symbol ref
symsize      = 0.5                ;symbol size
symtrans     = 0                 ;symbol transparency
fmt_ref      = 'm2'              ;format of the reference rms :Magenta
fmt_cor      = '0k:'
fmt_rms      = '0k:'
fmt_diff     = '0k:'
 ;color choice
color_ref    = 'Dark Grey'      ;color for the ref circle
color_1      = 'Royal Blue'     ;color for the correlation lines and labels
color_2      = 'Grey'           ;color for the rms circle and labels
color_3      = 'Dark Orange'    ;color for the rms circle and labels
color        = [color_ref,color_1,color_2,color_3]
  
IF NOT KEYWORD_SET(scale)     THEN scale    = 100           ;defaut scale
IF NOT KEYWORD_SET(units)     THEN units    = 'cm'          ;defaut units
IF NOT KEYWORD_SET(xaxis)     THEN xaxis    = 'lat'         ;defaut xaxis
IF NOT KEYWORD_SET(wave)      THEN wave     = 'M2'          ;defaut wave

idx     = WHERE(TAG_NAMES(tmis.sta) EQ STRUPCASE(xaxis))
idw     = WHERE(tmis.sta[0].wave.name EQ wave)
tmis.sta.wave.da=tmis.sta.wave.da*scale
tmis.sta.wave.de=tmis.sta.wave.de*scale


;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
 ;window creation
xsize  =  800
ysize  =  800
w      = window(dimensions=[xsize,ysize],$
                TITLE=head_title,FONT_SIZE=gen_font)
;w.refresh, /disable
t_head = TEXT([0.5],[0.85], $
               ['Track N° : '+tmis.sta[0].name+'/  WAVE = '+STRING(wave)], $
         TARGET=w,$
         COLOR='black',FONT_SIZE=gen_font,ALIGNMENT=0.5)                

i        = 0
leg_pos  = [0.77,0.95]
p_pos    = [0.10,0.10,0.90,0.30] 
sublabel = 5
nlabel   = N_ELEMENTS(tmis.sta.lat)
xlabel   = INDGEN(nlabel)*sublabel
index    = WHERE(xlabel LE nlabel) 

t   = TEXT(leg_pos[0],leg_pos[1],'Along-Track AH',$
            TARGET=w,$
            FONT_SIZE=gen_font,COLOR=color[0])               

p_amp   = PLOT(tmis.sta.(idx),tmis.sta.wave[idw].da,/DATA,$
               AXIS_STYLE=1,XTITLE='Latitude (deg)',YTITLE='Amplitude Diff (cm)',$
               YMINOR=0,$
               LINESTYLE=0,COLOR=color[0],$
               SYMBOL='Circle',$
               SYM_SIZE=symref,SYM_THICK=0.0,SYM_COLOR=color[0],$
               SYM_FILLED=1,SYM_FILL_COLOR=color[0],$
               SYM_TRANSPARENCY=symtrans,$
               POSITION=[p_pos[0],0.10,p_pos[2],0.30],$
               /CURRENT)

p_pha   = PLOT(tmis.sta.(idx),tmis.sta.wave[idw].dp,/DATA,$
               AXIS_STYLE=1,XTITLE='',YTITLE='Phase Diff (deg)',$
               YMINOR=0,$
               LINESTYLE=0,COLOR=color[0],$
               SYMBOL='Circle',$
               SYM_SIZE=symref,SYM_THICK=0.0,SYM_COLOR=color[0],$
               SYM_FILLED=1,SYM_FILL_COLOR=color[0],$
               SYM_TRANSPARENCY=symtrans,$
               POSITION=[p_pos[0],0.35,p_pos[2],0.65],$
               /CURRENT)

p_rms   = PLOT(tmis.sta.(idx),SQRT(tmis.sta.wave[idw].de*tmis.sta.wave[idw].de/2.),/DATA,$
               AXIS_STYLE=1,XTITLE='',YTITLE='Complex Diff (cm)',$
               YMINOR=0,$
               LINESTYLE=0,COLOR=color[0],$
               SYMBOL='Circle',$
               SYM_SIZE=symref,SYM_THICK=0.0,SYM_COLOR=color[0],$
               SYM_FILLED=1,SYM_FILL_COLOR=color[0],$
               SYM_TRANSPARENCY=symtrans,$
               POSITION=[p_pos[0],0.70,p_pos[2],0.95],$
               /CURRENT)

IF KEYWORD_SET(atlas) THEN BEGIN
 p_amp   = PLOT(mgr.(idx),mgr_mod.amp,/DATA,$
               LINESTYLE=0,COLOR=color[1],$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=color[1],$
               SYM_FILLED=1,SYM_FILL_COLOR=color[1],$
               SYM_TRANSPARENCY=symtrans,$
               OVERPLOT=p_amp)

 p_pha   = PLOT(mgr.(idx),mgr_mod.pha,/DATA,$
               LINESTYLE=0,COLOR=color[1],$
               SYMBOL='Circle',$
               SYM_SIZE=symsize,SYM_THICK=0.0,SYM_COLOR=color[1],$
               SYM_FILLED=1,SYM_FILL_COLOR=color[1],$
               SYM_TRANSPARENCY=symtrans,$
               OVERPLOT=p_pha)
t   = TEXT(leg_pos[0],leg_pos[1]-0.05,STRCOMPRESS(atlas,/REMOVE_ALL),$
            TARGET=w,$
            FONT_SIZE=gen_font,COLOR=color[1])               
                 
ENDIF

IF KEYWORD_SET(output) THEN BEGIN
 print,output
 w.save, output, resolution=100
ENDIF

END