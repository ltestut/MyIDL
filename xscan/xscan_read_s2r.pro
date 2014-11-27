FUNCTION xscan_read_s2r, filename
  ; read a .s2r file a return a structure of type s2r
  tmp_s2r = {version:1.0,delimiter:' ',datastart:2 ,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:2L,fieldTypes:[3,4],fieldNames:['id','depth'],fieldLocations:INDGEN(2),fieldGroups:INDGEN(2)}
  s2r = READ_ASCII(filename, TEMPLATE=tmp_s2r)
  RETURN, s2r
END