PRO write_jul2jmm, st, nom_station, lat, lon, filename=filename

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:'
print, 'write_jul2jmm, st, nom_station, lat, lon, entete, filename=filename'
print, ''
RETURN
ENDIF

nom_station = strarr(1)
lat         = strarr(1)
lon         = strarr(1)
entete      = lon64arr(8)

CALDAT,st[0].jul,mois,jour,an,heure,minute,second
entete[0]   = N_ELEMENTS(st)
entete[1]   = 600
entete[2]   = jour
entete[3]   = mois
entete[4]   = an
entete[5]   = heure
entete[6]   = minute
entete[7]   = second

	IF (KEYWORD_SET(FILENAME)) THEN BEGIN
	openw, unit, filename, /GET_LUN
	printf, unit, nom_station
	printf, unit, lat
	printf, unit, lon
	printf, unit, entete
	printf, unit, format='(12f13.3)',st.val
	close, unit
	free_lun, unit
	ENDIF

print, '*****************ECRITURE DU FICHIER AU FORMAT JMM**********'
print, 'Travail sur la station de    : ', nom_station
print, 'LAT                          : ', lat
print, 'LON                          : ', lon
print, 'entete                       : ', entete


END
 
