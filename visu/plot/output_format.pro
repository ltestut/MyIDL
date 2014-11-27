PRO output_format, col, bck_col, ps=ps, png=png, output=output, small=small 
; 
CASE 1 OF
    (KEYWORD_SET(ps) EQ 0) AND (KEYWORD_SET(png) EQ 0): BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        DEVICE, SET_CHARACTER_SIZE=[10,10]
        device, retain=2, decomposed=0
        ;output='Xwindow'
    END
    KEYWORD_SET(ps) : BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
;        IF NOT KEYWORD_SET(output) THEN output = DIALOG_PICKFILE(FILTER='*.ps',DEFAULT_EXTENSION='ps')
        IF NOT KEYWORD_SET(output) THEN output = !def_ps
        output=output+'.ps'  ;on ajoute l'extension
        xs = 20
        ys = 20
        IF KEYWORD_SET(small) THEN BEGIN
          xs = 10
          ys = 10
        ENDIF
        DEVICE, /TIMES, /BOLD, /PORTRAIT, /color, /encapsulated, /preview, /isolatin1,$
        filename=output, $
          font_size=10,$
          xsize=xs, ysize=xs,xoffset=2.,yoffset=2.
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
    KEYWORD_SET(png) : BEGIN
        IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
        IF NOT KEYWORD_SET(output) THEN output = DIALOG_PICKFILE(FILTER='*.png')
        ;output=output+'.png'  ;on ajoute l'extension
        DEVICE, SET_CHARACTER_SIZE=[12,12]
        DEVICE, retain=2, decomposed=1        
        col     =  cgcolor('black',255) 
        bck_col =  cgcolor('white',254)
    END
ENDCASE
END