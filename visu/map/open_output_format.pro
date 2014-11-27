PRO open_output_format, verbose=verbose, png=png, ps=ps, pal=pal, mypal=mypal,nlev=nlev, _EXTRA=_EXTRA
; chargement de la palette et du nbre de niveau de couleur pour les cartes
; ------------------------------------------------------------------------
LOADCT,0                                                             ; initialisation de la palette a N&B
IF (N_ELEMENTS(nlev) EQ 0) THEN nlev=!ncol_map ELSE !ncol_map=nlev   ; par defaut le !ncol_map sinon on force !ncol_map a nlev
IF (N_ELEMENTS(pal) EQ 0)  THEN pal=13                               ; par defaut palette 13
LOADCT, pal, NCOLORS=!ncol_map         
IF KEYWORD_SET(mypal) THEN my_colortable,'diff'  ,NCOLORS=!ncol_map                            ; chargement de la palette

X_output=(KEYWORD_SET(ps)+KEYWORD_SET(png))
CASE 1 OF
    (X_output EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        device, retain=2, decomposed=0
        output='Xwindow'
        col           =  cgcolor('white',255) 
        bck_col       =  cgcolor('black',254)
    END
    KEYWORD_SET(ps) : BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
        IF NOT KEYWORD_SET(output) THEN output = !def_ps
        output=output+'.ps'  ;on ajoute l'extension
        xs = 20
        ys = 25
        IF KEYWORD_SET(small) THEN BEGIN
          xs = 10
          ys = 10
        ENDIF
        DEVICE, /COURIER, /BOLD, /portrait, /color, /encapsulated, filename=output, bits_per_pixel=8,/PREVIEW,$
          font_size=10,$
          xsize=xs, ysize=xs,xoffset=2.,yoffset=8.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
    KEYWORD_SET(png) : BEGIN
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        IF NOT KEYWORD_SET(output) THEN output  =  'idl.png'      
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE
!P.BACKGROUND = bck_col
!P.COLOR      = col
IF KEYWORD_SET(verbose) THEN BEGIN
; print,"ps        =>  ",KEYWORD_SET(ps)
; print,"png       =>  ",KEYWORD_SET(png)
; print,"X         =>  ",X_output
 print,"Output            =>  ",output
 print,"Axis       Color  = ",!P.COLOR
 print,"Background color  = ",!P.BACKGROUND
 print,"Color Palette     = ",pal
 print,"Nbre de couleur   = ",!ncol_map
ENDIF
END