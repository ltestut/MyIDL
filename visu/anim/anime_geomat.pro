PRO anime, A

;; Mise a l'echelle des valeurs entre 0 et 255
     Nx  = N_ELEMENTS(A[*,0,0])
     Ny  = N_ELEMENTS(A[0,*,0])
     Nt  = N_ELEMENTS(A[0,0,*])

;; Initialize XINTERANIMATE:
   XINTERANIMATE, SET=[Nx, Ny, Nt]
;; Load the images into XINTERANIMATE:
   FOR I=0,Nt-1 DO XINTERANIMATE, FRAME = I, IMAGE = A[*,*,I]
;; Play the animation:
   XINTERANIMATE,50, /KEEP_PIXMAPS

END

PRO anime_geomat, geo
SET_PLOT,'WIN'
TX=800
ilat=55
NC=20 ;740 ;130
nlev=10
WINDOW,0,XSIZE=TX,YSIZE=TX
A=BYTARR(TX,TX,NC)
FOR I=0,NC-1 DO BEGIN
map_geomat,geo, FRAME=I,pal=0
A[0,0,I]=TVRD()
ENDFOR

anime,A
END
