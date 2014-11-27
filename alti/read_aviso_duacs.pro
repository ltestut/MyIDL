FUNCTION read_aviso_duacs_along_track, filename
; function to read the along-track netcdf from ftp.aviso.altimetry.fr
; using the new DUACS2014 version

IF NOT KEYWORD_SET(filename) THEN filename=!idl_satpass_arx+$
   'dt_UPD_GLOBAL_tpn_sla_VxxC_20021223_20140325.nc'

id = NCDF_OPEN(filename)              ;ouverture du fichier netdcf
NCDF_VARGET,id,NCDF_VARID(id,'time'),time
NCDF_VARGET,id,NCDF_VARID(id,'longitude'),lo 
NCDF_VARGET,id,NCDF_VARID(id,'latitude') ,la 
NCDF_ATTGET,id,NCDF_VARID(id,'longitude'),'scale_factor',lonscale
NCDF_ATTGET,id,NCDF_VARID(id,'latitude'),'scale_factor',latscale
NCDF_VARGET,id,NCDF_VARID(id,'cycle') ,cycle  ;cycle
NCDF_VARGET,id,NCDF_VARID(id,'track') ,track  ;track
NCDF_VARGET,id,NCDF_VARID(id,'SLA') ,sla      ;sla
NCDF_CLOSE,id
lon=LIST(lo*lonscale,/EXTRACT)
lat=LIST(la*latscale,/EXTRACT)
cyc=LIST(cycle,/EXTRACT)
pass=LIST(track,/EXTRACT)
time=LIST(time+JULDAY(1,1,1950,0,0,0),/EXTRACT)
RETURN,{lon:lon,lat:lat,cyc:cyc,pass:pass,time:time}
END

FUNCTION read_aviso_duacs_grid, filename, err=err
; function to read the netcdf extract from AVISO+ web site
; using the data extraction tool DUACS2014

id = NCDF_OPEN(filename)              ;ouverture du fichier netdcf
NCDF_DIMINQ,id,0,dim_0_name,ntime     ;get dim 0 : time number
NCDF_DIMINQ,id,1,dim_1_name,nlat      ;get dim 1 : lat number
NCDF_DIMINQ,id,2,dim_2_name,nlon      ;get dim 2 : lon number
NCDF_ATTGET,id,/GLOBAL,'title',info   ;get product title
geo=geo_create(nlon,nlat,ntime)
NCDF_VARGET,id, NCDF_VARID(id,'lon') ,lon ;longitude variable
NCDF_VARGET,id, NCDF_VARID(id,'lat') ,lat ;latitude  variable
NCDF_VARGET,id, NCDF_VARID(id,'time'),time
IF KEYWORD_SET(err) THEN vid=NCDF_VARID(id,'err') ELSE $
  vid=NCDF_VARID(id,'sla')
NCDF_VARGET,id,vid,val
NCDF_ATTGET,id,vid,'scale_factor',scale
NCDF_ATTGET,id,vid,'_FillValue',fnan
val=flag_matrix3d(FLOAT(val),equal=FLOAT(fnan),/VERBOSE)
jtime=time+JULDAY(1,1,1950,0,0,0)
print,"Start date : ",print_date(jtime[0],/SINGLE)
print,"End   date : ",print_date(jtime[-1],/SINGLE)
 ;;TODO  check the grid system and
geo.filename = FILE_BASENAME(filename)
geo.info     = STRING(info)
geo.lon      = lon
geo.lat      = lat
geo.jul      = jtime
geo.val      = val*scale
RETURN,geo   
END

FUNCTION read_aviso_duacs,filename,err=err,along_track=along_track,grid=grid
; read the along_track and gridded data
IF KEYWORD_SET(along_track) THEN RETURN,read_aviso_duacs_along_track(filename)
IF KEYWORD_SET(grid) THEN RETURN,read_aviso_duacs_grid(filename, err=err)
END