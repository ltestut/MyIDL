PRO read_mog2d,ibd,h,lon,lat,time

;file2_ncdf='F:\data\mog2d-global\global-0.5-2001.01.huv.nc'
;file_ncdf='H:\data\tugo\simu_old_mesh\AUTO-2001.03.huv.old.nc'
file_ncdf='/data/model/tugo/ker_fev_2004.nc'
;file_ncdf = '/periph/disk1/data/mog2d-global/global-0.5-2001.01.huv.nc'
id        = NCDF_OPEN(file_ncdf)
NCDF_VARGET, id, NCDF_VARID(id,'lon'),    lon
NCDF_VARGET, id, NCDF_VARID(id,'lat'),    lat
NCDF_VARGET, id, NCDF_VARID(id,'time'),   stime
NCDF_VARGET, id, NCDF_VARID(id,'ibd'),    ibd ;cm
NCDF_VARGET, id, NCDF_VARID(id,'h'),      h   ;m

nan       = 1e35 ;for MOG2D global
inan      = WHERE(ibd EQ nan,count)
IF (count GT 0) THEN BEGIN
ibd[inan] = !VALUES.F_NAN
h[inan]   = !VALUES.F_NAN
ENDIF
time=stime/(3600.*24.)+JULDAY(1,1,1950,0,0,0)


NCDF_CLOSE,id
END
