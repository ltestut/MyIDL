PRO complete_zero,tab
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
print,'UTILISATION: cpz, tab'
print,'remplace tout les 9999. par des zero'
RETURN
ENDIF

idt  = WHERE(tab eq 999999.000,nt);Position des trous de la série, nt=nombre de trou

if (nt gt 0) then begin
tab[idt] = 0.
endif
return
END
     
