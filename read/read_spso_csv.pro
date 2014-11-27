FUNCTION read_spso_csv, filename, scale=scale, sts=sts, distance=distance
; read the .csv output from the SPSO software.
IF NOT KEYWORD_SET(scale) THEN scale = 1.  


; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:','   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:''   ,$
        fieldcount:6 ,$
        fieldTypes:[7,4,4,4,7,7], $
        fieldNames:['code','lat','lon','haut','x','date'] , $
        fieldLocations:[0,1,2,4,5,6], $
        fieldGroups:indgen(6) $
      }
      
 ;read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)
N     = N_ELEMENTS(data.lon)
date  = DBLARR(N)
print,'READ_ASCII   : ',filename,'  Ndata =',N


 ;compute the date
READS,data.date[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
;READS,data.date[0:N-1],date,FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI2,X,CMI2,X,CSI2))'

st     = create_julval(N)
st.jul = date
st.val = data.haut*scale  

IF KEYWORD_SET(distance) THEN BEGIN
  ms2knot = 3.6/1.852
  stll = create_llval(N)
  sts  = create_julval(N)  ;speed
  scl  = 1.    ;to cm
  sm   = 1.    ;smoothing factor
  stll.lon = SMOOTH(360+data.lon,1)
  stll.lat = SMOOTH(data.lat,1)
  ;write_ll2kml,stll,DECIMATE=60,OUTPUT=filename+'.kml'
  projec  = MAP_PROJ_INIT('Orthographic',CENTER_LATITUDE=MEAN(data.lat),CENTER_LONGITUDE=MEAN(data.lon))
  proj    = MAP_PROJ_FORWARD(SMOOTH(data.lon,sm),SMOOTH(data.lat,sm),MAP_STRUCTURE=projec)
  x       = TRANSPOSE(proj[0,*]*scl)
  y       = TRANSPOSE(proj[1,*]*scl)
  dx      = x-SHIFT(x,1)
  dy      = y-SHIFT(y,1)
  dl      = SQRT(dx*dx+dy*dy)   ;distance in meter
  az      = 180.+deg(ATAN(dy,dx))
  sts.jul = date
  sts.val = dl*ms2knot ;speed in knots
  inan    = WHERE(sts.val GT 15.,cpt)
  IF (cpt GT 0) THEN sts[inan].val=!VALUES.F_NAN 
ENDIF
      
RETURN, tri_julval(st)
END