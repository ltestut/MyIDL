FUNCTION create_stp, nlev, nt
; create a single profile structure :  of *nlevel* points et *nt* time values

tmp  = {level:0,jul:DBLARR(nt), val:MAKE_ARRAY(nt,/FLOAT,VALUE=!VALUES.F_NAN),$
                                  u:MAKE_ARRAY(nt,/FLOAT,VALUE=!VALUES.F_NAN),$
                                  v:MAKE_ARRAY(nt,/FLOAT,VALUE=!VALUES.F_NAN)}
                         
;- on replique la structure pour les npt
stp  = replicate(tmp,nlev)


 ;on ajoute les variables informatives de la structure
stp = {info:'', name:'', filename:'',$
       lon:0.0,   lat:0.0, nlev:0L,$   
       lev:stp} 

RETURN, stp
END