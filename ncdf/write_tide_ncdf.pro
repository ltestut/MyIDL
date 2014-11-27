PRO write_tide_ncdf, filename, st_ncdf=st_ncdf, nwave=nwave

; Procedure qui ecrit un NETCDF de type tide LEGOS à partir d'une structure netcdf créée par create_ncdf_st_tide



IF NOT KEYWORD_SET(filename) THEN filename='/home/olvac/testut/test.nc'

IF NOT KEYWORD_SET(nwave) THEN nwave=st_ncdf.nw

; open the netcdf file (/CLOBBER : erase the former one if exist)
fid = NCDF_CREATE(filename,/CLOBBER)

; define the dimension 
id_x    = NCDF_DIMDEF(fid, 'x', st_ncdf.nx)
id_y    = NCDF_DIMDEF(fid, 'y', st_ncdf.ny)
id_w    = NCDF_DIMDEF(fid, 'w', nwave)
id_l    = NCDF_DIMDEF(fid, 'l', st_ncdf.nl)

print,fid
print,st_ncdf.nw,st_ncdf.nx,st_ncdf.ny
; define the variable
;id_var     =         id_file, var_name       dimension (!inverse order) , type)
id_lon      = NCDF_VARDEF(fid, 'lon',         [id_x,id_y]     , /DOUBLE)
id_lat      = NCDF_VARDEF(fid, 'lat',         [id_x,id_y]     , /DOUBLE)
id_spectrum = NCDF_VARDEF(fid, 'spectrum',    [id_l,id_w]     , /CHAR)
id_ha       = NCDF_VARDEF(fid, 'Ha',          [id_x,id_y,id_w], /FLOAT)
id_hg       = NCDF_VARDEF(fid, 'Hg',          [id_x,id_y,id_w], /FLOAT)
id_ua       = NCDF_VARDEF(fid, 'Ua',          [id_x,id_y,id_w], /FLOAT)
id_ug       = NCDF_VARDEF(fid, 'Ug',          [id_x,id_y,id_w], /FLOAT)
id_va       = NCDF_VARDEF(fid, 'Va',          [id_x,id_y,id_w], /FLOAT)
id_vg       = NCDF_VARDEF(fid, 'Vg',          [id_x,id_y,id_w], /FLOAT)
id_bathy    = NCDF_VARDEF(fid, 'bathy',       [id_x,id_y]     , /FLOAT)

; attribute fo variable LON
NCDF_ATTPUT, fid, id_lon,    "units",          "degree_east"
NCDF_ATTPUT, fid, id_lon,    "valid_min",       st_ncdf.lon_min
NCDF_ATTPUT, fid, id_lon,    "valid_max",       st_ncdf.lon_max
NCDF_ATTPUT, fid, id_lon,    "long_name",      "longitude"
NCDF_ATTPUT, fid, id_lon,    "standard_name",  "longitude"
NCDF_ATTPUT, fid, id_lon,    "nav_model",      "Default grid" 
; attribute fo variable LAT
NCDF_ATTPUT, fid, id_lat,    "units",          "degrees_north"
NCDF_ATTPUT, fid, id_lat,    "valid_min",       st_ncdf.lat_min
NCDF_ATTPUT, fid, id_lat,    "valid_max",       st_ncdf.lat_max
NCDF_ATTPUT, fid, id_lat,    "long_name",      "latitude"
NCDF_ATTPUT, fid, id_lat,    "standard_name",  "latitude"
NCDF_ATTPUT, fid, id_lat,    "nav_model",      "Default grid" 

; attribute fo variable SPECTRUM
NCDF_ATTPUT, fid, id_spectrum,    "long_name",      "tidal_spectrum"


; attribute fo variable HA
  NCDF_ATTPUT, fid, id_ha,      "long_name",      "tidal_amplitude"
  NCDF_ATTPUT, fid, id_ha,      "short_name",     "Ha"
  NCDF_ATTPUT, fid, id_ha,      "units",          "m"
  NCDF_ATTPUT, fid, id_ha,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_ha,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_ha,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_ha,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_ha,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_ha,      "associate",      "spectrum lat lon"
; attribute fo variable HG
  NCDF_ATTPUT, fid, id_hg,      "long_name",      "tidal_phase_lag"
  NCDF_ATTPUT, fid, id_hg,      "short_name",     "Hg"
  NCDF_ATTPUT, fid, id_hg,      "units",          "degrees"
  NCDF_ATTPUT, fid, id_hg,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_hg,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_hg,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_hg,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_hg,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_hg,      "associate",      "spectrum lat lon"


; attribute fo variable UA
  NCDF_ATTPUT, fid, id_ua,      "long_name",      "tidal_eastward_current_amplitude"
  NCDF_ATTPUT, fid, id_ua,      "short_name",     "Ua"
  NCDF_ATTPUT, fid, id_ua,      "units",          "m/s"
  NCDF_ATTPUT, fid, id_ua,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_ua,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_ua,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_ua,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_ua,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_ua,      "associate",      "spectrum lat lon"
; attribute fo variable UG
  NCDF_ATTPUT, fid, id_ug,      "long_name",      "tidal_eastward_current_phase_lag"
  NCDF_ATTPUT, fid, id_ug,      "short_name",     "Ug"
  NCDF_ATTPUT, fid, id_ug,      "units",          "degrees"
  NCDF_ATTPUT, fid, id_ug,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_ug,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_ug,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_ug,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_ug,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_ug,      "associate",      "spectrum lat lon"


; attribute fo variable VA
  NCDF_ATTPUT, fid, id_va,      "long_name",      "tidal_northward_current_amplitude"
  NCDF_ATTPUT, fid, id_va,      "short_name",     "Va"
  NCDF_ATTPUT, fid, id_va,      "units",          "m/s"
  NCDF_ATTPUT, fid, id_va,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_va,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_va,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_va,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_va,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_va,      "associate",      "spectrum lat lon"
; attribute fo variable VG
  NCDF_ATTPUT, fid, id_vg,      "long_name",      "tidal_northward_current_phase_lag"
  NCDF_ATTPUT, fid, id_vg,      "short_name",     "Vg"
  NCDF_ATTPUT, fid, id_vg,      "units",          "degrees"
  NCDF_ATTPUT, fid, id_vg,      "_FillValue",     -9999.
  NCDF_ATTPUT, fid, id_vg,      "missing_value",  -9999.
  NCDF_ATTPUT, fid, id_vg,      "scale_factor",   1.      
  NCDF_ATTPUT, fid, id_vg,      "add_offset",     0.
  NCDF_ATTPUT, fid, id_vg,      "axis",           "WYX"
  NCDF_ATTPUT, fid, id_vg,      "associate",      "spectrum lat lon"


; attribute fo variable BATHYMETRY
NCDF_ATTPUT, fid, id_bathy,   "units",          "m"
NCDF_ATTPUT, fid, id_bathy,   "long_name",      "bathymetry"
NCDF_ATTPUT, fid, id_bathy,   "standard_name",  "bathymetry"
NCDF_ATTPUT, fid, id_bathy,   "short_name",     "bathymetry"
NCDF_ATTPUT, fid, id_bathy,   "axis",           "YX"
NCDF_ATTPUT, fid, id_bathy,   "associate",      "lat lon" 
NCDF_ATTPUT, fid, id_bathy,   "missing_value",  -9999.
NCDF_ATTPUT, fid, id_bathy,   "_FillValue" ,    -9999.
NCDF_ATTPUT, fid, id_bathy,   "scale_factor",   1.
NCDF_ATTPUT, fid, id_bathy,   "offset",         0.

NCDF_CONTROL, fid, /VERBOSE
NCDF_CONTROL, fid, /ENDEF

lon_arr   = st_ncdf.lon
lat_arr   = st_ncdf.lat
bathy_arr = st_ncdf.bathy
ha_arr    = st_ncdf.ha
hg_arr    = st_ncdf.hg
ua_arr    = st_ncdf.ua
ug_arr    = st_ncdf.ug
va_arr    = st_ncdf.va
vg_arr    = st_ncdf.vg

;lon_arr   = TRANSPOSE(st_ncdf.lon)
;lat_arr   = TRANSPOSE(st_ncdf.lat)
;bathy_arr = TRANSPOSE(st_ncdf.bathy)
;ha_arr    = TRANSPOSE(st_ncdf.ha)
;hg_arr    = TRANSPOSE(st_ncdf.hg)
;ua_arr    = TRANSPOSE(st_ncdf.ua)
;ug_arr    = TRANSPOSE(st_ncdf.ug)
;va_arr    = TRANSPOSE(st_ncdf.va)
;vg_arr    = TRANSPOSE(st_ncdf.vg)

NCDF_VARPUT, fid, id_ha, ha_arr
NCDF_VARPUT, fid, id_hg, hg_arr
NCDF_VARPUT, fid, id_ua, ua_arr
NCDF_VARPUT, fid, id_ug, ug_arr
NCDF_VARPUT, fid, id_va, va_arr
NCDF_VARPUT, fid, id_vg, vg_arr
NCDF_VARPUT, fid, id_lon, lon_arr    
NCDF_VARPUT, fid, id_lat,    lat_arr
NCDF_VARPUT, fid, id_bathy,   bathy_arr


NCDF_CLOSE, fid
END