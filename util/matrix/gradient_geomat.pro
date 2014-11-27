FUNCTION gradient_geomat, geo_in, limit=limit, scale=scale, D=D
;compute the gradient of a matrix
; geo_in      : input matrix
; geo_out.u   : output matrix px=dval/(D*dx) 
; geo_out.v   : output matrix px=dval/(D*dy)
; geo_out.val : output matrix p=sqrt(px^2+py^2)
;  
; D=-1       : grid separation to compute the gradient
; Zout        : RETURN the magnitude of the slope


IF NOT KEYWORD_SET(D) THEN D=-1  ;grid separation + shifts are to the right while left shifts are - number.
sig = -1  ;sign convention for the slope
 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE

 ;determination du type de la matrice
gtype = geotype(geo,/VERBOSE)

IF NOT KEYWORD_SET(scale) THEN scale=1.

s           = SIZE(geo.val)
Z           = geo.val
dx          = MAP_2POINTS(geo.lon[0], geo.lat[0], geo.lon[0+ABS(D)], geo.lat[0] ,/METERS)
dy          = MAP_2POINTS(geo.lon[0], geo.lat[0], geo.lon[0], geo.lat[0+ABS(D)] ,/METERS)

CASE (gtype) OF
  0: BEGIN ;cas de la matrice 2D val(nx,ny)
      geo_out                                = create_geomat(s[1],s[2],/HUV)
      geo_out.type                           = 6 
      geo_out.u   = sig*(SHIFT(Z,[D,0])-Z)/dx  ;DZ/Dx
      geo_out.v   = sig*(SHIFT(Z,[0,D])-Z)/dy ;DZ/Dy
      geo_out.val = scale*SQRT(geo_out.u^2+geo_out.v^2) 
     END
  2: BEGIN ;cas de la matrice 2D temporelle val(nx,ny,nt)
      geo_out                                   = create_geomat(s[1],s[2],s[3],/HUV)
      geo_out.type                              = 7
      geo_out.jul                               = geo.jul
      FOR I=0,s[3]-1 DO BEGIN
       geo_out.u[INDGEN(s[1]),INDGEN(s[2]),I]   = sig*(SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[D,0])-Z[INDGEN(s[1]),INDGEN(s[2]),I])/dx ;DZ/Dx
       geo_out.v[INDGEN(s[1]),INDGEN(s[2]),I]   = sig*(SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[0,D])-Z[INDGEN(s[1]),INDGEN(s[2]),I])/dy ;DZ/Dy
       geo_out.val[INDGEN(s[1]),INDGEN(s[2]),I] = scale*SQRT(geo_out.u[INDGEN(s[1]),INDGEN(s[2]),I]^2+geo_out.v[INDGEN(s[1]),INDGEN(s[2]),I]^2)
      ENDFOR
     END
  6: BEGIN ;cas de la matrice 2D scalaire+vecteur val(nx,ny) u(nx,ny) v(nx,ny)
      geo_out                                = create_geomat(s[1],s[2],/HUV)
      geo_out.type                           = 6 
      geo_out.u   = sig*(SHIFT(Z,[D,0])-Z)/dx ;DZ/Dx
      geo_out.v   = sig*(SHIFT(Z,[0,D])-Z)/dy ;DZ/Dy
      geo_out.val = scale*SQRT(geo_out.u^2+geo_out.v^2) 
     END
  7: BEGIN ;cas de la matrice 2D temporelle val(nx,ny,nt)
      geo_out                                   = create_geomat(s[1],s[2],s[3],/HUV)
      geo_out.type                              = 7
      geo_out.jul                               = geo.jul
      FOR I=0,s[3]-1 DO BEGIN
       geo_out.u[INDGEN(s[1]),INDGEN(s[2]),I]   = sig*(SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[D,0])-Z[INDGEN(s[1]),INDGEN(s[2]),I])/dx ;DZ/Dx
       geo_out.v[INDGEN(s[1]),INDGEN(s[2]),I]   = sig*(SHIFT(Z[INDGEN(s[1]),INDGEN(s[2]),I],[0,D])-Z[INDGEN(s[1]),INDGEN(s[2]),I])/dy ;DZ/Dy
       geo_out.val[INDGEN(s[1]),INDGEN(s[2]),I] = scale*SQRT(geo_out.u[INDGEN(s[1]),INDGEN(s[2]),I]^2+geo_out.v[INDGEN(s[1]),INDGEN(s[2]),I]^2)
      ENDFOR
     END

ENDCASE

geo_out.lon  = geo.lon
geo_out.lat  = geo.lat
geo_out.info = 'gradient :'+geo.info
RETURN, geo_out
END
 