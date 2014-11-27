PRO remove_monthly_annual_mean_cycle, st, stf

IF (N_PARAMS() EQ 0) THEN BEGIN
 print, 'UTILISATION:
 print, 'remove_monthly_annual_mean_cycle, st, stf'
 print, ''
 print, 'INPUT: st   --> str de type {jul,val}'
 print, 'OUTPUT: stf --> moyenne mensuelle - cycle annuel'
RETURN
ENDIF

daily_mean, st, std
daily_annual_mean_cycle, st, sta
N    = N_ELEMENTS(std)
tmp  = {jul:0.0D ,val:0.0}
stf  = REPLICATE(tmp,N)
stf  = std
ID   = WHERE(FINITE(std.val))
stf[ID].val = std[ID].val - sta[ID].val


;;Derniere modif le 13/05/2003
END
