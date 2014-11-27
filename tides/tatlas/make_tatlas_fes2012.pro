PRO make_tatlas_fes2012, filepath, name=name, descr=descr, $
                               search_format=search_format,$
                               info=info, $
                               mode=mode, obc=obc, bathy=bathy, assimilation=assimilation, $
                               uv=uv, huv=huv,$
                               varname=varname 

;prog to archive the distributed version of FES2012 assimilated tidal atlas in .sav format 



 ;input keyword for atlas information 
IF NOT KEYWORD_SET(info)  THEN info  = filepath
IF NOT KEYWORD_SET(mode)  THEN mode  = 'N/A'
IF NOT KEYWORD_SET(obc)   THEN obc   = 'N/A'
IF NOT KEYWORD_SET(bathy) THEN bathy = 'N/A'
IF NOT KEYWORD_SET(assimilation) THEN assimilation = 'N/A'

varname = ['H','U','V']
type    = 12
huv     = 1

 ;only height
varname = 'H'
type    = 10
huv     = 0

wave_list     = ['M2','S2','N2','K2','K1','O1','P1','Q1','M4']

 ;read the height tidal atlase to init the tatlas structure
;nc_files = FILE_SEARCH(filepath+'*'+'FES2012_SLEV.nc')
nc_files = filepath+wave_list+'_FES2012_SLEV.nc'
 
nwave    = N_ELEMENTS(nc_files)                        ;get the number of waves (should be 33)
fid      = NCDF_OPEN(nc_files[0])                      ;open 1st file to get the grid size 
NCDF_VARGET, fid, NCDF_VARID(fid,'lon'),  lon  ;lon(nlon)
NCDF_VARGET, fid, NCDF_VARID(fid,'lat'),  lat  ;lat(nlat)
NCDF_CLOSE,  fid

PRINT,'-----------------INFO---------------------'
PRINT,info
PRINT,'-----------------INFO---------------------'

 ;get the dimensions x and y and create tatlas
dim_x       = N_ELEMENTS(lon)
dim_y       = N_ELEMENTS(lat)
tatlas      = create_tatlas(dim_x,dim_y,nwave,HUV=huv)
tatlas.assimilation = assimilation
tatlas.info         = info
tatlas.mode         = mode
tatlas.obc          = obc
tatlas.bathy        = bathy
tatlas.type         = type
tatlas.lon          = lon
tatlas.lat          = lat
ineg                = WHERE(tatlas.lon LT 0.,cneg)
IF (cneg GT 0) THEN tatlas.lon[ineg]=360+tatlas.lon[ineg] ;on passe toute les longitudes en 0-360

FOR i=0,nwave-1 DO BEGIN                                         ;loop on all waves 
 ; wname = (STRSPLIT(FILE_BASENAME(nc_files[i]),search_format,/EXTRACT))(0)
  wname = STRSPLIT(FILE_BASENAME(nc_files[i]),'_FES2012_SLEV.nc',/EXTRACT,/REGEX)
  hid  = NCDF_OPEN(nc_files[i])                                  ;open the height file
;  cid  = NCDF_OPEN(str_replace(nc_files[i],'SLEV','UV'))         ;open the current file

  PRINT,"Traitement de l'onde :",wname
  FOR j=0,N_ELEMENTS(varname)-1 DO BEGIN            ;on parcours toutes les variables du fichier i
    If (j EQ 0) THEN fid=hid ELSE fid=cid
    NCDF_VARGET, fid, NCDF_VARID(fid,varname[j]+'a'), var_amp
    NCDF_VARGET, fid, NCDF_VARID(fid,varname[j]+'g'), var_pha
    NCDF_ATTGET, fid, NCDF_VARID(fid,varname[j]+'a'), '_FillValue', flg
    NCDF_ATTGET, fid, NCDF_VARID(fid,varname[j]+'a'), 'scale_factor', scl
    scl=0.01                                                                  ;switch to meter
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
     Xg  = TEMPORARY(Xg)
     neg = WHERE( Xg LT 0. , cnt_neg)                            ; passage de -180/180 à 0/360
   IF (cnt_neg GT 0 ) THEN Xg[neg]=Xg[neg]+360.
     tatlas.wave[i].name     = STRUPCASE(wname)    
     tatlas.wave[i].filename = nc_files[i]
   CASE (varname[j]) OF
     'H': BEGIN
         tatlas.wave[i].amp = Xa
         tatlas.wave[i].pha = Xg
         tatlas.type        = type
     END
     'U': BEGIN
         tatlas.wave[i].ua = Xa
         tatlas.wave[i].ug = Xg
         tatlas.type        = type
     END
     'V': BEGIN
         tatlas.wave[i].va = Xa
         tatlas.wave[i].vg = Xg
         tatlas.type        = type
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