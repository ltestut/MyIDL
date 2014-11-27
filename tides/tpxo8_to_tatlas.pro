PRO tpxo8_to_tatlas
path  = '/data/genesis/tides/tpxo8/'
files = FILE_SEARCH(path,'*.nc')
nwave = N_ELEMENTS(files)

filename = path+'hf.m2_tpxo8_atlas_30c.nc'
 ;ouvertur du fichier netcdf (.nc) et lecture des variable lon,lat
fid  = NCDF_OPEN(filename)     ;open the file
info = NCDF_INQUIRE(fid)       ;return netcdf into into a structure 
NCDF_DIMINQ,fid,0,name,nx
NCDF_DIMINQ,fid,1,name,ny
NCDF_VARGET, fid, NCDF_VARID(fid,'lon_z'),  lon  ;lon(nlon,nlat) ou lon(x,y)
NCDF_VARGET, fid, NCDF_VARID(fid,'lat_z'),  lat  ;lat(nlon,nlat) ou lat(x,y)
NCDF_CLOSE,  fid

tatlas=create_tatlas(nx,ny,nwave)
tatlas.assimilation = "yes"
tatlas.info         = "TPXO8-2'"
tatlas.mode         = "Tidal Inversion"
tatlas.obc          = "N/A"
tatlas.bathy        = "GEBCO-1'+S&Sv12.1+CATs"
tatlas.lon          = lon
tatlas.lat          = lat

FOR i=0,nwave-1 DO BEGIN                             ;on parcours toutes les ondes du model
  w1 = STRSPLIT(FILE_BASENAME(files[i]),"_",/EXTRACT,/REGEX)
  w2 = STRUPCASE(STRSPLIT(FILE_BASENAME(w1[0]),".",/EXTRACT))
  wname = w2[1]
  fid   = NCDF_OPEN(files[i])                       ;ouverture du fichier i
  PRINT,"Traitement de l'onde :",wname
  NCDF_VARGET, fid, NCDF_VARID(fid,'hRe'), real
  NCDF_VARGET, fid, NCDF_VARID(fid,'hIm'), img
  NCDF_ATTGET, fid, NCDF_VARID(fid,'hRe'), 'option_0', land
  
    var  = COMPLEX(TRANSPOSE(real),TRANSPOSE(img))
    amp  = ABS(var)
    pha  = 180.+ATAN(-TRANSPOSE(img),TRANSPOSE(real))/!pi*180;
    Xa   = flag_matrix(amp,seuil=0.,/EQUAL) ;/!\ au difference de flag des sorties de modeles
    Xg  =  flag_matrix(pha,seuil=0.,/EQUAL) ;/!\ au difference de flag des sorties de modeles
;    Xa  = TEMPORARY(Xa)*scl
;    Xg  = TEMPORARY(Xg)*scl
    neg = WHERE( Xg LT 0. , cnt_neg)                            ; passage de -180/180 à 0/360
    tatlas.wave[i].name     = STRUPCASE(wname)    
    tatlas.wave[i].filename = files[i]
    tatlas.wave[i].amp = Xa
    tatlas.wave[i].pha = Xg
    tatlas.type        = 10
NCDF_CLOSE, fid
ENDFOR
SAVE, tatlas, DESCRIPTION="Gary Egbert's (TPXO) tide models have been computed using inverse theory using tide gauge and TOPEX/Poseidon data. The latest version TPXO8 also includes GRACE data.",$
      file=!idl_tatlas_arx+'glob/glob_tpxo8.sav'
PRINT,"Archivage du tidal atlas dans :'
PRINT,!idl_tatlas_arx+'glob/glob_tpxo8.sav'
PRINT,'-----------------------'
PRINT,"Add to load_tatlas ==> '",FILE_BASENAME(name,'.sav'),"'"
END