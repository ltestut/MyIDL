PRO adcirc_plot_mesh,mesh,tlb=tlb
loadct,13
;oModel    = OBJ_NEW('IDLgrModel')
mesh->SetProperty, STYLE=2,VERT_COLORS=[10,20,30,40,50,60,70,80,90,100,200],SHADING=1
;oModel->Add, mesh
XOBJVIEW, mesh, TLB=tlb, TITLE = 'Original Mesh'
END