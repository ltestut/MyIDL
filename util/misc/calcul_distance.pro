FUNCTION calcul_distance,lat_a_in,lon_a_in,lat_b_in,lon_b_in

;*********************************************************
;
;    fonction permettant de calculer la
;    distance entre deux points sur la sphere
;
;*********************************************************

pi=ACOS(-1d0)
deg_rad= (2.*pi)/360.


;   constante utile pour la suite du programme
;   ici le rayon de la terre (km)

RT=6378.137

;   conversion en radian
lon_a=lon_a_in*deg_rad
lat_a=lat_a_in*deg_rad
lat_b=lat_b_in*deg_rad
lon_b=lon_b_in*deg_rad

;   calcul de la distance entre les deux points consideres

interm=(COS(lon_a)*COS(lat_a)*COS(lon_b)*COS(lat_b)) + $
  (SIN(lon_a)*COS(lat_a)*SIN(lon_b)*COS(lat_b)) + $
  (SIN(lat_a)*SIN(lat_b))
	
dist=RT*ACOS(interm)

RETURN, dist
END
