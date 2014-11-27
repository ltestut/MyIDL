FUNCTION load_scan,dom=dom,sec=sec,cont=cont,$
                  ant=ant,mertz=mertz,b9b=b9b,along=along,across=across,$
                  benoit=benoit,model=model,lydie=lydie,nindian=nindian,$
                  quiet=quiet

; UTILISATION DES MOT-CLES:
; ------------------------
; /dom, /ant,               =>  segment dom.scan du modele Antarctique
; /sec, /mertz,             =>  segment des sections.dat du modele mertz
; /sec, /mertz, /lydie      =>  segment along mertz pour Lydie
; /sec, /mertz, /lydie      =>  segment along mertz pour Lydie


IF KEYWORD_SET(dom) THEN BEGIN
  ;classement par zone
  IF KEYWORD_SET(ant) THEN BEGIN
          file=!idl_scan_arx+'dom_antarctic_model.sav'
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ENDIF
  ;ENDELSE
ENDIF

IF KEYWORD_SET(nindian) THEN BEGIN
  ;classement par zone
  file=!idl_scan_arx+'nindian_isobath200m.sav'
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ;ENDIF
  ;ENDELSE
ENDIF


IF KEYWORD_SET(sec) THEN BEGIN
  ;classement par zone
  IF KEYWORD_SET(mertz) THEN BEGIN
     IF KEYWORD_SET(model) THEN BEGIN
       file=!idl_scan_arx+'section_mertz_model.sav'
     ENDIF ELSE IF KEYWORD_SET(benoit) THEN BEGIN
       file=!idl_scan_arx+'section_mertz_benoit.sav'
     ENDIF ELSE IF KEYWORD_SET(lydie) THEN BEGIN
       IF KEYWORD_SET(along) THEN file=!idl_scan_arx+'section_along_mertz_lydie.sav'
       IF KEYWORD_SET(across) THEN file=!idl_scan_arx+'section_across_mertz_lydie.sav'
     ENDIF
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ENDIF
  ;ENDELSE
ENDIF

IF KEYWORD_SET(cont) THEN BEGIN
  ;classement par zone
  IF KEYWORD_SET(mertz) THEN BEGIN
     IF KEYWORD_SET(b9b) THEN BEGIN
       file=!idl_scan_arx+'cont_mertz_b9b_1_2.sav'
     ENDIF ELSE IF KEYWORD_SET(c28) THEN BEGIN
       ;file=!idl_scan_arx+'section_mertz_benoit.sav'
     ENDIF
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ;ENDIF ELSE IF KEYWORD_SET() THEN BEGIN
  ENDIF
  ;ENDELSE
ENDIF



RESTORE,file,DESCRIPTION=descr

IF NOT KEYWORD_SET(quiet) THEN BEGIN
  PRINT,file
  PRINT,descr
ENDIF

RETURN,seg
END