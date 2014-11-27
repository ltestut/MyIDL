PRO read_fic, tab, filename=filename

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:
print, 'read_fic, tab, filename=filename'
print, ''
print, "INPUT: filename='nom_de_fichiers'"
print, 'OUTPUT: tab !!STRUCTURE'
RETURN
ENDIF

Pa_template = ASCII_TEMPLATE(filename)
help,/structure,Pa_template

	IF (KEYWORD_SET(FILENAME)) THEN BEGIN
	openr, unit, filename, /GET_LUN
;        tab=READ_ASCII(filename,COMMENT_SYMBOL='',COUNT=nrecord, $
;	DATA_START=0,DELIMITER=' ',/VERBOSE)
        tab=READ_ASCII(filename,TEMPLATE=ASCII_TEMPLATE(filename))
	close, unit
	free_lun, unit
	ENDIF


help,/structure,tab
;print, 'Nombre de donnees du fichier : ', nrecord
y_max        = MAX(tab.field01,MIN=y_min,/NaN)
y_max2       = MAX(tab.field02,MIN=y_min2,/NaN)
print, 'Y_max=', y_max , '    Y_min= ', y_min
print, 'Y_max2=', y_max2 , '    Y_min2= ', y_min2
END
 
