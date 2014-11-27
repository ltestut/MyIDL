; $Id: read_mtm.pro,v 1.00 04/04/2005 L. Testut $
;

;+
; NAME:
;	READ_MTM
;
; PURPOSE:
;	Read the Hawai Sea Level data file of Mitchum type .dat (with NaN=9999) and slev in mm
;                                                               (with NaN=99999) for bot(mb*10), baro(mb*10), twat(degC*10)
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_SHM(filename, para='bot')
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
; - Le 14/11/2007 Add the para keyword to read with the same routine the bot, twat and baro parameter
; - Le 20/08/2013 Add the name,lon,lat output keyword
;
;
;-
;
FUNCTION  read_mtm, filename, para=para, verbose=verbose, with_nan=with_nan, name=name, lat=lat, lon=lon

; Attention il faut prealablement enlever les interligne entre chque
; ann�e
; PB tout les 24 h prog a verifier !!! � 11hh

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_MTM(filename, para=*bot* by default *slev*)'
IF NOT KEYWORD_SET(para) THEN para='slev'
nan=99999.000
; Define the template to be used
IF (para EQ 'slev') THEN BEGIN
   templ = USE_TEMPLATE('mtm')
   nan=9999.000
ENDIF
IF (para EQ 'bot')  THEN templ = USE_TEMPLATE('mtm2')
IF (para EQ 'baro') THEN templ = USE_TEMPLATE('mtm2')
IF (para EQ 'twat') THEN templ = USE_TEMPLATE('mtm2')


; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

;get information about station: name, lon,lat
name=data.name[0]
line=''
OPENR,UNIT,filename,/GET_LUN
READF,UNIT,line
FREE_LUN, UNIT
sud=STRMID(line,28,1)
IF (sud EQ 'S') THEN hemi=-1 ELSE hemi=1. 
lat=(FLOAT(STRMID(line,21,2))+FLOAT(STRMID(line,24,4))/60.)*hemi
lon=FLOAT(STRMID(line,36,3))+FLOAT(STRMID(line,40,4))/60.




;Remove the yearly line
iok=WHERE(data.m GT 0 AND data.m LE 12,N)

; Create the julval structure for output 
st   = create_julval(N*12)
data.apm[WHERE(data.apm EQ 1)]=0
data.apm[WHERE(data.apm EQ 2)]=12

FOR I=0,11 DO BEGIN
    st[I*N:(I+1)*(N-1)+I].jul=DOUBLE(JULDAY(data.m[iok],data.d[iok],data.y[iok],I+data.apm[iok],0,0))
    st[I*N:(I+1)*(N-1)+I].val=data.(I+6)[iok]
;print,FORMAT='("I=",I2,C(),X,F10.2)',I,st[I*477+406].jul,st[I*477+406].val
ENDFOR

;print,para,nan
itrou=WHERE(st.val EQ nan,count)
IF (count GE 1) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF

IF KEYWORD_SET(verbose) THEN BEGIN
   print,'USE_TEMPLATE : mtm or mtm2'
   print,'READ_ASCII   : ',filename
   print,'Number of NaN',count
ENDIF

st=tri_julval(st)
st.val=st.val/10.
IF KEYWORD_SET(with_nan) THEN BEGIN
  RETURN, st
ENDIF ELSE BEGIN
  RETURN, finite_st(st)
ENDELSE

END
 
