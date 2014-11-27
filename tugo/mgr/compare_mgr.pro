;################################## HEAD ##################################################
FUNCTION write_compare_header, mgr1,mgr2, unit=unit, compact=compact, fancy=fancy, html=html, tex=tex, mn=mn
; programme d'ecriture de l'entete de la comparaison de deux structure mgr
IF KEYWORD_SET(unit) THEN BEGIN
       IF KEYWORD_SET(html) THEN BEGIN
          text_main ='color:black;padding:4px;font-size:1.2em;'
          bck_sta   = 'background-color:rgb(0,102,204)'
          bck_obs   = 'background-color:rgb(245,245,245)'
          IF KEYWORD_SET(mn) THEN time_unit ='mn' ELSE time_unit ='h'
          PRINTF,UNIT, '<table style="border-width:1px;border-collapse:collapse;width:100%;height:50px;font-weight:normal;text-align:center;" border="1">'
          PRINTF,UNIT, FORMAT='(%"<tr style=\"%s;%s\" ><td colspan=\"9\">%s (%6.2f&#176;E,%6.2f&#176;N)</td></tr>")',$
           bck_sta,text_main,mgr1.name,mgr1.lon,mgr1.lat
          PRINTF,UNIT, FORMAT='(%"<tr style=\"%s\" ><td style=\"%s;\" colspan=\"4\">1 => %50s[%2s]</td><td colspan=\"4\">2 => %50s[%2s]</td></tr>")',$
           text_main,bck_obs,STRCOMPRESS(mgr1.origine,/REMOVE_ALL),STRCOMPRESS(mgr1.nwav,/REMOVE_ALL),STRCOMPRESS(mgr2.origine,/REMOVE_ALL),STRCOMPRESS(mgr2.nwav,/REMOVE_ALL)
          PRINTF,UNIT, FORMAT='(%"<tr><td>Wave</td><td  style=\"%s;\">A1</td><td  style=\"%s;\">G1</td><td>A2</td><td>G2</td><td>&#x00394;A=A1-A2</td><td>&#x00394;G(&#176;)=G1-G2</td><td>&#x00394;G(%s)</td><td>&Delta;E</td></tr>")',$
           bck_obs,bck_obs,time_unit 
           fmt='(%"<tr><td>%4s</td><td style=\"background-color:rgb(245,245,245);\">%5.1f</td><td style=\"background-color:rgb(245,245,245);\">%5.1f</td><td>%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%6.1f</td><td>%5.1f</td></tr>")'
       ENDIF ELSE IF KEYWORD_SET(tex) THEN BEGIN
         ;PRINTF,UNIT,"\begin{table}"
         ;PRINTF,UNIT,"\begin{center}"
         PRINTF,UNIT,"\begin{tabular}{|*{9}{c|}}"
         ;PRINTF,UNIT,"\multicolumn{9}{c}{"+STRUPCASE(mgr1.name)+"}\\
         ;PRINTF,UNIT,"\hline"
         PRINTF,UNIT,"             &\multicolumn{2}{|c|}{"+STRUPCASE(mgr1.origine)+"} &  \multicolumn{2}{|c|}{"+STRUPCASE(mgr2.origine)+"} & \multicolumn{4}{|c|}{Difference}\\"
         PRINTF,UNIT,"\hline"
         PRINTF,UNIT,"     & A     & G      & A         & G     & $\Delta_A$      & $\Delta_G$ &  $\Delta_h$ & $\Delta_E$ \\"
         ;PRINTF,UNIT,"\hline"
         
         fmt='(%"%4s & %5.1f & %6.1f & %5.1f & %6.1f & %6.1f & %6.1f & %6.1f & %5.1f \\\\")'
       ENDIF ELSE BEGIN
          PRINTF,UNIT,FORMAT="(A-80)",'####################################################'
          PRINTF,UNIT,FORMAT='(%"st1: %10s (%-20s) [%3d Waves]")',mgr1.name,mgr1.origine,mgr1.nwav
          PRINTF,UNIT,FORMAT='(%"st2: %10s (%-20s) [%3d Waves]")',mgr2.name,mgr2.origine,mgr2.nwav
       IF NOT KEYWORD_SET(compact) THEN BEGIN
          PRINTF,UNIT, 'A : amplitude in unit'
          PRINTF,UNIT, 'P : phase lag in degree'
          PRINTF,UNIT, 'dA: in unit'
          PRINTF,UNIT, 'dG: in degree'
          PRINTF,UNIT, 'dE: complex difference in unit'
          PRINTF,UNIT, '  '
       ENDIF
       PRINTF,UNIT, '1:',mgr1.origine,' / 2:', mgr2.origine,'     '
       PRINTF,UNIT, '|wave| A1  / G1  |   A2 / G2   |   dA |   dG |dG(h) |  dE |'
       PRINTF,UNIT, '-----------------------------------------------------------'
       fmt="(A4,2(F6.1,X),2(F6.1,X),3(F6.1,X),F5.1)"  ;default text format
      ENDELSE
ENDIF ELSE BEGIN
      PRINT, '---------------------------------------------------'
      PRINT,FORMAT='(%"st1: %10s (%-20s) [%3d Waves]")',mgr1.name,mgr1.origine,mgr1.nwav
      PRINT,FORMAT='(%"st2: %10s (%-20s) [%3d Waves]")',mgr2.name,mgr2.origine,mgr2.nwav
      IF NOT KEYWORD_SET(compact) THEN BEGIN
         PRINT, 'A : amplitude in unit'
         PRINT, 'P : phase lag in degree'
         PRINT, 'dA: in unit'
         PRINT, 'dG: in degree'
         PRINT, 'dE: complex difference in unit'
         PRINT, '  '
      ENDIF
      PRINT, '1:',mgr1.origine,' / 2:', mgr2.origine,'     '
      PRINT, '|wave| A1  / A2  |   G1 / G2   |   dA |   dG |dG(h) |  dE |'
      PRINT, '-----------------------------------------------------------'
      fmt="(A4,2(F6.1,X),2(F6.1,X),3(F6.1,X),F5.1)"  ;default display format
      IF KEYWORD_SET(fancy) THEN fmt="('|',A-4,'|',F5.1,'/',F5.1,'|',F6.1,'/',F6.1,'|',3(F6.1,'|'),F5.1,'|')"
ENDELSE
RETURN,fmt
END

;################################## TAIL ##################################################
PRO write_compare_tail, tmis, cpt, unit=unit, tex=tex,html=html
; programme d'ecriture de la fin de tableau en latex
IF KEYWORD_SET(unit) THEN BEGIN
   IF KEYWORD_SET(tex) THEN BEGIN
      PRINTF,UNIT,"\hline"
      PRINTF,UNIT,FORMAT='(%"%4s &  &  &  &  & %6.1f & %6.1f &  & %5.1f \\\\")','Mean', MEAN(tmis.sta[cpt].wave.da,/NAN),MEAN(tmis.sta[cpt].wave.dp,/NAN),MEAN(tmis.sta[cpt].wave.de,/NAN)
      PRINTF,UNIT,"\hline"
      PRINTF,UNIT,"\end{tabular}"
      ;PRINTF,UNIT,"\caption{"+tmis.sta[cpt].name+" Tidal Misfits}"
      ;PRINTF,UNIT,"\end{center}"
      ;PRINTF,UNIT,"\end{table}"
      PRINTF,UNIT,""
   ENDIF ELSE IF KEYWORD_SET(html) THEN BEGIN
   fmt_1 ='(%"<tr style=\"background-color:rgb(250,250,250);color:rgb(250,0,0);\"><td>%4s</td><td></td><td></td><td></td><td></td>'
   fmt_2 ='<td>%5.1f</td><td>%5.1f</td><td></td><td>%5.1f</td></tr>")'
   fmt_end=fmt_1+fmt_2
   PRINT,fmt_end
     PRINTF,UNIT,FORMAT=fmt_end,'Mean',MEAN(tmis.sta[cpt].wave.da,/NAN),MEAN(tmis.sta[cpt].wave.dp,/NAN),MEAN(tmis.sta[cpt].wave.de,/NAN)
   ENDIF
ENDIF
END




FUNCTION compare_mgr, mgr1_in,mgr2_in, waves=waves, output=output, scale=scale, $
                      tresh_amp=tresh_amp , $
                      no_reduce=no_reduce,_EXTRA=_EXTRA
; this function compares 2 mgr structures based on their common *station-name* 
;  1) sort the mgr according to their *station names* and *selected waves*
;  2) compute for each validat the difference of their amplitude, phase and complex misfits
;
; RETURN a tmis structure and display comparison table
;  
;  defaut output is displayed on the screen   
;      /compact   : remove the explaination legend
;      /fancy     : add separation pipe
;
;  == KEYWORDS ==
;  scale     = 100.               : scale factor for amplitude
;  waves     = ['M2','S2']        : give the list of waves you want to compare
;  output    = 'my_tables.txt'    : give a file name where the summary table will be written in either (txt, latex or html format)
;  tresh_amp = 2.                 : select only the waves where amp is superior to tresh_amp
;  /HTML
;  /MN                            : output the phase difference in minute instead of hours


 ;keyword default
IF KEYWORD_SET(output)    THEN OPENW,  UNIT, output, /GET_LUN
IF NOT KEYWORD_SET(scale) THEN scale=1.                      ;default should be in meter => scale=100. for cm
tscl=1.                                                      ;default time unit for phase diff is in hour
IF KEYWORD_SET(_extra) THEN IF ((WHERE(STRUPCASE(tag_names(_extra)) EQ 'MN')) GE 0) THEN tscl=60.  ;default time unit switch to minute if keyword set /mn
IF NOT KEYWORD_SET(tresh_amp) THEN tresh_amp=0.              ;default treshold for amplitude 

jc          = COMPLEX(0,1)                                   ;i complexe
wave_atlas  = load_tidal_wave_list(/UPPERCASE)               ;load tidal wave list (Name/frequence/period)

 ;reduce mgr1_in and mgr2_in to their common *station name*
IF KEYWORD_SET(no_reduce) THEN BEGIN
  mgr1  = mgr1_in
  mgr2  = mgr2_in
  ncomb = N_ELEMENTS(mgr1)
  common_wave  = cmset_op(REFORM(mgr1_in.wave,N_ELEMENTS(mgr1_in.wave)),'AND',$
                        REFORM(mgr2_in.wave,N_ELEMENTS(mgr2_in.wave)),COUNT=nwav) ;nwa =Nbre of common wave
  
ENDIF ELSE BEGIN
 reduce_mgr2common,mgr1_in, mgr2_in, mgr1, mgr2, n1,nwav, common_wave, ncomb
ENDELSE  

IF KEYWORD_SET(waves) THEN nwav=N_ELEMENTS(waves) ;nwav= common number of waves or number of input waves
tmis    = create_tmisfit(ncomb,nwav)              ;init tmis structure
cnt_val = 0                                       ;init the validats counter

FOR i=0,N_ELEMENTS(mgr1)-1 DO BEGIN  ;---------------loop on all mgr1 validats
id2 = WHERE((mgr2.name EQ mgr1[i].name) AND $  ; mgr2 id with same *station name* 
         (mgr2.origine NE mgr1[i].origine),cn2); but different *origine*
  IF (cn2 GE 1) THEN BEGIN                     ; if at least one match 
  FOR j=0,cn2-1 DO BEGIN             ;---------------------loop on all macthes     
    IF KEYWORD_SET(output) THEN fmt=write_compare_header(mgr1[i],mgr2[id2[j]],$
  UNIT=unit,_EXTRA=_EXTRA) ELSE fmt=write_compare_header(mgr1[i],mgr2[id2[j]],$
                                                                 _EXTRA=_EXTRA)
    IF KEYWORD_SET(waves)  THEN BEGIN
       wlist = waves 
    ENDIF ELSE BEGIN                 ;--automatic selection of wave list and sorting
       ifinite1  = WHERE(FINITE(mgr1[i].amp) AND (mgr1[i].amp*scale GT tresh_amp))
       ifinite2  = WHERE(FINITE(mgr2[id2[j]].amp) AND (mgr2[id2[j]].amp*scale GT tresh_amp))
       wlist1    = cmset_op(REFORM(mgr1[i].wave[ifinite1],N_ELEMENTS(mgr1[i].wave[ifinite1])),'AND',REFORM(mgr2[id2[j]].wave[ifinite2],N_ELEMENTS(mgr2[id2[j]].wave[ifinite2])),COUNT=nb_wave_max)
       wlist     = sort_wlist(wlist1,mgr1[i])
    ENDELSE
     nb_wave      = N_ELEMENTS(wlist)
     de_tab       = FLTARR(nb_wave)          ;init dE vector for this validat
     tmis.sta[cnt_val].code  = cnt_val 
     tmis.sta[cnt_val].name  = mgr1[i].name
     tmis.sta[cnt_val].org1  = mgr1[i].origine
     tmis.sta[cnt_val].org2  = mgr2[id2[j]].origine
     tmis.sta[cnt_val].lon   = mgr1[i].lon
     tmis.sta[cnt_val].lat   = mgr1[i].lat 
                 FOR k=0,nb_wave-1 DO BEGIN  ;------------------------------------loop on all common waves for this station 
                     ik1=WHERE(mgr1[i].wave      EQ wlist[k], count1)
                     ik2=WHERE(mgr2[id2[j]].wave EQ wlist[k], count2)
                      IF (count1 EQ 1 && count2 EQ 1) THEN BEGIN
                            z1  = mgr1[i].amp[ik1]*scale*EXP(jc*RAD(mgr1[i].pha[ik1]))                      ;Z1=a1*exp(i*p1)
                            z2  = mgr2[id2[j]].amp[ik2]*scale*EXP(jc*RAD(mgr2[id2[j]].pha[ik2]))            ;Z2=a2*exp(i*p2)
                            de  = ABS(z1-z2)                                                                ;|Z1-Z2| difference complexe
                            tmis.sta[cnt_val].wave[k].name =  mgr1[i].wave[ik1]                             ;common wave name
                            tmis.sta[cnt_val].wave[k].da   = (mgr1[i].amp[ik1]-mgr2[id2[j]].amp[ik2])*scale ;amplitude diff mgr1-mgr2
                            tmis.sta[cnt_val].wave[k].dp   = (mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2])       ;phase diff mgr1-mgr2
                            tmis.sta[cnt_val].wave[k].de   = de                                             ;complex diff mgr1-mgr2
                            de_tab[k]                      = de
                                 IF KEYWORD_SET(output) THEN BEGIN
                                   PRINTF,UNIT,FORMAT=fmt,mgr1[i].wave[ik1],mgr1[i].amp[ik1]*scale,mgr1[i].pha[ik1],mgr2[id2[j]].amp[ik2]*scale,mgr2[id2[j]].pha[ik2],$
                                                         (mgr1[i].amp[ik1]-mgr2[id2[j]].amp[ik2])*scale,(mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2]),$
                                                         (mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2])/tidal_wave_info(mgr1[i].wave[ik1],wave_list=wave_atlas)*tscl,de
                                 ENDIF ELSE BEGIN
                                   PRINT,FORMAT=fmt,     mgr1[i].wave[ik1],mgr1[i].amp[ik1]*scale,mgr2[id2[j]].amp[ik2]*scale,mgr1[i].pha[ik1], mgr2[id2[j]].pha[ik2],$
                                                        (mgr1[i].amp[ik1]-mgr2[id2[j]].amp[ik2])*scale,(mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2]),$
                                                        (mgr1[i].pha[ik1]-mgr2[id2[j]].pha[ik2])/tidal_wave_info(mgr1[i].wave[ik1],wave_list=wave_atlas)*tscl,de
                                 ENDELSE
                      ENDIF ELSE BEGIN
                           tmis.sta[cnt_val].wave[k].name = 'N/A'
                           tmis.sta[cnt_val].wave[k].da   = !VALUES.F_NAN
                           tmis.sta[cnt_val].wave[k].dp   = !VALUES.F_NAN
                           tmis.sta[cnt_val].wave[k].de   = !VALUES.F_NAN
                           de_tab[k]= !VALUES.F_NAN
                      ENDELSE
;                 debug line
;                 PRINT,FORMAT='(%"i=%2d,j=%2d,k=%2d,validat_number=%2d  | name=%s [wave=%4s]| da=%6.2f | dp=%7.2f | de=%6.2f")',i,j,k,cnt_val,$
;                 tmis.sta[cnt_val].name,tmis.sta[cnt_val].wave[k].name,tmis.sta[cnt_val].wave[k].da,tmis.sta[cnt_val].wave[k].dp,tmis.sta[cnt_val].wave[k].de
                 
                  ENDFOR  ;-------------------------------------------------------end loop on all waves
  IF KEYWORD_SET(output) THEN write_compare_tail,tmis,cnt_val,UNIT=unit,_EXTRA=_EXTRA
  cnt_val++                                                                       ;validats counter
  ENDFOR ;------------------------------------------------------------------------end loop on all match
  ENDIF  ;------------------------------------------------------------------------end if mgr2 have same name than mgr1 with different origine 
ENDFOR ;--------------------------------------------------------------------------end loop on all mgr1 validats


IF KEYWORD_SET(output) THEN BEGIN
 PRINT, 'Ecriture du fichier : ',output
 CLOSE, UNIT
 FREE_LUN, UNIT
ENDIF
RETURN,tmis
END