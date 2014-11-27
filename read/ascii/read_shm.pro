; $Id: read_shm.pro,v 1.00 01/04/2005 L. Testut $
;

;+
; NAME:
;	READ_SHM
;
; PURPOSE:
;	Read the SHOM data file of type .shm
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
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.shm' 
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
; -Add the nvpd (Number of Value Per Day) Keyword to read the sub-hourly sampling
;-
;
FUNCTION  read_shm, filename, nvpd=nvpd

; probleme a DDU Attention au fichers qui n'est pas toujours en heure
; TU !!!!



IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_SHM(filename)'


IF NOT KEYWORD_SET(nvpd) THEN BEGIN
 ; Define the template to be used
 templ = USE_TEMPLATE('shm')
 ; Read the data corresponding to the defined template
 data  = READ_ASCII(filename,TEMPLATE=templ)
 print,'USE_TEMPLATE : shm'
 print,'READ_ASCII   : ',filename
 ; Create the julval structure for output 
 N    = N_ELEMENTS(data.y) 
 st   = create_julval(N*24)
 FOR I=0,23 DO BEGIN
    st[I*N:(I+1)*(N-1)+I].jul=DOUBLE(JULDAY(1,0,data.y,I,0,0)+data.day)
    st[I*N:(I+1)*(N-1)+I].val=data.(I+3)
 ;print,FORMAT='("I=",I2,C(),X,F10.2)',I,st[I*477+406].jul,st[I*477+406].val
 ENDFOR
itrou=WHERE(st.val EQ 9999.000,count)
IF (count GE 1) THEN BEGIN
    st[itrou].val=!VALUES.F_NAN
ENDIF
print,'Number of NaN',count
ENDIF ELSE BEGIN
 data  = READ_ASCII(filename)
 nvpd  = LONG(nvpd)
 Nd    = N_ELEMENTS(data.(0))    ;nbre total d'elements du tableau
 Nlpd  = CEIL((nvpd+3L)/27.) ;nbre de ligne par jour
 Nl    = Nd/27                   ;nbre total de lignes du fichier
 nday  = Nl/Nlpd                 ;nbre de jour de valeur
 st    = create_julval(nday*nvpd,/NAN)
 FOR i=0,nday-1 DO BEGIN
 j=i*(Nlpd*27L)           ;incide du debut de chaque jour
 k=i*(nvpd)               ;incide du debut de chaque donnee du jour
; print,FORMAT='(%"%d  %f %f")',i,data.(0)[j],data.(0)[j+2]
 st[k:k+nvpd-1].jul=JULDAY(1,data.(0)[j+2],data.(0)[j],0,INDGEN(nvpd)*(24.*60./nvpd),0)
 st[k:k+nvpd-1].val=data.(0)[j+3:j+3+nvpd-1]
 ENDFOR
 st = finite_st(st)
ENDELSE

st=tri_julval(st)

RETURN, st
END
 
