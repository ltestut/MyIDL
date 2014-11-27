; lancer la ligne de commande ci-dessous pour lancer l'animation
;
;@anim_plot_julval
;

; definition des parametres de l'animation
; ----------------------------------------
TX    = 600    ; taille de la fenetre a animer
NC    = 10     ; nombre de couche de l'animation
window,0,title='ANIMATION',XSIZE=TX,YSIZE=TX
A=bytarr(TX,TX,Nc)
   FOR I=0,Nc-1 DO BEGIN
   ; inserer ici votre ligne de commande a animer
   ; ex : plot_julval,/data,yrange=[-60,60],monthly_mean(NMIN=2,stx2julval(stx,pt=12,/sla)),st3
plot_julval,/data,yrange=[-60,60],$
            monthly_mean(NMIN=2,stx2julval(stx,pt=7+I,/sla)),st3,$
            TITLE='red(Newlin monthly mean) track point N'+STRCOMPRESS(STRING(I+7))
       A[0,0,I]=TVRD()
   ENDFOR

print,'FIN ANIMATION'

Nx  = N_ELEMENTS(A[*,0,0])
Ny  = N_ELEMENTS(A[0,*,0])
Nt  = N_ELEMENTS(A[0,0,*])
  
;; Initialize XINTERANIMATE:
   XINTERANIMATE, SET=[Nx, Ny, Nt], /SHOWLOAD 
;; Load the images into XINTERANIMATE:
  FOR I=0,(Nt-1) DO XINTERANIMATE, FRAME = I, IMAGE = A[*,*,I]
;; Play the animation: 
   XINTERANIMATE, /KEEP_PIXMAPS
END