FUNCTION selfe_read_ncdf_output, filename

If NOT KEYWORD_SET(filename) THEN $
   filename='C:\Users\ltestut\Desktop\1_elev.nc'

id=ncdf_info(filename)

fid=NCDF_OPEN(filename, /NOWRITE)   ;open netcdf file and return the file id

NCDF_DIMINQ, fid, NCDF_DIMID(fid, 'node'), name, node ; read number of nodes
NCDF_DIMINQ, fid, NCDF_DIMID(fid, 'nele'), name, nele ; read number of elements
NCDF_DIMINQ, fid, NCDF_DIMID(fid, 'time'), name, time ; read number of time pts

;NCDF_ATTGET, fid, '_FillValue', fillValue, /GLOBAL

varNames = ['x', 'y', 'ele', 'depth']
timeVarNames = ['elev']
;;    To do this with a HASH (get data with result['u-vec']
result = DICTIONARY()
result.dim = DICTIONARY('node', node, 'nele', nele, 'time', time)
result.var = ORDEREDHASH()           ; Want to preserve standard order of names
allVarNames = [varNames, timeVarNames]
FOREACH varName, allVarNames DO BEGIN
   NCDF_VARGET, fid, NCDF_VARID(fid, varName), varData  ; Read variable
   ;varData[Where(varData EQ fillValue, /NULL)] = !VALUES.D_NaN ; Replace fillData:NaN
   (result.var)[varName] = varData           ; Add to hash
ENDFOREACH ; varName

NCDF_CLOSE, fid           ; close netcdf file

RETURN, result


END