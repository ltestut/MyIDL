PRO kml_snippet,unit,snippet,description=description

If NOT KEYWORD_SET(description) THEN description='test'
PRINTF, UNIT, '<Snippet maxLines="1">',description,'</Snippet>'
PRINTF, UNIT, "<description>"
PRINTF, UNIT, "<![CDATA["
FOREACH key,snippet.keys() DO BEGIN
 IF (key EQ 'Image') THEN BEGIN
   FOR i=0,N_ELEMENTS(snippet[key])-1 DO PRINTF, UNIT,"<h1>",key,'-',STRING(i,FORMAT='(I02)')," :</h1>","<img src=",(snippet['Image'])[i],".jpg></img>" 
 ENDIF ELSE BEGIN
 PRINTF, UNIT, "<h1>",key,' :</h1><b><font color="blue">',snippet[key],"</b></font>"
 PRINTF, UNIT, "<hr />"
 ENDELSE
endforeach
PRINTF, UNIT, "]]>"
PRINTF, UNIT, "</description>"
END
;PRINTF, UNIT, "<img src=""></img>"
;<img src="./tg1.jpg"></img>
