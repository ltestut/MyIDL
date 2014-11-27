FUNCTION cal2jul, cal
; fonction qui permet de passer du format calendaire 110720051351 au format jour juli
scal = STRLEN(cal) ;calcul de la taille en caractere 
jul  = 0.0D        ;initialisation du jour julien en format double
READS,cal,jul,FORMAT=get_format(scal)
RETURN,jul
END