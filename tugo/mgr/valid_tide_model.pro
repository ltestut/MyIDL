FUNCTION valid_tide_model, mgr1_in, mgr2_in ,$
                               waves=waves, no_reduce=no_reduce ,$
                               output=output, fancy=fancy, $
                               latex=latex, html=html, show=show, $
                               show_origine=show_origine, show_number=show_number, _EXTRA=_EXTRA
; compute the validation table for a given model 
; mgr1_in : from observation  
; mgr2_in : from model  

 ;gestion des mots-clefs et initialisation
IF     KEYWORD_SET(output) THEN OPENW,  UNIT, output, /GET_LUN
ncol = 2 + KEYWORD_SET(show_origine) + KEYWORD_SET(show_number)

 ;reduce mgr1_in and mgr2_in to their common *station name*
IF KEYWORD_SET(no_reduce) THEN BEGIN
  mgr1  = mgr1_in
  mgr2  = mgr2_in
  ncomb = N_ELEMENTS(mgr1)
  nval  = N_ELEMENTS(mgr1)
  common_wave  = cmset_op(REFORM(mgr1_in.wave,N_ELEMENTS(mgr1_in.wave)),'AND',$
                        REFORM(mgr2_in.wave,N_ELEMENTS(mgr2_in.wave)),COUNT=nwav) ;nwa =Nbre of common wave
  
ENDIF ELSE BEGIN
 reduce_mgr2common,mgr1_in, mgr2_in, mgr1, mgr2, nval,nwav, wlist, ncomb
ENDELSE  
IF KEYWORD_SET(waves)  THEN wlist=waves
nb_wave=N_ELEMENTS(wlist)

 ;ascii header format
fmt_head        = '(24X,A1,'+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+'(A5,1X),A11)'
fmt_line        = '(I3,X,A-20,X,'+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+'("",F5.1,1X),"",F5.1)'
;fmt_line        = '(I3,":",A-20,":",'+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+'("",F5.1,":"),"",F5.1)' ;to paste in word table

head_line       = '|==========================================================================='
 ;latex header format
begin_tab_latex = "('\begin{tabular}{|*{"+STRCOMPRESS(STRING(nb_wave+ncol),/REMOVE_ALL)+"}{c|}}')"
multi_latex     = "('\multicolumn{"+STRCOMPRESS(STRING(nb_wave+ncol),/REMOVE_ALL)+'}{|c|}{'+mgr2[0].origine+"}\\')"
wave_latex      = "("+STRCOMPRESS(STRING(ncol-1),/REMOVE_ALL)+"(X,'&'),"                       +STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"(A3,X,'&'),"+"'$\sigma_{s}$  \\')"
sig_latex       = "("+STRCOMPRESS(STRING(ncol-1),/REMOVE_ALL)+"(A-15,X,'&'),"                  +STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"(F5.1,X,'&'),' \textbf{',F5.1,'}\\')"
error_latex     = "("+STRCOMPRESS(STRING(ncol-2),/REMOVE_ALL)+"(X,'&'),"+"'$\sigma_{w}$','&'," +STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"('\textbf{',F4.1,'}',X,'&'),'\textbf{RSS=',F4.1,'}\\')"
IF (ncol LE 2) THEN error_latex  = "('$\sigma_{w}$','&'," +STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"('\textbf{',F4.1,'}',X,'&'),'\textbf{RSS=',F4.1,' }\\')"
end_tab_latex   = "('\end{tabular}')"
 ;html header format 
wave_html       = "('<tr><td>Wave</td>',"+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"('<td>',A3,'</td>'),'<td>Error</td></tr>')"
error_html     = "('<tr style=""background-color:rgb(245,245,245);color:#0776A0;""><td>Error</td>',"+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"('<td>',F4.1,'</td>'),'<td style=""font-size:1.2em;color:#A61A00"">',F4.1,'</td></tr>')"
;amp_latex       = "('&',"+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"(F4.0,'cm &'),'\\ \hline')"
sig_html        = "('<tr><td>',A-25,'</td>',"+STRCOMPRESS(STRING(nb_wave),/REMOVE_ALL)+"('<td>',F4.1,'</td>'),'<td style=""background-color:rgb(245,245,245);color:#0776A0;"">',F4.1,'</td></tr>')"

IF KEYWORD_SET(output) THEN BEGIN 
 IF KEYWORD_SET(latex) THEN BEGIN
  PRINTF,UNIT,FORMAT=begin_tab_latex
  PRINTF,UNIT, '\hline'
  PRINTF,UNIT,FORMAT=multi_latex
  PRINTF,UNIT, '\hline'
  PRINTF,UNIT,FORMAT=wave_latex,wlist
  PRINTF,UNIT, '\hline'  
 ENDIF ELSE IF KEYWORD_SET(html) THEN BEGIN
  PRINTF,UNIT, '<table style="border-width:1px;border-collapse:collapse;width:100%;height:50px;font-weight:normal;text-align:center;" border="1">'
  PRINTF,UNIT, FORMAT="('<tr><td style=""background-color:rgb(130,130,130);color:white;padding:4px;font-size:1.2em;"" colspan="+STRCOMPRESS(STRING(nb_wave+2),/REMOVE_ALL)+">','MODEL = ',A-40,'</td></tr>')",mgr2[0].origine
  PRINTF,UNIT,FORMAT=wave_html,wlist
  ENDIF ELSE BEGIN
  PRINTF,UNIT, FORMAT='(20x,A60)',head_line
  PRINTF,UNIT, FORMAT="(20x,'|       MODEL = ',A-40)",mgr2[0].origine
  PRINTF,UNIT, FORMAT='(20x,A60)',head_line
  PRINTF,UNIT, FORMAT=fmt_head,' ',wlist,'total_error'
 ENDELSE
ENDIF ELSE BEGIN
 PRINT,FORMAT='(20x,A60)',head_line
 PRINT,FORMAT="(20x,'|       MODEL =',A25)",mgr2[0].origine
 PRINT,FORMAT='(20x,A60)',head_line
 PRINT,FORMAT=fmt_head,' ',wlist,'total_error'
ENDELSE

mrg_name     = STRARR(nval)                    ;tableau des noms des stations 
mrg_origine  = STRARR(nval)                    ;tableau des noms d'origine des series
de_tab     = FLTARR(nb_wave)                 ;tableau des DE pour un validat
de_tab_tot = FLTARR(nb_wave,nval)            ;tableau des DE pour tout les validats
tmis       = create_tmisfit(nval,nb_wave)   ;creation de la structure de type misfit

FOR i=0,nval-1 DO BEGIN    ;on parcours toutes les validats de mgr1 qui ont un nom commun dans mgr2
;  id2              = WHERE(mgr2.name EQ mgr1[i].name)                    ;on choisit l'indice de mgr2 qui a le meme nom de station que mgr1
  id2              = WHERE((mgr2.name EQ mgr1[i].name) AND (mgr2.origine NE mgr1[i].origine),cn2) ;index where mgr2 have same *station name* but differente *origine*
  de_tab           = mgr2de(mgr1[i],mgr2[id2],WLIST=wlist,_EXTRA=_EXTRA) ;on calcul DE pour la wlist
  sigma_site       = SQRT(TOTAL(de_tab*de_tab,/NAN)/2)                   ;calcul de l'erreur cumule du validat
  de_tab_tot[*,i]  = TRANSPOSE(de_tab)                                       ;
  mrg_name[i]      = mgr1[i].name ;+'/'+mgr1[i].origine
  mrg_origine[i]   = mgr1[i].origine
  tmis             = fill_tmisfit(tmis,mgr1[i],mgr2[id2],ista=i, wlist=wlist)
  IF KEYWORD_SET(output) THEN BEGIN
   IF KEYWORD_SET(latex) THEN BEGIN
      IF (KEYWORD_SET(show_origine) AND KEYWORD_SET(show_number)) THEN BEGIN
         PRINTF,UNIT,FORMAT=sig_latex,STRING(i+1,FORMAT='(I2)'),mgr1[i].name,mgr1[i].origine, de_tab/SQRT(2), sigma_site 
      ENDIF ELSE IF KEYWORD_SET(show_origine) THEN BEGIN
         PRINTF,UNIT,FORMAT=sig_latex,mgr1[i].name,mgr1[i].origine, de_tab/SQRT(2), sigma_site 
      ENDIF ELSE IF KEYWORD_SET(show_number) THEN BEGIN
         PRINTF,UNIT,FORMAT=sig_latex,STRING(i+1,FORMAT='(I2)'),mgr1[i].name, de_tab/SQRT(2), sigma_site 
      ENDIF ELSE BEGIN
         PRINTF,UNIT,FORMAT=sig_latex,mgr1[i].name, de_tab/SQRT(2), sigma_site
      ENDELSE
   ENDIF ELSE IF KEYWORD_SET(html) THEN BEGIN
   PRINTF,UNIT,FORMAT=sig_html,mgr1[i].name, de_tab/SQRT(2), sigma_site    
   ENDIF ELSE BEGIN
    PRINTF, UNIT, FORMAT=fmt_line, i+1,mrg_name[i], de_tab/SQRT(2), sigma_site
   ENDELSE
  ENDIF ELSE BEGIN
   PRINT, FORMAT=fmt_line, i+1, mrg_name[i], de_tab/SQRT(2), sigma_site
  ENDELSE
ENDFOR 
IF (nval LE 1) THEN BEGIN
 sigma_onde  =  SQRT((de_tab_tot*de_tab_tot)/2)
 sigma_comb  =  SQRT(TOTAL(sigma_onde*sigma_onde,/NAN))
 ;sigma_comb  =  SQRT(TOTAL(de_tab_tot*de_tab_tot,/NAN)/2)
 last_line   =  [sigma_onde, sigma_comb]
ENDIF ELSE BEGIN
 sigma_onde  =  SQRT(TOTAL(de_tab_tot*de_tab_tot, 2,/NAN)/(2*nval))
 sigma_comb  =  SQRT(TOTAL(sigma_onde*sigma_onde,/NAN))
; sigma_comb  =  SQRT(TOTAL(de_tab_tot*de_tab_tot,/NAN)/(2*n1))
 last_line   =  [sigma_onde, sigma_comb]
ENDELSE
tmis.rss     = sigma_comb
IF KEYWORD_SET(output) THEN BEGIN
  IF KEYWORD_SET(latex) THEN BEGIN 
  PRINTF,UNIT, '\hline'
  PRINTF,UNIT, FORMAT=error_latex,sigma_onde, sigma_comb
  PRINTF,UNIT, '\hline'
  PRINTF,UNIT, FORMAT=end_tab_latex
  PRINTF,UNIT, '\newline'
  PRINTF,UNIT, '\newline'
  PRINTF,UNIT, '\newline'
  ENDIF ELSE IF KEYWORD_SET(html) THEN BEGIN
  PRINTF,UNIT, FORMAT=error_html,sigma_onde, sigma_comb
  PRINTF,UNIT, '</table>'
    ENDIF ELSE BEGIN
  PRINTF,UNIT, FORMAT='(20x,A60)',head_line
  PRINTF,UNIT, FORMAT=fmt_line,0, 'mean_error', sigma_onde, sigma_comb
  ENDELSE
  PRINT, 'Ecriture du fichier : ',output
  CLOSE, UNIT
ENDIF ELSE BEGIN
 PRINT,FORMAT='(20x,A60)',head_line
 PRINT, FORMAT=fmt_line, 0, 'mean_error', sigma_onde, sigma_comb
ENDELSE

IF KEYWORD_SET(show) THEN BEGIN
;p = POLARPLOT(
p = POLARPLOT(tmis.sta.wave[0].da,tmis.sta.wave[0].dp,$
                LINESTYLE='none',SYMBOL='plus',SYM_COLOR='red',SYM_SIZE=2,/SYM_FILLED,$
                TITLE=tmis.STA[0].wave[0].name+'  ['+tmis.sta[0].org1+' / '+tmis.STA[0].org2+']',$
                XRANGE=[MIN(tmis.sta.wave.da),MAX(tmis.sta.wave.da)],YRANGE=[-10.,10.]$
               )
t = TEXT(tmis.sta.wave[0].da,tmis.sta.wave[0].dp,STRCOMPRESS(STRING(tmis.sta.code),/REMOVE_ALL),$
             TARGET=p,/DATA, ALIGNMENT=0., VERTICAL_ALIGNMENT=0.,ORIENTATION=0., $
             FONT_SIZE=14,COLOR='black')
                
;p =PLOT(REFORM(de_tab_tot[0,*]/SQRT(2)),YTITLE="RMS Misfit (cm)",_EXTRA=_EXTRA)
ENDIF

CLOSE, UNIT
FREE_LUN, UNIT
RETURN, tmis
END
