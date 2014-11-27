PRO make_track_arx, track,  name=name, descr=descr 
; on construit les fichiers d'archive de type track mgr pour l'analyse des sorties de simu
IF NOT KEYWORD_SET(descr) THEN descr='track => archive '
IF NOT KEYWORD_SET(name) THEN PRINT,'Need a directory to archive the file'  
SAVE, track, DESCRIPTION=descr,file=!idl_scan_arx+name
PRINT,"Archivage de track dans :'
PRINT,!idl_scan_arx+name
PRINT,descr
PRINT,'-----------------------'
END 
