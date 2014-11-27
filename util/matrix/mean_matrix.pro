FUNCTION mean_matrix, Z, rms=rms
IF (N_PARAMS() EQ 0) THEN STOP, 'm=MEAN_MATRIX(Z,/rms)'

s        = SIZE(Z)
mean     = TOTAL(Z,3,/NAN)/S[3]

IF KEYWORD_SET(rms) THEN BEGIN
   stddev = SQRT(TOTAL((Z-REBIN(mean,s[1],s[2],s[3]))^2,3,/NAN)/(s[3]-1))
RETURN, stddev
ENDIF

RETURN,mean
END
