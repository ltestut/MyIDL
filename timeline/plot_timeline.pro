PRO plot_timeline, chrono, nogrid=nogrid, title=title
; program to visualize a chronogram in a timeline manner
;  

IF NOT KEYWORD_SET(title) THEN title='Timeline'
w=WINDOW(TITLE=title)
key0  = (chrono.keys())[0]                ;get the first key
isort = sort((chrono.keys()).toarray())   ;ordered list of keys 
keys  = ((chrono.keys()).toarray())[isort];ordered keys 
nkey  = N_ELEMENTS(keys)                  ;number of keys
CASE (chrono[key0])[0] OF
  'yearly': BEGIN
              duration   = 365.  ;nb of days per block
              resolution =  24.  ;nb of hours per day
              start_date = JULDAY(1,1,1950,0,0,0)
              date_label = LABEL_DATE(DATE_FORMAT = ['%M'])
              ;compute the time grid
              ;       jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec
              dpermth  = [31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.]
              tickgrid = INTARR(11) & tickgrid[0]=dpermth[0]*resolution
              FOR i=1,10 DO tickgrid[i]=tickgrid[i-1]+dpermth[i]*resolution
            END
  'weekly': BEGIN
              duration   =  7.   ;nb of days per block
              resolution =  24.  ;nb of hours per day
              start_date = JULDAY(1,6,1980,0,0,0)
              date_label = LABEL_DATE(DATE_FORMAT = ['%w'])
              ;compute the time grid
              ;       jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec
              tickgrid = INTARR(7) & tickgrid[0]=resolution
              FOR i=1,6 DO tickgrid[i]=tickgrid[i-1]+resolution
            END
  else: begin
  end
ENDCASE


nlines     = chrono.count()                       ;equal to the number of keys of the chrono
cpt_line   = 0
x          = INDGEN(duration*resolution)          ;compute the X axis (usually in hours)
y          = MAKE_ARRAY(N_ELEMENTS(x),VALUE=0.)   ;init a fake-blank y vector
date       = start_date+INDGEN(duration+1)        ;init a fake date vector 
 ;plot the date frame
pdate     = PLOT(date,INDGEN(N_ELEMENTS(date)),/NODATA,POSITION=[0.2,0.2,0.9,0.25],AXIS_STYLE=0,$
                  XTICKUNITS='time',XTICKFORMAT='LABEL_DATE',XSTYLE=1,/CURRENT)
date_axis = AXIS('X', TARGET=pdate, LOCATION=0, MINOR=0,TICKFONT_SIZE=8,$
                  TICKFORMAT='LABEL_DATE',TICKUNITS='time',TICKINTERVAL=1,TICKLAYOUT=2)

 ;plot timeline frame and tag axis
p        = PLOT(x,y,YRANGE=[0,nlines+1],/NODATA,AXIS_STYLE=0,XSTYLE=1,POSITION=[0.2,0.2,0.9,0.9],/CURRENT)
gridaxis = AXIS('X',TARGET=p,LOCATION=0,MINOR=0,TICKVALUES=tickgrid,TICKNAME=MAKE_ARRAY(N_ELEMENTS(tickgrid),/STRING,VALUE=''),TICKLEN=1,$
                    COLOR='grey',GRIDSTYLE=5,SUBGRIDSTYLE=6,HIDE=KEYWORD_SET(nogrid))
tagaxis  = AXIS('Y',TARGET=p,LOCATION=0,MINOR=0,GRIDSTYLE=0,TICKVALUES=1+INDGEN(nlines),TICKNAME=STRING(REVERSE(keys)))

                                   
  ;loop on blocks
FOREACH key,keys DO BEGIN        ;loop on the number of period (year,month)
   line  = nlines-cpt_line++            ;line number descending order
   frame = POLYGON([x[0],x[-1],x[-1],x[0]],[line-0.5,line-0.5,line+0.5,line+0.5],/DATA,COLOR='grey',FILL_BACKGROUND=0,target=p)
   FOR i=1,chrono[key].count()-1 DO BEGIN ;loop on the number of block per lines (per period)
   xb=compute_timeline_block_min_max(chrono[key,0],key,((chrono[key])[i])['start_block'],((chrono[key])[i])['end_block'],RESOLUTION=resolution)
   y0=(line-0.5)+((chrono[key])[i])['frame_position'] ;position of the block /frame 0-1
   yb=[y0,y0,y0+((chrono[key])[i])['block_thick'],y0+((chrono[key])[i])['block_thick']]
   print,FORMAT='(%"key:%d / line:%d / xmin/xmax:%8.3f - %8.3f / color: %s " )',key,line,xb,((chrono[key])[i])['block_color']
   block = POLYGON([xb[0],xb[1],xb[1],xb[0]],yb,$
          FILL_BACKGROUND=1,FILL_COLOR=((chrono[key])[i])['block_color'],FILL_TRANSPARENCY=((chrono[key])[i])['block_transp'],$
          LINESTYLE=((chrono[key])[i])['ct_style'],COLOR=((chrono[key])[i])['ct_color'],THICK=((chrono[key])[i])['ct_thick'],$
          /DATA,TARGET=p)
   leg   =TEXT(xb[1],yb[0],(((chrono[key])[i])['info'])['default'],/DATA,TARGET=p,CLIP=0,$
               FONT_NAME=((chrono[key])[i])['txt_font'],FONT_COLOR=((chrono[key])[i])['txt_color'],FONT_SIZE=((chrono[key])[i])['txt_size'])
   ENDFOR
ENDFOREACH

print,'toto'

END