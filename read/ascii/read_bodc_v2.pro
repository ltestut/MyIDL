; $Id: read_bodc.pro,v 1.00 21/05/2008 L. Testut $
;

;+
; NAME:
; READ_BODC
;
; PURPOSE:
; Read the data file of type 1 01/01/02 02 1001.3 from BODC database
; 
; CATEGORY:
; Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
; st=READ_BODC(filename)
; 
;       use the fct/proc : -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
; filename      : string of the filename ex:'/local/home/ocean/testut/test.dateval' 
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

FUNCTION read_bodc, filename
; LECTURE DU FICHIER .LST
; -----------------------
trm=  { version:1.0,$
        datastart:13   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:3L ,$
        fieldTypes:[4,7,4], $
        fieldNames:['num','jul','val'] , $
        fieldLocations:[0,8,29]    , $
        fieldGroups:INDGEN(3) $
      }
data  = READ_ASCII(filename,TEMPLATE=trm)
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;IF KEYWORD_SET(hms) THEN READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
READS,data.jul[0:N-1],date,FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(2)[0:N-1]
RETURN, st
END