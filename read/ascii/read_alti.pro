; $Id: read_alti.pro,v 1.00 24/03/2006 L. Testut $
;

;+
; NAME:
;	READ_ALTI
;
; PURPOSE:
;	Read the altimetric file from Claire processing chain
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_ALTI(filename,para=parameter)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_JULVAL
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst' 
;       template_name : string of the template name ex:'alti'
;       para=         : keyword string of the parameter to extract ex: para='mrg'
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
FUNCTION  read_alti, filename, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_LST(filename,template_name,para=parameter)'
IF (KEYWORD_SET(para)EQ 0) THEN STOP, '! Need the tag parameter to read'

; Define the template to be used
templ = USE_TEMPLATE('alti')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames) 

print,'USE_TEMPLATE : ','alti'
print,'READ_ASCII   : ',filename
print,'Extract para : ',templ.fieldNames[IP]

; Create the julval structure with N-1 data (because last data of .lst
; is the number of rows extracted). Last data read should be: 31 Dec 19XX 21:00 
iend = 0
N    = (N_ELEMENTS(data.jul)-iend) 
st   = create_julval(N)
date = DBLARR(N)

st.jul = data.jul+JULDAY(1,1,1950,0,0,0)
st.val = data.(IP)[0:N-1]

RETURN, st
END
 
