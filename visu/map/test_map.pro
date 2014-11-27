pro test_map
; Define the data by reading the image into IDL,

; creating the daymap variable to hold the data.

READ_JPEG, FILEPATH('Day.jpg', $

   SUBDIR=['examples','data']), daymap

 

; Define the latitude and longitude data for the contour.

longitude = FINDGEN(360) - 180

latitude = FINDGEN(180) - 90

cntrdata = SIN(longitude/30) # COS(latitude/30)

 

; Display the global image.

map2 = IMAGE(daymap, $

LIMIT=[-90,-180,90,180], GRID_UNITS=2, $

   IMAGE_LOCATION=[-180,-90], IMAGE_DIMENSIONS=[360,180],$

   MAP_PROJECTION='Mollweide')

 

; Draw the contour on top of the map image.

cntr2 = CONTOUR(cntrdata, longitude, latitude, $

   GRID_UNITS=2, N_LEVELS=10, RGB_TABLE=39, /OVERPLOT)

end