FUNCTION adcirc_convert_mesh, path=path, verbose=verbose
; this program allows to convert a mesh produce by xscan into a mesh usable by ADCIRC (fort.14)
; the 3 files needed are the *mesh.nei* and *mesh.bel* and the *dom.scan*
; From these 3 files the vertices position (*.nei), elements connectivity (*.ele)
; and boundaries segments (order the dom.scan continuous order) are build. 

IF NOT KEYWORD_SET(path) THEN path = '/data/tmp/test/'

; read the .nei and .bel and .scan files
nei = xscan_read_nei(path+'mesh.nei')
bel = xscan_read_bel(path+'mesh.bel')
seg = xscan_read_scan(path+'dom.scan')
dep = xscan_read_s2r(path+'topo.s2r')
ibc = WHERE(bel.bc EQ 5,bc5,NCOMPLEMENT=bc1)
ib  = WHERE(nei.bc EQ 1,Nbound)

; test the depth file
idep = WHERE(dep.depth LT -50.,count)
IF (count GT 1) THEN dep.depth[idep]=-10.

;find the boundary nodes and the ordered index of the boundary
sort_nei= LIST()
;find the index of the continuous boundary files
FOR i=0,N_ELEMENTS(seg.lat)-1 DO BEGIN
  nei_id  = WHERE((ABS(seg.lon[i]-nei.x) LT 0.001) AND (ABS(seg.lat[i]-nei.y) LT 0.001),cpt)
  min_lat = MIN(ABS(seg.lat[i]-nei.y),ilat_min)
  min_lon = MIN(ABS(seg.lon[i]-nei.x),ilon_min)
  IF (cpt EQ 1) THEN BEGIN
    IF (sort_nei.where(nei_id) EQ !NULL) THEN BEGIN
      sort_nei.Add, nei_id
    ENDIF ELSE BEGIN
      print,'doublon',nei_id
    ENDELSE
  ENDIF ELSE BEGIN
    PRINT,'no match',i,cpt
    PRINT,seg.lon[i],seg.lat[i]
    PRINT,nei.x[ilon_min],nei.y[ilon_min]
    PRINT,nei.x[ilat_min],nei.y[ilat_min]
    PRINT,min_lon,min_lat
    PRINT,ilon_min,ilat_min
  ENDELSE
ENDFOR
id_sort=sort_nei.ToArray()                           ;index of the boundary nodes (some are open-boundary or elevation-specified-boundary and some are normal-flow boundary)
nbn    = sort_nei.Count()
PRINT,'Sorted boundary nodes : ',nbn                 ;number of boundary node
; /!\ the node numbering in xscan is the id_sort (not the nei.id[id_sort] which is id_sort+1) 


;write a mesh.poly for triangulation
Nnodes=N_ELEMENTS(nei.x)
IF (Nbound NE N_ELEMENTS(bel.id)) THEN print,"Pb"
OPENW,  UNIT  , path+'mesh.poly'  , /GET_LUN
PRINTF, UNIT  , FORMAT='(I8,X,I2,X,I2,X,I2)', Nnodes,2,1,0
FOR i=0,Nnodes-1 DO PRINTF, UNIT, i+1,nei.x[i],nei.y[i],0.0
PRINTF, UNIT, FORMAT='(I8,X,I2)', Nbound,0
FOR i=0,Nbound-1 DO PRINTF, UNIT, i+1,bel.e1[i],bel.e2[i]
PRINTF,UNIT,0
FREE_LUN, UNIT
;CD, path
;SPAWN,'triangle.exe -p mesh.poly'

; read the resulting .node and .ele files
nod  = xscan_read_node(path+'mesh.1.node')
ele  = xscan_read_ele(path+'mesh.1.ele')
Nnod = N_ELEMENTS(nod.id)                  ;total number of nodes
Nele = N_ELEMENTS(ele.number)              ;total number of elements

; get the boundary code from the ordered list and the .bel
ebn = LIST()  ;init the elevation-boundary list (code 5 in bel)
nfn = LIST()  ;init the normal-flow list (code 1 in bel)
FOR i=0,nbn-1 DO BEGIN                        ;loop on the boundary node
  node_number = (id_sort[i]+1)                ;node number (as in nod)
  b1 = WHERE(bel.e1 EQ node_number)           ;bel index where this node start the segment 
  b2 = WHERE(bel.e2 EQ node_number)           ;bel index where this node end   the segment
  ;PRINT,"Boundary code for node",sort_nei[i]+1,'  :',bel.bc[b1],bel.bc[b2]
  ;if the node is twice on the land (BC=1) then node is added on normal-flow list
  ;if the node is on the land and the ocean then node is added on elevation-boundary list
  ;if the node is twice on the ocean (BC=5) then node is added on elevation-boundary list
  ;if the node is on the ocean and the land then node is added on elevation-boundary list
  CASE bel.bc[b1] OF                          
    1 : IF (bel.bc[b2] EQ 1) THEN nfn.add,node_number ELSE ebn.add,node_number
    5 : IF (bel.bc[b2] EQ 5) THEN ebn.add,node_number ELSE ebn.add,node_number,/EXTRACT 
  ENDCASE
ENDFOR
  print,'Elevation Boundary list ',ebn
  print,'Normal-Flow Boundary list ',nfn


IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,"  Number of nodes    in nei file    :",N_ELEMENTS(nei.id)
  PRINT,"  Number of depth    in s2r file    :",N_ELEMENTS(dep.depth)
  PRINT,"  Total Number of nodes on boundary :",Nbound
  PRINT,"  Number of segments in bel file    :",N_ELEMENTS(bel.id)
  PRINT,"                      + on land     :",bc1
  PRINT,"                      + on ocean    :",bc5
  PRINT,"  Number of points   in scan file   :",N_ELEMENTS(seg.lon)
  PRINT,"  Number of eb nodes (ebn list)     :",N_ELEMENTS(ebn)
  PRINT,"  Number of nf nodes (nfn list)     :",N_ELEMENTS(nfn)
  
ENDIF

OPENW , UNIT, path+'fort.14', /GET_LUN
PRINTF, UNIT, 'zone_wic'              ;print the grid id
PRINTF, UNIT, Nele, Nnod              ;[NE][NP] print the total nbr of elements and nodes
FOR i=0,Nnod-1 DO PRINTF, UNIT, nod.id[i],nod.x[i],nod.y[i],dep.depth[i]
FOR i=0,Nele-1 DO PRINTF, UNIT, ele.number[i],3,ele.n1[i],ele.n2[i],ele.n3[i]
PRINTF, UNIT, 1
PRINTF, UNIT, N_ELEMENTS(ebn)
PRINTF, UNIT, N_ELEMENTS(ebn)
FOR i=0,N_ELEMENTS(ebn)-1 DO PRINTF, UNIT, ebn[i]
PRINTF, UNIT, 1
PRINTF, UNIT, N_ELEMENTS(nfn)
PRINTF, UNIT, N_ELEMENTS(nfn), 0
FOR i=0,N_ELEMENTS(nfn)-1 DO PRINTF, UNIT, nfn[i]
FREE_LUN,UNIT
RETURN,0
END