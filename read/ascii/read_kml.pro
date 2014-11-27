FUNCTION read_kml, filename=filename



; definition du patron de lecture
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter:','   ,$
       missingvalue:!VALUES.F_NAN   ,$
       commentsymbol:'#'   ,$
       fieldcount:3 ,$
       fieldTypes:[4,4,4], $
       fieldNames:['lon','lat','val'] ,$
       fieldLocations:[0,10,20], $
       fieldGroups:indgen(3) $
      }
; lecture du fichier a partir du patron de lecture tmp
data  = READ_ASCII(filename,TEMPLATE=tmp)

id         =  WHERE(FINITE(data.lon,/NAN),count)
id_bis     = -TS_DIFF(id,1)-1
id_valid   =  WHERE(id_bis NE 0.)
id_nan_del =  id[id_valid]

data.lon[id_nan_del] =0.0
data.lat[id_nan_del] =0.0
data.val[id_nan_del] =0.0

inan = WHERE(FINITE(data.lon),count)
print,'data n elt  : ', N_ELEMENTS(data.lon)
print,'count       : ', count


st    = create_llval(count,/NAN)
st.lon = data.lon[inan]
st.lat = data.lat[inan]
st.val = data.val[inan]

RETURN, st
END