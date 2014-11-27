FUNCTION adcirc_read_xscan_nei, node=node, nei=nei, ele=ele, depth=depth

; plutot que de travailler sur une grille lon,lat,
; pourquoi ne pas travailler sur la grille projetee !!!

; [block1] : nodes.id,nodes.x,nodes.y,nodes.depth
; [block2] : elements.id,elements.nb,elements.n1,elements.n2,elements.n3
; [block3] : elements.id,elements.nb,elements.n1,elements.n2,elements.n3

;/!\ dans les fichiers tugo il y a plus dans le fichier s2r que dans le fichiers node ??

;dans le fichier nei et s2r on a 10374 pts
;et dans le .node 10097 


; Il y a un pb avec le passage du mesh.nei au fort.14 a cause du changement 
; du nbre de noeud du au passage du mesh-doctor 
; on a l'information sur le block1 : nodes.id,nodes.x,nodes.y,nodes.depth avec le mesh.nei et le depth a partir du topo.s2r)

adcirc_basic = {nelts:0L, np:0L, nope:0L, neta:0L}

;path='C:\Users\Testut\Desktop\mesh\'
;path='/data/model_indien_nord/zone_wic/mesh/'
path='D:\pcp_tugo\data\model_indien_nord\zone_shelf\mesh\'
IF NOT KEYWORD_SET(node_file)  THEN node_file   = path+'tmp/mod00.1.node'
IF NOT KEYWORD_SET(ele_file)   THEN ele_file    = path+'tmp/mod00.1.ele'
IF NOT KEYWORD_SET(depth_file) THEN depth_file  = path+'tmp/topo-LGP1-1.s2r'
IF NOT KEYWORD_SET(bel_file)   THEN bel_file    = path+'mesh.bel'


Nnodes    = 0L
Nelements = 0L
;define the template for the node
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
;define the template for the topography
tmp_bathy = {version:1.0,$
  delimiter:' '   ,$
  datastart:2    ,$
  missingvalue:!VALUES.F_NAN   ,$
  commentsymbol:'#'   ,$
  fieldcount:2L ,$
  fieldTypes:[3,4], $
  fieldNames:['id','depth'] , $
  fieldLocations:INDGEN(2)    , $
  fieldGroups:INDGEN(2) $
}

;define the template for the elements
tmp_elements = {version:1.0,$
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
;define the template for the nei
tmp_nei = {version:1.0,$
  delimiter:' '   ,$
  datastart:3    ,$
  missingvalue:!VALUES.F_NAN   ,$
  commentsymbol:''   ,$
  fieldcount:13L ,$
  fieldTypes:[3,5,5,2,4,3,3,3,3,3,3,3,3], $
  fieldNames:['number','x','y','code','depth','n1','n2','n3','n4','n5','n6','n7','n8'] , $
  fieldLocations:INDGEN(13)    , $
  fieldGroups:INDGEN(13) $
}

;OPENR, UNIT, nei, /GET_LUN
;READF, UNIT, Nnodes
;READF, UNIT, l1
;READF, UNIT, l2
;data_bathy   = READ_ASCII(depth_file, TEMPLATE=tmp_bathy)      ;read the topo.s2r to get the depth
OPENR, UELE, ele_file, /GET_LUN
READF, UELE, FORMAT='(I6,X,I1,X,I1)',Nelements,a,b
OPENR, UNODE, node_file, /GET_LUN
READF, UNODE, FORMAT='(I6,X,I2,X,I2,X,I2)',Nnodes,a,b,c
data_elements = READ_ASCII(ele_file,  NUM_RECORDS=Nelements, TEMPLATE=tmp_elements)
data_nodes    = READ_ASCII(node_file, NUM_RECORDS=Nnodes, TEMPLATE=tmp_nodes)

; create the 4-structures
nodes     = {id:LONARR(Nnodes)   ,  x:DBLARR(Nnodes), y:DBLARR(Nnodes), depth:FLTARR(Nnodes)} 
elements  = {id:LONARR(Nelements), nb:INTARR(Nelements), n1:LONARR(Nelements), n2:LONARR(Nelements), n3:LONARR(Nelements)}


; fill the structures
nodes.id    = data_nodes.id-1
nodes.x     = data_nodes.x
nodes.y     = data_nodes.y
;nodes.depth = data_bathy.depth
elements.id = data_elements.number
elements.nb = MAKE_ARRAY(Nelements,VALUE=3,/INTEGER)
elements.n1 = data_elements.n1
elements.n2 = data_elements.n2
elements.n3 = data_elements.n3

vertices      = FLTARR(2,Nnodes)
vertices[0,*] = nodes.x
vertices[1,*] = nodes.y
conn         = LONARR(1)
FOR i=0,Nelements-1 DO conn = [[conn],3,elements.n1[i],elements.n2[i],elements.n3[i]]
connectivity = conn[1:N_ELEMENTS(conn)-1]

map = MAP_PROJ_INIT('Lambert Azimuthal',CENTER_LATITUDE=14.132409,$
                                     CENTER_LONGITUDE=73.5)
ll  = MAP_PROJ_INVERSE(nodes.x,nodes.y,MAP_STRUCTURE=map)


RETURN,{vert:ll, conn:connectivity}

oModel = OBJ_NEW('IDLgrModel')
oPolygon = OBJ_NEW('IDLgrPolygon', vertices, POLYGONS = connectivity,$
  STYLE = 1)
oPolygon->SetProperty, STYLE=1, thick=1
oModel->Add, oPolygon
XOBJVIEW, oModel, /BLOCK, $
  TITLE = 'Original Mesh'


;TRIANGULATE, nodes.x,nodes.y,triangles,CONNECTIVITY=conn
;Nelement     = N_ELEMENTS(triangles[0,*])
;conn         = LONARR(1)
;FOR i=0,Nelement-1 DO conn = [[conn],3,triangles[0,i],triangles[1,i],triangles[2,i]]
;connectivity = conn[1:N_ELEMENTS(conn)-1]
;
;vertices      = FLTARR(2,Nnodes)
;vertices[0,*] = nodes.x
;vertices[1,*] = nodes.y
;
;oModel = OBJ_NEW('IDLgrModel')
;oPolygon = OBJ_NEW('IDLgrPolygon', vertices, POLYGONS=connectivity, STYLE = 1)
;oPolygon->SetProperty, STYLE=0, thick=1
;oModel->Add, oPolygon
;XOBJVIEW, oModel, /BLOCK, $
;  TITLE = 'Original Mesh'
;



END