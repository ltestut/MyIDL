PRO grd2grd, filename=filename

;+ 
;UTILISATION :  grd2grd, filename=filename
;
;Ce programme convertit un fichier .grd en un fichier .grd lisible par xscan.
;
;-


; lecture du fichier grd
id  = NCDF_OPEN(filename)
info= NCDF_INQUIRE(id)   ;=> renvoie les info sur le fichier NetCDF dans la structure info
NCDF_DIMINQ,id,0,name,Nx
NCDF_DIMINQ,id,1,name,Ny

print, 'dim x: ', Nx, 'dim y : ', Ny

; Recupere les variables x,y,z
NCDF_VARGET,id,NCDF_VARID(id,'x'),X
NCDF_VARGET,id,NCDF_VARID(id,'y'),Y
NCDF_VARGET,id,NCDF_VARID(id,'z'),Z
Z  = ROTATE(Z,7)
zr = REFORM(Z,N_ELEMENTS(Z))
Nz = N_ELEMENTS(zr)


; Recupere les valeurs limites des variables x,y,z
NCDF_ATTGET, id, NCDF_VARID(id,'x') , 'actual_range', Xrange
NCDF_ATTGET, id, NCDF_VARID(id,'y') , 'actual_range', Yrange
NCDF_ATTGET, id, NCDF_VARID(id,'z') , 'actual_range', Zrange
; calcul du spacing
sp_x = (Xrange[1]-Xrange[0])/(Nx-1)
sp_y = (Yrange[1]-Yrange[0])/(Ny-1)
print,'Spacing =',sp_x,sp_y
NCDF_CLOSE, id


; création du fichier de sortie


info_file=getfilename(filename)
file_out=info_file.namestem+'_xscan.grd'
SPAWN,'rm '+file_out
print,file_out
id=NCDF_CREATE(file_out)

; Creation des dimensions
side_id   = NCDF_DIMDEF(id,'side',2)
xysize_id = NCDF_DIMDEF(id,'xysize',Nz)


; Création des variables
id_x_range=NCDF_VARDEF(id, 'x_range',  [side_id], /double) 
NCDF_ATTPUT, id, id_x_range, 'long_name', 'lon'
NCDF_ATTPUT, id, id_x_range, 'actual_range', Xrange

id_y_range=NCDF_VARDEF(id, 'y_range',  [side_id], /double)
NCDF_ATTPUT, id, id_y_range, 'long_name', 'lat'
NCDF_ATTPUT, id, id_y_range, 'actual_range', Yrange

id_z_range=NCDF_VARDEF(id, 'z_range',  [side_id], /double)
NCDF_ATTPUT, id, id_z_range, 'long_name', 'z'
NCDF_ATTPUT, id, id_z_range, 'actual_range', Zrange

id_spacing=NCDF_VARDEF(id, 'spacing',  [side_id], /double)
NCDF_ATTPUT, id, id_x_range, 'long_name', 'spacing'

id_dimension=NCDF_VARDEF(id, 'dimension',[side_id], /long)
NCDF_ATTPUT, id, id_x_range, 'long_name', 'dimension'

id_z=NCDF_VARDEF(id, 'z',        [xysize_id], /float)


; ecriture des données
; --------------------
NCDF_CONTROL, id, /ENDEF 

NCDF_VARPUT, id, id_x_range, Xrange
NCDF_VARPUT, id, id_y_range, Yrange
NCDF_VARPUT, id, id_z_range, Zrange
NCDF_VARPUT, id, id_spacing, [sp_x,sp_y]
NCDF_VARPUT, id, id_dimension, [Nx,Ny]
NCDF_VARPUT, id, id_z, zr

NCDF_CLOSE, id
END