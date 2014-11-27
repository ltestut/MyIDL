PRO geodimeter2kml, file, year=year, day_of_year=day_of_year, decimate=decimate, output=output
; prog qui ecrite un fichier de position de type kml a partir d'un fichier geodimeter

IF NOT KEYWORD_SET(decimate) THEN dec=1

;file= 'C:\Documents and Settings\testut\Bureau\Kavaratti\data\GPS\ttc\buoy276c.POS'

 ;read. geo coordinates
lon  = read_geodimeter(file,year=year,day_of_year=day_of_year,PARA='lon')
lat  = read_geodimeter(file,year=year,day_of_year=day_of_year,PARA='lat')

npt  = N_ELEMENTS(lon)

 ;decimate
id = L64INDGEN(npt/dec)*dec

 ;on create llval structure
N      = N_ELEMENTS(id)
st     = create_llval(N)
st.lon = lon[id].val
st.lat = lat[id].val

seg_size = 100
fmt      = '(F10.5,",",F10.5,",0 ")'
IF (KEYWORD_SET(output)) THEN BEGIN

 OPENW,  UNIT, output  , /GET_LUN        ;; ouverture en ecriture du fichier
 PRINTF, UNIT, '<?xml version="1.0" encoding="UTF-8"?>'
 PRINTF, UNIT, '<kml xmlns="http://earth.google.com/kml/2.2">'
 PRINTF, UNIT, '<Document>'
 PRINTF, UNIT, '     <name>', "data", '</name>
 PRINTF, UNIT, '     <open>1</open>'
 
 I  =  0L
 f  =  1
 j  =  1
 segt_name          = STRCOMPRESS('segt_'+STRING(f), /REMOVE_ALL)

; while ( I LT N-1 ) do begin
    ;; si la premiere ligne contient des valeurs, ecrire l'en tete et la ligne de valeurs
;    if ( (i EQ 0) OR ((j MOD seg_size EQ 0))) then begin
        PRINTF, UNIT, '      <Placemark>'
        PRINTF, UNIT, '           <name>', segt_name, '</name>
        PRINTF, UNIT, '           <LineString>'
        PRINTF, UNIT, '                <tessellate>1</tessellate>'
        PRINTF, UNIT, '                <coordinates>'
;    endif
        FOR i=0,N-1 DO PRINTF, UNIT, FORMAT=fmt, st[i].lon,st[i].lat
;        i  =  i+1        
;    endif 
    
        PRINTF, UNIT, '                </coordinates>'
        PRINTF, UNIT, '           </LineString>'
        PRINTF, UNIT, '      </Placemark>'
    
; endwhile

 PRINTF, UNIT, '</Document>'
 PRINTF, UNIT, '</kml>'
 FREE_LUN, UNIT
ENDIF
END