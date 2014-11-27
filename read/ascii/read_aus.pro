; $Id: read_aus.pro,v 1.00 27/02/2006 L. Testut $
;

;+
; NAME:
;	READ_AUS
;
; PURPOSE:
;	Read the Australian Tide Gauge file .bef
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_AUS(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.bef' 
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
FUNCTION  read_aus, filename

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_AUS(filename)'

; Define the template to be used
templ = USE_TEMPLATE('bef')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE : bef'
print,'READ_ASCII   : ',filename

; Create the julval structure for output 
N    = N_ELEMENTS(data.y) 
st   = create_julval(N*12)
data.apm[WHERE(data.apm EQ 0)]  = 0
data.apm[WHERE(data.apm EQ 1200)] = 12

FOR I=0,11 DO BEGIN
    st[I*N:(I+1)*(N-1)+I].jul=DOUBLE(JULDAY(data.m,data.d,data.y,I+data.apm,0,0))
    st[I*N:(I+1)*(N-1)+I].val=data.(I+5)
;print,FORMAT='("I=",I2,X,C(),X,F10.2)',I,st[I].jul,st[I].val
ENDFOR

itrou=WHERE(st.val EQ 9999,count)
IF (count GE 1) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
print,'Number of NaN',count

st     = tri_julval(st)
st.jul = st.jul 
st.val = st.val/1000. ;return the value in m
RETURN, st
END
 
