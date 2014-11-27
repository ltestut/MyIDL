PRO kml_placemark, unit, name=name,lon=lon,lat=lat,height=height,extrude=extrude,$
                         style=style,description=description,timespan=timespan,snippet=snippet

IF NOT KEYWORD_SET(name)    THEN name='place'
IF NOT KEYWORD_SET(lon)     THEN lon=0.0
IF NOT KEYWORD_SET(lat)     THEN lat=0.0
IF NOT KEYWORD_SET(height)  THEN height=0.0



coord=STRCOMPRESS(STRING(FORMAT='(F12.6)',lon)+','+STRING(FORMAT='(F12.6)',lat)+','+STRING(FORMAT='(F12.3)',height),/REMOVE_ALL)
PRINTF, UNIT, '      <Placemark>'
PRINTF, UNIT, "           <name>",name,"</name>"
IF KEYWORD_SET(style)       THEN PRINTF, UNIT, "            <styleUrl>#",style,"</styleUrl>"
IF KEYWORD_SET(timespan)    THEN PRINTF, UNIT, "            <TimeSpan><begin>",STRCOMPRESS(STRING(TimeSpan[0])),"</begin><end>",STRCOMPRESS(STRING(TimeSpan[1])),"</end></TimeSpan>"
IF KEYWORD_SET(description) THEN PRINTF, UNIT, "            <description>",description,"</description>"
IF KEYWORD_SET(snippet) THEN kml_snippet,UNIT,snippet
PRINTF, UNIT, "            <Point>"
IF KEYWORD_SET(extrude) THEN PRINTF, UNIT, "              <extrude>1</extrude>"
IF KEYWORD_SET(extrude) THEN PRINTF, UNIT, "              <altitudeMode>absolute</altitudeMode>"
PRINTF, UNIT, "              <coordinates>",coord,"</coordinates>"
PRINTF, UNIT, "            </Point>"
PRINTF, UNIT, "       </Placemark>"
END