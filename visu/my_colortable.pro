PRO my_colortable, pal_name, ncolors=ncolors

; Charge la palette de couleur dont le nom est PAL_NAME



IF NOT KEYWORD_SET(ncolors) THEN ncolors=!D.TABLE_SIZE

IF (pal_name EQ 'diff') THEN RESTORE, !my_col_path+'pal_diff.sav'


r = CONGRID(r, ncolors)
g = CONGRID(g, ncolors)
b = CONGRID(b, ncolors)

TVLCT, r, g, b

END