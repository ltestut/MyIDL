file='/data/model_indien_sud/zone_ker_mr/simu_tide/run_sequential_obc_got4.7/M2.sequential.nc'
fid=NCDF_OPEN(file)
NCDF_VARGET, fid, NCDF_VARID(fid,'lon'), lon
NCDF_VARGET, fid, NCDF_VARID(fid,'lat'), lat
NCDF_VARGET, fid, NCDF_VARID(fid,'bathymetry'), bathy

N=N_ELEMENTS(lon)

; Triangulate the mesh to establish connectivity.
TRIANGULATE, lon, lat, tr, /DEGREES, SPHERE=s, FVALUE=bathy

; Perform a spherical triangulation using the values returned from
; TRIANGULATE. The result, r, is a 180 by 91 element array:
;r=TRIGRID(bathy, [1.,1.],[MIN(lon), MIN(lat), MAX(lon), MAX(lat)],SPHERE=s,/DEGREES,NX=150,NY=150)
r=TRIGRID(bathy,[0.01,0.01],[MIN(lon), MIN(lat), MAX(lon), MAX(lat)],SPHERE=s,/DEGREES,$
           NX=567,NY=284,XGRID=glon,YGRID=glat)

s=SURFACE(r)
