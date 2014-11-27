PRO synchro_julval_by_year, st1, st2, stsync1, stsync2, _EXTRA=_EXTRA
; programme qui va synchroniser 2 serie en les decoupant par annee pour des pb de memoire

 ;determination de la periode commune
minab      = MIN(st1.jul,/NAN) > (MIN(st2.jul,/NAN))
maxab      = MAX(st1.jul,/NAN) < (MAX(st2.jul,/NAN))
print,'SYNCHRO_JULVAL_BY_YEAR :   MIN = ',print_date(minab,/SINGLE)
print,'SYNCHRO_JULVAL_BY_YEAR :   MIN = ',print_date(maxab,/SINGLE)

CALDAT, minab, m_min,d_min,y_min,h_min,mn_min,s_min 
CALDAT, maxab, m_max,d_max,y_max,h_max,mn_max,s_max

 ;initialisation des structures synchronisee
stsync1=create_julval(1,/NAN)
stsync2=create_julval(1,/NAN)

FOR i=y_min,y_max,1 DO BEGIN
synchro_julval,julcut(st1,dmin=JULDAY(1,1,i,0,0,0),dmax=JULDAY(1,1,i+1,0,0,0),/VERB),$
               julcut(st2,dmin=JULDAY(1,1,i,0,0,0),dmax=JULDAY(1,1,i+1,0,0,0),/VERB),$
               sts1,sts2,_EXTRA=_EXTRA
               
stsync1=concat_julval(stsync1,sts1)
stsync2=concat_julval(stsync2,sts2)
               

ENDFOR



END