PRO adcirc_view_mesh, mesh
oModel  = OBJ_NEW('IDLgrModel')
mesh.SetProperty,style=1
oModel -> Add, mesh
XOBJVIEW, oModel
END