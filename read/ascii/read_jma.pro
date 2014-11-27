; $Id: read_jma.pro,v 1.00 26/08/2008 L. Testut $
;

;+
; NAME:
;	READ_JMA
;
; PURPOSE:
;	Read the data file of type 01/01/2002 20:52:00 1001.3
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_JMA(filename)
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
; - 29/07/2013 Add the format_date keyword
; - 29/01/2014 Add the skip= keyword
;-
;
FUNCTION  read_jma, filename, flag=flag, rms=rms, format_date=format_date, skip=skip
; read a day/month/year value formatted data file 
IF NOT KEYWORD_SET(flag)        THEN flag=9999.900
IF NOT KEYWORD_SET(format_date) THEN format_date='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'

; Define the template to be used
IF KEYWORD_SET(rms) THEN templ = use_template('jmarms') $
   ELSE templ = USE_TEMPLATE('jma')

; Read the data corresponding to the defined template
IF KEYWORD_SET(skip) THEN data  = READ_ASCII(filename,TEMPLATE=templ,DATA_START=skip) $
  ELSE data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE :  jma'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
IF KEYWORD_SET(rms) THEN st=create_julval(N,/RMS)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;IF KEYWORD_SET(hms) THEN READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
READS,data.jul[0:N-1],date,FORMAT=format_date
;print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(1)[0:N-1]
IF KEYWORD_SET(rms) THEN st.rms = data.(2)[0:N-1] 

itrou = where(st.val eq flag, nb_trou)
IF (nb_trou ne 0) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
RETURN, finite_st(st)
END
 
