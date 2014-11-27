PRO read_ecmwf, file, lat, lon, stime, var, var_name=var_name, verbose=verbose

;Open the .nc file
  fid  = NCDF_OPEN(file)     ; ouverture du fichier

;Read the lon lat time variables
  NCDF_VARGET, fid, NCDF_VARID(fid,'lon'),  lon  ;lon(nlon,nlat) ou lon(x,y)
  NCDF_VARGET, fid, NCDF_VARID(fid,'lat'),  lat  ;lat(nlon,nlat) ou lat(x,y)
  NCDF_VARGET, fid, NCDF_VARID(fid,'time'),  time  ;lat(nlon,nlat) ou lat(x,y)  
  
; Get the x y  time dimensions
  dim_lon = ncdf_read_dim(NAME1='lon', NAME2='LON', NCDF_ID=fid)
  dim_lat = ncdf_read_dim(NAME1='lat', NAME2='LAT', NCDF_ID=fid)
  dim_t   = ncdf_read_dim(NAME1='time', NAME2='t', NCDF_ID=fid)
  

  IF NOT KEYWORD_SET(var_name) THEN var_name='10u'

  ; Initialise the time vector
    stime   = (time/24.0)+JULDAY(1,1,1900,0,0,0)
  ;convert lon (-180/180) ==>> (0/360)
  ineg    = WHERE(lon LT 0.,cneg)
    IF (cneg GT 0) THEN BEGIN
      lon[ineg]=360+lon[ineg] ;on passe toute les longitudes en 0-360
    ENDIF
    
  ;Read the variable specified in var_name

  var=fltarr(dim_lon, dim_lat,dim_t)
  
  FOR i=0,N_ELEMENTS(var_name)-1 DO BEGIN
    NCDF_VARGET, fid, NCDF_VARID(fid,var_name[i]), var_tmp
    var[*,*,*]=var_tmp    
    IF KEYWORD_SET(verbose) THEN  print,'ecmwf2geomat  : extraction du parametre  = '+var_name[i]
  END
    NCDF_CLOSE, fid

   IF KEYWORD_SET(verbose) THEN BEGIN
     lim_geo=STRING(MIN(lon),FORMAT='(F6.2)')+'/'+STRING(MAX(lon),FORMAT='(F6.2)')+'/'+STRING(MIN(lat),FORMAT='(F6.2)')+'/'+STRING(MAX(lat),FORMAT='(F6 .2)')
     print,'ecmwf2geomat  : Date de debut du fichier = ',print_date(stime[0],/SINGLE)
     print,'ecmwf2geomat  : Date de fin du fichier   = ',print_date(stime[N_ELEMENTS(stime)-1],/SINGLE)
     print,'ecmwf2geomat  : limite geographique      =',STRCOMPRESS(lim_geo)     
    ; print,'ecmwf2geomat  : extraction du parametre  = ',var_name
    ; print,'tugo2geomat  :          valeur du flag  = ',flg
    ; print,'tugo2geomat  :          facteur echelle = ',scl
   ENDIF

END