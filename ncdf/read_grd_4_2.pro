PRO read_grd_4_2, filename, Z, X, Y, deg=deg
id=NCDF_OPEN(filename)

; Recupere les variables x,y,z
NCDF_VARGET,id,NCDF_VARID(id,'x'),X
NCDF_VARGET,id,NCDF_VARID(id,'y'),Y
NCDF_VARGET,id,NCDF_VARID(id,'z'),Z

; Recupere les valeurs limites des variables x,y,z
NCDF_ATTGET, id, NCDF_VARID(id,'x') , 'actual_range', Xrange
NCDF_ATTGET, id, NCDF_VARID(id,'y') , 'actual_range', Yrange
NCDF_ATTGET, id, NCDF_VARID(id,'z') , 'actual_range', Zrange

IF KEYWORD_SET(deg) THEN BEGIN
   Nx=N_ELEMENTS(X)
   Ny=N_ELEMENTS(Y)
   ; Compute the X and Y vector in degree format
   dx=ABS(Xrange[1]-Xrange[0])/(Nx-1)
   dy=ABS(Yrange[1]-Yrange[0])/(Ny-1)
   X=Xrange[0]+FINDGEN(Nx)*dx
   Y=Yrange[0]+FINDGEN(Ny)*dy
ENDIF
NCDF_CLOSE, id
END

