FUNCTION load_track,mertz=mertz,$
                  b9b1=b9b1,b9b2=b9b2,$
                  tide=tide,mto=mto,$
                  lydie=lydie,across=across,$
                  proj=proj,$
                  quiet=quiet

; UTILISATION DES MOT-CLES:
; ------------------------
; /mertz, /b9b1, /tide , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit
; /mertz, /b9b1, /mto  , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit
; /mertz, /b9b1        , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit maree+mto
; /mertz, /b9b1, /tide          =>  champ de vitesse interpole au section East,Mid, West de Benoit
; /mertz, /b9b1, /mto           =>  champ de vitesse interpole au section East,Mid, West de Benoit
; /mertz, /b9b1                 =>  champ de vitesse interpole au section East,Mid, West de Benoit maree+mto
; /mertz, /b9b1, /lydie         =>  champ de vitesse along Mertz pour Lydie mto
; /mertz, /b9b1, /lydie, /across =>  champ de vitesse along Mertz pour Lydie mto across Mertz
; /mertz, /b9b2, /tide , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit
; /mertz, /b9b2, /mto  , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit
; /mertz, /b9b2        , /proj  =>  champ de vitesse normal au section East,Mid, West de Benoit maree+mto
; /mertz, /b9b2, /tide          =>  champ de vitesse interpole au section East,Mid, West de Benoit
; /mertz, /b9b2, /mto           =>  champ de vitesse interpole au section East,Mid, West de Benoit
; /mertz, /b9b2, /lydie         =>  champ de vitesse along Mertz pour Lydie mto
; /mertz, /b9b2                 =>  champ de vitesse interpole au section East,Mid, West de Benoit maree+mto
; /mertz, /mto                  =>  champ de vitesse mto interpole au section East,Mid, West de Benoit
; /mertz, /mto,        ,/proj   =>  champ de vitesse mto normal interpole au section East,Mid, West de Benoit

;classement par zone
IF KEYWORD_SET(mertz) THEN BEGIN
   ;classement par simu
   IF KEYWORD_SET(b9b1) THEN BEGIN
      ;classement par projete ou non
      IF KEYWORD_SET(lydie) THEN BEGIN
        file=!idl_scan_arx+'track_mertz_b9b1_lydie_mto_nov07-jan08.sav'
        IF KEYWORD_SET(across) THEN file=!idl_scan_arx+'track_mertz_across_b9b1_lydie_mto_nov07-jan08.sav'
       ENDIF ELSE BEGIN
       IF KEYWORD_SET(proj) THEN BEGIN
        file=!idl_scan_arx+'track_mertz_b9b1_tide+mto_feb-mar2010_proj.sav'
        IF KEYWORD_SET(tide) THEN file=!idl_scan_arx+'track_mertz_b9b1_tide_feb-mar2010_proj.sav'
        IF KEYWORD_SET(mto)  THEN file=!idl_scan_arx+'track_mertz_b9b1_mto_feb-mar2010_proj.sav'
       ENDIF ELSE BEGIN
        file=!idl_scan_arx+'track_mertz_b9b1_tide+mto_feb-mar2010.sav'
        IF KEYWORD_SET(tide) THEN file=!idl_scan_arx+'track_mertz_b9b1_tide_feb-mar2010.sav'
        IF KEYWORD_SET(mto)  THEN file=!idl_scan_arx+'track_mertz_b9b1_mto_feb-mar2010.sav'
       ENDELSE
      ENDELSE
   ENDIF ELSE IF KEYWORD_SET(b9b2) THEN BEGIN
      ;classement par projete ou non
      IF KEYWORD_SET(lydie) THEN BEGIN
        file=!idl_scan_arx+'track_mertz_b9b2_lydie_mto_nov07-jan08.sav'
       ENDIF ELSE BEGIN
       IF KEYWORD_SET(proj) THEN BEGIN
        file=!idl_scan_arx+'track_mertz_b9b2_tide+mto_feb-mar2010_proj.sav'
        IF KEYWORD_SET(tide) THEN file=!idl_scan_arx+'track_mertz_b9b2_tide_feb-mar2010_proj.sav'
        IF KEYWORD_SET(mto)  THEN file=!idl_scan_arx+'track_mertz_b9b2_mto_feb-mar2010_proj.sav'
       ENDIF ELSE BEGIN
        file=!idl_scan_arx+'track_mertz_b9b1_tide+mto_feb-mar2010.sav'
        IF KEYWORD_SET(tide) THEN file=!idl_scan_arx+'track_mertz_b9b2_tide_feb-mar2010.sav'
        IF KEYWORD_SET(mto)  THEN file=!idl_scan_arx+'track_mertz_b9b2_mto_feb-mar2010.sav'
       ENDELSE
       ENDELSE     
   ENDIF ELSE BEGIN
      IF KEYWORD_SET(proj) THEN file=!idl_scan_arx+'track_mertz_mto_jan-mar2010_proj.sav' ELSE file=!idl_scan_arx+'track_mertz_mto_jan-mar2010.sav'
   ENDELSE
ENDIF


RESTORE,file,DESCRIPTION=descr

IF NOT KEYWORD_SET(quiet) THEN BEGIN
  PRINT,file
  PRINT,descr
ENDIF

RETURN,track
END