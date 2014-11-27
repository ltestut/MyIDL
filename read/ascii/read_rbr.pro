; $Id: read_rbr.pro,v 1.00 19/06/2007 L. Testut $
;

;+
; NAME:
;	READ_RBR
;
; PURPOSE:
;	Read the .rbr data file from RBR sensor(usually contains cwat,twat,bot,depth,...)
;       see. the USE_TEMPLATE function to define the appropriate template
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_RBR(filename,para='parameter')
;
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst'
;       para=     : keyword string of the parameter to extract ex: para='bot'
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
FUNCTION read_rbr, filename, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_RBR(filename,para='parameter-name'"
IF (KEYWORD_SET(para) EQ 0) THEN STOP, "! ==> Need the *para* keyword : st=READ_RBR(filename,para='parameter-name') "
; Define the template to be used
templ = USE_TEMPLATE('rbr') ;ou phy1

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames)

print,'USE_TEMPLATE : rbr'
print,'READ_ASCII   : ',filename
print,'Extract para : ',templ.fieldNames[IP]

scl=1.
IF (templ.fieldNames[IP] EQ 'bot') THEN scl=100.

; Create the julval structure with N-1 data (because last data of .lst
; is the number of rows extracted). Last data read should be: 31 Dec 19XX 21:00
N    = N_ELEMENTS(data.jul)
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date
READS,data.jul[0:N-1],date,FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(IP)[0:N-1]*scl
RETURN, st
END
