FUNCTION read_ctoh_nominal_track, filename=filename

IF NOT KEYWORD_SET(filename) THEN filename=!desk+'GFO_track_lonlat.csv'
tmp = {version:1.0,$
        datastart:1   ,$
        delimiter:','   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:''   ,$
        fieldcount:3 ,$
        fieldTypes:[2,5,5], $
        fieldNames:['track','lon','lat'] , $
        fieldLocations:[0,1,2]    , $
        fieldGroups:indgen(3) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=tmp)
N     = N_ELEMENTS(data.track) 
;st    = {track:INTARR(N), lon:DBLARR(N), lat:DBLARR(N)}
tmp   = {track:0, lon:0.0D, lat:0.0D}
st    = REPLICATE(tmp,N)
                         
st.track = data.track
st.lon   = data.lon+180.
st.lat   = data.lat
RETURN, st
END