; $Id: read_list.pro,v 1.00 26/10/2006 L. Testut $
;

;+
; NAME:
;	READ_LIST
;
; PURPOSE:
;	Read the .list data file use for HA 
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_LIST(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.list' 
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
; - Le 06/01/2010 Add the keyword jul_ref to change the date reference 
;-
;
FUNCTION read_list, filename, jul_ref=jul_ref

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_LIST(filename)'
IF NOT KEYWORD_SET(jul_ref) THEN jul_ref=JULDAY(1,1,1950,0,0,0)

; Define the template to be used
templ = USE_TEMPLATE('list') ;ou phy1

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


print,'USE_TEMPLATE :  list'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
st.jul = data.jul+jul_ref
st.val = data.val


RETURN, st

END
 
