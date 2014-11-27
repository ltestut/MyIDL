; $Id: read_mto_ddu.pro,v 1.00 17/07/2008 L. Testut $
;

;+
; NAME:
;	READ_MTO_DDU
;
; PURPOSE:
;	Read the .txt meteo data file (from geophy DDU)
;
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_MTO_DDU(filename,para='parameter',tpl='template')
;
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.txt'
;       para=     : keyword string of the parameter to extract ex: para='fwind'
;       tpl =     : keyword string of the template to use ex: tpl='mto'
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
FUNCTION read_mto_ddu, filename, para=para, tpl=tpl

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_MTO_DDU(filename,para='parameter-name',tpl='template-name')"
IF (KEYWORD_SET(para) EQ 0) THEN STOP, "! ==> Need the *para* keyword : st=READ_PHY(filename,para='baro') "
IF NOT KEYWORD_SET(tpl) THEN tpl='mto'



; Define the template to be used
templ = USE_TEMPLATE(tpl)

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames)
print,'USE_TEMPLATE : ',tpl
print,'READ_ASCII   : ',filename
print,'Extract para : ',templ.fieldNames[IP]

; Create the julval structure with N-1 data (because last data of .lst
; is the number of rows extracted). Last data read should be: 31 Dec 19XX 21:00
N    = N_ELEMENTS(data.jul)
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date
CASE tpl OF
  'mto_ddu'  : BEGIN    
                READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4))'
                CALDAT,date,month,day,year,hour,mn,sec
                st.jul = JULDAY(month,day,year,data.hour,0,0)
                st.val = data.(IP)[0:N-1]
               END
 'mto_ddu2010': BEGIN
                READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
                st.jul = date
                st.val = data.(IP)[0:N-1]
                st     = tri_julval(st)
           END
 'mto_ddu2010_08': BEGIN
             READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI2,X,CHI2,X,CMI2))'
             st.jul = date+730487. ;add 2000 years in days
             st.val = data.(IP)[0:N-1]
           END
  
ENDCASE 

PRINT,st[0].jul,FORMAT='(C())'
PRINT,st[-1].jul,FORMAT='(C())'


iflg = WHERE(st.val EQ -999.,count)
IF (count GT 0) THEN BEGIN
   print,"Nbre de NaN : ",count
   st[iflg].val=!VALUES.F_NAN
ENDIF
RETURN, finite_st(st)
END

