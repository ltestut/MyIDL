FUNCTION write_kml2llval, st, filename=filename

N   = N_ELEMENTS(st.lon)
filename_info= getfilename(filename)
file_ll=filename_info.namestem+'.ll'
print, 'ecriture du fichier  ', file_ll
OPENW, UNIT, file_ll, /GET_LUN  ;; ouverture du fichier en ecriture

FOR I=0L,N-1 DO BEGIN
        IF ((st[I].lon EQ 0.) OR (st[I].lat EQ 0.)) THEN BEGIN
        PRINTF, UNIT, '>'
        ENDIF ELSE BEGIN
        PRINTF, UNIT, FORMAT='(F11.5,F11.5)', st[I].lon, st[I].lat
        ENDELSE        
ENDFOR

FREE_LUN, UNIT
print, 'done'
return, file_ll


END

