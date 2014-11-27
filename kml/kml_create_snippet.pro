FUNCTION kml_create_snippet,str

 ;build the id array
nid    = (str.id).count() 
id     = ((str.id).keys()).toarray()
idref  = ((str.id).values()).toarray()
id_str = STRARR(nid)
FOR i=0,nid-1 DO id_str[i]=id[i]+'('+idref[i]+')'

;build the image array
nimg   = (str.img).count()
id_str = STRARR(nid)
FOR i=0,nid-1 DO id_str[i]=id[i]+'('+idref[i]+')'



snip=HASH('ID' ,id_str)
;snip=HASH('BM_ID'   ,STRCOMPRESS(STRING(FORMAT='(F12.6)',str.lon)+' / '+STRING(FORMAT='(F12.6)',str.lat),/REMOVE_ALL))
snip=snip+HASH('Coordinate' ,STRCOMPRESS(STRING(FORMAT='(F12.6)',str.lon)+' / '+STRING(FORMAT='(F12.6)',str.lat),/REMOVE_ALL))
snip=snip+HASH('Description' ,str.descr)
snip=snip+HASH('Reference',(str.ref).toarray())
snip=snip+HASH('Image',(str.img).toarray())

;PRINTF, UNIT, "Installation  : On the side wall a hut on the main Jetty"
;PRINTF, UNIT, "<hr />"
;PRINTF, UNIT, "Configuration : Radar gauge OTT at 5 minute sampling"
;PRINTF, UNIT, "<hr />"
;PRINTF, UNIT, "Images:"
;PRINTF, UNIT, "<hr />"
;PRINTF, UNIT, "<img src=""></img>"
;<img src="./tg1.jpg"></img>


RETURN,snip
END