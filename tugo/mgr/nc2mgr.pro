FUNCTION nc2mgr, mgr, model_path=model_path,model_name=model_name, model_format=model_format , mgr_out_path=mgr_out_path, mgr_root_name=mgr_root_name
; fonction qui va creer un mgr a partir d'une structure mgr d'entree et d'une sortie de modele
; l'idee etant de creer un mgr_modele equivalent au mgr des obs pour faire les comparaisons
;   mgr                        => entrer une structure de type mgr
;   model_path   = '/data/netcdf/'   => indiquer le chemin qui contient les fichiers ondes.nc
;   model_name   = 'mertz_b9b2'      => indiquer le nom et la version de la simulation
;   model_format = '*.fes2004.nc'    => indiquer le format de recherche des fichiers netcdf
;   
 ;valeur par defaut
IF NOT KEYWORD_SET(model_path)   THEN model_path='/media/usb_data_idl/model_mertz/run_b9b1/netcdf/'
IF NOT KEYWORD_SET(model_name)   THEN model_name='model_default'
IF NOT KEYWORD_SET(model_format) THEN model_format='*.nc'
  ;si on ne donne pas le repertoire de stockage du mgr de sortie il est stocke au meme endroit que le mgr d'entree
IF NOT KEYWORD_SET(mgr_out_path) THEN mgr_out_path=FILE_DIRNAME(mgr[0].filename,/MARK_DIRECTORY)
IF KEYWORD_SET(mgr_root_name) THEN file_in=mgr_root_name ELSE file_in  = FILE_BASENAME(mgr[0].filename,'.mgr') 

nc_files = FILE_SEARCH(model_path+model_format) 
nwave    = N_ELEMENTS(nc_files)

;file_out = mgr_out_path+str_replace(file_in,'_obs','_mod_')+model_name
file_out = mgr_out_path+str_replace(file_in,'_mrg_','_mod_')+model_name+'.mgr'
cname    = cmset_op(mgr.name,'AND',mgr.name,COUNT=nsta) ;nsta=nbre de stations communes
mgr_mod  = create_mgr(nsta,nwave)
limit    = get_mgr_limit(mgr)
dl       = 2. ;on ajoute 2deg de chaque cote des limites
PRINT,'########################################',model_name,' ####################################'
FOR i=0,nwave-1 DO BEGIN ;on parcours toutes les ondes du model
  wname = file_basename(nc_files[i],'.nc')
  PRINT,"Traitement de l'onde :",wname
  geo   = read_tugo(nc_files[i],/TIDE,/VERBOSE) ;on lit l'onde i du model
  ;on decoupe la geomat autour des limites du mgr
  geo   = geocut(geo,limit=[limit[0]-dl,limit[1]+dl,limit[2]-dl,limit[3]+dl], /QUIET)
 FOR j=0,nsta-1 DO BEGIN ;on parcours les stations du .mgr
  ;on recupere les coordonnees de la station
  id_sta = WHERE(mgr.name EQ cname[j], n)
  lon    = mgr[id_sta[0]].lon
  lat    = mgr[id_sta[0]].lat
  PRINT,'#############recherche sur la station :',cname[j], '#####################'
  amp = geomat2val(geo,LON=lon,LAT=lat,/AMP,/VERBOSE)
  pha = geomat2val(geo,LON=lon,LAT=lat,/PHA,/VERBOSE)
  PRINT,'######################################'
   ;on remplit la structure
  mgr_mod[j].name     = cname[j]
  mgr_mod[j].origine  = model_name
  mgr_mod[j].enr      = 'Dfrom '+model_name+' atlas' ;attention cette ligne doit commencer par D??? (comme les mgr de mrg : Debut ...)
  mgr_mod[j].val      = 'no'                         ;c'est pour le tri des chaines de caracteres dans la lecture du read_mgr
  mgr_mod[j].lat      = lat
  mgr_mod[j].lon      = lon
  mgr_mod[j].nwav     = nwave
  mgr_mod[j].filename = file_out   
  mgr_mod[j].code[i]  = wave2code(wname)
  mgr_mod[j].wave[i]  = wname         ;on remplit les nwa premieres ondes
  mgr_mod[j].amp[i]   = amp
  mgr_mod[j].pha[i]   = pha
 ENDFOR
ENDFOR
 ;on ecrit le mgr_modele dans le repertoire des sorties netcdf
write_mgr, mgr_mod, FILENAME=file_out
PRINT,file_out
RETURN,mgr_mod
END