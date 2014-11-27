FUNCTION read_add_gmt2scan, filename=filename
; definition du patron de lecture
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter:','   ,$
       missingvalue:!VALUES.F_NAN   ,$
       commentsymbol:'#'   ,$
       fieldcount:2 ,$
       fieldTypes:[7,7], $
       fieldNames:['lon','lat'] , $
        fieldLocations:[0,16], $
        fieldGroups:indgen(2) $
      }

; lecture du fichier a partir du patron de lecture tmp
data   = READ_ASCII(filename,TEMPLATE=tmp)
a      = '>'
id_sep = WHERE(STRCMP(data.lon,a,1) EQ 1,count)
IF (count GE 1) THEN BEGIN
   data.lon[id_sep]='0.00'
   data.lat[id_sep]='0.00'
ENDIF
st     = create_llval(N_ELEMENTS(data.lon),/NAN)
st.lon = FLOAT(data.lon)
st.lat = FLOAT(data.lat)

out  =   write_llval2scan(st, filename=filename)


RETURN, st
END