PRO make_scan_archive, seg, name=name, descr=descr 
; routine d'archivage d'une structure de type mgr 
IF NOT KEYWORD_SET(descr) THEN descr='st => archive '
IF NOT KEYWORD_SET(name) THEN PRINT,'Need a directory to archive the file'  
SAVE, seg, DESCRIPTION=descr,file=!idl_scan_arx+name
PRINT,"Archivage du mgr dans :'
PRINT,!idl_scan_arx+name
PRINT,descr
PRINT,'-----------------------'
END