PRO plot_homage_info,st, wave=wave, station=station

IF NOT KEYWORD_SET(wave) THEN wave='M2'
IF NOT KEYWORD_SET(station) THEN station='station'

iwave = WHERE(st[0].name EQ wave)
iwave=0
title='Evolution of '+st[0].name[iwave]+' for '+station

head=TEXT(0.5,0.95,title,ALiGN=0.5,FONT_SIZE=18)

pvalid=st.ndata/8760.
tresh=0.6
id = WHERE(pvalid GE 0.6,COMPLEMENT=idn,count)


pformat='sk-2'

moy   = plot(st.year,st.mean      ,pformat,YTITLE='Mean Sea Level' ,POSITION=[0.10,0.70,0.45,0.90],/CURRENT)
pour  = barplot(st.year,st.ndata/8760.,FILL_COLOR='grey'           ,POSITION=[0.55,0.70,0.90,0.90],YRANGE=[0,1],/CURRENT)
IF (count GE 2) THEN BEGIN

amp  = plot(st[id].year,st[id].amp[iwave],pformat,YTITLE='Amplitude'      ,POSITION=[0.10,0.20,0.45,0.60],/CURRENT)
pha  = plot(st[id].year,st[id].pha[iwave],pformat,YTITLE='Phase'          ,POSITION=[0.55,0.20,0.90,0.60],/CURRENT)
ENDIF

END
