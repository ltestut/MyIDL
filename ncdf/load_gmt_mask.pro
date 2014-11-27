FUNCTION load_gmt_mask
; load a mask made with the grdlandmask GMT command
mask_file = !IDL_ROOT_PATH+'idl/data/land_mask.grd'
id        = NCDF_OPEN(mask_file)
NCDF_DIMINQ,id,0,lon_name,nx
NCDF_DIMINQ,id,1,lat_name,ny
geo       = create_geomat(nx,ny) ;initialisation de la structure geomat geo(lon,lat,time)
NCDF_VARGET,id,NCDF_VARID(id,lon_name),lon
NCDF_VARGET,id,NCDF_VARID(id,lat_name),lat
NCDF_VARGET,id,NCDF_VARID(id,'z')     ,val
geo.info='GMT land mask'
geo.filename=mask_file
geo.lon=lon
geo.lat=lat
geo.val=val
RETURN,geo
END