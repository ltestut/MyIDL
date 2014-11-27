; $Id: read_obs.pro,v 1.00 14/06/2007 L. Testut $
;

;+
; NAME:
;	READ_OBS
;
; PURPOSE:
;	Read the .obs.1 output of the filtering routine 
;       see. the USE_TEMPLATE function to define the appropriate template
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_OBS(filename,para='parameter')
;
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst'
;       para=        : keyword string of the parameter to extract ex: para='f1'
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
FUNCTION read_obs, filename, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_OBS(filename,para='parameter-name')"
IF (KEYWORD_SET(para) EQ 0) THEN para='f1'

; Define the template to be used
templ = USE_TEMPLATE('obs') ;ou phy1

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames)

print,'USE_TEMPLATE : obs'
print,'READ_ASCII   : ',filename
print,'Extract para : ',templ.fieldNames[IP]

; Create the julval structure with N-1 data (because last data of .lst
; is the number of rows extracted). Last data read should be: 31 Dec 19XX 21:00
N    = N_ELEMENTS(data.jul)
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date
;READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
;print,date[N-1],FORMAT='(C())'
st.jul = data.jul+JULDAY(1,1,1950,0,0,0)
st.val = data.(IP)[0:N-1]
RETURN, st
END

