; $Id: decimate_julval.pro,v 1.00 11/11/2008 L. Testut $
;

;+
; NAME:
;	DECIMATE_JULVAL
;
; PURPOSE:
;	Decimate a hf {jul,val} time serie 
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=decimate_julval(st,sampling=sampling,bs=bs,/verb)
;
;       use the fct/proc : -> TIMEGEN
;                          -> FINITE_ST
;                          -> SYNCHRO_JULVAL
;                          -> WHERE
; INPUTS:
;	st     : Structure of type {jul,val}
;
; OUTPUTS:
;	std   : Structure of type {jul,val} at the new sampling
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
; Le 11/11/2008 can add a start -jmin- date 
; Le 21/01/2010 add the daily keyword to center at noon
; Le 14/09/2010 on utilise comme base de temps la base de temps reguliere 
; Le 21/04/2013 on ajoute le appropriate julval pour les structures de type jul,val,rms
;-
;

FUNCTION decimate_julval, st_in, sampling=sampling, daily=daily, verbose=verbose, jmin=jmin, bs=bs, _EXTRA=_EXTRA
IF (N_PARAMS() EQ 0) THEN STOP, "st=decimate_julval(st,sampling=10 *in minutes*, bs=60. *in seconds*, /verb)"
st         = finite_st(st_in)
nt         = N_TAGS(st)     ; number of tag
tn         = TAG_NAMES(st)  ; name of tags
IF (nt GT 2) THEN BEGIN
  IF (tn[2] EQ 'RMS') THEN rms=1 ELSE rms=0
ENDIF ELSE BEGIN
  rms=0
ENDELSE

IF NOT KEYWORD_SET(jmin) THEN jmin = FLOOR(MIN(st.jul))-0.5
jmax       = CEIL(MAX(st.jul))+0.5
ispl       = sampling_julval(st)       ;initial sampling of the julval in seconds.
IF NOT KEYWORD_SET(sampling) THEN sampling =60.
IF NOT KEYWORD_SET(bs) THEN BEGIN
  bs         = 60.                       ;size of the windows to synchronize data
  IF (ispl LT 61.) THEN bs=90.
  IF (ispl LT 5.)  THEN bs=3.
  IF (ispl LT 1.)  THEN bs=1.
ENDIF

IF KEYWORD_SET(verbose) THEN BEGIN
   print,'Debut de la serie a decimer      = ',print_date(MIN(st.jul,/NAN),/SINGLE)
   print,'Fin  de la serie a decimer       = ',print_date(MAX(st.jul,/NAN),/SINGLE)
   print,'Debut base de temps choisie      = ',print_date(jmin,/SINGLE)
   print,'Fin   base de temps choisie      = ',print_date(jmax,/SINGLE)
   print,"Initial sampling of the data     : ",ispl," s"
   print,"Final   sampling of the data     : ",sampling*60.,"  s"   
   print,"Taille des classes de comparaison: ",bs,' s' 
ENDIF

; On decoupe chaque serie en tranche de -sampling- minutes et on verifie la presence de valeurs
IF KEYWORD_SET(daily) THEN BEGIN
   sampling    = 1440.
   base_temps  =  decimate_at_noon(st_in) 
   st_base     =  create_julval(N_ELEMENTS(base_temps),RMS=rms)
   st_base.jul = base_temps
   st_base.val = 1.
   synchro_julval, st_in, st_base, sti$b, stb$i, bs=bs, /NOSTRICT 
RETURN, sti$b
ENDIF ELSE BEGIN   
  base_temps  =  TIMEGEN(start=jmin,final=jmax,unit='minutes', step_size=sampling) ;on creer une base de temps 
  st_base     =  create_julval(N_ELEMENTS(base_temps),RMS=rms)
  st_base.jul = base_temps
  st_base.val = 1.
  synchro_julval, st_in, st_base, sti$b, stb$i, bs=bs, /NOSTRICT
  st     = create_julval(N_ELEMENTS(sti$b.jul),RMS=rms)
  st.jul = stb$i.jul
  st.val = sti$b.val
  IF rms THEN st.rms = sti$b.rms
RETURN, st
ENDELSE
END
