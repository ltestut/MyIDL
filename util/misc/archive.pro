PRO archive, st_arx, descr=descr, rep=rep, comment=comment, geo=geo
IF NOT KEYWORD_SET(descr)   THEN descr='st => archive '
IF NOT KEYWORD_SET(rep)     THEN PRINT,'Need a directory to archive the file'  
IF NOT KEYWORD_SET(comment) THEN comment='---Archivage---'
  sav_descr = descr
  sav_rep   = rep
  PRINT,'#######'+comment+'#######'
  IF KEYWORD_SET(geo) THEN BEGIN 
   geo        = st_arx
   SAVE, geo, DESCRIPTION=sav_descr,file=sav_rep
  ENDIF ELSE BEGIN
   st        = st_arx
   SAVE, st, DESCRIPTION=sav_descr,file=sav_rep
  ENDELSE
  PRINT,sav_descr
  PRINT,sav_rep
;  PRINT,"Date de la dernier valeur : ",print_date(MAX(st.jul),/SINGLE)
  PRINT,'-----------------------------------------------------------------'
END