PRO plot_annual_cycle, st_raw, ps=ps, png=png, output=output, small=small, filter=filter, pal=pal,_EXTRA=_EXTRA
; ebauche de routine de calcul et de plot du cycle annuel
; ; mettre au ppropre ce propre, ajouter la possiblite d'une 2eme serie
; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map


IF NOT KEYWORD_SET(pal) THEN pal=13
LOADCT,pal

; on filtre les donnees brutes (par default a 1 mois)
IF NOT KEYWORD_SET(filter) THEN filter=1. 
st   = smooth_julval(st_raw,ts=24.*30.*filter,/EDGE_TRUNCATE,/VERB) ;
;st   = st_raw
nday = 15 ;calcul des moyennes mensuelles pour au moins Nday jours disponible dans le mois

; determination des positions de cadres et titre par defaut
pos_ac   = [0.1,0.65,0.8,0.9] ;coord du cadre du haut
pos_st   = [0.1,0.2,0.8,0.5] ;coord du cadre du bas
xtab1    = 0.05              ;position de la legende du cadre du haut
ytab1    = pos_ac[1]-0.07    ;   " 
xtab2    = xtab1             ;position de la legende du cadre du bas
ytab2    = pos_st[1]-0.07    ;   "
xinfo    = pos_st[2]+0.01    ;position de la colonne des annees
yinfo    = pos_st[3]         ;position de la colonne des annees
cz_txt   = 1.                ;taille des caracteres des legendes haut & bas
title_ac = 'MEAN SEASONAL CYCLE' ; (applied :'+STRCOMPRESS(STRING(filter,FORMAT='(I2)'),/REMOVE_ALL)+' month running mean filter)'

; gestion du format de sortie
col           =  cgcolor('white',255) ;initialisation des couleurs de fond&premier plan 
bck_col       =  cgcolor('black',254)
output_format, col, bck_col, ps=ps, png=png, output=output, small=small

; calcul des moy. mens. et journ. et des valeurs de rms
monthly_stat, st, stj, stm, stn, ym, nmth,  moy_m, rms_m, trend_m, val_min_m, val_max_m, delta_m,$
              nval=nval, nday=nday, _EXTRA=_EXTRA
; stj           => moy. journ. calculees pour au - *nval* val/jour
; stm           => moy. mens.  calculees pour au - *nday* jours/mois
; stn           => nbre de jour utilise pour le calcul de la moy. mens.
; yy            => tableau des annees de chacune des moyennes mensuelles
; N_val(13)     => de [0:11] nbre de moy. mens. utilise pour chaque mois         & [12] = TOTAL de tous les mois utiles de la serie
; moy(13)       => de [0:11] moy. des moy. mens. pour chacun des mois            & [12] = MOYENNE de l'ensemble des mois disponibles
; rms(13)       => de [0:11] ect des moy. mens. pour chacun des mois             & [12] = ECART-TYPE de l'ensemble des mois disponibles
; trend(13)     => de [0:11] tendance des moy mens. pour chacun des mois         & [12] = TENDANCE sur l'ensemble des mois disponibles
; val_min(13)   => de [0:11] valeur mens. min pour chacun des mois               & [12] = MIN mensuelle de toute la serie
; val_max(13)   => de [0:11] valeur mens. max pour chacun des mois               & [12] = MAX mensuelle de toute la serie
; delta(13)     => de [0:11] ecart max entre valeurs mens. pour chacun des mois  & [12] = ECART-MAX mensuelle de toute la serie

; on range dans une struct {jul,val,rms} les sorties de monthly_stat
; donnees moyen. sur tout les mois de [jan,..,dec]
st_ac       = create_rms_julval(12)  
st_ac.jul   = stm[0:11].jul-13.D ;on est caler le 2 du mois
st_ac.val   = moy_m[0:11]
st_ac.rms   = rms_m[0:11]
id_max      = WHERE(moy_m[0:11] EQ MAX(moy_m[0:11],/NAN)) ;indice du moins le + haut
id_min      = WHERE(moy_m[0:11] EQ MIN(moy_m[0:11],/NAN)) ;indice du moins le + bas
amp_ac      = moy_m[id_max]-moy_m[id_min]
yrange      = [MIN(moy_m)-MAX(rms_m),MAX(moy_m)+MAX(rms_m)]
tab_mth     = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
str_line    = '     -----------------------------------------------------------------------'
str_mima    = 'SEASONAL CYCLE PEAK TO PEAK ='+STRING(amp_ac,FORMAT='(F6.1)')+$
              ' / MIN='+STRING(moy_m[id_min],FORMAT='(F6.1)')+' in '+STRING(tab_mth[id_min])+$
              ' / MAX='+STRING(moy_m[id_max],FORMAT='(F6.1)')+' in '+STRING(tab_mth[id_max])
str_mth     = '    '+STRING(tab_mth,FORMAT='(12(A6))')
str_mean    = 'Mean'+STRING(moy_m[0:11],FORMAT='(12(F6.1))')+'='+STRING(moy_m[12],FORMAT='(F6.1)')
str_rms     = 'RMS '+STRING(rms_m[0:11],FORMAT='(12(F6.1))')+'='+STRING(rms_m[12],FORMAT='(F6.1)')

; plot du cycle annuel moyen
; --------------------------
choose_time_axis, ta='only_month'
!P.BACKGROUND = bck_col
!P.COLOR      = col
!P.MULTI      = [0,1,2]
PLOT, st_ac.jul, st_ac.val , /DATA, title=title_ac , COLOR=col, $
      YRANGE=yrange, XSTYLE=2, thick=2,$ 
      POSITION      =  pos_ac
oploterror, st_ac.jul, st_ac.val , INTARR(N_ELEMENTS(st_ac.rms)), st_ac.rms, PSYM=6, ERRTHICK=2
XYOUTS,xtab1,ytab1,  str_mima,  CHARSIZE=cz_txt,/NORMAL,COLOR=col

st_filtre=stj ;serie totale pour toute les annees
; plot des courbes annuelles
; --------------------------
year    = remove_doublon_tab(ym)       ;tab des annees utiles
Ny      = N_ELEMENTS(year)             ;Nbre d'annee disponible
dmi0    = JULDAY(1,1,year[0],0,0,0)    ;on se cale le premier jour de l'annee
dma0    = dmi0+bissextile(year[0])-0.4 ;jusqu'au dernier de l'annee
st_ini  = julcut(st_filtre,DMIN=dmi0,DMAX=dma0)
yrange  = [MIN(st_filtre.val,/NAN),MAX(st_filtre.val,/NAN)]
IF NOT KEYWORD_SET(psy) THEN psy = 0
title_st = 'ANNUAL TIME SERIES (for the '+STRCOMPRESS(STRING(Ny,FORMAT='(I2)'),/REMOVE_ALL)+' available years)'

IF (Ny GE 20) THEN psy=3
PLOT, st_ac.jul, st_ac.val , /DATA, title=title_st , COLOR=col, $
      XRANGE=[dmi0,dma0], YRANGE=yrange, XSTYLE=2, thick=2,$
      POSITION=pos_st, _EXTRA=_EXTRA 

FOR i=0,Ny-1 DO BEGIN
 dmi     = JULDAY(1,1,year[i],0,0,0) ;on se cale au premier jour de l'annee
 dma     = dmi+bissextile(year[i])   ;jusqu'au dernier de l'annee
 st_plot = julcut(st_filtre,DMIN=dmin,DMAX=dma) ;on decoupe la serie en tranche de 1 an
 st_plot.jul = st_plot.jul-(dmi-dmi0)           ;on se recale le premier jour de l'annee zero  
 OPLOT, st_plot.jul, st_plot.val, psym=psy,COLOR=(255-ROUND(255./Ny)*i-2),thick=2,_EXTRA=_EXTRA ;on trace chaque serie 
 XYOUTS,xinfo,yinfo-float(i)*0.02,STRCOMPRESS(STRING(year[i]),/REMOVE_ALL),CHARSIZE=1,/NORMAL,COLOR=(255-ROUND(255./Ny)*i-2)
ENDFOR
oploterror, st_ac.jul, st_ac.val , INTARR(N_ELEMENTS(st_ac.rms)), st_ac.rms, PSYM=6, ERRTHICK=2
oplot     , st_ac.jul, st_ac.val , THICK=2


; on ecrite le tab. synthetique de resultats 
XYOUTS,xtab2,ytab2,       str_mth,  CHARSIZE=cz_txt,/NORMAL,COLOR=col
XYOUTS,xtab2,ytab2-0.03,       str_line,  CHARSIZE=cz_txt,/NORMAL,COLOR=col
XYOUTS,xtab2,ytab2-2*0.03,  str_mean, CHARSIZE=cz_txt,/NORMAL,COLOR=col
XYOUTS,xtab2,ytab2-3*0.03,str_rms,  CHARSIZE=cz_txt,/NORMAL,COLOR=col


IF KEYWORD_SET(data_info) THEN BEGIN
ENDIF


IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG,/NO_EXT)
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
ENDIF
print,'plot_annual_cycle  :',output

;LOADCT,0
   ; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map
END