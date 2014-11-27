FUNCTION tatlas_diff,tatlas1,tatlas2,wave=wave,abs=abs
; compute the difference of two tide atlas on the same grid for one given wave 

IF NOT KEYWORD_SET(wave) THEN wave='M2'
jc          = COMPLEX(0,1)                                   ;i complexe

 ;info on the size of the input structures 
nwaves     = N_ELEMENTS(tatlas1.wave)
ntags      = N_TAGS(tatlas1)
ntags_wave = N_TAGS(tatlas1.wave)

 ;create new atlas, copy new lon, lat and common fields 
t_diff     = create_tatlas(N_ELEMENTS(tatlas1.lon),N_ELEMENTS(tatlas1.lat),1)
tab_tags   = WHERE(TAG_NAMES(tatlas1) NE 'LON' AND TAG_NAMES(tatlas1) NE 'LAT' AND TAG_NAMES(tatlas1) NE 'WAVE',cpt)
FOR i=0,cpt-1 DO t_diff.(tab_tags[i]) = t_diff.(tab_tags[i])
t_diff.info = tatlas1.info+' - '+tatlas2.info
t_diff.lon  = tatlas1.lon
t_diff.lat  = tatlas1.lat

id1 = WHERE(tatlas1.wave.name EQ wave,cpt1)
id2 = WHERE(tatlas2.wave.name EQ wave,cpt2)
IF (cpt1 NE 1 AND cpt2 NE 1) THEN STOP,'/!\ wrong wave name ? '
Xa    = tatlas1.wave[id1].amp-tatlas2.wave[id2].amp
Xg    = tatlas1.wave[id1].pha-tatlas2.wave[id2].pha

IF KEYWORD_SET(abs) THEN BEGIN
Z1  = tatlas1.wave[id1].amp*EXP(jc*RAD(tatlas1.wave[id1].pha))   
Z2  = tatlas2.wave[id2].amp*EXP(jc*RAD(tatlas2.wave[id2].pha))   
Xa  = ABS(z1-z2)                                                                ;|Z1-Z2| difference complexe
ENDIF

t_diff.wave.amp  = Xa
t_diff.wave.pha  = Xg
t_diff.wave.name = wave

RETURN,t_diff
END