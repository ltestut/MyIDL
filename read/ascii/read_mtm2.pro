; $Id: read_mtm2.pro,v 1.00 12/05/2005 L. Testut $
;

;+
; NAME:
;	READ_MTM2
;
; PURPOSE:
;	Read file near Mitchum type .dat 
;       Usually it reads the file for bottom pressure (with NaN=99999) and pressure in mbar/10.
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_SHM(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.dat' 
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
FUNCTION  read_mtm2, filename, flag=flag

IF (KEYWORD_SET(flag) EQ 0) THEN flag=99999

; Attention il faut prealablement enlever les interligne entre chque
; année
; PB tout les 24 h prog a verifier !!! à 11hh

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_MTM(filename)'

; Define the template to be used
templ = USE_TEMPLATE('mtm2')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE : mtm2'
print,'READ_ASCII   : ',filename

; Create the julval structure for output 
N    = N_ELEMENTS(data.y) 
st   = create_julval(N*12)
data.apm[WHERE(data.apm EQ 1)]=0
data.apm[WHERE(data.apm EQ 2)]=12

FOR I=0,11 DO BEGIN
    st[I*N:(I+1)*(N-1)+I].jul=DOUBLE(JULDAY(data.m,data.d,data.y,I+data.apm,0,0))
    st[I*N:(I+1)*(N-1)+I].val=data.(I+6)
ENDFOR

itrou=WHERE(st.val EQ flag,count)
IF (count GE 1) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
ifinite=WHERE(FINITE(st.val))
st[ifinite].val=st[ifinite].val/10.
print,'Number of NaN',count

st=tri_julval(st)

RETURN, st
END
 
