FUNCTION read_rbr_cmb, filename, para=para, slev=slev, template=template
; lecture des donnees du RBR de commonwealth bay dans les differents formats

IF NOT KEYWORD_SET(para) THEN para='bot'

IF (template EQ 'cmb_2009') THEN BEGIN
 trm = {version:1.0,$
        datastart:28   ,$
        delimiter:' '   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:6 ,$
        fieldTypes:[4,4,4,4,4,4], $
        fieldNames:['cond','twat','bot','dep','swat','sos'] , $
        fieldLocations:[0,10,20,30,40,50], $
        fieldGroups:indgen(6) $
      }
 jmin  = JULDAY(01,09,2008,01,38,10) ;date de debut de la serie
 tmin  ='130120080140'
 tmax  ='160120091310'
ENDIF ELSE IF (template EQ 'cmb_2010') THEN BEGIN      
 trm = {version:1.0,$
        datastart:27   ,$
        delimiter:' '   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:3 ,$
        fieldTypes:[4,4,4], $
        fieldNames:['cond','twat','bot'] , $
        fieldLocations:[0,10,20], $
        fieldGroups:indgen(3) $
      }
 jmin  = JULDAY(01,16,2009,14,10,10) ;date de debut de la serie
 tmin  ='160120091400'
 tmax  ='160120110700'
ENDIF ELSE BEGIN
  PRINT,"Vous n'avez pas specificie de template"
ENDELSE

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)
Nd    = N_ELEMENTS(data.cond)
st    = create_julval(Nd)
date  = TIMEGEN(Nd,UNITS='Minutes',START=jmin,STEP_SIZE=10)
; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ trm.fieldNames)
scl   = 1.
IF (IP EQ 2) THEN scl=100. 
 print,'READ_ASCII   : ',filename & print,'Extract para : ',trm.fieldNames[IP]
 st.jul = date
 st.val = data.(IP)[0:Nd-1]*scl
IF (para EQ 'bot' AND KEYWORD_SET(slev)) THEN BEGIN
 slev   = (st.val-983.3)/(1.02578*0.981)
 st.val = slev
ENDIF
st = julcut(st,TMIN=tmin,TMAX=tmax)
RETURN, st
END