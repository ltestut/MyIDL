FUNCTION create_tatlas,  nlon, nlat, nwa, uv=uv, huv=huv, nan=nan
; creation d'une structure de type tide-atlas a *nwa* ondes
; /!\ cette structure contient une structure de tableau de structure 

 ;creation de la structre wave de type h,uv ou huv (h par defaut)
wtmp = {name:'',  filename:'', amp:FLTARR(Nlon,Nlat), pha:FLTARR(Nlon,Nlat)}
IF KEYWORD_SET(huv) THEN wtmp = {name:'',  filename:'', amp:FLTARR(Nlon,Nlat), pha:FLTARR(Nlon,Nlat),ua:FLTARR(Nlon,Nlat),  ug:FLTARR(Nlon,Nlat), va:FLTARR(Nlon,Nlat),  vg:FLTARR(Nlon,Nlat) }
IF KEYWORD_SET(uv)  THEN wtmp = {name:'',  filename:'', ua:FLTARR(Nlon,Nlat),  ug:FLTARR(Nlon,Nlat), va:FLTARR(Nlon,Nlat),  vg:FLTARR(Nlon,Nlat) }

 ;replication de la structure sur nwa onde
st = replicate(wtmp,nwa)

 ;on ajoute les variables geographiques commune a la structure
tatlas = {lon:FLTARR(Nlon), lat:FLTARR(Nlat), $
          mode:'', info:'', obc:'', bathy:'', $
          assimilation:'', type:0, wave:st} 

RETURN, tatlas
END