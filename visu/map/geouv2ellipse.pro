PRO geouv2ellipse,geo,a,b,phi,e,scale=scale
; calcul des parametres de l'ellipse de maree a partir d'une matrice de type :
; UV tide => geo.u[nx,ny] geo.v[nx,ny] geo.ug[nx,ny] geo.vg[nx,ny]

IF NOT KEYWORD_SET(scale) THEN scale=100.

ug = rad(geo.ug)
vg = rad(geo.vg)
x1 = geo.u*scale*geo.u*scale+geo.v*scale*geo.v*scale
x2 = 2*geo.u*scale*geo.v*scale*SIN(ug-vg)
t1 = ATAN((geo.v*COS(vg)-geo.u*SIN(ug))/(geo.u*COS(ug)+geo.v*SIN(vg)))
t2 = ATAN((geo.v*COS(vg)+geo.u*SIN(ug))/(geo.u*COS(ug)-geo.v*SIN(vg)))

;calcul du 1/2 grand-axe a, du 1/2 petit-axe b et de l'exentircite e de l'ellipse
a=0.5*(SQRT(x1+x2)+SQRT(x1-x2))
b=0.5*(SQRT(x1+x2)-SQRT(x1-x2))
e=SQRT(a*a-b*b)/a


;calcul de phi
phi = deg(((t1+t2)/2))




END