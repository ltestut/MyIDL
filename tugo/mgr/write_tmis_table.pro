PRO write_tmis_header, tmis,  unit=unit, compact=compact, html=html, fmt=fmt
; programme d'ecriture de l'entete de la comparaison de deux structure mgr
IF KEYWORD_SET(unit) THEN BEGIN
       IF KEYWORD_SET(html) THEN BEGIN
          text_main ='color:black;padding:4px;font-size:1.2em;'
          bck_sta   = 'background-color:rgb(0,102,204)'
          bck_obs   = 'background-color:rgb(245,245,245)'
          PRINTF,UNIT, '<table style="border-width:1px;border-collapse:collapse;width:100%;height:50px;font-weight:normal;text-align:center;" border="1">'
          PRINTF,UNIT, FORMAT='(%"<tr style=\"%s;%s\" ><td colspan=\"8\">%10s</td></tr>")',$
           bck_sta,text_main,STRCOMPRESS(mgr1.name,/REMOVE_ALL)
          PRINTF,UNIT, FORMAT='(%"<tr style=\"%s\" ><td style=\"%s;\" colspan=\"4\">1 => %10s[%2s]</td><td colspan=\"4\">2 => %10s[%2s]</td></tr>")',$
           text_main,bck_obs,STRCOMPRESS(mgr1.origine,/REMOVE_ALL),STRCOMPRESS(mgr1.nwav,/REMOVE_ALL),STRCOMPRESS(mgr2.origine,/REMOVE_ALL),STRCOMPRESS(mgr2.nwav,/REMOVE_ALL)
          PRINTF,UNIT, FORMAT='(%"<tr><td>Wave</td><td  style=\"%s;\">A1</td><td>A2</td><td  style=\"%s;\">P1</td><td>P2</td><td>&#x00394;A</td><td>&#x00394;P(&#176;)</td><td>&#x00394;P(h)</td><td>&Delta;E</td></tr>")',$
           bck_obs,bck_obs 
           fmt='(%"<tr><td>%4s</td><td style=\"background-color:rgb(245,245,245);\">%5.1f</td><td>%5.1f</td><td style=\"background-color:rgb(245,245,245);\">%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%5.1f</td></tr>")'

       ENDIF ELSE BEGIN
          PRINTF,UNIT,FORMAT="(A-80)",'####################################################'
          PRINTF,UNIT,FORMAT="('st1:',A-10,'(',A-25,')','[',I3,' ONDES]')",STRCOMPRESS(mgr1.name,/REMOVE_ALL),STRCOMPRESS(mgr1.origine,/REMOVE_ALL),STRCOMPRESS(mgr1.nwav,/REMOVE_ALL)
          PRINTF,UNIT,FORMAT="('st2:',A-10,'(',A-25,')','[',I3,' ONDES]')",STRCOMPRESS(mgr2.name,/REMOVE_ALL),STRCOMPRESS(mgr2.origine,/REMOVE_ALL),STRCOMPRESS(mgr2.nwav,/REMOVE_ALL)
       IF NOT KEYWORD_SET(compact) THEN BEGIN
          PRINTF,UNIT, 'A : amplitude in unit'
          PRINTF,UNIT, 'P : phase lag in degree'
          PRINTF,UNIT, 'dA: in unit'
          PRINTF,UNIT, 'dP: in degree'
          PRINTF,UNIT, 'dE: complex difference in unit'
          PRINTF,UNIT, '  '
       ENDIF
       PRINTF,UNIT, '1:',mgr1.origine,' / 2:', mgr2.origine,'     '
       PRINTF,UNIT, '|wave| A1  / A2  |   P1 / P2   |   dA |   dP |dP(h) |  dE |'
       PRINTF,UNIT, '-----------------------------------------------------------'  
      ENDELSE
ENDIF ELSE BEGIN
      PRINT, '---------------------------------------------------'
      PRINT,FORMAT="('st1:',A-10,'(',A-25,')','[',I3,' ONDES]')",STRCOMPRESS(mgr1.name,/REMOVE_ALL),STRCOMPRESS(mgr1.origine,/REMOVE_ALL),STRCOMPRESS(mgr1.nwav,/REMOVE_ALL)
      PRINT,FORMAT="('st2:',A-10,'(',A-25,')','[',I3,' ONDES]')",STRCOMPRESS(mgr2.name,/REMOVE_ALL),STRCOMPRESS(mgr2.origine,/REMOVE_ALL),STRCOMPRESS(mgr2.nwav,/REMOVE_ALL)
      IF NOT KEYWORD_SET(compact) THEN BEGIN
         PRINT, 'A : amplitude in unit'
         PRINT, 'P : phase lag in degree'
         PRINT, 'dA: in unit'
         PRINT, 'dP: in degree'
         PRINT, 'dE: complex difference in unit'
         PRINT, '  '
      ENDIF
      PRINT, '1:',tmis.sta.origine,' / 2:', mgr2.origine,'     '
      PRINT, '|wave| A1  / A2  |   P1 / P2   |   dA |   dP |dP(h) |  dE |'
      PRINT, '-----------------------------------------------------------'
ENDELSE
END


PRO write_tmis_table, tmis, wave=wave, output=output, scale=scale
 ;procedure to display and write on ascii or html format a misfit list
 
IF NOT KEYWORD_SET(scale) THEN scale=1. ;passage de m a cm dans le cas des mgr classique
IF KEYWORD_SET(output) THEN OPENW,  UNIT, output, /GET_LUN
fmt='(%" %10s  %6.2f %6.2f %3s %6.2f %6.2f %6.2f "

jc  = COMPLEX(0,1) ;i complexe

 ;on charge la liste d'onde qui met en relation nom/frequence/periode
wave_list= load_tidal_wave_list()
nsta     = N_ELEMENTS(tmis.sta)
nwave    = N_ELEMENTS(tmis.sta[0].wave)

FOR i=0,nsta-1 DO BEGIN                   ;loop on selected station
   IF KEYWORD_SET(output) THEN BEGIN
      write_compare_header,mgr1[i],mgr2[id2[j]],UNIT=unit,fmt=fmt,_EXTRA=_EXTRA
   ENDIF ELSE BEGIN
      write_compare_header,mgr1[i],mgr2[id2[j]], _EXTRA=_EXTRA
   ENDELSE
   FOR j=0,nwave-1 DO BEGIN             ;loop on selected waves
           IF KEYWORD_SET(output) THEN BEGIN
              PRINTF,UNIT,FORMAT=fmt,mgr1[i].wave[ik1],mgr1[i].amp[ik1]*scale,mgr2[id2[j]].amp[ik2]*scale,$
                   mgr1[i].pha[ik1], mgr2[id2[j]].pha[ik2],$
                   ABS(mgr1[i].amp[ik1]-mgr2[id2[j]].amp[ik2])*scale,ABS(mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2]),$
                   ABS(mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2])/tidal_wave_info(mgr1[i].wave[ik1],wave_list=wave_list),de
           ENDIF ELSE BEGIN
           PRINT,FORMAT=fmt,tmis.sta[i].name,tmis.sta[i].lon,tmis.sta[i].lat,tmis.sta[i].wave[j].name,$
                   tmis.sta[i].wave[j].da,tmis.sta[i].wave[j].dp,tmis.sta[i].wave[j].dp/tidal_wave_info(tmis.sta[i].wave[j].name,wave_list=wave_list)
           ENDELSE
           cnt_wave          = cnt_wave+1
         
    ENDFOR  ;end loop for waves
ENDFOR     ;end loop for station

IF KEYWORD_SET(output) THEN BEGIN
 PRINTF,UNIT,'---------------------------------------------------'
 PRINT, 'Ecriture du fichier : ',output
 FREE_LUN, UNIT
 CLOSE, UNIT
ENDIF
 
 
 
END