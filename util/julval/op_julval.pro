; $Id: op_julval.pro,v 1.00 27/05/2005 L. Testut $
;

;+
; NAME:
;	OP_JULVAL
;
; PURPOSE:
;	Add, multiply a number to the .val of a structure of type
;	{jul:0.0D, val:0.0} or remove the mean or trend.
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=OP_JULVAL(st,add=add,mul=mul,/moy,/trend)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
;                          -> REMOVE_TREND
; INPUTS:
;       st     : Structure of type {jul:0.0D, val:0.0}
;	add    : The value to add
;	mul    : The value to multiply
;	/moy   : To remove the mean 
;       /trend : To remove the trend (also remove the mean)
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
; - Le 16/01/07 Add remove_trend
; - Le 05/11/07 Change the order of /moy and /trend to apply them before mul and add 
; - Le 12/07/08 add the possibility to pass {jul,val,rms} structure
; - Le 17/02/10 if no keyword set then set /moy by defaut
; - Le 22/11/10 add the tmin tmax keyword 
;-

FUNCTION  op_julval, st, add=add , mul=mul,  moy=moy, trend=trend, tmin=tmin,tmax=tmax, verb=verb

IF (N_PARAMS() EQ 0) THEN STOP, "st=OP_JULVAL(st,add=*-1.2*,mul=*3*,/moy,/trend),tmin='0101200103',tmax=''"

 ;-gestion du nbre de tag
st  = finite_st(st)
st1 = create_appropriate_julval(st)
st1.jul = st.jul
st1.val = st.val

 ;-on choisit le periode sur laquelle on veut appliquer la correction
dmin=MIN(st1.jul,MAX=dmax)
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
i=WHERE((st1.jul GE dmin-0.00001) AND (st1.jul LE dmax+0.00001),count)



IF KEYWORD_SET(trend) THEN st1=remove_trend(st)
IF (N_ELEMENTS(add) NE 0)  THEN st1[i].val = st[i].val+FLOAT(add)
IF (N_ELEMENTS(mul) NE 0)  THEN st1[i].val = st[i].val*FLOAT(mul)
IF KEYWORD_SET(moy) THEN st1[i].val = st1[i].val-MEAN(st1[i].val)

 ;-verbeux
IF KEYWORD_SET(verb) THEN BEGIN
 IF NOT KEYWORD_SET(add) THEN add=0.
 IF NOT KEYWORD_SET(mul) THEN mul=0.
 print,'OPJULVAL  ADD =',STRING(add,FORMAT='(F6.1)'),' : ',print_date(dmin,/single),' -> ',print_date(dmax,/single),'N=',count
 print,'OPJULVAL  MUL =',STRING(mul,FORMAT='(F6.1)'),' : ',print_date(dmin,/single),' -> ',print_date(dmax,/single),'N=',count
ENDIF
RETURN, st1
END
