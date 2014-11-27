FUNCTION load_section, mertz=mertz,$
                     b9b1=b9b1,b9b2=b9b2,remaining_b9b2=remaining_b9b2,$
                     mto=mto,tide=tide,$
                  quiet=quiet

; UTILISATION DES MOT-CLES:
; ------------------------
; /mertz, /b9b1           =>  section de la simu b9b1 du model mertz [maree]
; /mertz, /b9b1, /mto     =>  section de la simu b9b1 du model mertz [meteo]

IF KEYWORD_SET(mertz) THEN BEGIN
  IF KEYWORD_SET(b9b1) THEN BEGIN
    IF KEYWORD_SET(mto) THEN BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_mto_b9b1.sav'
    ENDIF ELSE BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_tide_b9b1.sav'
    ENDELSE
  ENDIF ELSE IF KEYWORD_SET(b9b2) THEN BEGIN
    IF KEYWORD_SET(mto) THEN BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_mto_b9b2.sav'
    ENDIF ELSE BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_tide_b9b2.sav'
    ENDELSE
  ENDIF ELSE IF KEYWORD_SET(remaining_b9b2) THEN BEGIN
    IF KEYWORD_SET(mto) THEN BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_mto_remaining_b9b2.sav'
    ENDIF ELSE BEGIN
     file=!idl_sample_arx+'mertz/tugo_section_tide_remaining_b9b2.sav'
    ENDELSE

  ENDIF ELSE BEGIN
  ENDELSE
ENDIF

RESTORE,file,DESCRIPTION=descr

IF NOT KEYWORD_SET(quiet) THEN BEGIN
  PRINT,file
  PRINT,descr
ENDIF

RETURN,sec
END