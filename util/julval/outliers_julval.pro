FUNCTION outliers_julval, st, fct=fct, nsig=nsig, inan=inan, range=range, verbose=verbose
; can remove the outliers *st* from a detection of them on fct
IF NOT KEYWORD_SET(nsig) THEN nsig=4.

st1    = st
sdetect= st
IF KEYWORD_SET(fct) THEN sdetect=fct

; compute the standard deviation of the serie
sigma = STDDEV(sdetect.val,/NAN)
moy   = MEAN(sdetect.val,/NAN)
diff  = ABS(sdetect.val-moy)
inan =  WHERE(diff GT nsig*sigma,count)
IF KEYWORD_SET(verbose) THEN print,'number of outliers (pour mille) =',(FLOAT(count)/FLOAT(N_ELEMENTS(sdetect.jul)))*1000.
IF KEYWORD_SET(range) THEN BEGIN
inan = WHERE((sdetect.val LE range[0]) OR (sdetect.val GE range[1]),count) 
print,range
print,count
ENDIF
IF (count ge 1) THEN st1[inan].val=!VALUES.F_NAN
RETURN, st1
END
