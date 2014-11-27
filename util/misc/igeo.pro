FUNCTION igeo, tab, xtab
; interpole un index sur une grille lon,lat pas forcement regulier a partir de lon et lat
dtab = ABS(tab-xtab)  ;on construit le tableau des diff
is   = SORT(dtab)     ;renvoie les indices de plus petite difference du min au max
itab = is[0] + ((is[1]-is[0])/(tab[is[1]]-tab[is[0]]))*(xtab-tab[is[0]])
RETURN, itab
END
