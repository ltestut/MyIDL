; $Id: read_jmm.pro,v 1.00 12/05/2005 L. Testut $
;

;+
; NAME:
;	read_jmm
;
; PURPOSE:
;	Read the JMM data file of type .bot, .baro, .slev, ...
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=read_jmm(filename)
;	
;       use the fct/proc : -> CREATE_JULVAL
; INPUTS:
;	filename      : string of the filename ex:'/home/testut/test.bot' 
;
; OUTPUTS:
;	Structure of type {jul,val}
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;
;-

FUNCTION read_jmm,  filename, flag=flag

IF (KEYWORD_SET(flag) EQ 0) THEN flag=999999.000

nom_station = STRARR(1)
lat         = STRARR(1)
lon         = STRARR(1)
entete      = LON64ARR(8)

;c LECTURE DU FICHIER AU FORMAT JMM --> tab
    openr, unit, filename, /GET_LUN
    readf, unit, nom_station
    readf, unit, lat
    readf, unit, lon
    readf, unit, entete
    N   = entete(0)
    tab = FLTARR(N)
    readf, unit, tab
    free_lun, unit

st     = CREATE_JULVAL(N)
st.val = tab    
help,st,/st

STEP        = ROUND(entete(1))
delt        = FLOAT(entete(1))/3600.       ;;en heures
duree       = FLOAT(N)*FLOAT(delt)/24.     ;;en jours

print, '*****************LECTURE DU FICHIER AU FORMAT JMM**********'
;;print, 'Travail sur la station de    : ', nom_station
;;print, 'LAT                          : ', lat
;;print, 'LON                          : ', lon
;;print, 'entete                       : ', entete
print, 'Ndata=',N,' de',delt,'  heures',' Duree=', duree, '  jours'

itrou = where(st.val eq flag, nb_trou)
IF (nb_trou ne 0) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
y_max       = MAX(st.val,MIN=y_min,/NaN)

;print, 'Nbre trou=', nb_trou
print, 'Y_max=', y_max , '    Y_min= ', y_min

;c CALCUL DES DATES DE DEBUT ET FIN ET RENVOIE DANS UNE STRUCTURE 

;; pb d'affichage des dates !!!
jul_deb = JULDAY(entete(3),entete(2),entete(4),entete(5),entete(6))
jul_fin = JULDAY(entete(3),entete(2),entete(4),entete(5),entete(6))+duree

print,FORMAT='(C())',jul_deb
print,FORMAT='(C())',jul_fin

st.jul = TIMEGEN(N, START = jul_deb, UNIT  = 'Seconds', STEP_SIZE=STEP)
RETURN,st
END
