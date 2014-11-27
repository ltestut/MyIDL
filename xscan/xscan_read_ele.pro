FUNCTION xscan_read_ele, filename
; read a .ele (output of triangle.exe) file and return a structure of type ele
;define the template for the elements
tmp_ele = {version:1.0,$
  delimiter:' '   ,$
  datastart:1    ,$
  missingvalue:!VALUES.F_NAN   ,$
  commentsymbol:'#'   ,$
  fieldcount:4L ,$
  fieldTypes:[3,3,3,3], $
  fieldNames:['number','n1','n2','n3'] , $
  fieldLocations:INDGEN(4)    , $
  fieldGroups:INDGEN(4) $
}
ele = READ_ASCII(filename, TEMPLATE=tmp_ele)
RETURN, ele
END