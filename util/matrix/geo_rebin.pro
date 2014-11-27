FUNCTION geo_rebin, geo_in, factor=factor
; fonction qui regrille une geomatrice

 ;on cherche les multiples les + proches du factor pour faire le rebin
IF NOT KEYWORD_SET(factor) THEN factor=10
nx = N_ELEMENTS(geo_in.lon)
ny = N_ELEMENTS(geo_in.lat)
nx_rebin = nx/multiple(nx,NEAREST=factor)
ny_rebin = ny/multiple(ny,NEAREST=factor)
 ;on rebin lon et lat
lon = REBIN(geo_in.lon,nx_rebin)
lat = REBIN(geo_in.lat,ny_rebin)
 ;on recupere le geotype de la matrice
gtype= geotype(geo_in)
print,gtype
  
CASE (gtype) OF
  0: BEGIN
   geo          = create_geomat(nx_rebin,ny_rebin)
   geo.lon      = lon
   geo.lat      = lat
   geo.val      = REBIN(geo_in.val,nx_rebin,ny_rebin)
   geo.info     = geo_in.info
   geo.filename = geo_in.filename
  END
  1 : BEGIN
   geo     = create_geomat(nx_rebin,ny_rebin,/TIDE)
   geo.lon = lon
   geo.lat = lat
   geo.amp = REBIN(geo_in.amp,nx_rebin,ny_rebin)
   geo.pha = REBIN(geo_in.pha,nx_rebin,ny_rebin)
   geo.info = geo_in.info
   geo.wave = geo_in.wave
   geo.filename = geo_in.filename
  END
  2 : BEGIN
   nt      = N_ELEMENTS(geo_in.jul)
   geo     = create_geomat(nx_rebin,ny_rebin,nt)
   geo.lon = lon
   geo.lat = lat
   geo.val = REBIN(geo_in.amp,nx_rebin,ny_rebin,nt)
   geo.info = geo_in.info
   geo.filename = geo_in.filename
  END
  3 : BEGIN
   geo     = create_geomat(nx_rebin,ny_rebin,/UV)
   geo.lon = lon
   geo.lat = lat
   geo.u   = REBIN(geo_in.u,nx_rebin,ny_rebin)
   geo.v   = REBIN(geo_in.v,nx_rebin,ny_rebin)
   geo.info = geo_in.info
   geo.filename = geo_in.filename
  END
  4 : BEGIN
   nt      = N_ELEMENTS(geo_in.jul)
   geo     = create_geomat(nx_rebin,ny_rebin,nt,/UV)
   geo.lon = lon
   geo.lat = lat
   geo.u   = REBIN(geo_in.u,nx_rebin,ny_rebin,nt)
   geo.v   = REBIN(geo_in.v,nx_rebin,ny_rebin,nt)
   geo.info = geo_in.info
   geo.filename = geo_in.filename
  END
ENDCASE

  
RETURN,geo
END