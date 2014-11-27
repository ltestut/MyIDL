FUNCTION fast_decimate_julval, st, sampling=sampling, verbose=verbose
; fonction qui decime a 1hr et 1minute sans passer par synchro_julval
; et sans faire des tableau enorme en cas d'echantillonnage initiale eleve (1s)
; sampling : echantillonnage de sortie en mn

CALDAT, st.jul, month, day, year, hour, minute, second

IF NOT KEYWORD_SET(sampling) THEN sampling=60.
IF (sampling EQ 1.)  THEN id = WHERE(second LT 1.0e-3)
IF (sampling EQ 60.) THEN id = WHERE((second EQ 0) AND (minute EQ 0)) 


std     = create_julval(N_ELEMENTS(id))
std.jul = st[id].jul
std.val = st[id].val

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,"FAST_DECIMATE_JULVAL  : initial nbr of data  = ",N_ELEMENTS(st)
 PRINT,"FAST_DECIMATE_JULVAL  : initial sampling     = ",sampling_julval(st),' sec.'
 PRINT,"FAST_DECIMATE_JULVAL  : final nbre of data   = ",N_ELEMENTS(std)
 PRINT,"FAST_DECIMATE_JULVAL  : final sampling       = ",sampling_julval(std),' sec.'
ENDIF
RETURN, std
END
