PRO write_ll2kml, st_in, output=output, decimate=decimate

IF NOT KEYWORD_SET(output) THEN output=!kml
N = N_ELEMENTS(st_in.lon)
If KEYWORD_SET(decimate) THEN BEGIN
 id     = L64INDGEN(N/decimate)*decimate    ;find the decimated index
 N      = N_ELEMENTS(id)                    ;replace the number of elements
 st     = create_llval(N)
 st.lon = st_in[id].lon
 st.lat = st_in[id].lat
 st.val = st_in[id].val
ENDIF ELSE BEGIN
 st     = st_in
ENDELSE

OPENW,  UNIT, output  , /GET_LUN        ;; ouverture en ecriture du fichier
PRINTF, UNIT, '<?xml version="1.0" encoding="UTF-8"?>'
PRINTF, UNIT, '<kml xmlns="http://www.opengis.net/kml/2.2">'
PRINTF, UNIT, '<Document>'
PRINTF, UNIT, '     <name>', "Trajectory", '</name>
PRINTF, UNIT, '     <open>1</open>'
PRINTF, UNIT, '<Style id="linestyleExample">'
PRINTF, UNIT, '<LineStyle>'
PRINTF, UNIT, '<color>7f0000ff</color>'
PRINTF, UNIT, '<width>5</width>'
PRINTF, UNIT, '</LineStyle>'
PRINTF, UNIT, '</Style>'
PRINTF, UNIT, '      <Placemark>'
PRINTF, UNIT, '           <name>', "data", '</name>
PRINTF, UNIT, '<styleUrl>#linestyleExample</styleUrl>
PRINTF, UNIT, '           <LineString>'
PRINTF, UNIT, '                <tessellate>1</tessellate>'
PRINTF, UNIT, '                <coordinates>'
 ;PRINTF, UNIT, FORMAT='(I13,I13)', 1, N
 coord=STRCOMPRESS(STRING(FORMAT='(F12.6)',st[0].lon)+','+STRING(FORMAT='(F12.6)',st[0].lat)+',0 ',/REMOVE_ALL)
    FOR I=0L,N-1 DO BEGIN
    coord=coord+' '+STRCOMPRESS(STRING(FORMAT='(F12.6)',st[I].lon)+','+STRING(FORMAT='(F12.6)',st[I].lat)+',0',/REMOVE_ALL)
    ENDFOR
       PRINTF, UNIT,coord
  PRINTF, UNIT, '                </coordinates>'
 PRINTF, UNIT, '           </LineString>'
 PRINTF, UNIT, '      </Placemark>'
 PRINTF, UNIT, '</Document>'
 PRINTF, UNIT, '</kml>'
 FREE_LUN, UNIT
 PRINT,output
END