PRO complete_prevision,tab,prev
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
print,'UTILISATION: cpa,tab,prev'
print,'Pour completer une serie de donne tab a partir'
print,'de sa previson'
RETURN
ENDIF

print,'ATTENTION A CE QUE LE TABLEAU ET LA PREVI COMMENCE A LA MEME DATE !!'
print,'tab  =',size(tab,/dimension)
print,'prev =',size(prev,/dimension)
idt   = WHERE(tab eq 999999.000,nt)           ;indice des trous de la serie
print,'nombre de trou de la serie tab',nt

FOR J=0,nt-1 DO BEGIN

tab[idt(J)] = prev[idt(J)]

END

END
