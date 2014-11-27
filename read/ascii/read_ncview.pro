; $Id: read_ncview.pro,v 1.00 02/05/2007 L. Testut $
;

;+
; NAME:
;	READ_NCVIEW
;
; PURPOSE:
;	Read data file of type ncview.dump {hours,values}
;       see. the USE_TEMPLATE function to define the appropriate template
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_NCVIEW(filename)
;
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
; INPUTS:
;	filename      : string of the filename ex:'/home/testut/ncview.dump'
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
; - Le 18/05/2007 Add the dt keyword
; - LE 15/06/2007 Add the origin keyword
;
;-
;

FUNCTION read_ncview, filename, dt=dt, origin=origin

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_NCVIEW(filename,dt=1. *in hour*,origin= *JULDAY(1,1,2004,0,0,0)*)'

IF (N_ELEMENTS(dt) EQ 0) THEN dt=1.
IF (N_ELEMENTS(origin) EQ 0) THEN origin=JULDAY(1,1,1950,0,0,0)

; Define the template to be used
templ = USE_TEMPLATE('ncview')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE : ncview'
print,'READ_ASCII   : ',filename

N      = N_ELEMENTS(data.jul)
st     = CREATE_JULVAL(N)
st.jul = (data.jul*dt)/24.+origin
st.val = data.val*100.
RETURN, st
END
