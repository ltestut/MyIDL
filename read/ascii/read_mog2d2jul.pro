PRO read_mog2jul,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'read_mog2jul, struct, filename=nom du fichier'
 print, ''
 print, "INPUT : filename='nom_de_fichiers'"
 print, 'OUTPUT: structure de type {julien_time,valeur_ibmog2d,valeur_baro}'
 print, '        --> struct.jul'
 print, '        --> struct.ib'
 print, '        --> struct.baro'
 RETURN
ENDIF

Ndata = intarr(1)
flag  = 100000.


;c CREATION D'UNE STRUCTURE ANONYME --> jul,ib,baro
tmp = {jul:0.0D, ib:0.0, baro:0.0}


IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENR, UNIT, fic  , /GET_LUN        ;; ouverture du fichier
 READF, UNIT, Ndata                  ;; lecture de nombre de donnees
 PRINT,'NOMBRE DE DONNEES =',Ndata

;c REPLICATION DE LA STRUCURE

 struct=REPLICATE(tmp, Ndata)

 READF, UNIT, struct                  ;c Lecture de la struture 

 print,'Fin de lecture de la structure'
 FREE_LUN, UNIT
 ENDIF

print, 'On rajoute le nombre de jour Julien CNES à 00:00 !'
struct.jul = struct.jul + JULDAY(1,1,1950,0,0,0)

itrou1 = where(struct.ib eq flag, nb_trou1)
   IF (nb_trou1 ne 0) THEN BEGIN
     struct[itrou1].ib  = !VALUES.F_NAN
   ENDIF
itrou2 = where(struct.baro eq flag, nb_trou2)
   IF (nb_trou2 ne 0) THEN BEGIN
     struct[itrou2].baro = !VALUES.F_NAN
   ENDIF

t_max    = MAX(struct.jul ,MIN=t_min,/NaN)
ib_max   = MAX(struct.ib  ,MIN=ib_min,/NaN)
baro_max = MAX(struct.baro,MIN=baro_min,/NaN)

print,FORMAT='(C())',t_min
print,FORMAT='(C())',t_max
print, 'ib_max='  , ib_max , '    ib_min= ', ib_min
print, 'baro_max=', baro_max , '    baro_min= ', baro_min

;; Derniere modif: 25/03/03

END
