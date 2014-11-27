; $Id: read_julval.pro,v 1.00 13/05/2005 L. Testut $
;

;+
; NAME:
;	READ_JULVAL
;
; PURPOSE:
;	Read data file of type .julval {Julian days,values}
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_JULVAL(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
; INPUTS:
;	filename      : string of the filename ex:'/home/testut/test.julval' 
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
;
;-
;

FUNCTION read_julval, filename

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_JULVAL(filename)'

; Define the template to be used
templ = USE_TEMPLATE('julval')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE : julval'
print,'READ_ASCII   : ',filename

N      = N_ELEMENTS(data.jul)
st     = CREATE_JULVAL(N)
st.jul = data.jul+JULDAY(1,1,1950,0,0,0)
st.val = data.val
RETURN, st
END
