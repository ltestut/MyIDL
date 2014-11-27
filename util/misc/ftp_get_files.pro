PRO ftp_get_files
oUrl = OBJ_NEW('IDLnetUrl', URL_SCHEME='ftp', $
  URL_HOST='ftp.aviso.oceanobs.com', $
  URL_Port=21, $
  URL_USERNAME='anonymous', URL_PASSWORD='', $
  URL_PATH='/pub/oceano/pistach/J2/IGDR/coastal/cycle_007/')
void = oURL -> GetFtpDirList(/SHORT)

;ftp://ftp.aviso.oceanobs.com/pub/oceano/pistach/J2/IGDR/coastal/cycle_007/JA2_IPC_2PTP007_253_20080919_091721_20080919_101334.nc.gz

;oUrl = OBJ_NEW('IDLnetUrl', URL_SCHEME='ftp', $
;  URL_HOST='ftp.saral.oceanobs.com', $
;  URL_Port=21, $
;  URL_USERNAME='pi_altika', URL_PASSWORD='', $
;  URL_PATH='/SSHA_GDR_T/cycle_001')
;void = oURL -> Get(FILENAME='C:\IDL\test\file_2008')


END
