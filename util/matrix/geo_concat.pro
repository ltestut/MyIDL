FUNCTION geo_concat, _EXTRA=extra
; concat geomat
; geo=concat_geo(g1=geo1,g2=geo1,g3= ...)

tag  = TAG_NAMES(extra)  ;keywords used to add the geo
ngeo = N_TAGS(extra)     ;number of mgr to concat

 ;check if geo have constitent type ans size
t=LIST()         ;list of geomat type
s=LIST()         ;list of geomat size
f=LIST()         ;list of geomat filename
val=LIST()       ;list of geomat value
u=LIST()         ;list of geomat u zonal current
v=LIST()         ;list of geomat v meridional current
j=LIST()         ;list of geomat time
FOR i=0,ngeo-1 DO BEGIN
 t.Add,(geo_type(extra.(i)))['type']
 s.Add,(geo_type(extra.(i)))['size']
 f.Add,extra.(i).filename,/EXTRACT
ENDFOR

arr_type=t.ToArray()
arr_size=s.ToArray()

IF (N_ELEMENTS(arr_type[UNIQ(arr_type)]) NE 1) THEN STOP,"Non consitent geotype",arr_type
;;TODO make the check and dimension

 ;get the common geotype and matrix size
gtype=geo_type(extra.(0))
tab_size=gtype['size']
ndim=N_ELEMENTS(tab_size)
cpt=0
IF (ndim EQ 3) THEN BEGIN
   FOR i=0,ngeo-1 DO cpt=cpt+s[i,2] 
   geo=geo_create(tab_size[0],tab_size[1],cpt)
ENDIF ELSE IF (ndim EQ 2) THEN BEGIN
   geo=geo_create(tab_size[0],tab_size[1])
ENDIF ELSE BEGIN
   STOP,'Need 2D or 3D matrix'
ENDELSE
                    

geo.lon=extra.(0).lon
geo.lat=extra.(0).lat
geo.info=extra.(0).info
geo.filename= STRJOIN(f.ToArray(TYPE='STRING'),';')

FOR i=0,ngeo-1 DO BEGIN ;loop on all geo to concatenate 
  IF (odd(gtype['type'])) THEN j.Add,extra.(i).jul 
  IF (gtype['type'] NE 2 AND gtype['type'] NE 3 ) THEN val.Add,extra.(i).val
  IF (gtype['type'] NE 0 AND gtype['type'] NE 1 ) THEN BEGIN
   u.Add,extra.(i).u
   v.Add,extra.(i).v
  ENDIF
ENDFOR

IF (odd(gtype['type'])) THEN BEGIN ;if time varying geomat
 IF (gtype['type'] NE 3 ) THEN geo.val=val.ToArray(DIMENSION=3)
 IF (gtype['type'] NE 1 ) THEN BEGIN
  geo.u=u.ToArray(DIMENSION=3)
  geo.v=v.ToArray(DIMENSION=3)
 ENDIF
  geo.jul=j.ToArray(DIMENSION=1)
ENDIF ELSE BEGIN
   ;;TODO  see what to do with concatenation of static field ???
ENDELSE

RETURN,geo
END