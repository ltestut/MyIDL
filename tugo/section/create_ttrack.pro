FUNCTION create_ttrack, npt, nt, nan=nan
; creation d'une structure de type tugo_track a *npt* points de coordonnees et *nt* valeurs temporelle
; /!\ cette structure contient une structure de tableau de structure 
tmp  = {lon:0.0D, lat:0.0D, depth:0.0, dist:0.0 , $
        h:FLTARR(nt), u:FLTARR(nt), v:FLTARR(nt),$
        jul:DBLARR(nt) ,val:FLTARR(nt)}

 ;-on replique la structure pour les npt
st = replicate(tmp,npt)

 ;on ajoute les variables informatives de la structure
st = {name:'', filename:'', val_info:''  ,pt:st} 
      
RETURN, st
END