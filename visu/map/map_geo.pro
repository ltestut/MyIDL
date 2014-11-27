FUNCTION map_geo, geo

geosize=SIZE(geo.val,/N_DIMENSIONS)
IF NOT KEYWORD_SET(frame) THEN frame=0
IF (geosize EQ 3) THEN val=geo.val[*,*,frame] ELSE val=geo.val 

state=DICTIONARY()

state.oWindow=WINDOW(WINDOW_TITLE='Map geo',DIMENSIONS=[1000,600],$
                     LOCATION=[200,0])

state.oMap = MAP('Geographic',/BOX_AXES,LIMIT=geo_limit(geo),$
                                                        CURRENT=state.oWindow)



state.oMainVis=state.oMap

state.oImage=IMAGE(val,geo.lon,geo.lat,GRID_UNITS='degrees',$
             RGB_TABLE=COLORTABLE(70,/REVERSE),$
             CURRENT=state.oMainVis,/OVERPLOT)


state.oContinent=MAPCONTINENTS(/CONTINENTS,FILL_COLOR='light gray',/HIRES)

state.oColorbar=COLORBAR(TARGET=state.oImage,/TAPER)

RETURN,state
END