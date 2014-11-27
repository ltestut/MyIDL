FUNCTION geo_create, nlon,nlat,ntime,scalar=scalar,vector=vector
; create a 2D or 3D geomat structure (light version with HASH table)
; with this version all tide type structure are moved to tatlas type
; type 0 : "geomat" scalar                       / val(nx,ny)
; type 1 : "geomat" time varying scalar          / val(nx,ny,nt)
; type 2 : "geomat" vector                      / u(nx,ny)      & v(nx,ny)
; type 3 : "geomat" time varying vector         / u(nx,ny,nt)   & v(nx,ny,nt)
; type 4 : "geomat" scalar+vect  / val(nx,ny) & u(nx,ny) & v(nx,ny)
; type 5 : "geomat" time varying scalar+vector /val(nx,ny,nt)&u(nx,ny,nt)&v(nx,ny,nt)


tmp=HASH('lon',FLTARR(Nlon),'lat',FLTARR(Nlat),$
         'info','','filename','')

 ;set default to scalar field
IF NOT KEYWORD_SET(scalar) AND NOT KEYWORD_SET(vector) THEN scalar=1

IF (N_PARAMS() EQ 3) THEN BEGIN ; odd number type 1,3,5 (time varying field)
 tmp=tmp+HASH('jul',DBLARR(ntime))
 IF KEYWORD_SET(scalar) THEN tmp=tmp+HASH('val',FLTARR(nlon,nlat,ntime),'type',1)   
 IF KEYWORD_SET(vector) THEN tmp=tmp+HASH('u',FLTARR(nlon,nlat,ntime),$
                                          'v',FLTARR(nlon,nlat,ntime),'type',3)
 IF (KEYWORD_SET(scalar) AND KEYWORD_SET(vector)) THEN tmp['type']=5                                          

ENDIF ELSE BEGIN ;even number value 0,2,4 (static field)
 IF KEYWORD_SET(scalar) THEN tmp=tmp+HASH('val',FLTARR(nlon,nlat),'type',0)
 IF KEYWORD_SET(vector) THEN tmp=tmp+HASH('u',FLTARR(nlon,nlat),$
      'v',FLTARR(nlon,nlat),'type',2)
 IF (KEYWORD_SET(scalar) AND KEYWORD_SET(vector)) THEN tmp['type']=4
ENDELSE
   
         
RETURN,tmp.ToStruct()
END
