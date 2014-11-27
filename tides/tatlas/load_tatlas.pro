FUNCTION load_tatlas,zone=zone, $
                     model=model, $
                     limit=limit,wave=wave,$
                     quiet=quiet
                  
                  
IF NOT KEYWORD_SET(zone) THEN BEGIN
 PRINT,"     ---------------- 
 PRINT,"     AVAILABLE  ZONE : glob, ker, mertz, sol,arb, bob"
 PRINT,"     ---------------- 
 PRINT,"                         "
 PRINT,"      tatlas = load_tatlas(ZONE='mertz',MODEL='b9b1')
 PRINT,"                         " 
 PRINT,"       !idl_tatlas_arx/[ZONE]/[ZONE]_[MODEL].sav"
 PRINT,"                         "
 STOP,"    ex: !idl_tatlas_arx/[glob]/[glob]_[fes2004].sav"
ENDIF



;zone_name.resolution.sav

CASE zone OF
  'glob'     : model_name   = ['fes2004','fes2013-hydro','fes2012-hydro','fes2012','got4.7','got4.8','tpxo6.2','tpxo7.0','tpxo7.2','tpxo8','dtu10','eot10a',$
                               'cats02.01','cats2008','cada00.10']
  'nindian'  : model_name   = ['tpxo7.2']
  'ker'   : model_name   = ['ref.hr','ref.mr','fes2004.ref','fes2004.hr','fes2004.mr','got4.7.hr','got4.7.mr','got4.7.taaf']
  'mertz' : model_name   = ['ref','b9b1','b9b2','remaining-b9b2']
  'sol'   : model_name   = ['']
  'arb'   : model_name   = ['arb-2011',$   
                            'kha-lr_cd-unni','kha-lr_cd-unni-5m','kha-lr_cd-2.5e-3','kha-lr_cd-2.5e-4',$
                            'kha-lr_cd-2.5e-10   ===>  kha-lr_cd-2.5e0',$
                            'kha-lr_two-rugo_00  ===>  kha-lr_two-rugo_15',$
                            'kha-lr_cd-2e-4      ===>  kha-lr_cd-2e-2',$
                            'kha-lr_cw_0050      ===>  kha-lr_cw_1000',$
                            'kha-lr_cw-300_H_100-2000  ===>  kha-lr_cw_1000',$
                            'kha-lr_cw-zmax_300  ===>  kha-lr_cw-zmax_950',$
                            'no-kha-lr_cd_1.0E-03   ===>  no-kha-lr_cd_1.0E-01',$
                            'kha-alti-hr_cw-200_H_100-2000_rugofile_1e-3',$
                            'kha-hr_cd_1e-4   ===>  kha-hr_cd_2e-3',$
                            'shelf-hr_sp_cd_1.2e-3','shelf-hr_sq_cd_2.5e-3','shelf-hr_sq_cd_1.2e-3',$
                            'shelf-hr_sp_rugo_1_cd_1.2e-3','shelf-hr_sp_rugo_2_cd_1.2e-3',$
                            'shelf-hr_sp_cw_0_cd_1.2e-3','shelf-hr_sp_cw_0_cd_2.5e-3',$
                            'arb_kha-lr_cw0',$
                            'shelf-hr_sp_obc_got4.7 --> fes2004',$
                            'shelf-hr_sp_cdf_1.2e-3','shelf-hr_sp_cdf_1.6e-3',$ ;full waves spectrum
                            'shelf-hr_sp_fes2013 --> gridone',$
                            'arb_goc_sq_saheed']

  'wic'   : model_name   = ['wic_tamil_sq_cd_2.5e-3']
  'bob'   : model_name   = ['bob_tamil_sq_cd_2.5e-3','bob_test1']

ENDCASE


IF KEYWORD_SET(model) THEN BEGIN
  file=!idl_tatlas_arx+zone+'/'+zone+'_'+model+'.sav'
ENDIF ELSE BEGIN
  PRINT," Possible Argument for this Zone :"
  STOP,model_name

ENDELSE  

RESTORE,file,DESCRIPTION=descr
IF NOT KEYWORD_SET(quiet) THEN BEGIN
 PRINT,'#####################  LOAD_TATLAS  ##############################'
 PRINT,descr
 PRINT,file
ENDIF

 ;on selectionne une zone geographique
IF KEYWORD_SET(limit) THEN BEGIN
 tatlas =geocut(tatlas, limit=limit)
ENDIF

 ;on selectionne une liste d'onde
IF KEYWORD_SET(wave) THEN BEGIN
 PRINT,'Selection des ondes : '
 nwave      = N_ELEMENTS(wave)
 atlas      = create_tatlas(N_ELEMENTS(tatlas.lon), N_ELEMENTS(tatlas.lat), nwave)
 idw_name   = INTARR(nwave)
 atlas.info = tatlas.info
 atlas.type = tatlas.type
 atlas.lon  = tatlas.lon
 atlas.lat  = tatlas.lat
 FOR i=0,nwave-1 DO BEGIN
   idw_name[i]             = WHERE(tatlas.wave.name EQ wave[i],cpt)
   atlas.wave[i].name      = tatlas.wave[idw_name[i]].name
   atlas.wave[i].filename  = tatlas.wave[idw_name[i]].filename
   IF (cpt EQ 1) THEN BEGIN 
   atlas.wave[i].amp       = tatlas.wave[idw_name[i]].amp
   atlas.wave[i].pha       = tatlas.wave[idw_name[i]].pha
   ENDIF ELSE BEGIN
   atlas.wave[i].amp       = !VALUES.F_NAN
   atlas.wave[i].pha       = !VALUES.F_NAN
   ENDELSE
 ENDFOR
 tatlas=atlas   
ENDIF

RETURN,tatlas
END