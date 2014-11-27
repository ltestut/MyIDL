;   Removing the climatological mean


nyears  = 4                                      ;Number of years
nmonths = 12*nyears                              ;Number of months
t       = (0.5 + FINDGEN(nmonths))/12            ;Time in years
n       = N_ELEMENTS(t)
z = COS(2.0*!PI*t) + 0.2*RANDOMN(seed, n)        ;Data with an annual cycle
z = REFORM(z, 12, nyears)                        ;Rearrange for convenience
zclim = REBIN(TOTAL(z, 2)/nyears, 12, nyears)    ;Compute climatological mean

PLOT, t, z, PSYM = 1                             ;Plot original data
OPLOT, t, zclim                                  ;Plot climatological mean
OPLOT, t, z - zclim, LINESTYLE = 1               ;Plot anomaly

cr = ''
READ, cr, PROMPT = 'Enter <cr> to continue : '

;   Removing the annual harmonic

z = COS(2.0*!PI*t - 0.75) + 0.2*RANDOMN(seed, n)    ;Data with an annual cycle
x = TRANSPOSE([[SIN(2.0*!PI*t)], [COS(2.0*!PI*t)]]) ;Create predictor variables

coeffs = REGRESS(x, z, CONST = zmean, YFIT = yfit)  ;Fit the sinusoids
PRINT, SQRT(TOTAL(coeffs^2)), ATAN(coeffs[0], coeffs[1]) ;Amplitude and phase

PLOT, t, z, PSYM = 1                                ;Plot original data
OPLOT, t, yfit                                      ;Plot climatological mean
OPLOT, t, z - yfit, LINESTYLE = 1                   ;Plot anomaly 
