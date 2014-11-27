FUNCTION read_sample_init, filename, fmt=fmt
; lecture du fichier de configuration des samples avant le lancement de tugo
; sample.input ou tugoa.sample
; lecture du fichier de config qui associe le numéro du fichier sample
; avec le nom de la station, lon, lat


 ;lecture de la ligne d'entete du fichier pour determiner le format
head  = STRARR(1)
OPENR, unit, filename, /GET_LUN
READF, unit, head
FREE_LUN, unit
index  = WHERE(stregex(head,'xyn',/FOLD_CASE,/BOOLEAN) EQ 1, nind)
fmt    = nind
IF nind THEN BEGIN 
tmp = {version:1.0,$
      datastart:1   ,$
      delimiter: ' '  ,$
      missingvalue: 0   ,$
      commentsymbol: ''  ,$
      fieldcount:3 ,$
      fieldTypes:[4,4,7], $
      fieldNames:['lon','lat','name'] ,$
      fieldLocations:[0,7,15], $
      fieldGroups:indgen(3) $
     }
ENDIF ELSE BEGIN
tmp = {version:1.0,$
      datastart:1   ,$
      delimiter: ''  ,$
      missingvalue: 0   ,$
      commentsymbol: ''  ,$
      fieldcount:3 ,$
      fieldTypes:[7,4,4], $
      fieldNames:['name','lon','lat'] ,$
      fieldLocations:[0,1,9], $
      fieldGroups:indgen(3) $
     }
ENDELSE
init_spl  = READ_ASCII(filename,TEMPLATE=tmp)

RETURN, init_spl
END