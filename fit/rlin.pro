PRO rlin, st, str

IF (N_PARAMS() EQ 0) THEN BEGIN
   print, 'rlin, st, str'
   print, ''
   print, 'INPUT : st   --> structure de {jul,val}'
   print, 'OUTPUT: str  --> droite de type {jul,val}'
RETURN
ENDIF

iz  = WHERE(FINITE(st.jul) and FINITE(st.val))
rl  = LINFIT(st[iz].jul,st[iz].val,SIGMA=err)
print,'Tendance =',rl(1)*365,'+/-',err(1)*365
tmp = {jul:0.0D, val:0.0}
str = REPLICATE(tmp,N_ELEMENTS(iz))
str.jul  = st[iz].jul
str.val  = (rl(0)  + rl(1)*st[iz].jul)

END
