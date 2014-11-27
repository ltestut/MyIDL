FUNCTION read_aws_benoit, file, para=para
; read the data compiled by benoit
template = {version:1.0,$
           datastart:0   ,$
           delimiter:' '   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:''   ,$
           fieldlocations:[1,6,9,13,19,24,32,39,46,53]  ,$
           fieldcount:10L ,$
           fieldTypes:[2,2,2,2,4,4,4,4,4,4], $
           fieldNames:['yy','mm','dd','mes','temp','Ps','Ws','cap','hyg','dtv'] , $
          ; fieldLocations:[0,17]    , $
           fieldGroups:INDGEN(10) $
          }


data  = READ_ASCII(file,TEMPLATE=template)

N       = N_ELEMENTS(data.yy) 
date    = DBLARR(N)
jul     = JULDAY(1,data.dd,data.yy,0,data.mes*10)

IF (para EQ 'baro') THEN BEGIN
 st      = create_julval(N)
 st.jul  = jul
 st.val  = data.Ps
ENDIF ELSE BEGIN
 st      = create_julvent(N)
 st.jul  = jul
 st.amp  = data.ws
 st.cap  = data.cap
ENDELSE

;st=tri_julval(st)
return, st


END