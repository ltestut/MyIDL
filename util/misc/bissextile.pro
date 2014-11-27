FUNCTION bissextile, y
;  "Les annÃ©es bissextiles sont celles dont le millÃ©sime est multiple de 4 sauf celles
; dont le millÃ©sime est multiple de 100 sans l'Ãªtre de 400."B. Simon,Cours sur la marÃ©e

c1 = ((y MOD 400) EQ 0)    ; 1 si multiple de 400
c2 = ((y MOD 4)   EQ 0)    ; 1 si multiple de 4
c3 = ((y MOD 100) NE 0)    ; 1 si non-multiple de 100
;print,"Multiple de 400    ",c1,float(y)/400.
;print,"Multiple de 4      ",c2,float(y)/4.
;print,"Non-Multiple de 100",c3,float(y)/100.

IF c1 THEN BEGIN
;print,"Annee bissextile"
RETURN,366
ENDIF ELSE BEGIN
   IF ((c2+c3) EQ 2) THEN BEGIN
;   print,"Annee bissextile"
   RETURN,366
   ENDIF ELSE BEGIN
;   print,"Non"
   RETURN,365
   ENDELSE
ENDELSE
END
