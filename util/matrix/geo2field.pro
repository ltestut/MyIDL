FUNCTION geo2field, geo, lon, lat, full_range, tstamp, frame=frame, tdate=tdate, scale=scale
; get the lon,lat, 2D field and its full zrange depending of the geomatrix type
; you can indicate the frame number or the date='ddmmyyyyhhmmss' you want to plot


IF NOT KEYWORD_SET(frame) THEN frame=0
IF NOT KEYWORD_SET(scale) THEN scale=1.
IF KEYWORD_SET(tdate) THEN BEGIN
  READS,tdate,ddate,FORMAT=get_format(STRLEN(tdate))
  iframe=WHERE(ABS(geo.jul-DOUBLE(ddate)) LT 1./24.,count)
  IF (count GE 1) THEN frame=iframe[0]
ENDIF
IF (MAX('JUL' EQ TAG_NAMES(geo))) THEN tstamp=print_date(geo.jul[frame],/SINGLE) ELSE tstamp='' ;init the time stamp
lon    = geo.lon
lat    = geo.lat

 ;on determine le type de geomatrice
gtype   = geotype(geo,/VERBOSE)

 ;on selectione le champ 2D
CASE (gtype) OF
    0: field=geo.val
    1: IF KEYWORD_SET(pha) THEN field=geo.pha ELSE field=geo.amp 
    2: field=geo.val[*,*,frame]
    3: BEGIN
        type = 3
        type_name = '2D vecteur  => geo.u[nx,ny] geo.v[nx,ny]'
        s         = SIZE(geo.u,/DIMENSIONS)
    END
    6: field=geo.val[nx,ny]
    7: field=geo.val[nx,ny,frame]
    10: BEGIN
        iwav = where(geo.wave.name EQ 'M2')
        IF KEYWORD_SET(pha) THEN field=geo.wave[iwav].pha ELSE field=geo.wave[iwav].amp
        END
    11: BEGIN
        type = 11
        type_name = 'geo.wave[nwa].u[nx,ny] geo.wave[nwa].v[nx,ny] geo.wave[nwa].ug[nx,ny] geo.wave[nwa].vg[nx,ny]'
        s         = SIZE(geo.wave[0].u,/DIMENSIONS)
    END
    12: BEGIN
        type = 12
        type_name = 'tgeo.wave[nwa].amp[nx,ny], tgeo.wave[nwa].pha[nx,ny], geo.wave[nwa].u[nx,ny] geo.wave[nwa].v[nx,ny] geo.wave[nwa].ug[nx,ny] geo.wave[nwa].vg[nx,ny]'
        s         = SIZE(geo.wave[0].amp,/DIMENSIONS)
    END
  ENDCASE

 ;compute the scaled field and the full range
sfield     = field*scale 
full_range = [MIN(sfield,/NAN),MAX(sfield,/NAN)]
RETURN,sfield
END