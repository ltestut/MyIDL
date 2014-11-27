PRO read_tpa,  struct, filename=fic

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'read_column_topex_allpara, st, filename=nom du fichier'
 print, ''
 print, "INPUT : file --> nom_de_fichiers'
 print, 'OUTPUT: st   --> structure de type {ALLPARA}'
 RETURN
ENDIF

tmp = {ALLPARA     ,$
        jul:0.0D,$
	sat:0   ,$
        cyc:0   ,$
        tra:0   ,$
	npt:0   ,$
	std:0.0 ,$
        lat:0.0 ,$
        lon:0.0 ,$
        dis:0.0 ,$
      range:0.0D,$
       nasa:0.0D,$
       cnes:0.0D,$
        mss:0.0 ,$
      geoid:0.0 ,$
     tropos:0.0 ,$
     tropoh:0.0 ,$      
       ibtp:0.0 ,$
    ibecmwf:0.0 ,$
    ibmog2d:0.0 ,$
     ionotp:0.0 ,$
  ionodoris:0.0 ,$
   ionobent:0.0 ,$
  solidtide:0.0 ,$
  polartide:0.0 ,$
    gottide:0.0 ,$
    festide:0.0 ,$
    ssbcnes:0.0 ,$
    ssbnasa:0.0 ,$
     waweku:0.0 ,$
      wawec:0.0 ,$
       wind:0.0 }

Ndata = 0L
flag  = 99999.900
flagd = 99999.900D
flag2d = 999.999D

IF (KEYWORD_SET(FIC)) THEN BEGIN
 OPENR, UNIT, fic  , /GET_LUN        ;; ouverture du fichier
 READF, UNIT, Ndata                  ;; lecture de nombre de donnees
 struct=REPLICATE(tmp,Ndata) 
 READF, UNIT, struct                  ;c Lecture de la struture 
 FREE_LUN, UNIT
 ENDIF

;;print, 'On rajoute le nombre de jour Julien TOPEX à 00:00 !'
struct.jul = struct.jul + JULDAY(1,1,1958,0,0,0)

FOR I=0,N_TAGS(struct)-1 DO BEGIN
  itrou=where(struct.(I) eq flag OR struct.(I) eq flagd OR struct.(I) eq flag2d, n)
  IF (n GT 0) THEN struct[itrou].(I)=!VALUES.F_NAN
ENDFOR

t_max    = MAX(struct.jul    ,MIN=t_min,/NAN)
val_max  = MAX(struct.range  ,MIN=val_min,/NAN)
t_val_min= struct[WHERE(struct.range eq val_min)].jul
t_val_max= struct[WHERE(struct.range eq val_max)].jul

print,'********************LECTURE D UN FICHIER A FORMAT TOPEX'
print,FORMAT='(C())',t_min
print,FORMAT='(C())',t_max
print,'Vmax=',val_max,'   MAX_JULDAY',t_val_max-JULDAY(1,1,1958,0,0,0)
print,FORMAT='(C())',t_val_max
print,'Vmin=',val_min,'   MIN_JULDAY',t_val_min-JULDAY(1,1,1958,0,0,0)
print,FORMAT='(C())',t_val_min
print,'*********************************************************'

;; Derniere modif: 02/03/04

END
