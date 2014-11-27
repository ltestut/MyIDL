; $Id: phy2julval.pro,v 1.00 20/05/2005 L. Testut $
;

;+
; NAME:
;	PHY2JULVAL
;
; PURPOSE:
;	Transform the phytot structure to julval structure
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=PHY2JULVAL(st,para=para)
;	
;       use the fct/proc : -> CREATE_JULVAL
;                         
; INPUTS:
;	st : Structure of type {jul,twat,bot,baro,mto}
;
; OUTPUTS:
;	st  : Structure of type {jul,val}
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
;
;-
;

FUNCTION phy2julval, st, para=para

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=phy2julval(st,para=para) '
IF (KEYWORD_SET(para)EQ 0) THEN STOP, '! Need the tag parameter to read'

Names = TAG_NAMES(st)
IP    = WHERE(STRUPCASE(para) EQ Names ,count) 
IF (count EQ 0) THEN STOP, '! Unknown parameter '
N  = N_ELEMENTS(st.jul)
st1= CREATE_JULVAL(N)
;print,'Convert para',Names(IP), 'to JULVAL'
;print,'N=',N
st1.jul = st.jul
st1.val = st[0:N-1].(IP)
RETURN, finite_st(st1)
END
