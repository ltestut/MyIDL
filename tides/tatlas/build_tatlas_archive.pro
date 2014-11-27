PRO build_tatlas_archive, glob=glob
; program to build some of the important tidal atlases.

IF KEYWORD_SET(glob) THEN BEGIN
;###GLOBAL TIDAL ATLAS #################################################################
  ;### TPX #################################################################
make_tatlas_archive, '/data/genesis/tides/TPX0.7/DATA-GLOBAL/netcdf/',NAME='glob/glob_tpxo7.2.sav',$
  SEARCH_FORMAT='.TPXO7.2.nc',INFO='TPXO7.2 - 1/4° -',MODE='Tidal Inversion', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Gary Egbert's (TPXO) tide models have been computed using inverse theory using tide gauge and TOPEX/Poseidon data. The latest version TPXO.7.2 also includes GRACE data."
  ;### GOT #################################################################
make_tatlas_archive, '/data/genesis/tides/GOT4.7/netcdf/'    ,NAME='glob/glob_got4.7.sav',$
  SEARCH_FORMAT='.nc',INFO='GOT4.7 - 1/4° -',MODE='inversion', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Richard Ray's (GOT) tide models derived from T/P, Jason-1, ERS and GFO altimetry"
make_tatlas_archive, '/data/genesis/tides/GOT4.8/netcdf/'    ,NAME='glob/glob_got4.8.sav',$
  SEARCH_FORMAT='.nc',INFO='GOT4.8 - 1/2° -',MODE='inversion', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Richard Ray's (GOT) tide models latest version which only differs from GOT4.7 for harmonic S2"
  ;### FES #################################################################
make_tatlas_archive, '/data/genesis/tides/FES2004/netcdf/'    ,NAME='glob/glob_fes2004.sav',$
  SEARCH_FORMAT='.tide.nc',INFO='FES2004 - 1/4° -',MODE='spectral', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Florent Lyard's (FES) tide models are based on a barotropic model which assimilates altimetry and tide gauge data."
make_tatlas_archive, '/data/genesis/tides/FES2012/'    ,NAME='glob/glob_fes2012-hydro.sav',$
  SEARCH_FORMAT='.FES2012-hydro.nc',INFO='FES2012-HYDRO - 1/4° -',MODE='spectral', OBC='N/A', BATHY='composite', ASSIMILATION='no',$
  DESCR="Florent Lyard's (FES) tide models are based on a barotropic model which assimilates altimetry and tide gauge data. This version is the latest version whitout assimilation"
make_tatlas_archive, 'C:\work\'    ,NAME='glob/glob_fes2013-hydro.sav',$
  SEARCH_FORMAT='.FES2012-hydro.nc',INFO='FES2013-HYDRO - 1/4° -',MODE='spectral', OBC='N/A', BATHY='composite', ASSIMILATION='no',$
  DESCR="Florent Lyard's (FES) tide models are based on a barotropic model which assimilates altimetry and tide gauge data. from ftp://ftp.legos.obs-mip.fr/pub/FES2012-project/spectral/hydrodynamic.2012-06-18/"
make_tatlas_fes2012, '/data/genesis/tides/FES2012/AVISO/fes2012/data/',NAME='glob/glob_fes2012.sav',$
  INFO='FES2012 - 1/36° -',MODE='spectral', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Florent Lyard's (FES) tide models are based on a barotropic model which assimilates altimetry and tide gauge data. from AVISO ftp site /donnees/ftpsedr/DUACS/auxiliary/tide_model/"

ENDIF ELSE BEGIN

  ;### CAT #################################################################
make_tatlas_archive, '/data/genesis/tides/cada00.10/'    ,NAME='glob/glob_cada00.10.sav',$
  SEARCH_FORMAT='.nc',INFO='CADA-00.10',MODE='inverse', OBC='N/A', BATHY='composite', ASSIMILATION='tp+25tg'
make_tatlas_archive, '/data/genesis/tides/cats02.01/'    ,NAME='glob/glob_cats02.01.sav',$
  SEARCH_FORMAT='.nc',INFO='CATS-02.01',MODE='forward', OBC='tpxo6.2', BATHY='composite', ASSIMILATION='no'
make_tatlas_archive, '/data/genesis/tides/cats2008/'    ,NAME='glob/glob_cats2008.sav',$
  SEARCH_FORMAT='.nc',INFO='CATS-2008',MODE='inverse', OBC='tpxo7.1', BATHY='gebco-modified', ASSIMILATION='tp+50tg+icesat+gps'
  ;### MERTZ #################################################################
path    = '/media/usb_data_idl/data/model/tides/tugo/mertz/'
make_tatlas_archive,path+'mertz_ref/'     , NAME='mertz/mertz_ref.sav',DESCR='Simulation de reference',$
  SEARCH_FORMAT='*.nc',INFO='MERTZ-REF',MODE='sequential', OBC='fes2004', BATHY='gebco-modified', ASSIMILATION='no'
  make_tatlas_archive,path+'b9b1/'          , NAME='mertz/mertz_b9b1.sav',DESCR='Simulation avec le B9B en position 1',$
  SEARCH_FORMAT='*.nc',INFO='MERTZ-B9B1',MODE='sequential', OBC='fes2004', BATHY='gebco-modified', ASSIMILATION='no'
make_tatlas_archive,path+'b9b2/'          , NAME='mertz/mertz_b9b2.sav',DESCR='Simulation avec le B9B en position 2',$
  SEARCH_FORMAT='*.nc',INFO='MERTZ-B9B2',MODE='sequential', OBC='fes2004', BATHY='gebco-modified', ASSIMILATION='no'
make_tatlas_archive,path+'remaining_b9b2/', NAME='mertz/mertz_remaining-b9b2.sav',DESCR='Simulation avec le B9B en position 2 et le Mertz brisee',$
  SEARCH_FORMAT='*.nc',INFO='MERTZ-B9B2-REMAINING',MODE='sequential', OBC='fes2004', BATHY='gebco-modified', ASSIMILATION='no'


;###REGIONAL TIDAL ATLAS #################################################################
  ;### TPX #################################################################
make_tatlas_archive, '/data/genesis/tides/TPX0.7/DATA-IO/netcdf/',NAME='nindian/nindian_tpxo7.2.sav',$
  SEARCH_FORMAT='.TPXO7.2.nc',INFO='TPXO7.2 - 1/12° -',MODE='Tidal Inversion', OBC='N/A', BATHY='composite', ASSIMILATION='yes',$
  DESCR="Gary Egbert's (TPXO) tide models have been computed using inverse theory using tide gauge and TOPEX/Poseidon data. The latest version TPXO.7.2 also includes GRACE data."



  ;########################################################################
  ;#########################       ARABIAN SEA ############################
  ;########################################################################
make_tatlas_archive,'/media/usb_data_idl/data/model/tides/tugo/arabian/', $
                     NAME='arb/arb_arb-2011.sav',DESCR='Khambhat LR model with Quadratic friction and friction coef cd as in Unni paper',$
                     SEARCH_FORMAT='*.nc',INFO='Arabian-2011',MODE='sequential', OBC='got4.7', BATHY='etopo-Sindhu', ASSIMILATION='no'


  ;########################################################################
  ;######################### WEST INDIAN SHELF ############################
  ;########################################################################

    ;### LARGE SHELF ZONE LOW RESOLUTON #################################################################
make_tatlas_archive, '/data/model_indien_nord/zone_wic/simu_tide/'    ,$
  NAME='arb/arb_kha-lr_cd-unni.sav',DESCR='Khambhat LR model with Quadratic friction and friction coef cd as in Unni paper',$
  SEARCH_FORMAT='*.cd.unni.nc',INFO='Khambhat[Q:cd=1.5e-3/4e-2/1e-2]',MODE='spectral M2|K1', OBC='fes2004', BATHY='etopo-Sindhu', ASSIMILATION='no'
  
make_tatlas_archive, '/data/model_indien_nord/zone_wic/simu_tide/'    ,$
  NAME='arb/arb_kha-lr_cd-unni-5m.sav',DESCR='Khambhat LR model with Quadratic friction and friction coef cd as in Unni paper depth=5m',$
  SEARCH_FORMAT='*.cd.unni.d5m.nc',INFO='Khambhat[Q:cd=1.5e-3/4e-2/1e-2:MinDepth=5m]',MODE='spectral M2|K1', OBC='fes2004', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_wic/simu_tide/'    ,$
  NAME='arb/arb_kha-lr_cd-2.5e-3.sav',DESCR='Khambhat LR model with Quadratic friction cd=2.5e-3',$
  SEARCH_FORMAT='*.2.5e-3.nc',INFO='Khambhat[Q:cd=2.5e-3]',MODE='spectral M2|K1', OBC='fes2004', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_wic/simu_tide/'    ,$
  NAME='arb/arb_kha-lr_cd-2.5e-4.sav',DESCR='Khambhat LR model with Quadratic friction cd=2.5e-4',$
  SEARCH_FORMAT='*.2.5e-4.nc',INFO='Khambhat[Q:cd=2.5e-4]',MODE='spectral M2|K1', OBC='fes2004', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_wic/simu_tide/'    ,$
  NAME='arb/arb_kha-lr_cw-0000.sav',DESCR='Khambhat LR model with Quadratic friction cd=2.5e-3 and Cw=0',$
  SEARCH_FORMAT='.cw0.nc',INFO='Khambhat[Q:cd=2.5e-3/Cw=0]',MODE='spectral M2|K1', OBC='fes2004', BATHY='etopo-Sindhu', ASSIMILATION='no'




  ;### SHELF ZONE FORCED BY ALTI #################################################################
make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/run_sequential/' ,$
   NAME='arb/arb_shelf-hr_sq_cd_2.5e-3.sav',DESCR='Shelf HR model sequential cd=2.5e-3',SEARCH_FORMAT='-AUTO.73.SG.nc',$
   INFO='Shelf[SQ-Q:cd=2.5e-3]',MODE='sequential', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'
  
make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/run_sequential_cd_1.2e-3/' ,$
   NAME='arb/arb_shelf-hr_sq_cd_1.2e-3.sav',DESCR='Shelf HR model sequential cd=1.2e-3',SEARCH_FORMAT='-AUTO.23.SG.nc',$
   INFO='Shelf[SQ-Q:cd=1.2e-3]',MODE='sequential', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/' ,$
   NAME='arb/arb_shelf-hr_sp_rugo_1_cd_1.2e-3.sav',DESCR='Shelf HR model spectral cd=1.2E-03>5m>3.0E-03',SEARCH_FORMAT='.rugofile.1.2e-3.nc',$
   INFO='Shelf[SP-Q:1.2E-03>5m>3.0E-03]',MODE='spectral', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/' ,$
   NAME='arb/arb_shelf-hr_sp_rugo_2_cd_1.2e-3.sav',DESCR='Shelf HR model spectral cd=1.2E-03>5m>5.0E-05',SEARCH_FORMAT='.cdfile.1.2e-3.nc',$
   INFO='Shelf[SP-Q:1.2E-03>5m>5.0E-05]',MODE='spectral', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/' ,$
   NAME='arb/arb_shelf-hr_sp_cw_0_cd_1.2e-3.sav',DESCR='Shelf HR spectral model -Internal Drag Coef cw = 0- cd=1.2e-3',SEARCH_FORMAT='.cw_0_cd.1.2E-03.nc',$
   INFO='Shelf[SP-Q-CW0:1.2E-03]',MODE='spectral', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_shelf/simu_tide/' ,$
   NAME='arb/arb_shelf-hr_sp_cw_0_cd_2.5e-3.sav',DESCR='Shelf HR spectral model -Internal Drag Coef cw = 0- cd=2.5e-3',SEARCH_FORMAT='.cw_0_cd.2.5e-3.nc',$
   INFO='Shelf[SP-Q-CW0:2.5E-03]',MODE='spectral', OBC='XTRACK', BATHY='etopo-Sindhu', ASSIMILATION='no'

make_tatlas_archive, '/data/model_indien_nord/zone_goc_saheed/' ,VARNAME='zeta_',$
   NAME='arb/arb_goc_sq_saheed.sav',DESCR='Goc sequential model COHERENS',SEARCH_FORMAT='-zeta-atlas.nc',$
   INFO='GOC[SQ-COHERENS]',MODE='sequential', OBC='TPXO', BATHY='NIO', ASSIMILATION='no'



  ;########################################################################
  ;######################### BAY OF BENGAL     ############################
  ;########################################################################
make_tatlas_archive, '/data/model_indien_nord/zone_tamil_nadu/simu_tide/' ,$
   NAME='bob/bob_tamil_sq_cd_2.5e-3.sav',DESCR='Shelf HR model spectral cd=2.5e-3',SEARCH_FORMAT='.generic.nc',$
   INFO='Shelf[SP-Q:cd=2.5e-3]',MODE='spectral', OBC='GOT4.7', BATHY='ETOPO-Sindhu', ASSIMILATION='no',$
   /HUV

;########################################################################
;######################### BAY OF BENGAL     ############################
;########################################################################
make_tatlas_archive, 'X:\sortie_tugo_spectral\' ,$
   NAME='bob/bob_test1.sav',$
   DESCR='on SELFE mesh',SEARCH_FORMAT='.lzlz.nc',$
   INFO='Shelf[SP-Q:cd=2.5e-3]',MODE='spectral', OBC='FESxx',$
   BATHY='ETOPO-Sindhu',ASSIMILATION='no'




ENDELSE




END