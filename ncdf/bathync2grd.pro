PRO bathync2grd, filename=filename
; fichier qui convertit les bathy au format netcdf en .grd lisible par xscan 

; lecture du fichier de bathy au format netcdf
filename='/data/genesis/topography/etopo-2/indiano2.nc'
;filename='/data/genesis/topography/etopo-5/indiano5.nc'

;################################################################
;### read your nc file and get the lon,lat and bathy variable  ##
;################################################################
id   = NCDF_OPEN(filename)
info = NCDF_INQUIRE(id)   ;=> renvoie les info sur le fichier NetCDF dans la structure info
NCDF_DIMINQ,id,1,namex,Nx
NCDF_DIMINQ,id,0,namey,Ny

print, 'dim x -longitude- : ', Nx,' = ',namex
print, 'dim y -latitude - : ', Ny,' = ',namey

; Recupere les variables x,y,z
NCDF_VARGET,id,NCDF_VARID(id,'longitude'),X  ;X should always be the longitude
NCDF_VARGET,id,NCDF_VARID(id,'latitude'),Y   ;Y should always be the longitude
NCDF_VARGET,id,NCDF_VARID(id,'depth'),Z      ;Z should always be a matrix
NCDF_CLOSE, id


;################################################################
;### compute the variable needed by the grd file              ##
;################################################################

 ;apply some modification to the matrix
Z     = ROTATE(1.*Z,7)
zr    = REFORM(Z,N_ELEMENTS(Z))
Nz    = N_ELEMENTS(zr)
x_range=[MIN(X),MAX(X)]
y_range=[MIN(Y),MAX(Y)]
z_range=[MIN(Z),MAX(Z)]

 ;compute spacing
sp_x = (DOUBLE(x_range[1])-DOUBLE(x_range[0]))/(Nx-1)
sp_y = (DOUBLE(y_range[1])-DOUBLE(y_range[0]))/(Ny-1)
print,'Spacing =',sp_x,sp_y

 ; create output file
IF NOT KEYWORD_SET(file_out) THEN file_out=FILE_DIRNAME(filename)+'/output.grd' 
id        = NCDF_CREATE(file_out,/CLOBBER)
side_id   = NCDF_DIMDEF(id,'side',2)
xysize_id = NCDF_DIMDEF(id,'xysize',Nz)


NCDF_ATTPUT, id, /GLOBAL, 'title', 'Transform to grd with bathync2grd.pro / L. Testut'
NCDF_ATTPUT, id, /GLOBAL, 'source', filename

; Création des variables
; Création des definitions de variables et de leur attributs
id_x_range=NCDF_VARDEF(id, 'x_range',  [side_id], /double) 
NCDF_ATTPUT, id, id_x_range, 'long_name', 'longitude'
NCDF_ATTPUT, id, id_x_range, 'units', 'degrees_east'
NCDF_ATTPUT, id, id_x_range, 'actual_range', x_range
id_y_range=NCDF_VARDEF(id, 'y_range',  [side_id], /double)
NCDF_ATTPUT, id, id_y_range, 'long_name', 'latitude'
NCDF_ATTPUT, id, id_y_range, 'units', 'degrees_north'
NCDF_ATTPUT, id, id_y_range, 'actual_range', y_range
id_z_range=NCDF_VARDEF(id, 'z_range',  [side_id], /double)
NCDF_ATTPUT, id, id_z_range, 'long_name', 'bathymetry'
NCDF_ATTPUT, id, id_z_range, 'units', 'meter'
NCDF_ATTPUT, id, id_z_range, 'actual_range', z_range
id_spacing=NCDF_VARDEF(id, 'spacing',  [side_id], /double)
NCDF_ATTPUT, id, id_spacing, 'long_name', 'spacing'
id_dimension=NCDF_VARDEF(id, 'dimension',[side_id], /long)
NCDF_ATTPUT, id, id_dimension, 'long_name', 'dimension'
id_z=NCDF_VARDEF(id, 'z',        [xysize_id], /SHORT)
NCDF_ATTPUT, id, id_z, 'scale_factor', 1
NCDF_ATTPUT, id, id_z, 'units', "meters"
NCDF_ATTPUT, id, id_z, 'add_offset', 0
NCDF_ATTPUT, id, id_z, 'node_offset', 0
;NCDF_ATTPUT, id, id_z, "_FillValue", -9999.


; ecriture des données
; --------------------
NCDF_CONTROL, id, /ENDEF 

NCDF_VARPUT, id, id_x_range, x_range
NCDF_VARPUT, id, id_y_range, y_range
NCDF_VARPUT, id, id_z_range, z_range
NCDF_VARPUT, id, id_spacing, [sp_x,sp_y]
NCDF_VARPUT, id, id_dimension, [Nx,Ny]
NCDF_VARPUT, id, id_z, zr

NCDF_CLOSE, id


;I have found that a grd file needs the following:
;
;a global attribute called "title"
;a global attribute called "source"
;a dimension named "side"
;a dimension named "x_range" with attribute "units"
;a variable named "y_range" with attribute "units"
;a variable named "z_range" with attribute "units"
;a variable named "spacing"
;a variable named "dimension"
;a variable named "z" with attributes "units", "node_offset",
;"scale_factor", "add_offset"
;
;compare the grd file that you are creating with one of the examples
;in the release and make sure that EVERYTHING is there and has the right name

END