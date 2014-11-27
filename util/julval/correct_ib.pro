FUNCTION correct_ib, stpb, stpa, rho=rho, g=g
IF NOT KEYWORD_SET(rho) THEN rho=1.02782
IF NOT KEYWORD_SET(g)   THEN   g=9.78049


deno = rho*g      ;denominateur
; synchronisation des 2 series 
;  stpb le presssion de fond doit etre corrigee de la maree 
synchro_julval, stpb, stpa, spb, spa
Nd = N_ELEMENTS(spb.val)
; calcul du niveau de la mer
h   = 10.*(spb.val-spa.val)/deno    ;niv. de la mer en cm
dh  = h - MEAN(h)  

dib = -(spa.val-MEAN(spa.val))/deno

plot,dh,dib,psym=1

stc     = create_julval(Nd)
stc.jul = spb.jul
stc.val = h
RETURN, stc
END 