; $Id: read_pre.pro,v 1.00 26/01/2005 L. Testut $
;

;+
; NAME:
;	READ_PRE
;
; PURPOSE:
;	Read the data file from the prevision tidal software of T. Letellier
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_PRE(filename,template_name)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.pre' 
;       template_name : string of the template name ex:'pre'
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
FUNCTION  read_pre, filename, tpl

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_PRE(filename,template_name)'
IF (N_ELEMENTS(tpl) EQ 0)  THEN STOP, '! Need the template name'


; Define the template to be used
templ = USE_TEMPLATE(tpl)

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


print,'USE_TEMPLATE : ',tpl
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)


; Add the number of TOPEX Julian days
st.jul = data.jul + JULDAY(1,1,1950,0,0,0)
st.val = data.val
RETURN, st
END
 
