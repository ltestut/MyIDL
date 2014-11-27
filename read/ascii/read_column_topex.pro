PRO read_column_topex,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'read_column_topex, st, filename=nom du fichier'
 print, ''
 print, "INPUT : file --> nom_de_fichiers'
 print, 'OUTPUT: st   --> structure de type {ALTI}'
 RETURN
ENDIF

tmp = {ALTI     ,$
        jul:0.0D,$
        cyc:0   ,$
        tra:0   ,$
        lat:0.0 ,$
        lon:0.0 ,$
        dis:0.0 ,$
       slev:0.0 ,$
      cslev:0.0 ,$
        sla:0.0 ,$
       hdyn:0.0 ,$
         ib:0.0 ,$
      geoid:0.0 ,$
        mss:0.0 ,$      
      bathy:0.0 ,$
       cenv:0.0 ,$
       cgeo:0.0 ,$
       cssb:0.0 ,$
        rms:0.0 ,$
       npts:0   ,$
	sat:0}

Ndata = 0L
flag  = 99999.9

IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENR, UNIT, fic  , /GET_LUN        ;; ouverture du fichier
 READF, UNIT, Ndata                  ;; lecture de nombre de donnees
;; PRINT,'REPLICATE STRUCT ANONYME = NOMBRE DE DONNEES =',Ndata
 struct=REPLICATE(tmp,Ndata) 
 READF, UNIT, struct                  ;c Lecture de la struture 
 FREE_LUN, UNIT
 ENDIF
;; HELP,struct
;;print, 'On rajoute le nombre de jour Julien TOPEX à 00:00 !'
struct.jul = struct.jul + JULDAY(1,1,1958,0,0,0)

i = where(struct.slev eq flag, n)
  IF (n ne 0) then struct[i].slev   = !VALUES.F_NAN
i = where(struct.cslev eq flag, n)
  IF (n ne 0) then struct[i].cslev  = !VALUES.F_NAN
i = where(struct.sla eq flag, n)
  IF (n ne 0) then struct[i].sla    = !VALUES.F_NAN
i = where(struct.geoid eq flag, n)
  IF (n ne 0) then struct[i].geoid  = !VALUES.F_NAN
i = where(struct.mss eq flag, n)
  IF (n ne 0) then struct[i].mss    = !VALUES.F_NAN
i = where(struct.hdyn eq flag, n)
  IF (n ne 0) then struct[i].hdyn   = !VALUES.F_NAN
i = where(struct.ib eq flag, n)
  IF (n ne 0) then struct[i].ib     = !VALUES.F_NAN
i = where(struct.bathy eq flag, n)
  IF (n ne 0) then struct[i].bathy  = !VALUES.F_NAN
i = where(struct.cenv eq flag, n)
  IF (n ne 0) then struct[i].cenv   = !VALUES.F_NAN
i = where(struct.cgeo eq flag, n)
  IF (n ne 0) then struct[i].cgeo   = !VALUES.F_NAN
i = where(struct.cssb eq flag, n) 
  IF (n ne 0) then struct[i].cssb   = !VALUES.F_NAN
i = where(struct.rms eq flag, n) 
  IF (n ne 0) then struct[i].rms    = !VALUES.F_NAN


t_max    = MAX(struct.jul   ,MIN=t_min,/NAN)
val_max  = MAX(struct.sla  ,MIN=val_min,/NAN)
t_val_min= struct[WHERE(struct.sla eq val_min)].jul
t_val_max= struct[WHERE(struct.sla eq val_max)].jul

print,'********************LECTURE D UN FICHIER A FORMAT TOPEX'
print,FORMAT='(C())',t_min
print,FORMAT='(C())',t_max
print,'Vmax=',val_max,'   MAX_JULDAY',t_val_max-JULDAY(1,1,1958,0,0,0)
print,FORMAT='(C())',t_val_max
print,'Vmin=',val_min,'   MIN_JULDAY',t_val_min-JULDAY(1,1,1958,0,0,0)
print,FORMAT='(C())',t_val_min
print,'*********************************************************'

;; Derniere modif: 17/07/03

END
