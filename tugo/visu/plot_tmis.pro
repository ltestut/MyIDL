PRO plot_tmis, tmis
; prog qui permet de tracer une structure de validation de model de type tmis
minlon   = MIN(tmis.sta.lon, /NaN, MAX=maxlon)
minlat   = MIN(tmis.sta.lat, /NaN, MAX=maxlat)
limit    = [minlon,maxlon,minlat,maxlat]
dl       = 1. ;on ajout 2deg de chaque cote des limites
limit    = [limit[0]-dl,limit[1]+dl,limit[2]-dl,limit[3]+dl]
print,limit
limit    = change2idllimit(limit) ;convertit du format [lonmin,lonmax,latmin,latmax] au format [lonmax,latmax,lonmin,latmin]

IF NOT KEYWORD_SET(proj) THEN proj='mercator'
m  = MAP(proj,LIMIT=limit,FILL_COLOR='white',$  
         TRANSPARENCY=0,LABEL_SHOW=0,/BOX_AXES,$
         TITLE='LOCATION MAP OF VALIDATION POINTS')
g  = MAPGRID(GRID_LONGITUDE = 2.,GRID_LATITUDE = 2., LINESTYLE='dash',COLOR='grey')
c  = MAPCONTINENTS(FILL_COLOR="antique white",TRANSPARENCY=0,_EXTRA=_EXTRA)

FOR i=0,N_ELEMENTS(tmis.sta.lon)-1 DO BEGIN
print,STRCOMPRESS(tmis.sta[i].code,/REMOVE_ALL)
s   = SYMBOL(tmis.sta[i].lon,tmis.sta[i].lat,'circle',/DATA,$
      ;TARGET=m,$
      SYM_SIZE=1.0,SYM_THICK=1.0,SYM_COLOR=[125,125,125],$
      SYM_FILLED=1,SYM_FILL_COLOR='black',$
      SYM_TRANSPARENCY=0,$
      LABEL_STRING=STRCOMPRESS(tmis.sta[i].code,/REMOVE_ALL),LABEL_FONT_SIZE=10.,LABEL_COLOR='red',$
      LABEL_POSITION='Right',LABEL_FILL_BACKGROUND=0,LABEL_TRANSPARENCY=10,$
      /OVERPLOT)
ENDFOR


m.Save, !toto+'.pdf', /APPEND

; creation d'un objet a n_onde (1 onde par page)
nplot = N_ELEMENTS(tmis.sta[0].wave.name)
p     = OBJARR(nplot)

FOR i = 0, nplot-1 DO BEGIN
p[i]  = POLARPLOT(tmis.sta.wave[i].da,tmis.sta.wave[i].dp,$
                TITLE=tmis.sta[0].wave[i].name+'  ['+tmis.sta[0].org1+' / '+tmis.STA[0].org2+']',$
                LINESTYLE='none',SYMBOL='Circle',SYM_COLOR='red',SYM_SIZE=2,/SYM_FILLED,$
                TRANSPARENCY=50,$
                XRANGE=[MIN(tmis.sta.wave.da),MAX(tmis.sta.wave.da)],YRANGE=[-10.,10.]$
               )
t = TEXT(tmis.sta.wave[i].da,tmis.sta.wave[i].dp,STRCOMPRESS(tmis.sta.code,/REMOVE_ALL),$
             TARGET=p,/DATA, ALIGNMENT=0., VERTICAL_ALIGNMENT=0.,ORIENTATION=0., $
             FONT_SIZE=14,COLOR='black')

  IF (i LE (nplot-2)) THEN p[i].Save, !toto+'.pdf', /APPEND
ENDFOR

 p[nplot-1].Save, !toto+'.pdf', /APPEND, /CLOSE

print,!toto+'.pdf'
END