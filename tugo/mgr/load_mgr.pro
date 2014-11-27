FUNCTION load_mgr,zone=zone,$
                  model=model,obs=obs,track=track,$
                  quiet=quiet,limit=limit

  ;init the keyword
alt_key  = 'track'
obs_key  = 'obs'
mod_key  = 'mod'

IF NOT KEYWORD_SET(zone) THEN BEGIN
 PRINT,"     ---------------- 
 PRINT,"     AVAILABLE  ZONE : nindian, salomon, mertz, ker "
 PRINT,"     ---------------- 
 PRINT,"                         "
 PRINT,"      mgr = load_mgr(ZONE='nindian',OBS='shom-z19')
 PRINT,"      mgr = load_mgr(ZONE='nindian',OBS='shom-z19',MODEL='fes2004')
 PRINT,"      mgr = load_mgr(ZONE='nindian',TRACK='125')
 PRINT,"      mgr = load_mgr(ZONE='nindian',TRACK='125',MODEL='fes2004')
 PRINT,"                         "
 PRINT,"       !idl_mgr_arx/[ZONE]/[ZONE]_"+obs_key+"_[OBS/TRACK]_"+mod_key+"_[MODEL].sav"
 PRINT,"                         "
 PRINT,"    ex: !idl_mgr_arx/[nindian]/[nindian]_"+obs_key+"_[shom-z19]_"+mod_key+"_[fes2002].sav"
 RETURN,0
ENDIF


zone     = STRLOWCASE(zone)
mgr_path = !idl_mgr_arx+zone+'/'

CASE zone OF
  'nindian' : BEGIN
    model_name   = ['fes2004','got4.7','tpxo6.2','tpxo7.0','arabian_v1']
    obs_name     = ['shom_valid','shom_whole','shom-z19','mydb','nio','mehra','unni','unni-mod']  
    track_number = ['001','003','003N','005','014','016','027','029','029N','040','042','053','055','066','068',$
                    '079','079N','081','090','092','103','105','105N','116','118','129','131','142','142N','144','155',$
                    '157','166','168','170','179','181','181N','183','192','194','205','207','218','220',$
                    '231','233','244','246']
  END
  'salomon' : BEGIN
    model_name   = ['fes2004','got4.7','got4.8','tpxo6.2','tpxo7.0','dtu10',$
                    'sol-mr_got4.7','sol-mr_sp_got4.7_gebco120','sol-mr_sp_got4.7_gebco60',$
                    'sol-mr_sp_got4.7_nemo12','sol-mr_sp_got4.7_nemo36','sol-mr_sp_got4.7_orca12',$
                    'sol-mr_sq_got4.7_gebco60']
    obs_name     = ['uhslc','uhslc-raw'] 
    track_number = ['all','008','010','012','021','023','025','034','036','038','047','049',$
                    '060','062','071','073','075','084','086','088','097','099','101',$
                    '110','112','114','123','125','136','138','147','149','151','162',$
                    '164','173','175','177','186','188','190','199','201','212','214',$
                    '216','225','227','238','240','249','251','253']
   END 
  'mertz'   : BEGIN
    model_name   = ['fes2004','got4.7','tpxo6.2','tpxo7.0','mertz']
    obs_name     = ['best','full']  
    track_number = ['none']
  END
  'ker'    : BEGIN
    model_name   = ['fes2004','got4.7','tpxo6.2','tpxo7.0','arabian_v1']
    obs_name     = ['position','rosame','shom','allmrg','bestmrg','sio','shelfmrg']  
  END
  'nea' : BEGIN
    model_name   = ['fes2004','got4.7','tpxo6.2']
    obs_name     = ['']  
    track_number = ['011','018','020','035','037','044','046','061','063','068','070','087','089','094','096','111','113','120','122',$
                    '137','139','144','146','148','163','165','170','172','189','196','198','213','215','220','222','224','239','241',$
                    '246','248']  
  END
  ELSE: BEGIN
  print,'No match'
  END
ENDCASE

IF KEYWORD_SET(obs) THEN BEGIN
   file=mgr_path+zone+'_'+obs+'_'+obs_key+'.sav'
   IF KEYWORD_SET(model) THEN file=mgr_path+zone+'_'+obs+'_'+mod_key+'_'+model+'.sav'
ENDIF ELSE IF KEYWORD_SET(track) THEN BEGIN
   file=mgr_path+zone+'_'+track+'_'+alt_key+'.sav'
   IF KEYWORD_SET(model) THEN file=mgr_path+zone+'_'+track+'_'+mod_key+'_'+model+'.sav'
ENDIF ELSE BEGIN
  PRINT,"Possible Argument for this Zone :"
  PRINT,FORMAT="('MODEL=  ',"+STRCOMPRESS(N_ELEMENTS(model_name))+"(A-30,' / '))",model_name
  PRINT,FORMAT="('OBS  =  ',"+STRCOMPRESS(N_ELEMENTS(obs_name))+"(A-30,' / '))",obs_name
  PRINT,FORMAT="('TRACK=  ',"+STRCOMPRESS(N_ELEMENTS(track_number))+"(A-4,' / '))",track_number
  PRINT,'---------------------------------'
  RETURN,0
ENDELSE ;de model 

PRINT,file
RESTORE,file
IF KEYWORD_SET(limit) THEN RETURN, cut_mgr(mgr,LIMIT=limit)

RETURN,mgr
END