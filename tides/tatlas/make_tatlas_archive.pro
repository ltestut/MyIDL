PRO make_tatlas_archive, filepath, name=name, descr=descr, $
                               search_format=search_format,$
                               info=info, $
                               mode=mode, obc=obc, bathy=bathy, assimilation=assimilation, $
                               uv=uv, huv=huv,$
                               varname=varname 

;prog to archive a tidal atlas in .sav format 
;
;init default value
 
type    = 10

 ;input keyword for atlas information 
IF NOT KEYWORD_SET(info)  THEN info  = filepath
IF NOT KEYWORD_SET(mode)  THEN mode  = 'N/A'
IF NOT KEYWORD_SET(obc)   THEN obc   = 'N/A'
IF NOT KEYWORD_SET(bathy) THEN bathy = 'N/A'
IF NOT KEYWORD_SET(assimilation) THEN assimilation = 'N/A'

IF NOT KEYWORD_SET(varname) THEN varname = ['H']  ;defaule value
IF KEYWORD_SET(uv) THEN varname=['U','V']
IF KEYWORD_SET(uv) THEN type=11
IF KEYWORD_SET(huv) THEN varname=['H','U','V']
IF KEYWORD_SET(huv) THEN type=12
IF KEYWORD_SET(huv) THEN huv=1

IF NOT KEYWORD_SET(search_format) THEN search_format='.nc'

 ;lecture de la liste des fichiers de l'atlas de maree
nc_files = FILE_SEARCH(filepath+'*'+search_format) 
nwave    = N_ELEMENTS(nc_files)

fid  = NCDF_OPEN(nc_files[0])                    ;ouverture du 1er fichier pour recuperer la taille de la grille
NCDF_VARGET, fid, NCDF_VARID(fid,'lon'),  lon  ;lon(nlon,nlat) ou lon(x,y)
NCDF_VARGET, fid, NCDF_VARID(fid,'lat'),  lat  ;lat(nlon,nlat) ou lat(x,y)
NCDF_CLOSE,  fid

PRINT,'-----------------INFO---------------------'
PRINT,info
PRINT,'-----------------INFO---------------------'

 ;recuperation des dimensions x et y et creation de l'atlas de maree
dim_x= N_ELEMENTS(lon[*,0]) ;ncdf_read_dim(NAME1='x', NAME2='X', NCDF_ID=fid)
dim_y= N_ELEMENTS(lon[0,*]) ;ncdf_read_dim(NAME1='y', NAME2='Y', NCDF_ID=fid)
tatlas      = create_tatlas(dim_x,dim_y,nwave,HUV=huv)
tatlas.assimilation = assimilation
tatlas.info   = info
tatlas.mode   = mode
tatlas.obc    = obc
tatlas.bathy  = bathy
tatlas.type = type
tatlas.lon  = lon[*,0]
tatlas.lat  = lat[0,*]
ineg        = WHERE(tatlas.lon LT 0.,cneg)
IF (cneg GT 0) THEN tatlas.lon[ineg]=360+tatlas.lon[ineg] ;on passe toute les longitudes en 0-360

FOR i=0,nwave-1 DO BEGIN                             ;on parcours toutes les ondes du model
 ; wname = (STRSPLIT(FILE_BASENAME(nc_files[i]),search_format,/EXTRACT))(0)
  wname = STRSPLIT(FILE_BASENAME(nc_files[i]),search_format,/EXTRACT,/REGEX)
  fid  = NCDF_OPEN(nc_files[i])                       ;ouverture du fichier i
  PRINT,"Traitement de l'onde :",wname
  FOR j=0,N_ELEMENTS(varname)-1 DO BEGIN            ;on parcours toutes les variables du fichier i
    NCDF_VARGET, fid, NCDF_VARID(fid,varname[j]+'a'), var_amp
    NCDF_ATTGET, fid, NCDF_VARID(fid,varname[j]+'a'), '_FillValue', flg
    NCDF_ATTGET, fid, NCDF_VARID(fid,varname[j]+'a'), 'scale_factor', scl
;    scl=1.
    NCDF_VARGET, fid, NCDF_VARID(fid,varname[j]+'g'), var_pha
  IF (flg GT 0) THEN BEGIN
     Xa      = flag_matrix(var_amp,seuil=flg) ;/!\ au difference de flag des sorties de modeles
     Xg      = flag_matrix(var_pha,seuil=flg) ;/!\ au difference de flag des sorties de modeles
  ENDIF ELSE IF (flg LT 0) THEN BEGIN
     Xa      = flag_matrix(var_amp,seuil=flg, /less)
     Xg      = flag_matrix(var_pha,seuil=flg, /less)
  ENDIF ELSE IF (flg EQ 0.0) THEN BEGIN
     Xa      = flag_matrix(var_amp,seuil=flg, /EQUAL)
     Xg      = flag_matrix(var_pha,seuil=flg, /EQUAL)
  ENDIF    
     Xa  = TEMPORARY(Xa)*scl
     Xg  = TEMPORARY(Xg)*scl
     neg = WHERE( Xg LT 0. , cnt_neg)                            ; passage de -180/180 à 0/360
   IF (cnt_neg GT 0 ) THEN Xg[neg]=Xg[neg]+360.
     tatlas.wave[i].name     = STRUPCASE(wname)    
     tatlas.wave[i].filename = nc_files[i]
   CASE (varname[j]) OF
     'H': BEGIN
         tatlas.wave[i].amp = Xa
         tatlas.wave[i].pha = Xg
         tatlas.type        = 10
     END
     'U': BEGIN
         tatlas.wave[i].ua = Xa
         tatlas.wave[i].ug = Xg
         tatlas.type        = 10
     END
     'V': BEGIN
         tatlas.wave[i].va = Xa
         tatlas.wave[i].vg = Xg
         tatlas.type        = 10
     END
   ENDCASE
 ENDFOR
 NCDF_CLOSE, fid
ENDFOR

; routine d'archivage d'une structure de type tatlas 
IF NOT KEYWORD_SET(descr) THEN descr='tatlas => archive '
IF NOT KEYWORD_SET(name) THEN PRINT,'Need a directory to archive the file'  
PRINT,'-----------------INFO---------------------'
PRINT,tatlas.info
PRINT,'-----------------INFO---------------------'

SAVE, tatlas, DESCRIPTION=descr,file=!idl_tatlas_arx+name
PRINT,"Archivage du tidal atlas dans :'
PRINT,!idl_tatlas_arx+name
PRINT,descr
PRINT,'-----------------------'
PRINT,"Add to load_tatlas ==> '",FILE_BASENAME(name,'.sav'),"'"
END