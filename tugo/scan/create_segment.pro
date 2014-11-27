FUNCTION create_segment, nseg , ncoord
; creation d'une structure pour stocker les donnees de type segment
;  creer par XCAN (.scan)
seg = {id:LON64ARR(nseg), nbr:LON64ARR(nseg), con:LON64ARR(ncoord+nseg),$
       lon:DBLARR(ncoord), lat:DBLARR(ncoord)}
RETURN,seg
END