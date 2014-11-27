PRO read_jmm2jul, struct, filename=filename

IF (N_PARAMS() EQ 0) THEN BEGIN
    print, 'UTILISATION:
    print, 'read_jmm2jul, struct, filename=filename'
    print, ''
    print, "INPUT: filename='nom_de_fichiers'"
    print, 'OUTPUT: structure de type {julien_time,valeur}'
    print, '        --> struct.jul'
    print, '        --> struct.val'
    RETURN
ENDIF

nom_station = strarr(1)
lat         = strarr(1)
lon         = strarr(1)
entete      = lon64arr(8)
flag        = 999999.000

;c LECTURE DU FICHIER AU FORMAT JMM --> tab
IF (KEYWORD_SET(FILENAME)) THEN BEGIN
    openr, unit, filename, /GET_LUN
    readf, unit, nom_station
    readf, unit, lat
    readf, unit, lon
    readf, unit, entete
    tab = fltarr(entete(0))
    readf, unit, tab
    free_lun, unit
ENDIF
N           = entete(0)
STEP        = ROUND(entete(1))
delt        = FLOAT(entete(1))/3600.       ;;en heures
duree       = FLOAT(N)*FLOAT(delt)/24.     ;;en jours

print, '*****************LECTURE DU FICHIER AU FORMAT JMM**********'
;;print, 'Travail sur la station de    : ', nom_station
;;print, 'LAT                          : ', lat
;;print, 'LON                          : ', lon
;;print, 'entete                       : ', entete
print, 'Ndata=',N,' de',delt,'  heures',' Duree=', duree, '  jours'

itrou = where(tab eq flag, nb_trou)
IF (nb_trou ne 0) THEN BEGIN
    tab[itrou]=!VALUES.F_NAN
ENDIF
y_max       = MAX(tab,MIN=y_min,/NaN)

;print, 'Nbre trou=', nb_trou
print, 'Y_max=', y_max , '    Y_min= ', y_min

;c CALCUL DES DATES DE DEBUT ET FIN ET RENVOIE DANS UNE STRUCTURE 
jul_deb = JULDAY(entete(3),entete(2),entete(4),entete(5),entete(6))
jul_fin = JULDAY(entete(3),entete(2),entete(4),entete(5),entete(6))+(FLOAT(N)*FLOAT(delt)/24.)
caldat,jul_deb,mois_d,jour_d,an_d,heure_d
caldat,jul_fin,mois_f,jour_f,an_f,heure_f
;print,'JULIAN DAY debut = ',jul_deb-JULDAY(1,1,1950)
;print,'JULIAN DAY fin   = ',jul_fin-JULDAY(1,1,1950)
;print,'Date debut: le',jour_d,mois_d,an_d,' a  ',heure_d,'heures'
;print,'Date fin  : le',jour_f,mois_f,an_f,' a  ',heure_f,'heures
print,FORMAT='(C())',jul_deb
print,FORMAT='(C())',jul_fin

;c CREATION D'UNE STRUCTURE ET REPLICATION 
tmp        = {jul:0.0D, val:0.0}
struct     = REPLICATE(tmp, N)
;;tab_time   = 
;;tab_time   = TIMEGEN(START = jul_deb, FINAL = jul_fin , UNIT  = 'Hours')
struct.jul = TIMEGEN(N, START = jul_deb, UNIT  = 'Seconds', STEP_SIZE=STEP)
struct.val = tab
print, '***********************************************************'

;; Lecture d'un fichier au format jmm dans une structure de type {struct.jul, struct.val}
;; Derniere modif: le 23/04/2003

END
