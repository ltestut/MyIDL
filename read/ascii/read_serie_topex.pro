PRO read_serie_topex,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'read_serie_topex, serie, filename=nom du fichier'
 print, ''
 print, "INPUT : filename='nom_de_fichiers'"
 print, 'OUTPUT: structure de type {julien_time,value}'
 print, '        --> struct.jul'
 print, '        --> struct.val'
 RETURN
ENDIF

Ndata = intarr(1)
flag  = 9999.99


;c CREATION D'UNE STRUCTURE ANONYME --> jul,ib,baro
tmp = {jul:0.0D, val:0.0}


IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENR, UNIT, fic  , /GET_LUN        ;; ouverture du fichier
 READF, UNIT, Ndata                  ;; lecture de nombre de donnees
 PRINT,'NOMBRE DE DONNEES =',Ndata
;c REPLICATION DE LA STRUCURE
 struct=REPLICATE(tmp, Ndata)
 READF, UNIT, struct                  ;c Lecture de la struture 
 FREE_LUN, UNIT
 ENDIF

print, 'On rajoute le nombre de jour Julien TOPEX à 00:00 !'
struct.jul = struct.jul + JULDAY(1,1,1958,0,0,0)

itrou = where(struct.val eq flag, nb_trou)
   IF (nb_trou ne 0) THEN BEGIN
     struct[itrou].val  = !VALUES.F_NAN
   ENDIF

t_max    = MAX(struct.jul ,MIN=t_min,/NaN)
val_max  = MAX(struct.val ,MIN=val_min,/NaN)

print,FORMAT='(C())',t_min
print,FORMAT='(C())',t_max
print, 'Vmax='  , val_max , '    Vmin= ', val_min

;; Derniere modif: 09/04/03

END
