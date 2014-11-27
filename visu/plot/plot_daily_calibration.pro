PRO plot_daily_calibration, st1, st2, tmin=tmin, tmax=tmax, file_out=file_out, method=method, flag=flag, _EXTRA=_EXTRA

IF NOT KEYWORD_SET(method) THEN method='arithmetic'
IF NOT KEYWORD_SET(flag)   THEN flag=5.     ;on flag les differences journaliaires avec un rms > flag

; determination de la periode commune
; ----------------------------------
dmin  = MIN(st1.jul,/NAN) > (MIN(st2.jul,/NAN))
dmax  = MAX(st1.jul,/NAN) < (MAX(st2.jul,/NAN))
kmin  = N_ELEMENTS(tmin) & kmax = N_ELEMENTS(tmax) ;test de la presence du mot-cle tmin & tmax
IF (kmin NE 0) THEN BEGIN
   smin=STRLEN(tmin)
   READS,tmin,dmin,FORMAT=get_format(smin)   
ENDIF
IF (kmax NE 0) THEN BEGIN
   smax=STRLEN(tmax)
   READS,tmax,dmax,FORMAT=get_format(smax)
ENDIF
ste   = julcut(st1,DMIN=dmin,DMAX=dmax)
sts   = julcut(st2,DMIN=dmin,DMAX=dmax)

; on calcul les diff entre les ste et sts
; ---------------------------------------
std  = rms_diff_julval(ste,sts)
stdd = daily_mean(std,NVAL=4,method=method)

id = WHERE(stdd.rms LE flag,count)
print,"valeur du flag sur les donnees jounalieres     : ",STRCOMPRESS(STRING(flag),/REMOVE_ALL)
print,"nbr de val. retenu pour les diff. journalieres : ",STRCOMPRESS(STRING(count),/REMOVE_ALL),' / ',STRCOMPRESS(STRING(N_ELEMENTS(stdd.val)),/REMOVE_ALL)
IF (count GE 1) THEN stdd=where_julval(stdd,id)


xs=1200  ;largueur en X en pixel
ys=600  ;hauteur en Y en pixel;
xp=1200
yp=0
;
; plot des differences instantanees
WINDOW,1,XSIZE=xs,YSIZE=ys,XPOS=xp,YPOS=yp,$
         TITLE="[1]- RAW RESIDUALS"    
plot_julval,std,_EXTRA=_EXTRA,$
            title='Raw residuals between S1 and S2',ta='2m',psym=-1,$
            /TREND
;    
; plot des difference journaliere
WINDOW,2,XSIZE=xs,YSIZE=ys,XPOS=xp,YPOS=yp+ys,$
         TITLE="[2]- DAILY RESIDUALS"    
ploterr_julval,stdd,_EXTRA=_EXTRA,$
         title='Daily mean residuals between S1 and S2', psym=6,ta='2m',$
         /TREND

; plot des difference journaliere
WINDOW,3,XSIZE=xs,YSIZE=ys,XPOS=xp,YPOS=yp+2*ys,$
         TITLE="[3]- VDC"    
plot_vdc_julval_simple, ste,sts,xr=[-5,5],title='S1 - S2',/TREND   
                 
IF KEYWORD_SET(file_out) THEN BEGIN
    OPENW,  UNIT, file_out  , /GET_LUN        ;; ouverture du fichier info en ecriture
    PRINTF, UNIT, "Difference de hauteur entre l'etalon et le capeur"
    PRINTF, UNIT, "Solution journaliere"
    PRINTF, UNIT, "Date                H(cm)    RMS(cm) "
    FOR i=0,N_ELEMENTS(stdd.jul)-1 DO BEGIN
       PRINTF, UNIT,FORMAT='(A19,X,F8.3,X,F8.3)',print_date(stdd[i].jul,/SINGLE),stdd[i].val,stdd[i].rms 
    ENDFOR
FREE_LUN, UNIT
print,'Ecriture du fichier ==>',file_out
ENDIF

END