PRO plot_regr, Y1,Y2, png=png, output=output, _EXTRA=_EXTRA
; trace la regression entre Y1 et Y2 

; Save the current plot state.
bang_p = !P
bang_x = !X
bang_Y = !Y
bang_Z = !Z
bang_Map = !Map


; GESTION DU FORMAT DE SORTIE
; ---------------------------
col           =  cgcolor('white',255) 
bck_col       =  cgcolor('black',254)
CASE 1 OF
    (N_ELEMENTS(ps) EQ 0) AND (N_ELEMENTS(png) EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        device, retain=2, decomposed=0
        output='Xwindow'
    END
    KEYWORD_SET(ps) : BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
        stack = SCOPE_TRACEBACK(/STRUCTURE)
        sourceDir = FILE_DIRNAME((stack[N_ELEMENTS(stack)-1]).filename,/MARK_DIRECTORY)
        ; /MARK_DIRECTORY permet de placer un separateur de repertoire a la fin du chemin
        sdir=STRSPLIT(sourceDir,'/',/EXTRACT)
        ;dir='/'+sdir[0]+'/'
        ;print,'output_dir=',dir
        IF NOT KEYWORD_SET(output) THEN output = DIALOG_PICKFILE(DEFAULT_EXTENSION='ps')
        DEVICE, set_font='Times-Bold', /portrait, /color, /encapsulated, filename=output, $
          font_size=6,$
          xsize=14, ysize=6,xoffset=2.,yoffset=4.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
          
    END
    KEYWORD_SET(png) : BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE


!P.BACKGROUND = bck_col
!X.TICKLEN    = 1
!X.GRIDSTYLE  = 1   

PLOT,Y1,Y2,psym=1,COLOR=col,_EXTRA=_EXTRA

FIN : print,'OUTPUT ======>',output
IF KEYWORD_SET(ps) THEN device, /close_file
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"PLOT_JULVAL write => ",output
ENDIF

   ; Restore the previous plot and map system variables.
!P = bang_p
!X = bang_x
!Y = bang_y
!Z = bang_z
!Map = bang_map

;!X.TICKLAYOUT   = 0 
;!X.TICKINTERVAL = 0 
;!X.TICKUNITS    = '' 
;!X.TICKFORMAT   = '' 
;!P.BACKGROUND   = 0


END
