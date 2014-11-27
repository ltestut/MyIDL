; $Id: read_blq.pro,v 1.00 17/11/2008 L. Testut $
;

;+
; NAME:
; READ_BLQ
;
; PURPOSE:
; Read the data file of type .blq from the Ocean Tide Loading web site
;       see. the USE_TEMPLATE function to define the appropraite template
; 
; CATEGORY:
; Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
; st=READ_BLQ(filename,jmin=jmin,jmax=jmax,ech=ech)
; 
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
; filename      : string of the filename ex:'/local/home/ocean/testut/ker_otl.blq' 
;
; OUTPUTS:
; Structure of type {jul,val}
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;
;-
;
FUNCTION  read_blq, filename, jmin=jmin,jmax=jmax, ech=ech

IF NOT KEYWORD_SET(jmin)      THEN jmin=JULDAY(1,1,2002)
IF NOT KEYWORD_SET(jmax)      THEN jmax=jmin+365.
IF NOT KEYWORD_SET(ech) THEN ech=5

; Define the template to be used
templ = USE_TEMPLATE('blq')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)
N_wav = N_TAGS(data)
print,'USE_TEMPLATE :  blq'
print,'READ_ASCII   : ',filename
frq = DBLARR(11)
frq = [1.405189027044D-04,1.454441043329D-04,1.378796996516D-04,1.458423171028D-04,$
       7.292115855138D-05,6.759774415297D-05,7.252294578148D-05,6.495854110023D-05,$
       5.323414398410D-06,2.639203052741D-06,3.982127698995D-07]                     ;frequence en rad/s
frq = (frq*3600.*24.) ;/(2.*!PI)

print,1/frq       
; Construction de la base de temps
; --------------------------------
time   = TIMEGEN(start=jmin,final=jmax,unit='minutes', step_size=ech)
Nt     = N_ELEMENTS(time)                                                                              ; nbre de valeurs de la série
st     = create_julval(Nt)
st.jul = time

; Construction de la serie d'effet de charge oceanique
; ----------------------------------------------------

FOR i=0,N_wav-1 DO BEGIN
   st.val = st.val + data.(i)[0]*COS(frq[i]*(st.jul-st[0].jul)+rad(data.(i)[3]))
ENDFOR
st.val=st.val*100.  ;on passe en cm
RETURN,st
END
 
