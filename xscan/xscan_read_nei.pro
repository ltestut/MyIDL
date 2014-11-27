FUNCTION xscan_read_nei, filename
; read a .nei file a return a structure of type 
; nei 
; 

tmp_nei = {version:1.0,delimiter:' ',datastart:3 ,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:13L,fieldTypes:[3,5,5,2,4,3,3,3,3,3,3,3,3]  ,fieldNames:['id','x','y','bc','a','n1','n2','n3','n4','n5','n6','n7','n8'],fieldLocations:INDGEN(13),fieldGroups:INDGEN(13)}

OPENR, UNIT, filename, /GET_LUN
READF, UNIT, FORMAT='(I12)',Ntotal
READF, UNIT, FORMAT='(I12)',Nsegt
READF, UNIT, FORMAT='(I12)',Nnodes
nei = READ_ASCII(filename, NUM_RECORDS=Ntotal, TEMPLATE=tmp_nei)
FREE_LUN, UNIT

RETURN, nei
END