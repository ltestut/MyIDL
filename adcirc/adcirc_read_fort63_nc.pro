FUNCTION adcirc_read_fort63_nc, filename
;function to read the netcdf elevation output of ADCIRC model fort.63

filename='/home/softs/adcirc/v50_99_10/work/fort.63.nc'
filename='C:\Users\Testut\Desktop\mesh\adcirc\fort.63.nc'

fid=NCDF_OPEN(filename)   ;open netcdf file and return the file id

NCDF_DIMINQ, fid, 1, Name, node ;read the number of node 
NCDF_DIMINQ, fid, 2, Name, nele ;read the number of elements

NCDF_VARGET, fid, NCDF_VARID(fid,'x')       ,  lon  ;lon(node)
NCDF_VARGET, fid, NCDF_VARID(fid,'y')       ,  lat  ;lat(node)
NCDF_VARGET, fid, NCDF_VARID(fid,'element') ,  ele  ;ele(nele,nvertex)
NCDF_VARGET, fid, NCDF_VARID(fid,'depth')   ,  depth  ;ele(nele,nvertex)


map       = MAP_PROJ_INIT('Mercator',CENTER_LATITUDE=mean(lat),CENTER_LONGITUDE=mean(lon))
xy        = MAP_PROJ_FORWARD(lon,lat,MAP_STRUCTURE=map)
xy        = xy/1000.

vertices      = FLTARR(3,node)
vertices[0,*] = xy[0,*]
vertices[1,*] = xy[1,*]
vertices[2,*] = depth

conn          = LONARR(1)
FOR i=0,nele-1 DO conn = [[conn],3,ele[*,i]-1]
connectivity = conn[1:N_ELEMENTS(conn)-1]

oPolygon  = OBJ_NEW('IDLgrPolygon' , vertices, POLYGONS =connectivity, STYLE=1)
RETURN,oPolygon
END