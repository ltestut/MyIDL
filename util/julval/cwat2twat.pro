FUNCTION cwat2twat, cond, temp=temp, pres=pres
; function du compute the salinity in PSU from conductivity in mmho/cm (or mS/cm)
; from water temperature (degC) and from pressure in dbar 
; originally created by Philippe Techine (version 0.0 - octobre 1999)
; from sal81 de Gilles Reverdin (octobre 1979)
; cf. Unesco technical papers in marine science 44, Algorithms for
; computation of fundamental properties of seawater, Unesco 1983

IF NOT KEYWORD_SET(temp) THEN temp=15.
IF NOT KEYWORD_SET(pres) THEN pres=10. ;calcul par defaut a 10 decibar (10 m)


; calcul du rapport de conductivite
  r=cond/42.909d0

; passage de la pression en decibar
  pres=pres/100.

; equation (3) fonction de la temperature
; valable dans la gamme -2 a +35 degres C
 rt35=(((1.0031d-9*temp - 6.9698d-7)*temp + 1.104259d-4)*temp $
         + 2.00564d-2)*temp + 0.6766097d0

; equation (4) fonction de la pression et de la temperature
      c=((3.989d-15*pres - 6.370d-10)*pres + 2.070d-5)*pres
      b=(4.464d-4*temp + 3.426d-2)*temp + 1.d0
      a=-3.107d-3*temp + 0.4215d0
      rt=r/(rt35*(1.d0 + c/(b + a*r)))

; test si la valeur trouvee est negative pour les equations (1) et (2)
ineg = WHERE(rt LT 0.,cpt) 
IF (cpt GE 1) THEN rt[ineg]=0.d0
 rt=sqrt(rt)

; calcul intermediaire pour l'equation (2)
  dt=temp-15.d0

; equations (1) et (2) valables dans les gammes de temperture -2 a +35 degres C
;                                            et de salinite 2 a 42 psu
   sal=((((2.7081d0*rt - 7.0261d0)*rt + 14.0941d0)*rt + 25.3851d0)*rt - 0.1692d0)*rt + 0.0080d0$
     +(((((-0.0144d0*rt + 0.0636d0)*rt - 0.0375d0)*rt - 0.0066d0)*rt $
     - 0.0056d0)*rt + 0.0005d0) * (dt/(1.d0 + 0.0162d0*dt))
RETURN, sal     
END