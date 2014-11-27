PRO write_kml, output=output,name=name

IF NOT KEYWORD_SET(output) THEN output=!kml
IF NOT KEYWORD_SET(name)   THEN name='test'

OPENW,  UNIT, output  , /GET_LUN        ;; ouverture en ecriture du fichier
PRINTF, UNIT, '<?xml version="1.0" encoding="UTF-8"?>'
PRINTF, UNIT, '<kml xmlns="http://www.opengis.net/kml/2.2">'
PRINTF, UNIT, '<Document>'
kml_define_style,UNIT,NAME='benchmark-red'
PRINTF, UNIT, "<name>",name,"</name>"
PRINTF, UNIT, '<open>1</open>'
kml_placemark,UNIT,NAME='DDU',LON=140.0058732983528,LAT=-66.6639149290645,$
              STYLE='benchmark-red',DESCRIPTION='yes yes ',/SNIPPET,TIMESPAN=[1966,2020]
PRINTF, UNIT, '</Document>'
PRINTF, UNIT, '</kml>'
FREE_LUN, UNIT
PRINT,output
END