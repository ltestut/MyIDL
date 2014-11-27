FUNCTION create_tmisfit, nsta, nwa, nan=nan
; creation d'une structure de type tide-misfit a *nsta* stations et *nwa* ondes
; /!\ cette structure contient une structure de tableau de structure 

 ;on creer la structure pour les nwa ondes
tmp1 = {name:'', da:!VALUES.F_NAN, dp:!VALUES.F_NAN, de:!VALUES.F_NAN}
tmp2 = REPLICATE(tmp1,nwa) 

 ;on ajoute les variables informatives de la structure
tmp3 = {lon:0.0D, lat:0.0D, code:0L,  name:'', org1:'', org2:'', rms:'' ,wave:tmp2} 

 ;-on replique la structure pour les n stations nsta
st = replicate(tmp3,nsta)

tmis = {info:'', rss:'', sta:st}
      
RETURN, tmis
END