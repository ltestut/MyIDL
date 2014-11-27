PRO geo_valid,geo, vlon=vlon, vlat=vlat, verbose=verbose
; return valid index for longitudes and latitudes 

 ;type of geomatrix
gtype = geo_type(geo)

;on selectione le champ 2D
IF odd(gtype['type']) THEN H=geo.val[*,*,0] ELSE H=geo.val[*,*]
s      = SIZE(H)
ncol   = s[1]
nrow   = s[2]
index  = WHERE(FINITE(H),/L64,nvalid) ;index of definite values
vlon   = index MOD ncol               
vlat   = index/ncol                   

IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,FORMAT="('geomatrice de type         : ',I2)",gtype['type']
  PRINT,FORMAT="('dimension de la geomatrice : ',I5,I5)",s[1],s[2]
  PRINT,FORMAT="('nbre de donnees valid/total: ',I12,'/',I12)",nvalid,s[1]*s[2]
ENDIF
END