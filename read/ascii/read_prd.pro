; $Id: read_prd.pro,v 1.00 05/11/2008 L. Testut $
;

;+
; NAME:
;	READ_PRD
;
; PURPOSE:
;	Read the data file of type 20020131 205200 1001.3 (output from ETERNA earth tide software)
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_PRD(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.prd' 
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
FUNCTION  read_prd, filename, flag=flag

IF (KEYWORD_SET(flag) EQ 0) THEN flag=9999.900

; Define the template to be used
templ = USE_TEMPLATE('prd')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE :  prd'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;IF KEYWORD_SET(hms) THEN READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
;READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
READS,data.jul[0:N-1],date,FORMAT='(C(CYI4,CMOI2,CDI2,X,CHI2,CMI2,CSI2))'

print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(1)[0:N-1]/10.   ;passage en cm

itrou = where(st.val eq flag, nb_trou)
IF (nb_trou ne 0) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
RETURN, finite_st(st)
END
 
