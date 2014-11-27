PRO animate_plot_track,track,track2, scale=scale,f_start=f_start,n_frame=n_frame,$
                       st1=st1, st2=st2, titre_st=titre_st,  _EXTRA=_EXTRA


 ;gestion des mots-clefs 
IF NOT KEYWORD_SET(scale) THEN scale=100.
IF NOT KEYWORD_SET(output) THEN output='/home/testut/Desktop/idl.avi'
IF NOT KEYWORD_SET(f_start) THEN f_start=0
IF NOT KEYWORD_SET(n_frame) THEN n_frame=50


 ;recuperation des variables a tracer
time   = track.pt[0].jul
dist   = track.pt.dist/1000. ;in Km
var    = track.pt.val*scale
PRINT,"Min-Max for variable  = ",MIN(var,/NAN,MAX=maxvar),maxvar
IF (N_PARAMS() EQ 2) THEN BEGIN
 time2  = track2.pt[0].jul
 dist2  = track2.pt.dist/1000. ;in Km
 var2   = track2.pt.val*scale
 PRINT,"Min-Max for variable2 = ",MIN(var2,/NAN,MAX=maxvar2),maxvar2
ENDIF

;#######################################################################
;#################### GRAPHICAL PART : BACKGROUND ######################
;#######################################################################
 ;window creation
xsize  =  1000
ysize  =   600
w      = window(dimensions=[xsize,ysize])
w.refresh, /disable
pos      = [0.1,0.2,0.9,0.9]
IF KEYWORD_SET(st1) THEN pos = [0.1,0.2,0.9,0.6] 

p   = PLOT(dist,var[0,*],/DATA,/CURRENT,POSITION=pos,COLOR='blue',_EXTRA=_EXTRA)
IF (N_PARAMS() EQ 2) THEN p2 = PLOT(dist2,var2[0,*],/DATA,/OVERPLOT,COLOR='green')

  ;place la legende et un sous-titre
IF (N_PARAMS() EQ 2) THEN BEGIN
 legend   = text(0.05, 0.04, 'Date : '+print_date(REFORM(time[f_start,0]),/SINGLE)+' -- Date2 (red): '+print_date(REFORM(time2[f_start,0]),/SINGLE), font_size=15)
 sub      = [track.filename,track2.filename]
 subtitle = text([0.05,0.05], [0.02,0.01], sub, /normal, font_size=8)
ENDIF ELSE BEGIN  
 legend   = text(0.05, 0.04, 'Date : '+print_date(REFORM(time[f_start,0]),/SINGLE), font_size=15)
 sub      = [track.filename]
 subtitle = text(0.05, 0.01, sub, /normal, font_size=8)
ENDELSE

IF KEYWORD_SET(st1) THEN BEGIN
IF NOT KEYWORD_SET(titre_st) THEN titre_st=''
date_label = LABEL_DATE(DATE_FORMAT = ['%D%M'])
ymin       = MIN(st1.val,/NAN)
ymax       = MAX(st1.val,/NAN)
xr         = [time[f_start,0],time[f_start+n_frame,0]]
yr         = [-25.,25] ;,[ymin,ymax]
id0        = WHERE(st1.jul EQ time[f_start,0],cpt0) 
s1   = PLOT(st1.jul, st1.val,POSITION=[[0.1,0.76,0.8,0.95]],/CURRENT,$
       XRANGE=xr,XSTYLE=1,YRANGE=yr,YSTYLE=1,$
       TITLE=titre_st,$ ; induced by tide(red), meteo(blue) and sum of both(purple) ',$
       XTITLE='Time',YTITLE='SLA (cm)',$
       COLOR='blue',THICK=1,$      
       XTICKFORMAT   = ['LABEL_DATE'],$
       XTICKUNITS    = ['Day'],$
       XTICKINTERVAL = 5             ,$
       XMINOR        = 1             ,$
       XTICKLEN      = 0.05          ,$
       XGRIDSTYLE    = 0              )    
IF KEYWORD_SET(st2) THEN BEGIN
  id20   = WHERE(st2.jul EQ time[f_start,0],cpt0) 
  s2     = PLOT(st2.jul, st2.val,/OVERPLOT,YRANGE=yr,COLOR='red')
ENDIF
ENDIF
w.refresh

;#######################################################################
;#################### VIDEO PART : BACKGROUND     ######################
;#######################################################################

   
   ; Create the video object and add metadata.
video_file = output
video      = idlffvideowrite(video_file)
video.setmetadata, 'artist', 'L. Testut, LEGOS'
   
   ; Initialize the video stream. 
framerate = 4. ; the playback speed in frames per second
stream    = video.addvideostream(xsize, ysize, framerate)
   
   ; Write the current visualization as the first frame of the video.
timestamp = video.put(stream, w.copywindow())
help, timestamp
   
   ;parcours le temps
FOR i=f_start+1,f_start+n_frame DO BEGIN
  p.SetData,dist,var[i,*]
  IF (N_PARAMS() EQ 2) THEN BEGIN
     p2.SetData,dist2,var2[i,*]
     legend.string = 'Date : '+print_date(time[i,0],/SINGLE)+' -- Date2 (red): '+print_date(time2[i,0],/SINGLE)
  ENDIF ELSE BEGIN 
    legend.string = 'Date : '+print_date(time[i,0],/SINGLE)
  ENDELSE
  IF KEYWORD_SET(st1) THEN BEGIN
    id = WHERE(st1.jul EQ time[i,0],cpt)
    IF (cpt GE 1) THEN s1.SetData,st1[id0:id].jul,st1[id0:id].val    
  ENDIF
  IF KEYWORD_SET(st2) THEN BEGIN
    id = WHERE(st2.jul EQ time[i,0],cpt)
    IF (cpt GE 1) THEN s2.SetData,st2[id20:id].jul,st2[id20:id].val    
  ENDIF
  timestamp = video.put(stream, w.copywindow())
  help, timestamp
ENDFOR
   
   ; Destroy video object -- needed to close video file.
video.cleanup
print, 'File "' + video_file + '" written to current directory.'
END
