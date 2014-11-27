; $Id: read_oiso.pro,v 1.00 28/10/2005 L. Testut $
;

;+
; NAME:
;	READ_OISO
;
; PURPOSE:
;	Read the data file of type .dat from the OISO cruise
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/function
;
; CALLING SEQUENCE:
;	st=READ_OISO(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst' 
;
; OUTPUTS:
;	Structure of type {info:'', name:'', jul:'',coord:FLTARR(2), depth:0.0, temp:0.0, sal:0.0, theta:0.0, sigma:0.0}
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
FUNCTION  read_oiso, filename, tpl, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_OISO(filename)'

; Define the template to be used
templ = USE_TEMPLATE('oiso')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE : ','oiso'
print,'READ_ASCII   : ',filename

; Create the ctd structure
N    = (N_ELEMENTS(data.date))  
tmp  = {info:'', name:'', jul:'',coord:FLTARR(2), depth:0.0, temp:0.0, sal:0.0, theta:0.0, sigma:0.0}
st   = replicate(tmp,N)
date = DBLARR(N)

; Cut the string of the first field to build the corresponding date 
READS,data.date[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4))'

;print,date[N-1],FORMAT='(C())'
st.info    = data.(0)
st.name    = data.(1)
st.jul     = date
st.coord[0]= data.(3)
st.coord[1]= data.(4)
st.depth   = data.(5)
st.temp    = data.(6)
st.sal     = data.(7)
st.theta   = data.(8)
st.sigma   = data.(9)
RETURN, st
END
 
