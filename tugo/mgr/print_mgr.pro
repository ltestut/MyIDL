; docformat = 'rst'
;+
; :Author:
;    ltestut     - Laurent Testut, LEGOS, laurent.testut@legos.obs-mip.fr
;-

PRO print_mgr, mgr, scale=scale, station=station, wave=wave, list=list
  ;+
  ; :Description:
  ;    Display on console of the amp/phase of the mgr structure
  ;    Amplitude are in decreasing order
  ; :Params:
  ;    mgr   : the mgr to be displayed
  ;    
  ; :Keywords:
  ;    scale     :  to switch to cm scale=100.
  ;    station  :  display a condensed line for the station : station='Karachi'
  ;    wave    :  
  ;    list        : display the list of station with their respective number
  ;    
  ; :Author: Testut
  ;-

IF NOT KEYWORD_SET(scale) THEN scale=1. ; defaut is to stay in meter
nsta    = N_ELEMENTS(mgr.name)          ; nbre de station du mgr

 ; default format 
fmt_line="('|',A-4,'|',F5.1,' / ',F5.1)"
fmt_head="('>',A-20,'(',A7,',',A7,')[',A-15,']')"

IF KEYWORD_SET(list) THEN BEGIN
  FOR i=0,nsta-1 DO PRINT,FORMAT='(%"St Num= %03i ==> %s")',i,mgr[i].name
ENDIF ELSE BEGIN
  IF KEYWORD_SET(station) THEN BEGIN
      IF NOT KEYWORD_SET(wave) THEN wave='M2'
      ista  = WHERE(mgr.name EQ STRUPCASE(station),cpt)
      iwave = WHERE(mgr[ista].wave EQ STRUPCASE(wave),cpt)
      PRINT,FORMAT='(%"lon=%06.2f lat=%06.2f amp=%06.2f pha=%06.2f")',mgr[ista].lon,mgr[ista].lat,mgr[ista].amp[iwave]*scale,mgr[ista].pha[iwave]
  ENDIF ELSE BEGIN
  FOR i=0,nsta-1 DO BEGIN
     PRINT, '------------------------------------------------------'
     PRINT,FORMAT=fmt_head,STRCOMPRESS(mgr[i].name,/REMOVE_ALL),$
       STRING(mgr[i].lon,FORMAT='(F7.2)'),STRING(mgr[i].lat,FORMAT='(F7.2)'),$
       STRCOMPRESS(mgr[i].origine,/REMOVE_ALL)
     PRINT, '|wave| Amp  / Pha   '
     PRINT, '------------------------------------------------------'
    FOR j=0,mgr[i].nwav-1 DO BEGIN
      jmax = REVERSE(SORT(mgr[i].amp))
      PRINT,FORMAT=fmt_line,mgr[i].wave[jmax[j]],mgr[i].amp[jmax[j]]*scale,mgr[i].pha[jmax[j]]
    ENDFOR
  ENDFOR
 ENDELSE 
ENDELSE
END