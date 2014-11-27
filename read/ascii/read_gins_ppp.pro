FUNCTION read_gins_ppp, filename, scale=scale
; read the output from the GINS software.
IF NOT KEYWORD_SET(scale) THEN scale = 1.


; Definition of the template
trm = {version:1.0,$
  datastart:0   ,$
  delimiter:''   ,$
  missingvalue:!VALUES.F_NAN   ,$
  commentsymbol:''   ,$
  fieldcount:10 ,$
  fieldTypes:[7,4,4,2,2,4,2,4,4,4], $
  fieldNames:['date','radar','d1','j1','c1','ssh_radar','sec','ssh','dif1','dif2'] , $
  fieldLocations:[0,20,26,34,37,43,66,73,96,119], $
  fieldGroups:indgen(10) $
}

;read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)
N     = N_ELEMENTS(data.date)
date  = DBLARR(N)
print,'READ_ASCII   : ',filename,'  Ndata =',N

;compute the date
READS,data.date[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
st     = create_julval(N)
st.jul = date
st.val = data.ssh*scale

RETURN, st



END