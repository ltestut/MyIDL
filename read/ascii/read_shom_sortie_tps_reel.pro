FUNCTION  read_shom_sortie_tps_reel, filename, flag=flag, rms=rms, format_date=format_date, skip=skip

IF NOT KEYWORD_SET(format_date) THEN format_date='(C(CYI4,CMOI2,CDI2,X,CHI2,CMI2,CSI2))'
tmp     = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:'#'   ,$
           fieldcount:4L ,$
           fieldTypes:[7,4,7,2], $
           fieldNames:['jul','val','unit','code'] , $
           fieldLocations:[0,15,23,25]    , $
           fieldGroups:INDGEN(4) $
          }

data  = READ_ASCII(filename,TEMPLATE=tmp)
N    = N_ELEMENTS(data.jul)
st   = create_julval(N)
date = DBLARR(N)
READS,data.jul[0:N-1],date,FORMAT=format_date
  ;print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(1)[0:N-1]
;  itrou = where(st.val eq flag, nb_trou)
;  IF (nb_trou ne 0) THEN BEGIN
;    st[itrou].val=!VALUES.F_NAN
;  ENDIF
  RETURN, finite_st(st)
END

