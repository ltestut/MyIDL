PRO convert_cats_ncdf, path=path

; Programme de conversion des données CATS2008 au format netcdf tide legos


path='/data2/model/model_mertz/travail_en_cours/cats_new/'
file_out='cats2008.nc'

file_h=path+'hf.CATs2008_ll.nc'
file_uv=path+'uv.CATs2008_ll.nc'


st_ncdf_h  =  read_cats_ncdf(file=file_h, var_name='h')
st_ncdf_u  =  read_cats_ncdf(file=file_uv, var_name='u')
st_ncdf_v  =  read_cats_ncdf(file=file_uv, var_name='v')

geo_h = create_geomat(st_ncdf_h.nx, st_ncdf_h.ny, /tide)
geo_u_cos = create_geomat(st_ncdf_u.nx, st_ncdf_u.ny, /tide)
geo_v_cos = create_geomat(st_ncdf_v.nx, st_ncdf_v.ny, /tide)

geo_h.lon = FLOAT(st_ncdf_h.lon[0,*])
geo_h.lat = FLOAT(st_ncdf_h.lat[*,0])
geo_u_cos.lon = FLOAT(st_ncdf_u.lon[0,*])
geo_u_cos.lat = FLOAT(st_ncdf_u.lat[*,0])
geo_v_cos.lon = FLOAT(st_ncdf_v.lon[0,*])
geo_v_cos.lat = FLOAT(st_ncdf_v.lat[*,0])

geo_u_sin = geo_u_cos
geo_v_sin = geo_v_cos

;st_total=st_ncdf_h

  FOR i=0, (st_ncdf_h.nw-1) ,1 DO BEGIN
    
    geo_u_cos.amp  = TRANSPOSE(st_ncdf_u.ua[*,*,i])/100.
    geo_u_cos.pha  = COS(!DTOR*TRANSPOSE(st_ncdf_u.ug[*,*,i]))
    geo_u_cos.info = st_ncdf_h.spectrum[i]+'U-var'


    geo_u_sin.pha  = SIN(!DTOR*TRANSPOSE(st_ncdf_u.ug[*,*,i]))
    geo_u_sin.info = st_ncdf_h.spectrum[i]+'U-var'
     
    geo_v_cos.amp  = TRANSPOSE(st_ncdf_v.va[*,*,i])/100.
    geo_v_cos.pha  = COS(!DTOR*TRANSPOSE(st_ncdf_v.vg[*,*,i]))
    geo_v_cos.info = st_ncdf_h.spectrum[i]+'V-var' 

    geo_v_sin.pha  = SIN(!DTOR*TRANSPOSE(st_ncdf_v.vg[*,*,i]))
    geo_v_sin.info = st_ncdf_h.spectrum[i]+'V-var'   
    
    geo_h.amp  = TRANSPOSE(st_ncdf_h.ha[*,*,i])
    geo_h.pha  = TRANSPOSE(st_ncdf_h.hg[*,*,i])
    geo_h.info = st_ncdf_h.spectrum[i]+'H-var'  
    
    geo_interpolate, geo_h, geo_u_cos, geo_h_out, geo_u_cos_out, /VERBOSE
    geo_interpolate, geo_h, geo_u_sin, geo_h_out, geo_u_sin_out, /VERBOSE
    
    geo_interpolate, geo_h, geo_v_cos, geo_h_out, geo_v_cos_out, /VERBOSE
    geo_interpolate, geo_h, geo_v_sin, geo_h_out, geo_v_sin_out, /VERBOSE
    
    lat_arr = FLTARR(N_ELEMENTS(geo_h_out.lat), N_ELEMENTS(geo_h_out.lon))
    lon_arr = lat_arr
    
    for k=0, N_ELEMENTS(geo_h_out.lon)-1 DO lon_arr[*,k]=geo_h_out.lon[k]
    for k=0, N_ELEMENTS(geo_h_out.lat)-1 DO lat_arr[k,*]=geo_h_out.lat[k]
    
    st_tmp=create_ncdf_st_tide(lat=lat_arr, lon=lon_arr, nwave=1)
    
    st_tmp.ha=TRANSPOSE(geo_h_out.amp[*,*])
    id_flag  = WHERE((st_tmp.ha NE st_tmp.ha), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.ha[id_flag]=-9999
    
    st_tmp.hg=TRANSPOSE(geo_h_out.pha[*,*])
    id_flag  = WHERE((st_tmp.hg NE st_tmp.hg), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.hg[id_flag]=-9999
    
    st_tmp.ua=TRANSPOSE(geo_u_cos_out.amp[*,*])
    id_flag  = WHERE((st_tmp.ua NE st_tmp.ua), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.ua[id_flag]=-9999
    
    st_tmp.ug=TRANSPOSE(ATAN(geo_u_sin_out.pha[*,*], geo_u_cos_out.pha[*,*])*!RADEG)
    id_flag  = WHERE((st_tmp.ug NE st_tmp.ug), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.ug[id_flag]=-9999
    
    st_tmp.va=TRANSPOSE(geo_v_cos_out.amp[*,*])
    id_flag  = WHERE((st_tmp.va NE st_tmp.va), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.va[id_flag]=-9999
    
    st_tmp.vg=TRANSPOSE(ATAN(geo_v_sin_out.pha[*,*], geo_v_cos_out.pha[*,*])*!RADEG)
    id_flag  = WHERE((st_tmp.vg NE st_tmp.vg), cnt)
    IF ( cnt GT 0 ) THEN st_tmp.vg[id_flag]=-9999
    
       
    file_out_name=STRCOMPRESS(STRUPCASE(st_ncdf_h.spectrum[i])+'_huv.'+file_out, /REMOVE_ALL)  
    file_out_name=path+file_out_name
    write_tide_ncdf, file_out_name, ST_NCDF=st_tmp

  ENDFOR

;FOR j=0, 2, 1 DO BEGIN
;  st_ncdf  = read_cats_ncdf(file=file[j],  var_name=var[j])
;  
;  FOR i=0, (st_ncdf.nw-1) ,1 DO BEGIN
;    st_tmp=create_ncdf_st_tide(lat=st_ncdf.lat, lon=st_ncdf.lon, var_name=var[j], nwave=1)
;    st_tmp.var_a=st_ncdf.var_a[*,*,i]
;    st_tmp.var_g=st_ncdf.var_g[*,*,i]
;    file_out_name=STRCOMPRESS(st_ncdf.spectrum[i]+'.'+var[j]+'.'+file_out, /REMOVE_ALL)
;  
;    file_out_name=path+file_out_name
;    write_tide_ncdf, file_out_name, ST_NCDF=st_tmp
;
;  ENDFOR
;ENDFOR


END