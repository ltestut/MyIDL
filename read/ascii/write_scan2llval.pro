FUNCTION write_scan2llval, st, filename=filename
; ecriture d'un fichier du format scan au format llval
N   = N_ELEMENTS(st.lon)
filename_info= getfilename(filename)
file_ll=filename_info.namestem+'.ll'
print, 'ecriture du fichier  ', file_ll
OPENW, UNIT, file_ll, /GET_LUN  ;; ouverture du fichier en ecriture

cpt=0
FOR i=0L,N_ELEMENTS(st.id)-1 DO BEGIN
  PRINTF, UNIT, '>'
  FOR j=0,N_ELEMENTS(st.nbr[i])-1 DO BEGIN
   PRINTF, UNIT, FORMAT='(F11.5,F11.5)', st.lon[cpt], st.lat[cpt]
   cpt=cpt+1
  ENDFOR
ENDFOR

FREE_LUN, UNIT
print, 'done'
return, file_ll


END


