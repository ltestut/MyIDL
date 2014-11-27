; $Id: lag_julval.pro,v 1.00 15/05/2005 L. Testut $
;

;+
; NAME:
;	LAG_JULVAL
;
; PURPOSE:
;	Lag the julian day part of the julval structure
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=LAG_JULVAL(st,hour=hour,day=day)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;	st      : Structure de be laged
;       hour=   : Number of hours of the lag
;       day=    : Number of days of the lag
;       mn=     : Number of minutes of the lag
;
; OUTPUTS:
;	Structure of type {jul,val}
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
; -Le 05/12/2006 Add minute and second
; -Le 15/05/2007 Add the minute keyword (mn)
; -Le 18/11/2008 Add the minute keyword (sec)

;
;-
;

FUNCTION lag_julval, st, hour=hour, day=day, mn=mn, sec=sec

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=LAG_JULVAL(st,hour=hour,day=day,mn=mn,sec=sec)'
IF (N_ELEMENTS(day) EQ 0 AND N_ELEMENTS(hour) EQ 0 and N_ELEMENTS(mn) EQ 0 and N_ELEMENTS(sec) EQ 0 ) THEN STOP, '! Need lag information'
IF (N_ELEMENTS(day) EQ 0) THEN day=0.
IF (N_ELEMENTS(hour) EQ 0) THEN hour=0.
IF (N_ELEMENTS(mn) EQ 0) THEN mn=0.
IF (N_ELEMENTS(sec) EQ 0) THEN sec=0.

st1    = CREATE_JULVAL(N_ELEMENTS(st.jul))
st1.val= st.val

CALDAT, st.jul, mh, dy, yr, hr, mnt, sc

dyy    = dy[*] + day
hrr    = hr[*] + hour
mnr    = mnt[*] + mn
scr    = sc[*] + sec

st1.jul=JULDAY(mh,dyy,yr,hrr,mnr,scr) ;modifie la base de temps

RETURN, st1
END
