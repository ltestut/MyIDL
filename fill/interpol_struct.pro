PRO interpol_struct,st,sti
ON_ERROR,2

IF (N_PARAMS() EQ 0) THEN BEGIN
	print,'UTILISATION: interpol_struct,st,sti'
	print,'Interpolation lineaire des petis trous sur des valeurs horaires'
RETURN
ENDIF

tmp        = {jul:0.0D, val:0.0}
sti        = REPLICATE(tmp, N_ELEMENTS(st))

u   = TIMEGEN(N_ELEMENTS(st),UNITS="Hours",START=st[0].jul,FINAL=st[N_ELEMENTS(st.jul)-1].jul)
iz  = WHERE(FINITE(st.val) AND FINITE(st.jul))
x   = st[iz].jul
v   = st[iz].val
sti.jul = u
sti.val = INTERPOL(v,x,u)

;; Derniere modif: le 03/02/2004
END
     
