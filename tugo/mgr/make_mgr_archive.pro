PRO make_mgr_archive, mgr, name=name, descr=descr 
; routine d'archivage d'une structure de type mgr 
IF NOT KEYWORD_SET(descr) THEN descr='st => archive '
IF NOT KEYWORD_SET(name) THEN PRINT,'Need a directory to archive the file'  
SAVE, mgr, DESCRIPTION=descr,file=!idl_mgr_arx+name
PRINT,"Archivage du mgr dans :'
PRINT,!idl_mgr_arx+name
PRINT,descr
PRINT,'-----------------------'
END