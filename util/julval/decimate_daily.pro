; $Id: decimate_daily.pro,v 1.00 06/06/2008 L. Testut $
;

;+
; NAME:
;	DECIMATE_DAILY
;
; PURPOSE:
;	Decimate the time base of a {jul,val} serie on a daily basis
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	std=decimate_daily(st)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	Structure of type {jul,val}
;
; OUTPUTS:
;	date centered at noon 
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
;-  /!\ fait double emmploi avec decimate_at_noon !!!

FUNCTION decimate_daily, st

CALDAT, st.jul, month, day, year, hour, minute, second

; build a daily time basis from start to end of st 
N          = N_ELEMENTS(st.jul)
noon_date  = TIMEGEN(START=JULDAY(month[0],day[0],year[0],12,00,00),FINAL=JULDAY(month[N-1],day[N-1],year[N-1],12,00,00), STEP_SIZE=1, UNITS='days')
Ntot       = N_ELEMENTS(noon_date)
st_tot     = create_julval(Ntot)
st_tot.jul = noon_date
st_tot.val = 1.
synchro_julval, st, st_tot, st1, st2, id1, id2,bs=60.*60.*24.,/nostrict
; make 24hrs binsize and keep the date every time there is a value
RETURN, noon_date[id2]
;;last modification on 09/05/2008
END
