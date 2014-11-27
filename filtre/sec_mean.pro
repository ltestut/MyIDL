; $Id: sec_mean.pro,v 1.00 18/11/2008 L. Testut $
;

;+
; NAME:
;	SEC_MEAN
;
; PURPOSE:
;	Compute the arithmetic nseconds mean of {jul,val} time serie
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=mn_sec(st,nval=nval,nsec=nsec,/verb)
;
;       use the fct/proc : -> TIMEGEN
;                          -> CREATE_RMS_JULVAL
;                          -> FINITE_ST
;                          -> HISTOGRAM
;                          -> WHERE
; INPUTS:
;	st     : Structure of type {jul,val}
; nval   : number of value needed to compute the mean
;
; OUTPUTS:
;	std   : Structure of type {jul,val,rms} daily value centered at noon
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:

;-
;

FUNCTION sec_mean, st_in, nval=nval, method=method, verbose=verbose, nsec=nsec
IF (N_PARAMS() EQ 0) THEN STOP, "st=mn_mean(st,nval=nval,method='minmax',/verb)"
IF NOT KEYWORD_SET(method) THEN method='arithmetic'
IF NOT KEYWORD_SET(nsec) THEN nsec=40.
IF NOT KEYWORD_SET(nval) THEN BEGIN
   nval=2
   IF (sampling_julval(st_in) EQ 1) THEN nval=10
ENDIF

st         = finite_st(st_in)
jminr      = MIN(st.jul,/NAN)
jmaxr      = MAX(st.jul,/NAN)
CALDAT, jminr, m_min,d_min,y_min,h_min,mn_min,s_min 
CALDAT, jmaxr, m_max,d_max,y_max,h_max,mn_max,s_max
jmin      = JULDAY(m_min,d_min,y_min,h_min,mn_min,s_min-0.5)
jmax      = JULDAY(m_max,d_max,y_max,h_max,mn_max,s_max+0.5)

binsize    = FLOAT(nsec)/(24.*3600.)  ; nsec mean
;/!\ POSSIBILITE D AMELIORER EN DECALANT LA BASE DE TEMPS DE BINSIZE/2 pour centrer les valeurs.
; On decoupe chaque serie en classe de nsec et on verifie la presence de valeurs
; ------------------------------------------------------------------------------
print,print_date(jmin)
print,print_date(jmax)
base_temps = TIMEGEN(start=jmin,final=jmax,unit='Seconds', step_size=nsec)           ;on creer une base de temps a la seconde
histo_st   = HISTOGRAM(st.jul,min=jmin,max=jmax,binsize=binsize,REV=rev,/L64)
index      = WHERE(histo_st GE nval,count,/L64)                                ;au moins nval valeurs par classe d'histogramme pour faire la moyenne
print,nval,count
                                                                               ;count c'est le nombre de tranche ou l'on a au moins nval
IF (count GT 0) THEN BEGIN
   t1         = rev[rev[index]]             ;
   st_out     = create_rms_julval(count)    ; 
   st_out.jul = base_temps[index]           ;  
   
;  calcul de la moyenne arithmetic
   IF (method EQ 'arithmetic') THEN BEGIN
      FOR j=0L,count-1 DO BEGIN                 ;pour chaque classe de l'histo on calcul la moyenne
      nd            = N_ELEMENTS((st[t1[j]:t1[j]+histo_st[index[j]]-1].val))
      st_out[j].val = MEAN(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)
      st_out[j].rms = STDDEV(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)
      IF KEYWORD_SET(verbose) THEN print,print_date(st_out[j].jul,/single),$
      ' mean = ',STRCOMPRESS(STRING(st_out[j].val,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' rms  = ',STRCOMPRESS(STRING(st_out[j].rms,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' [',STRCOMPRESS(STRING(nd),/REMOVE_ALL),'/',STRCOMPRESS(STRING(nval),/REMOVE_ALL),']'
      ENDFOR
   ENDIF
   
;  calcul de la moyenne du min et du max
   IF (method EQ 'minmax') THEN BEGIN
      FOR j=0L,count-1 DO BEGIN                 ;pour chaque classe de l'histo on calcul la moyenne
      nd            = N_ELEMENTS((st[t1[j]:t1[j]+histo_st[index[j]]-1].val))
      st_out[j].val = (MAX(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)+MIN(st[t1[j]:t1[j]+histo_st[index[j]]-1].val))/2
      st_out[j].rms = MAX(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)-MIN(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)
      IF KEYWORD_SET(verbose) THEN print,print_date(st_out[j].jul,/single),$
      ' mean = ',STRCOMPRESS(STRING(st_out[j].val,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' amp  = ',STRCOMPRESS(STRING(st_out[j].rms,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' [',STRCOMPRESS(STRING(nd),/REMOVE_ALL),'/',STRCOMPRESS(STRING(nval),/REMOVE_ALL),']'
      ENDFOR
   ENDIF

;  calcul de la mediane
   IF (method EQ 'median') THEN BEGIN
      FOR j=0L,count-1 DO BEGIN                 ;pour chaque classe de l'histo on calcul la mediane
      nd            = N_ELEMENTS((st[t1[j]:t1[j]+histo_st[index[j]]-1].val))
      st_out[j].val = MEDIAN(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)
      st_out[j].rms = STDDEV(st[t1[j]:t1[j]+histo_st[index[j]]-1].val)
      IF KEYWORD_SET(verbose) THEN print,print_date(st_out[j].jul,/single),$
      ' mean = ',STRCOMPRESS(STRING(st_out[j].val,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' amp  = ',STRCOMPRESS(STRING(st_out[j].rms,FORMAT='(F9.3)'),/REMOVE_ALL),$
      ' [',STRCOMPRESS(STRING(nd),/REMOVE_ALL),'/',STRCOMPRESS(STRING(nval),/REMOVE_ALL),']'
      ENDFOR
   ENDIF

   
   RETURN, st_out
ENDIF ELSE BEGIN
   print,'NO DATA'
ENDELSE
END
