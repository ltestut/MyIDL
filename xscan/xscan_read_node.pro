FUNCTION xscan_read_node, filename
; read a .node (output of triangle.exe) file and return a structure of type node
tmp_nodes = {version:1.0,$
  delimiter:' '   ,$
  datastart:1    ,$
  missingvalue:!VALUES.F_NAN   ,$
  commentsymbol:'#'   ,$
  fieldcount:5L ,$
  fieldTypes:[3,5,5,4,2], $
  fieldNames:['id','x','y','c1','c2'] , $
  fieldLocations:INDGEN(5)    , $
  fieldGroups:INDGEN(5) $
}
node = READ_ASCII(filename,  TEMPLATE=tmp_nodes)
RETURN, node
END