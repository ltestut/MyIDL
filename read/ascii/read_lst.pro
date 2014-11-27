; $Id: read_lst.pro,v 1.00 21/12/2004 L. Testut $
;

;+
; NAME:
;	READ_LST
;
; PURPOSE:
;	Read the METEO data file of type .lst
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_LST(filename,template_name,para=parameter)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_JULVAL
; INPUTS:
;	filename      : string of the filename 
;       para=         : keyword string of the parameter to extract ex: para='pmer'
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
FUNCTION  read_lst, filename, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_LST(filename,para=parameter)'
IF (KEYWORD_SET(para)EQ 0) THEN STOP, '! Need the tag parameter to read'

; Define the template to be used
templ = USE_TEMPLATE('lst')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames) 

print,'USE_TEMPLATE : lst'
print,'READ_ASCII   : ',filename
print,'Extract para : ',templ.fieldNames[IP]

; Create the julval structure with N-1 data (because last data of .lst
; is the number of rows extracted). Last data read should be: 31 Dec 19XX 21:00 
iend = 1
N    = (N_ELEMENTS(data.jul)-iend) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the first field to build the corresponding date 
READS,data.jul[0:N-1],date,FORMAT='(C(CYI4,CMOI2,CDI2,CHI2))'

;print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(IP)[0:N-1]
RETURN, st
END
 
