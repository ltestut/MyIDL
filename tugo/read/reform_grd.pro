PRO reform_grd, filename, title=title, source=source
;fonction qui va lire un .grd et le ecrire dans une forme utilisable pour XSCAN

IF NOT KEYWORD_SET(title) THEN title='Data reformatted to XSCAN standard format with reform_grd.pro (L. Testut)'
IF NOT KEYWORD_SET(source) THEN source=filename

; lecture du fichier grd d'origine
id_in  = NCDF_OPEN(filename)
info   = NCDF_INQUIRE(id_in)   ;=> renvoie les info sur le fichier NetCDF dans la structure info
NCDF_DIMINQ,id_in,0,name,Nx
NCDF_DIMINQ,id_in,1,name,Ny
 ;recupere les valeurs limites des variables x,y,z
NCDF_VARGET,id_in,NCDF_VARID(id_in,'x_range'),x_range
NCDF_VARGET,id_in,NCDF_VARID(id_in,'y_range'),y_range
NCDF_VARGET,id_in,NCDF_VARID(id_in,'z_range'),z_range
NCDF_VARGET,id_in,NCDF_VARID(id_in,'spacing'),spacing
NCDF_VARGET,id_in,NCDF_VARID(id_in,'dimension'),dimension
NCDF_VARGET,id_in,NCDF_VARID(id_in,'z'),z

PRINT, 'Filename : ',filename
PRINT, 'dim x: ', Nx, '   / dim y : ', Ny
PRINT, 'x_range = ',x_range
PRINT, 'y_range = ',y_range
PRINT, 'z_range = ',z_range
PRINT, 'spacing deg = ',spacing
PRINT, 'spacing (1/N) deg = ',1/spacing
PRINT, 'spacing min = ',spacing*60.
PRINT, 'spacing sec = ',spacing*3600.
PRINT, 'dimension = ',dimension

; création du fichier de sortie
info_file = getfilename(filename)
file_in   = info_file.namestem+STRCOMPRESS(info_file.number,/REMOVE_ALL)
file_out  =  file_in+'_rf.grd'
SPAWN,'rm '+file_out
print,file_in
print,file_out


IF (info_file.name EQ 'bathy_roms_hristina_22.grd') THEN z=z*(-1.)

;on supprime mes valeurs positives de la bathy
id_pos = WHERE(z GT 0,count)
IF (count GT 1) THEN z[id_pos] = !VALUES.F_NAN
z_new   = FIX(z)
z_range = [MIN(z_new,/NAN),MAX(z_new,/NAN)]
help,z
help,z_new

;creation du fichier de sortie
id=NCDF_CREATE(file_out)
; Creation des dimensions et des attributs globaux
side_id   = NCDF_DIMDEF(id,'side',2)
xysize_id = NCDF_DIMDEF(id,'xysize',Ny)
IF (info.ngatts GE 1) THEN BEGIN ;on reecrit les attributs globaux du fichiers d'origine
 FOR i=0,info.ngatts-1 DO BEGIN
  att_name = NCDF_ATTNAME(id_in, i, /GLOBAL)
  value    = ''
  IF (att_name NE 'history') THEN BEGIN
  NCDF_ATTGET, id_in , att_name, value, /GLOBAL
  IF (att_name EQ 'title' AND STRING(value) EQ '') THEN value='A'
  print,att_name,'=',STRING(value)
  IF (STRING(value) NE '') THEN NCDF_ATTPUT, id, /GLOBAL, NCDF_ATTNAME( id_in, i, /GLOBAL), STRING(value)
  ENDIF
 ENDFOR
ENDIF
;NCDF_ATTPUT, id, /GLOBAL, 'Conventions', 'aucune'
NCDF_ATTPUT, id, /GLOBAL, 'info', title
NCDF_ATTPUT, id, /GLOBAL, 'src_file', source

IF (info_file.name EQ 'bathy_nemo_natacha_12.grd') THEN BEGIN ;on shift de 1/30.deg les donnees de cette bathy
  x_range = x_range ;- (1./20.)
  y_range = y_range - (1./4.)  
ENDIF


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
NCDF_ATTPUT, id, id_z, 'add_offset', 0
NCDF_ATTPUT, id, id_z, 'node_offset', 0
;NCDF_ATTPUT, id, id_z, "_FillValue", -9999.

; ecriture des données
; --------------------
NCDF_CONTROL, id, /VERBOSE
NCDF_CONTROL, id, /ENDEF 
NCDF_VARPUT, id, id_x_range, x_range
NCDF_VARPUT, id, id_y_range, y_range
NCDF_VARPUT, id, id_z_range, z_range
NCDF_VARPUT, id, id_spacing, spacing
NCDF_VARPUT, id, id_dimension, dimension
NCDF_VARPUT, id, id_z, z_new
NCDF_CLOSE, id_in ;on ferme le fichier d'origine
NCDF_CLOSE, id    ;on ferme le fichier que l'on vient de creer
END