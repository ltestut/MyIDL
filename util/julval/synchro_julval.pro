; $Id: synchro_julval.pro,v 1.00 04/04/2006 L. Testut $
;

;+
; NAME:
;	SYNCHRO_JULVAL
;
; PURPOSE:
;	Synchronize 2 {jul,val} time series
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	SYNCHRO_JULVAL, st1, st2, sts1, sts2, bs=bs
;
;       use the fct/proc : -> TIMEGEN
;                          -> CREATE_JULVAL
;                          -> FINITE_ST
;                          -> HISTOGRAM
;                          -> WHERE
; INPUTS:
;	st1     : Structure of type {jul,val}
;	st2     : Structure of type {jul,val}
; bs      : set this keywprd to the size of the bin you need in seconds
;
; OUTPUTS:
;	sts1    : Structure of type {jul,val} with common time base
;	sts2    : Structure of type {jul,val} with common time base
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
; - Le 08/10/2007 Add the 2 positional parameters id1 and id2 to pass the index
; - Le 13/11/2007 Add the finite_st of the structure
; - Le 06/05/2008 Add the bs keyword to synchronize gps data at 1s
; - Le 06/06/2008 Add the nostrcit keyword to authorize to have more than 1 value in histogram
; - Le 05/04/2009 Add the verbose keyword
; - Le 06/05/2009 Add the possibility to pass {jul,val,rms} structure
; - Le 06/07/2009 Add the with_nan keyword for the fill_nan_julval
;-
;

PRO synchro_julval, st1, st2, stsync1, stsync2, id1, id2, bs=bs, nostrict=nostrict, verbose=verbose, with_nan=with_nan

IF (N_PARAMS() EQ 0) THEN STOP, "SYNCHRO_JULVAL, st1, st2, sts1, sts2, id1, id2, bs=60."
IF KEYWORD_SET(with_nan) THEN BEGIN
   st1 = TEMPORARY(st1)
   st2 = TEMPORARY(st2)
ENDIF ELSE BEGIN
   st1 = finite_st(TEMPORARY(st1))
   st2 = finite_st(TEMPORARY(st2))
ENDELSE

; determination de la periode commune
; ----------------------------------
minab      = MIN(st1.jul,/NAN) > (MIN(st2.jul,/NAN))
maxab      = MAX(st1.jul,/NAN) < (MAX(st2.jul,/NAN))

;/!\ changement le 30/11/2011 par le + grand des min et le plus petit des max !!

; !!!! EST-CE UTILE DE CE METTRE A LA MIN OU SEC RONDE ?????
;CALDAT, minab, m_min,d_min,y_min,h_min,mn_min,s_min 
;CALDAT, maxab, m_max,d_max,y_max,h_max,mn_max,s_max
;jmin_b     = JULDAY(m_min,d_min,y_min,h_min,mn_min,0)     ; on se place aux minutes rondes pour le base de temps  hh:mn:00
;jmax_b     = JULDAY(m_max,d_max,y_max,h_max,mn_max,0)     ; on se place aux minutes rondes pour le base de temps  hh:mn:00

IF NOT KEYWORD_SET(bs) THEN bs=60.D     ;par defaut on fait des classes de 60s/1min
                                        ;cad que l'on considere comme synchrone toutes les donnees d'une meme classe
binsize    = DOUBLE(bs)/(24*3600.)      ; = bs secondes
bindelta   = binsize/2.                 ; on centre la classe pour etre legerement decalee 
; On construit une base de temps a *bs* secondes 
; On decoupe chaque serie en tranche de *bs* secondes et on verifie la presence d'une valeur de temps
; base_temps = TIMEGEN(start=minab,final=maxab,unit='Seconds', step_size=60)
nbr_bin=((maxab-minab)+1)/binsize
histo_st1  = histogram(st1.jul,min=minab-bindelta,max=maxab-bindelta,binsize=binsize,REV=rev1,/NAN)
histo_st2  = histogram(st2.jul,min=minab-bindelta,max=maxab-bindelta,binsize=binsize,REV=rev2,/NAN)
index      = WHERE((histo_st1 EQ 1) and (histo_st2 EQ 1),count,/L64)
IF KEYWORD_SET(nostrict) THEN index = WHERE((histo_st1 GE 1) and (histo_st2 GE 1),count,/L64)
IF (count GT 0) THEN BEGIN
   t1         = rev1[rev1[index]]
   t2         = rev2[rev2[index]]
   nt1        = N_TAGS(st1)
   nt2        = N_TAGS(st2)
   IF (nt1 EQ 3) THEN BEGIN
      stsync1    = create_rms_julval(count)
   ENDIF ELSE BEGIN
      stsync1    = create_julval(count)
   ENDELSE
   IF (nt2 EQ 3) THEN BEGIN
      stsync2    = create_rms_julval(count)
   ENDIF ELSE BEGIN
      stsync2    = create_julval(count)
   ENDELSE
   stsync1.jul = st1[t1].jul 
   stsync1.val = st1[t1].val
   IF (nt1 EQ 3) THEN stsync1.rms = st1[t1].rms
   stsync2.jul = st2[t2].jul
   stsync2.val = st2[t2].val
   IF (nt2 EQ 3) THEN stsync2.rms = st2[t1].rms
   id1=t1
   id2=t2
   IF KEYWORD_SET(verbose) THEN BEGIN
      ech1=sampling_julval(st1)     ;
      ech2=sampling_julval(st2)     ;
      ech3=sampling_julval(stsync1) ;
      tech1=STRING(ech1,FORMAT='(F6.0)')+'/'+STRING(ech1/60.,FORMAT='(F5.1)')+'/'+STRING(ech1/3600.,FORMAT='(F4.2)')+" [sec/mn/hr]"
      tech2=STRING(ech2,FORMAT='(F6.0)')+'/'+STRING(ech2/60.,FORMAT='(F5.1)')+'/'+STRING(ech2/3600.,FORMAT='(F4.2)')+" [sec/mn/hr]"
      tech3=STRING(ech3,FORMAT='(F6.0)')+'/'+STRING(ech3/60.,FORMAT='(F5.1)')+'/'+STRING(ech3/3600.,FORMAT='(F4.2)')+" [sec/mn/hr]"
      print,"SYNCHRO_JULVAL    : sampling of serie 1   = ",tech1
      print,"SYNCHRO_JULVAL    : sampling of serie 2   = ",tech2
      print,"SYNCHRO_JULVAL    : sampling of serie s   = ",tech3
      print,"SYNCHRO_JULVAL    : histogram class size  = ",STRING(bs,FORMAT='(F6.1)')," sec."
      print,"SYNCHRO_JULVAL    : histo number of class = ",nbr_bin       
      print,"SYNCHRO_JULVAL    : class 1               = ",print_date((minab-bindelta),/SINGLE)," au ",print_date((minab-bindelta)+binsize,/SINGLE)
      print,"SYNCHRO_JULVAL    : common preriod from   = ",print_date(MIN(st1[t1].jul),/SINGLE)," to ", print_date(MAX(st1[t1].jul),/SINGLE)
      print,"SYNCHRO_JULVAL    : nbr of common value   = ",N_ELEMENTS(stsync1)
   ENDIF
ENDIF ELSE BEGIN
   id1=0
   id2=0
   print,'NO SYNCHRONOUS DATA',id1,id2
   IF KEYWORD_SET(verbose) THEN BEGIN
      ech1=sampling_julval(st1)     ;
      ech2=sampling_julval(st2)     ;
      tech1=STRING(ech1,FORMAT='(F6.0)')+'/'+STRING(ech1/60.,FORMAT='(F5.1)')+'/'+STRING(ech1/3600.,FORMAT='(F4.2)')+" [sec/mn/hr]"
      tech2=STRING(ech2,FORMAT='(F6.0)')+'/'+STRING(ech2/60.,FORMAT='(F5.1)')+'/'+STRING(ech2/3600.,FORMAT='(F4.2)')+" [sec/mn/hr]"
      print,"SYNCHRO_JULVAL    : echantillonnage de la serie 1 = ",tech1
      print,"SYNCHRO_JULVAL    : echantillonnage de la serie 2 = ",tech2
      print,"SYNCHRO_JULVAL    : taille des classes de l'histogramme = ",STRING(bs,FORMAT='(F6.1)')," Secondes"
      print,"SYNCHRO_JULVAL    : classe 1 = ",print_date((minab-bindelta),/SINGLE)," au ",print_date((minab-bindelta)+binsize,/SINGLE)
   ENDIF
ENDELSE
END
