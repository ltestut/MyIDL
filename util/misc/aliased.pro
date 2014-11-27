FUNCTION aliased, period=period, ech=ech
; retourne la frequence d'echantillonnage a partir de 
; period : la periode du signal (en seconde)
; ech    : echantillonnage avec lequel est observe ce signal (en seconde)
 
freq_ech=(2.*!pi)/ech
freq_sig=(2.*!pi)/period

N=FLOOR(freq_sig/freq_ech+1/2)
freq_a=ABS(N*freq_ech-freq_sig)

IF (freq_a EQ 0) THEN print,"Frequence d'aliasing infinie"
print,freq_ech,freq_sig,N,freq_a


aliased_period=(2*!PI)/freq_a ; en seconde

print,"Aliased period : ",aliased_period,' secondes'
print,"Aliased period : ",aliased_period/60.,' minutes'
print,"Aliased period : ",aliased_period/(60*60.),' heures'
print,"Aliased period : ",aliased_period/(60*60*24.),' jours'


RETURN, aliased_period 
END