PRO kml_define_style,unit,name=name


;PRINTF, UNIT,

CASE name OF
  'benchmark-red' : BEGIN
                    PRINTF, UNIT,'  <Style id="',name,'">'
                    PRINTF, UNIT,"    <IconStyle>"
                    PRINTF, UNIT,"      <color>ff0000ff</color>"
                    PRINTF, UNIT,"      <scale>1.1</scale>"
                    PRINTF, UNIT,"      <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>"
                    PRINTF, UNIT,"    </IconStyle>"
                    PRINTF, UNIT,"  </Style>"
                    END
  'benchmark-gps' : BEGIN
                    PRINTF, UNIT,'  <Style id="',name,'">'
                    PRINTF, UNIT,"    <IconStyle>"
                    PRINTF, UNIT,"      <color>ff1478FF</color>"
                    PRINTF, UNIT,"      <scale>1.4</scale>"
                    PRINTF, UNIT,"      <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>"
                    PRINTF, UNIT,"    </IconStyle>"
                    PRINTF, UNIT,"  </Style>"
                    END
             else: begin
             end
ENDCASE
END