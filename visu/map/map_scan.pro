PRO map_scan, seg, seg2, seg3, limit=limit, proj=proj, num=num, id=id, point=point, label=label, _EXTRA=_EXTRA
; Programme pour tracer les donnees d'une structure de type segment 
; commes les *.scan ou les sections.dat

;gestion des mots-clefs 
IF NOT KEYWORD_SET(proj) THEN proj='stereo'
IF NOT KEYWORD_SET(limit) THEN limit = get_seg_lim(seg) 
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin] 

map      = MAP(proj,LIMIT=limit,_EXTRA=_EXTRA)
;grid  = MAP.MAPGRID

;coast = MAPCONTINENTS(_EXTRA=_EXTRA)
cst   = load_scan(/DOM,/ANT)
cont  = load_scan(/CONT,/MERTZ, /B9B)

coast =POLYLINE(cst.lon,cst.lat,CONNECTIVITY=cst.con,TARGET=map,$
          COLOR='black',/DATA,THICK=2,$
          /OVERPLOT) 
coast =POLYLINE(cont.lon,cont.lat,CONNECTIVITY=cont.con,TARGET=map,$
          COLOR='black',/DATA,THICK=2,$
          /OVERPLOT) 

; Carte global mercator

p=POLYLINE(seg.lon,seg.lat,CONNECTIVITY=seg.con,TARGET=map,$
           COLOR='grey',/DATA,THICK=1,$
           LINESTYLE=2,$
           /OVERPLOT)

CASE N_PARAMS() OF
   1 : 
   2 : BEGIN
           p2=POLYLINE(seg2.lon,seg2.lat,CONNECTIVITY=seg2.con,TARGET=map,$
           COLOR='red',/DATA,THICK=0.5,$
           LINESTYLE=0,$
           /OVERPLOT)
       END
   3 : BEGIN
           p2=POLYLINE(seg2.lon,seg2.lat,CONNECTIVITY=seg2.con,TARGET=map,$
           COLOR='red',/DATA,THICK=0.5,$
           LINESTYLE=0,$
           /OVERPLOT)
           p3=POLYLINE(seg3.lon,seg3.lat,CONNECTIVITY=seg3.con,TARGET=map,$
           COLOR='blue',/DATA,THICK=0.5,$
           LINESTYLE=0,$
           /OVERPLOT)
       END
ENDCASE

IF KEYWORD_SET(num) THEN BEGIN
FOR i=0,N_ELEMENTS(seg.id)-1 DO s=SYMBOL(seg.lon[2*i],seg.lat[2*i],'star',/DATA,$
                                            /SYM_FILLED,SYM_COLOR='red',LABEL_STRING=STRING(i),$
                                            LABEL_POSITION='C')
ENDIF

;IF KEYWORD_SET(id) THEN BEGIN
; icpt=0
; FOR i=0,N_ELEMENTS(seg.id)-1 DO BEGIN
;   print,seg.id[i]
;   s=SYMBOL(seg.lon[icpt],seg.lat[icpt],'circle',/DATA,$
;             /SYM_FILLED,SYM_COLOR='red',$
;             LABEL_FONT_SIZE=16,LABEL_STRING=STRCOMPRESS(seg.id[i],/REMOVE_ALL),LABEL_POSITION='L')
;   icpt=icpt+seg.nbr[i]
;ENDFOR
;ENDIF
IF NOT KEYWORD_SET(label) THEN label=INDGEN(N_ELEMENTS(seg.lon))
IF KEYWORD_SET(point) THEN  s=SYMBOL(seg.lon,seg.lat,'+',/DATA,/SYM_FILLED,SYM_COLOR='red',LABEL_STRING=label)



END
