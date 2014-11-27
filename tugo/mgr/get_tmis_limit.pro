FUNCTION get_tmis_limit,tmis,verbose=verbose
;fonction qui renvoie les limites d'extension geographique d'un fichier tmis
minlon   = MIN(tmis.sta.lon, /NaN, MAX=maxlon)
minlat   = MIN(tmis.sta.lat, /NaN, MAX=maxlat)
limites  = [minlon,maxlon,minlat,maxlat]
IF KEYWORD_SET(verbose) THEN PRINT,FORMAT='(A11,X,4(F7.3,A2))',"Limite geo=",minlon,'E/',maxlon,'E/',minlat,'N/',maxlat,'N'
return, limites
END