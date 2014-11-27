FUNCTION igrid, tab, xtab
; get the grid number given the value (generally lat or lon)
s = SIZE(tab) & st = SIZE(TRANSPOSE(tab))
IF ((s[0] GT 1) AND (st[0] GT 1)) THEN STOP,"Tab should be of size 1"
N  = N_ELEMENTS(tab)
dx = ABS(MAX(tab)-MIN(tab))/(N-1) ;grid size in x unit
print,dx
IF ((xtab GT MAX(tab)) OR (xtab LT MIN(tab))) THEN STOP,"Exceed tab range"
itab = (xtab - MIN(tab))/dx
RETURN,itab
END