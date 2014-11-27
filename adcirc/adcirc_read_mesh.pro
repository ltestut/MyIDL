FUNCTION adcirc_read_mesh, filename
; this function reads/decode the main ADCIRC input file (fort.14) which contains
; 4 main blocks
; the mesh geometry       : vertices position [block 1], elements id and connectivity [block 2]
; the boundary conditions : elevation BC [block 3] and the normal-flow BC [block 4]
; each of these blocks is represented by a structure
; [block1] : nodes.id,nodes.x,nodes.y,nodes.depth 
; [block2] : elements.id,elements.nb,elements.n1,elements.n2,elements.n3
; [block3] : eboundaries.id
; [block4] : nfboundaries.id


IF NOT KEYWORD_SET(filename) THEN filename='C:\Users\Testut\Desktop\hurricane_isabel_test_case\fort.14'
;IF NOT KEYWORD_SET(filename) THEN filename='/data/tmp/test/fort.14'

 ;define the template for the node, elements,elevation-boundaries
tmp_nodes        = {version:1.0,delimiter:' ',datastart:2 ,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:4L,fieldTypes:[3,4,4,4]  ,fieldNames:['id','x','y','depth']    ,fieldLocations:INDGEN(4),fieldGroups:INDGEN(4)}
tmp_elements     = {version:1.0,delimiter:' ',datastart:0L,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:5L,fieldTypes:[3,2,3,3,3],fieldNames:['id','nb','n1','n2','n3'],fieldLocations:INDGEN(5),fieldGroups:INDGEN(5)}
tmp_eboundaries  = {version:1.0,delimiter:' ',datastart:0L,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:1L,fieldTypes:[3]        ,fieldNames:['id']                    ,fieldLocations:INDGEN(1),fieldGroups:INDGEN(1)}
tmp_nfboundaries = {version:1.0,delimiter:' ',datastart:0L,missingvalue:!VALUES.F_NAN,commentsymbol:'',fieldcount:1L,fieldTypes:[3]        ,fieldNames:['id']                    ,fieldLocations:INDGEN(1),fieldGroups:INDGEN(1)}

grid_name  = ''
Nnodes     = 0L ;[NP] node number.The nodes must be input in ascending order.
Nelements  = 0L ;[NE] element number. The elements must be input in ascending order.
Neb_segt   = 0L ;[NOPE] number of elevation-boundaries segments
Nteb_nodes = 0L ;[NETA] TOTAL number of elevation-boundaries nodes
Neb_nodes  = 0L ;[NVDLL] number of elevation-boundaries nodes for segment i
Nnf_segt   = 0L ;[NBOU] number of normal-flow-boundaries segments
Ntnf_nodes = 0L ;[NVEL] TOTAL number of normal-flow-boundaries nodes
Nnf_nodes  = 0L ;[NVELL] number of normal-flow-boundaries for this segment
nf_type    = 0L ;[IBTYPE] normal-flow-boundary type (0,1,2,3 ...


OPENR, UNIT, filename, /GET_LUN                    ;open the fort.14 
READF, UNIT, grid_name                             ;read the grid id
READF, UNIT, Nelements, Nnodes                     ;[NE][NP] read the total nbr of elements and nodes
;#####################################################
; READ THE MESH GEOMETRY                      [NE][NP]
;#####################################################
tmp_elements.datastart    = (2+Nnodes)             ;compute the starting line of the elements 
nodes      = READ_ASCII(filename, NUM_RECORDS=Nnodes   , TEMPLATE=tmp_nodes)     ;read the nodes information
elements   = READ_ASCII(filename, NUM_RECORDS=Nelements, TEMPLATE=tmp_elements)  ;read the elements information
SKIP_LUN, UNIT, Nnodes+Nelements, /LINES           ;skip the nodes and elements lines 
;#####################################################
; READ THE ELEVATION BOUNDARY GEOMETRY    [NOPE][NETA]
;#####################################################
READF, UNIT, Neb_segt                              ;[NOPE] read the nbr of elevation-boundaries segment
READF, UNIT, Nteb_nodes                            ;[NETA] read the TOTAL nbr of elevation-boundaries nodes
tmp_eboundaries.datastart = (2+Nnodes+Nelements+3) ;compute the starting line of the elevation-boundaries
eb_conn = -1L                                      ;init the elevation-boundaries polylines connectivity
eb_tid  = LONARR(1)                                ;init the total elevation-boundaries id
FOR i=0,Neb_segt-1 DO BEGIN
    READF, UNIT, Neb_nodes                         ;[NVDLL(k)] read the nbr of elevation-boundaries nodes for this segment
    eboundaries = READ_ASCII(filename, NUM_RECORDS=Neb_nodes, TEMPLATE=tmp_eboundaries)
    tmp_eboundaries.datastart=tmp_eboundaries.datastart+Neb_nodes  ;incremente the line of the boundaries
    SKIP_LUN, UNIT, Neb_nodes, /LINES              ;skip the the elevation-boundaries lines
    eb_conn = [[eb_conn],Neb_nodes,eb_conn[-1]+1+INDGEN(Neb_nodes)]
    eb_tid  = [[eb_tid],eboundaries.id]
ENDFOR
eb_connectivity  = eb_conn[1:N_ELEMENTS(eb_conn)-1]
eb_nodes_id      = eb_tid[1:N_ELEMENTS(eb_tid)-1] ;NBDV(k,j) = node id on elevation specified boundary segment k. 
; The node numbers must be entered in order as one moves along the boundary segment, 
; however the direction (counter clockwise or clockwise around the domain) does not matter.
;#####################################################
; READ THE NORMAL-FLOW BOUNDARY GEOMETRY  [NBOU][NVEL]
;#####################################################
READF, UNIT, Nnf_segt                               ;[NBOU] read the nbr of normal-flow-boundaries segment 
READF, UNIT, Ntnf_nodes                             ;[NVEL] read the TOTAL nbr of normal-flow-boundaries nodes
tmp_nfboundaries.datastart = (tmp_eboundaries.datastart+3) ;compute the starting line of the nf-boundaries
nf_conn = -1L                                 ;init the normal-flow-boundaries polylines connectivity
nf_tid  = LONARR(1)                                 ;init the total normal-flow-boundaries id
FOR j=0,Nnf_segt-1 DO BEGIN
  READF, UNIT, Nnf_nodes, nf_type                 ;[NVELL(k)] read the nbr of normal-flow-boundaries nodes for this segment and type
  nfboundaries = READ_ASCII(filename, NUM_RECORDS=Nnf_nodes, TEMPLATE=tmp_nfboundaries)
  tmp_nfboundaries.datastart=tmp_nfboundaries.datastart+1+Nnf_nodes  ;incremente the line of the boundaries
  SKIP_LUN, UNIT, Nnf_nodes, /LINES              ;skip the the elevation-boundaries lines
  nf_conn = [[nf_conn],Nnf_nodes,nf_conn[-1]+1+INDGEN(Nnf_nodes)]
  nf_tid  = [[nf_tid],nfboundaries.id]
ENDFOR
nf_connectivity  = nf_conn[1:N_ELEMENTS(nf_conn)-1]
nf_nodes_id      = nf_tid[1:N_ELEMENTS(nf_tid)-1] ;NBDV(k,j) = node id on elevation specified boundary segment k.

;NBVV(k,j) = node numbers on normal flow boundary segment k.
; The node numbers must be entered in order as one moves along the boundary segment with land always on the right,
;  i.e., in a counter clockwise direction for external (e.g., mainland, external barrier) boundaries and a clockwise direction for internal (e.g., island, internal barrier) boundaries. 
;  For an internal barrier boundary (IBTYPE(k) = 4, 24) only the nodes on the front face of the boundary are specified in NBVV(k,j). 
;  The paired nodes on the back face of the boundary are specified in IBCONN(k,j).

vertices      = FLTARR(2,Nnodes)
vertices[0,*] = nodes.x
vertices[1,*] = nodes.y
;vertices[2,*] = nodes.depth*1000.
conn         = LONARR(1)
FOR i=0,Nelements-1 DO conn = [[conn],elements.nb[i],elements.n1[i]-1,elements.n2[i]-1,elements.n3[i]-1] 
connectivity = conn[1:N_ELEMENTS(conn)-1]

eb_sgts      = FLTARR(2,N_ELEMENTS(eb_nodes_id))
eb_sgts[0,*] = nodes.x[eb_nodes_id-1]
eb_sgts[1,*] = nodes.y[eb_nodes_id-1]

st=create_llval(N_ELEMENTS(eb_nodes_id),/NAN)
st.lon=(eb_sgts[0,*])[*]
st.lat=(eb_sgts[1,*])[*]
tatlas=load_tatlas(MODEL='fes2012',zone='glob',LIMIT=[78,110,5,30])
tatlas_obc_interpol,tatlas,st,WAVE_LIST=tatlas.wave.name


nf_sgts      = FLTARR(2,N_ELEMENTS(nf_nodes_id))
nf_sgts[0,*] = nodes.x[nf_nodes_id-1]
nf_sgts[1,*] = nodes.y[nf_nodes_id-1]



map  = MAP('Mercator', CLIP=1)
cont = MAPCONTINENTS(/CONTINENTS)
mesh = POLYGON((vertices[0,*])[*], (vertices[1,*])[*], /DATA,$
    CONNECTIVITY=connectivity, $
    FILL_BACKGROUND=1, RGB_TABLE=72, VERT_COLORS=[0,64,128], $
    TARGET=map, CLIP=1)



;oModel    = OBJ_NEW('IDLgrModel')
;oPolygon  = OBJ_NEW('IDLgrPolygon' , vertices, POLYGONS =connectivity,    STYLE=1)
;oPoly_eb  = OBJ_NEW('IDLgrPolyline', eb_sgts,  POLYLINES=eb_connectivity, THICK=2, COLOR=[255,0,0])
;oPoly_nf  = OBJ_NEW('IDLgrPolyline', nf_sgts,  POLYLINES=nf_connectivity, THICK=2, COLOR=[0,0,255])
;
;oPolygon->SetProperty, STYLE=1, thick=1
;oModel->Add, oPolygon
;oModel->Add, oPoly_eb
;oModel->Add, oPoly_nf
;
;XOBJVIEW, oModel, /BLOCK, TITLE = 'Original Mesh'

RETURN, oModel
END

;Boundary type
;  0  ext boundary with no normal flow as an essential boundary condition and no constraint on tangential flow.
;  1  int boundary with no normal flow treated as an essential boundary condition and no constraint on the tangential flow. 
;  2  ext boundary with non-zero normal flow as an essential boundary condition and no constraint on the tangential flow. ;
;  3  ext barrier boundary with either zero or non-zero normal outflow from the domain as an essential boundary condition and no constraint on the tangential flow
;  4  int barrier boundary with either zero or non-zero normal flow across the barrier as an essential boundary condition and no constraint on the tangential flow.
;  5  int barrier boundary with additional cross barrier pipes located under the crown. 
;  10 ext boundary with no normal and no tangential flow as essential boundary conditions.
;  11 int boundary with no normal and no tangential flow as essential boundary conditions.
;  12 ext boundary with non-zero normal and zero tangential flow as an essential boundary condition.
;  13 ext barrier boundary with either zero or non-zero normal outflow from the domain and zero tangential flow as essential boundary conditions. 
;  20 ext boundary with no normal flow as a natural boundary condition and no constraint on tangential flow. 
;  21 int boundary with no normal flow as a natural boundary condition and no constraint on the tangential flow. This is applied by zeroing the normal boundary flux integral in the continuity equation. There is no constraint on velocity (normal or tangential) in the momentum equations. This boundary condition should satisfy no normal flow in a global sense but will only satisfy no normal flow at each boundary node in the limit of infinite resolution. This type of boundary represents an island boundary with a weak no normal flow condition and free tangential slip.
;  22 ext boundary with non-zero normal flow as a natural boundary condition and no constraint on the tangential flow. 
;  23 ext barrier boundary with either zero or non-zero normal outflow from the domain as a natural boundary condition and no constraint on the tangential flow. 
;  24 int barrier boundary with either zero or non-zero normal flow across the barrier as a natural boundary condition and no constraint on the tangential flow. This is applied by specifying the contribution (zero or non-zero) to the normal boundary flux integral in the continuity equation.
;  25 int barrier boundary with additional cross barrier pipes located under the crown.  Cross barrier flow is treated as a natural normal flow boundary condition which leaves/enters the domain on one side of the barrier and enters/leaves the domain on the corresponding opposite side of the barrier.  Flow rate and direction are based on barrier height, surface water elevation on both sides of the barrier, barrier coefficient and the appropriate barrier flow formula.  In addition cross barrier pipe flow rate and direction are based on pipe crown height, surface water elevation on both sides of the barrier, pipe friction coefficient, pipe diameter and the appropriate pipe flow formula.  Free tangential slip is allowed.
;  30 wave radiation normal to the boundary as a natural boundary condition. 
;  32 a combined specified normal flux and outward radiating boundary.  
;  40 a zero normal velocity gradient boundary. 
;  41 a zero normal velocity gradient boundary. 
;  52 ext boundary with periodic non-zero normal flow combined with wave radiation normal to the boundary as natural boundary conditions and no constraint on the tangential flow. This is applied by specifying the non-zero contribution to the normal boundary flux integral in the continuity equation. There is no constraint on velocity (normal or tangential) in the momentum equations. This boundary condition should correctly satisfy the flux balance in a global sense but will only satisfy the normal flow at each boundary node in the limit of infinite resolution.
;  102, 112, or 122 flux specified baroclinic.  In order to designate a river boundary as baroclinic, 100 should be added to the IBTYPE that would be appropriate in the barotropic case. For example, to convert a barotropic river boundary (IBTYPE of 22) to a baroclinic river boundary with freshwater inflow, change the IBTYPE to 122. If there is a 1 in the 100s place of the IBTYPE, ADCIRC will then try to read an input file (fort.39) for the salinity and/or temperature boundary condition. The format of the fort.39 file depends on the value of IDEN; see the documentation of the fort.39 file for more details.

; X(JN), Y(JN) = X and Y coordinates.
; If ICS=1 in the Model Parameter and Periodic Boundary Condition File then X(JN), Y(JN) are
; Cartesian coordinates
; with units of length (e.g., feet or meters) that are consistent with the definition of gravity in the Model Parameter and Periodic Boundary Condition File.
; If ICS=2 in the Model Parameter and Periodic Boundary Condition File then X(JN), Y(JN) are
; spherical coordinates in degrees of longitude (east of Greenwich is positive and west of Greenwich is negative)
; and degrees of latitude (north of the equator is positive and south of the equator is negative)


; DP(JN)=bathymetric depth with respect to the geoid,
;        positive below the geoid and negative above the geoid.
;        Bathymetric depths above the geoid or sufficiently small that nodes will dry,
;        require that the wetting/drying option is enabled (NOLIFA=2 in the Model Parameter and Periodic Boundary Condition File.)
