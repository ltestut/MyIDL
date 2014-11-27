FUNCTION arrscl, array, min_value=min_value, max_value=max_value, top=top, missing=missing, centered=centered

; FONCTION presque equivalente à BYTSCL, qui retourne une matrice mise à l'echelle entre MIN ET MAX avec TOP valeurs
; Permet de préparer une matrice de valeurs en vue d'en faire une image avec MAP_IMAGE
; echantillone le tableau ARRAY entre les valeurs MIN_VALUE et MAX_VALUE sur un nombre de valeurs égal à TOP. (ex : TOP= nombre de couleurs voulu) 
; Tout ce qui est inferieur à MIN prend la valeur MIN, supérieur à MAX prend la valeur MAX
; Les NAN prennent la valeur de MISSING
; l'option CENTERED permet d'avoir des valeurs centrées autour de zéro

IF NOT KEYWORD_SET(min_value) THEN BEGIN
min_value=MIN(array, /NAN, max=maxtmp)
ENDIF

IF NOT KEYWORD_SET(max_value) THEN BEGIN
 max_value=maxtmp
ENDIF

IF (N_ELEMENTS(missing) EQ 1) THEN BEGIN
 missing=missing
ENDIF ELSE BEGIN
  missing=!VALUES.F_NAN
ENDELSE

lower_numbers = WHERE(array LT min_value, cnt)
IF (cnt GT 0) THEN array[lower_numbers]=min_value

greater_numbers = WHERE(array GT max_value, cnt)
IF (cnt GT 0) THEN array[greater_numbers]=max_value

valid_numbers = WHERE( (array GE min_value) OR (array LE max_value), cnt)

IF NOT KEYWORD_SET(centered) THEN BEGIN
  IF ( cnt GT 0 ) THEN BEGIN
    array[valid_numbers]=(((array[valid_numbers]-min_value)/(max_value-min_value))*top)
  ENDIF
ENDIF ELSE BEGIN
  max_abs = ABS(min_value) > ABS(max_value)
  array[valid_numbers]=((array[valid_numbers]+max_abs)/(2*max_abs))*top  
ENDELSE

not_numbers = WHERE(array NE array, cnt)
IF (cnt GT 0) THEN array[not_numbers]=missing

return, array

END