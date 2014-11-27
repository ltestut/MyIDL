; $Id: read_bodc.pro,v 1.00 24/10/2008 L. Testut $
;

;+
; NAME:
; READ_BODC
;
; PURPOSE:
; Read the data file of BODC 1) 01/01/2002 20:52:00 1001.3M 0.5M
;       see. the USE_TEMPLATE function to define the appropraite template
; 
; CATEGORY:
; Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
; st=READ_DATEVAL(filename)
; 
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
; filename      : string of the filename ex:'/local/home/ocean/testut/1915NEW.txt' 
;
; OUTPUTS:
; Structure of type {jul,val}
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;
;-
;
FUNCTION  read_bodc, filename

; Define the template to be used
templ = USE_TEMPLATE('bodc')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE :  bodc'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.num) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;IF KEYWORD_SET(hms) THEN READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
READS,data.date[0:N-1],date,FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(2)[0:N-1]

inan =  WHERE(st.val LT -80.,count)
IF (count GT 0) THEN st[inan].val = !VALUES.F_NAN


RETURN, finite_st(st)
END
 
