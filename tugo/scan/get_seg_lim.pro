FUNCTION get_seg_lim, seg
; fonction qui renvoie les limites geographique d'un segment de stype scan
minlon   = MIN(seg.lon, /NaN, MAX=maxlon)
minlat   = MIN(seg.lat, /NaN, MAX=maxlat)
limit    = [minlon,maxlon,minlat,maxlat]
RETURN, limit
END