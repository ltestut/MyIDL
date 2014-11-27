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
   XINTERANIMATE, /KEEP_PIXMAPS

END

PRO anime_tugo, Z, X , Y, T, A
TX=700
ilat=55
NC=200 ;740 ;130
nlev=30
WINDOW,0,XSIZE=TX,YSIZE=TX
A=BYTARR(TX,TX,NC)
LOADCT,0,NCOLOR=nlev
FOR I=0,NC-1 DO BEGIN
;map_aviso,z,x,y,t,format='(F8.2)',title="SLA in cm",range=[-0.05,0.05],fr=1+I,pal=13
;map_matrix,z[*,*,I]-mean(z[*,*,I],/NAN),format='(F8.2)',title='IBD => '+date(t[I]),range=[-0.02,0.02],nlev=nlev
;coupe_zonal,z,x,y,t,ilat=188,yrange=[-30.,30.],sm=10,fr=1+I
;hovmoller,z,x,y,t,ilat=135+I,speed=-5,range=[-12,12],/moy
;shade_surf,z[*,*,I]-MEAN(z[*,*,I],/NAN),ax=50,az=10,zrange=[-1.5,1.5]
shade_surf,Z[*,*,I],ax=40.,az=30,zrange=[-1.0,1.0]
;plot,x[*,ilat],(z[*,ilat,i]-MEAN(z[*,ilat,i]))-smooth(z[*,ilat,i]-MEAN(z[*,ilat,i]),50),xrange=[0,360],yrange=[-10.,10.],xstyle=1,title=string(y[0,ilat])
A[0,0,I]=TVRD()
ENDFOR

anime,A
END
