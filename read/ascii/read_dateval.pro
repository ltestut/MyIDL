; $Id: read_dateval.pro,v 1.00 26/08/2008 L. Testut $
;

;+
; NAME:
;	READ_DATEVAL
;
; PURPOSE:
;	Read the data file of type 01/01/2002 20:52:00 1001.3
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_DATEVAL(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.dateval' 
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
FUNCTION  read_dateval, filename

; Define the template to be used
templ = USE_TEMPLATE('dateval')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE :  dateval'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;IF KEYWORD_SET(hms) THEN READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(1)[0:N-1]
RETURN, st
END
 
