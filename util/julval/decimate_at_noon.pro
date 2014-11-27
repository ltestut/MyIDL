; $Id: decimate_at_noon.pro,v 1.00 09/05/2008 L. Testut $
;

;+
; NAME:
;	DECIMATE_AT_NOON
;
; PURPOSE:
;	Decimate the time base of a {jul,val} serie on a daily basis centered at noon
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=decimate_at_noon(st)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	Structure of type {jul,val}
;
; OUTPUTS:
;	array of date centered at noon 
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
; - 22/05/2008 Add the gap keyword for long time basis with gap
; - 17/11/2009 Add the centered keyword to centered at an other hour
;-

FUNCTION decimate_at_noon, st, gap=gap, centered=centered
IF NOT KEYWORD_SET(centered) THEN centered=12

CALDAT, st.jul, month, day, year, hour, minute, second

; build a daily time basis from start to end of st 
N         = N_ELEMENTS(st.jul)
noon_date = TIMEGEN(START=JULDAY(month[0],day[0],year[0],centered,00,00),FINAL=JULDAY(month[N-1],day[N-1],year[N-1],centered,00,00), STEP_SIZE=1, UNITS='days')

IF KEYWORD_SET(gap) THEN BEGIN
   Ntot   = N_ELEMENTS(noon_date)
   st_tot = create_julval(Ntot)
   st_tot.jul = noon_date
   st_tot.val = 1.
   synchro_julval, st, st_tot, st1, st2, id1, id2
RETURN, noon_date[id2]
ENDIF

RETURN, noon_date
;;last modification on 09/05/2008
END
