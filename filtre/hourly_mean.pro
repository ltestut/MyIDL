; $Id: hourly_mean.pro,v 1.00 15/10/2008 L. Testut $
;

;+
; NAME:
;	HOURLY_MEAN
;
; PURPOSE:
;	Compute the arithmetic hourly mean of {jul,val} time serie
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=hourly_mean(st,/verb)
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
; - Le 03/04/2009 On mets la base de temps au milieu de l'intervalle de temps
;-
;

FUNCTION hourly_mean, st_in, nval=nval, method=method, verbose=verbose
IF (N_PARAMS() EQ 0) THEN STOP, "st=hourly_mean(st,nval=nval,method='minmax',/verb)"
IF NOT KEYWORD_SET(method) THEN method='arithmetic'
IF NOT KEYWORD_SET(nval) THEN BEGIN
   nval=2
   IF (sampling_julval(st_in) EQ 60.) THEN nval=50
   IF (sampling_julval(st_in) EQ 120.) THEN nval=25
ENDIF

st         = finite_st(st_in)
jminr      = MIN(st.jul,/NAN)
jmaxr      = MAX(st.jul,/NAN)
CALDAT, jminr, m_min,d_min,y_min,h_min,mn_min,s_min 
CALDAT, jmaxr, m_max,d_max,y_max,h_max,mn_max,s_max
jmin_h     = JULDAY(m_min,d_min,y_min,h_min-1,30,0)  ; on se place a hh-1:30:00 pour l'histogramme
jmax_h     = JULDAY(m_max,d_max,y_max,h_max,30,0)    ; on se place a   hh:30:00 pour l'histogramme
jmin_b     = JULDAY(m_min,d_min,y_min,h_min,0,0)     ; on se place aux heures rondes pour le base de temps  hh:00:00
jmax_b     = JULDAY(m_max,d_max,y_max,h_max,0,0)     ; on se place aux heures rondes pour le base de temps  hh:00:00

binsize    = 1./24.  ; 1 hour mean
; On decoupe chaque serie en classe de 1H et on verifie la presence de valeurs
; ------------------------------------------------------------------------------
print,print_date(jmin_b)
print,print_date(jmax_b)
base_temps = TIMEGEN(start=jmin_b,final=jmax_b,unit='Hours', step_size=1)           ;on creer une base hh-1:30:00<->hh:30:00<->hh+1:30:00
histo_st   = HISTOGRAM(st.jul,min=jmin_h,max=jmax_h,binsize=binsize,REV=rev,/L64)
index      = WHERE(histo_st GE nval,count,/L64)                                ;au moins nval valeurs par classe d'histogramme pour faire la moyenne
                                                                               ;count c'est le nombre de tranche ou l'on a au moins nval
print,N_ELEMENTS(histo_st),N_ELEMENTS(base_temps)
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
      FOR j=0,count-1 DO BEGIN                 ;pour chaque classe de l'histo on calcul la moyenne
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
      FOR j=0,count-1 DO BEGIN                 ;pour chaque classe de l'histo on calcul la mediane
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
