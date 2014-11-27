FUNCTION load_sample, zone=zone,$
                      type=type,$
                      simu=simu,$
                      usage=usage,quiet=quiet


IF NOT KEYWORD_SET(zone) THEN zone='nindian'
IF NOT KEYWORD_SET(type) THEN type='mto'

available_zone     = ['mertz','nindian']
available_simu     = ['phyan','b9b1','b9b2','remaining_b9b2']
available_type     = ['mto','tide']

IF KEYWORD_SET(usage) THEN BEGIN
PRINT, "  "
PRINT, "USAGE :  "
PRINT, "------  "
PRINT, "load_sample(ZONE='nindian',TYPE='mto',simu='phyan')  =>  sample of Phyan Tugom Simu"
PRINT, "  "
PRINT, " AVAILABLE ZONE    = ",available_zone
PRINT, " AVAILABLE TYPE    = ",available_type
STOP,  " AVAILABLE SIMU    = ",available_simu
ENDIF

file = !idl_sample_arx+zone+'/tugo_sample_'+type+'_'+simu+'.sav'

RESTORE,file,DESCRIPTION=descr

IF NOT KEYWORD_SET(quiet) THEN BEGIN
  PRINT,file
  PRINT,descr
ENDIF
RETURN,spl
END