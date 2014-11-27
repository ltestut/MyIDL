PRO time_filter, st, Tech, Tmin, Tmax, stf

IF (N_PARAMS() EQ 0) THEN BEGIN
print, 'UTILISATION:
print, 'time_filter, st, stf'
print, ''
print, 'INPUT: st,tmin,tmax'
print, 'OUTPUT: sft'
RETURN
ENDIF

print,'FILTRAGE DE LA SERIE ENTRE ',Tmin,' ET ',Tmax
FN    = 1./(2.*Tech)
xlow  = (2.*Tech)/Tmax
xhigh = (2.*Tech)/Tmin
coeff = DIGITAL_FILTER(xlow,xhigh, 50., 1000)
END
