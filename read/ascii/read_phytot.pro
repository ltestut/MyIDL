; $Id: read_phytot.pro,v 1.00 20/05/2005 L. Testut $
;

;+
; NAME:
;	READ_PHYTOT
;
; PURPOSE:
;	Read the .phytot ROSAME data file (with meteo data in the last column)
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_PHYTOT(filename,para=parameter)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst' 
;       para=         : keyword string of the parameter to extract ex: para='bot'
;
; OUTPUTS:
;	Structure of type {jul,val} or of type phytot {jul,twat,bot,baro,mto}
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
; - Le 20/05/2005 Add the possibility to have phy output
; - Le 17/12/2008 Add the possibility to give the template name
;-
;
FUNCTION read_phytot, filename, para=para, phytot=phytot, tpl_name=tpl_name

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_PHYTOT(filename,para=parameter, /phytot)'
IF NOT KEYWORD_SET(tpl_name) THEN tpl_name='phy1'
; Define the template to be used
templ = USE_TEMPLATE(tpl_name)    ;USE_TEMPLATE('phytot')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

IF KEYWORD_SET(phytot) THEN BEGIN
        print,'USE_TEMPLATE : ',tpl_name
        print,'READ_ASCII   : ',filename
        print,'Extract para : all ==> phytot'
        
; Create the julval structure 
        N    = N_ELEMENTS(data.jul) 
        st   = create_phy(N)
        date = DBLARR(N)
; Cut the string of the date field to build the corresponding date 
        READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
        print,date[N-1],FORMAT='(C())'
        st.jul  = date        
        st.twat = data.(1)[0:N-1]
        st.bot  = data.(2)[0:N-1]
        st.baro = data.(3)[0:N-1]  ; Attention modif par rapport a phytot
        st.mto  = MAKE_ARRAY(N,VALUE=!VALUES.F_NAN)  ;data.(4)[0:N-1] 
        RETURN, st
    ENDIF ELSE BEGIN 
        IF (KEYWORD_SET(para)EQ 0) THEN STOP, '! Need the tag parameter to read'
        
; Find the tag number of the keyword string parameter para=
        IP    = WHERE(para EQ templ.fieldNames, count) 
        
        IF (count EQ 0) THEN STOP, '! Unknown parameter '
        
        print,'USE_TEMPLATE :  phytot'
        print,'READ_ASCII   : ',filename
        print,'Extract para : ',templ.fieldNames[IP]
        
; Create the julval structure 
        N    = N_ELEMENTS(data.jul) 
        st   = create_julval(N)
        date = DBLARR(N)
; Cut the string of the date field to build the corresponding date 
        READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
        print,date[N-1],FORMAT='(C())'
        st.jul = date        
        st.val = data.(IP)[0:N-1]
        RETURN, st
    ENDELSE
END

