FUNCTION xscan_read_bel, filename
; read a .bel file a return a structure of type bel
tmp_bel = {version:1.0,delimiter:' ',datastart:2 ,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:5L ,fieldTypes:[3,3,3,2,2],fieldNames:['id','e1','e2','na','bc'],fieldLocations:INDGEN(5) ,fieldGroups:INDGEN(5)}
bel = READ_ASCII(filename, TEMPLATE=tmp_bel)
RETURN, bel
END