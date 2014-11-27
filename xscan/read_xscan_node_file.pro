PRO read_xscan_node_file


path='/data/model_indien_nord/zone_wic/mesh/'
IF NOT KEYWORD_SET(node_file)  THEN node_file   = path+'tmp/mod02.nod'
tmp_nodes = {version:1.0,delimiter:' ',datastart:3 ,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:3L,fieldTypes:[4,4,4]  ,fieldNames:['x','y','val'],fieldLocations:INDGEN(3),fieldGroups:INDGEN(3)}



OPENR, UNODE, node_file, /GET_LUN
READF, UNODE, FORMAT='(I12)',Ntotal
READF, UNODE, FORMAT='(I12)',Nsegt
READF, UNODE, FORMAT='(I12)',Nnodes
bnodes    = READ_ASCII(node_file, NUM_RECORDS=Nnodes, TEMPLATE=tmp_nodes)
SKIP_LUN, UNODE, Nnodes, /LINES           ;skip the nodes and elements lines
tmp_nodes.datastart = (3+Nnodes)             ;compute the starting line of the elements
READF, UNODE, FORMAT='(I12)',Nnodes
inodes    = READ_ASCII(node_file, NUM_RECORDS=Nnodes, TEMPLATE=tmp_nodes)
FREE_LUN, UNODE

plot,bnodes.x,bnodes.y,psym=1
oplot,inodes.x,inodes.y,psym=1

END