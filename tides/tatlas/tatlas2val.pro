FUNCTION tatlas2val, tatlas, lon=lon, lat=lat, info=info, $
                      wave=wave, tresh_dist=tresh_dist,$
                      ifinite=ifinite, summary_list=summary_list,verbose=verbose
; Fonction qui renvoie la valeur interpolee aux points de coordonnees (lon,lat)
;  tatlas         : un atlas de maree au format structure de type tatlas
;  lon,lat,info   : vecteur contenant les longitudes et latitudes des pts a extraire et info=''
;  ifinite        : return the finite index where interpolation succeed
;  wave           : vecteur contenant les noms des ondes que l'on veut interpoler (sinon toutes celle de l'atlas)
;  tresh_dist     : seuil d'interpolation en metres
;  summary_list   : un nom de fichier qui contiendrait un resume de l'interpolation
; après une interpolation bilineaire (/amp et /pha pour les tatlas)
; pour les pts proches de la cote il faut mieux utiliser geomat2nearestpoint

 ;gestion des mots-clefs et initialisation
IF NOT KEYWORD_SET(lon) THEN STOP,'tatlas2val : /!\ need lon and lat keyword'
IF NOT KEYWORD_SET(info) THEN info=MAKE_ARRAY(N_ELEMENTS(lon),/STRING,VALUE='?')

IF NOT KEYWORD_SET(tresh_dist) THEN tresh_dist = 5000. ;distance minimum acceptable pour le pt de grille le plus proche
IF N_ELEMENTS(lon) NE N_ELEMENTS(lat) THEN STOP,'tatlas2val : /!\ lon et lat must have same dimension'
npts       = N_ELEMENTS(lon)

 ;on selectionne les pts valides de la geomatrice et on les recupere
gtype  = geovalid(tatlas, VLON=ilon, VLAT=ilat)
nvalid = N_ELEMENTS(ilon)

 ;on extrait amp,pha,wave_name de l'atlas de maree
CASE (gtype) OF
  10 : BEGIN
       IF NOT KEYWORD_SET(wave) THEN BEGIN 
         Xa    = tatlas.wave.amp 
         Xg    = tatlas.wave.pha
         wname = tatlas.wave.name
       ENDIF ELSE BEGIN
         iwave = -1
         FOR i=0,N_ELEMENTS(wave)-1 DO BEGIN
          index = WHERE(tatlas.wave.name EQ wave[i],cpt)
          IF (cpt NE 1) THEN STOP,'/!\ wrong wave name ? '
          iwave = [iwave,index]
         ENDFOR
          Xa    = tatlas.wave[iwave[1:*]].amp
          Xg    = tatlas.wave[iwave[1:*]].pha
          wname = tatlas.wave[iwave[1:*]].name
       ENDELSE     
  END
ENDCASE
nwa      = N_ELEMENTS(wname)  ;nbr d'onde a traiter
tab_val  = FLTARR(2,npts,nwa) ;init total array for Amp/Pha of the *npts* and *nwa* waves 

;################################################################################
IF KEYWORD_SET(verbose) THEN BEGIN
 TX    = 800    ; taille de la fenetre a animer
 window,0,title='ANIMATION',XSIZE=TX,YSIZE=TX
 PRINT,FORMAT="('ATLAS DEFINITION                          : ',A-45)",tatlas.info
 PRINT,FORMAT="('  -> Nlon x Nlat [total wave/ used waves] : ',I4,' x',I4,' [',I3,'/',I3,']')",$
              N_ELEMENTS(tatlas.lon),N_ELEMENTS(tatlas.lat),N_ELEMENTS(tatlas.wave.name),N_ELEMENTS(iwave)-1
 PRINT,FORMAT="('POINTS TO INTERPOLATE                     : ',I3)",N_ELEMENTS(lon)
 PRINT,"---BILINEAR INTERPOLATION"   
 A=BYTARR(TX,TX,npts) ;init the snap shot matrix
ENDIF
IF KEYWORD_SET(summary_list) THEN BEGIN
 OPENW,  UNIT,  summary_list  , /GET_LUN
 PRINTF, UNIT, "#---BILINEAR INTERPOLATION"
ENDIF
;################################################################################

FOR i=0,nwa-1 DO BEGIN
  FOR j=0,npts-1 DO BEGIN
   igeo_lon = igeo(tatlas.lon,lon[j])
   igeo_lat = igeo(tatlas.lat,lat[j])
   tab_val[0,j,i]=TRANSPOSE(DIAG_MATRIX(BILINEAR(Xa[*,*,i],igeo_lon,igeo_lat,MISSING=!VALUES.F_NAN))) ;on fait d'abord une interpolation bilineaire
   tab_val[1,j,i]=TRANSPOSE(DIAG_MATRIX(BILINEAR(Xg[*,*,i],igeo_lon,igeo_lat,MISSING=!VALUES.F_NAN))) ;on fait d'abord une interpolation bilineaire
   IF (KEYWORD_SET(verbose) AND (i EQ 0)) THEN BEGIN
      PRINT,FORMAT='(%"->pt %03d [%s,lon=%06.2f,lat=%06.2f,Wave = %03s] ==>  [ilon=%06.2f,ilat=%06.2f] / AMP=%6.2f & PHA=%6.2f")'$
           ,j,info[j],lon[j],lat[j],wname[i],igeo_lon,igeo_lat,tab_val[0,j,i],tab_val[1,j,i]
       map_geogrid,tatlas,LON=lon[j],LAT=lat[j],INFO=info[j],fscale=2;la matrice est decoupe avant d'etre tracee
       A[0,0,j]=TVRD()
   ENDIF
   IF KEYWORD_SET(summary_list) THEN PRINTF, UNIT, FORMAT='(%"-->Pts %03d [%15s,lon=%06.2f,lat=%06.2f] Wave = %03s / AMP=%6.2f & PHA=%6.2f")'$
                                ,j,info[j],lon[j],lat[j],wname[i],tab_val[0,j,i],tab_val[1,j,i]
  ENDFOR
ENDFOR
; This double loop fill the tab_val=[2,npts,nwa] with bilinear
inv     = WHERE(~FINITE(tab_val[0,*,0]),cpt_bilifail) ;index of not valid bilinear
n_bili  = npts-cpt_bilifail

;################################################################################
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,FORMAT='("Nb of bilinear succeed : ",I4," / ",I4)',n_bili,npts
 PRINT,"-> Failed list : ",inv
 PRINT,"---NEAREST POINT INTERPOLATION"
ENDIF
IF KEYWORD_SET(summary_list) THEN BEGIN
 PRINTF, UNIT,FORMAT='("Nb of bilinear succeed : ",I4," / ",I4)',n_bili,npts
 PRINTF, UNIT,"-> Failed list : ",inv
 PRINTF, UNIT,"---NEAREST POINT INTERPOLATION"
ENDIF
;################################################################################

npt_near = 0 ;init nearest counter
FOR i=0,cpt_bilifail-1 DO BEGIN   ;loop on all not valid bilinear interpolation
 arc_azimuth,lon[inv[i]],lat[inv[i]],tatlas.lon[ilon], tatlas.lat[ilat],d,az,/METERS ;calul de la distance ou point (lon,lat)
 min_d   = MIN(d,/NAN)
 IF (min_d LT tresh_dist) THEN BEGIN ;on impose une limite
  id_near = WHERE(d EQ min_d,cpt_near)
  IF (cpt_near GT 1) THEN id_near=id_near[0]
  id_lon  = ilon[id_near] &  id_lat  = ilat[id_near]
  tab_val[0,inv[i],*]  = Xa[ilon[id_near],ilat[id_near],*]
  tab_val[1,inv[i],*]  = Xg[ilon[id_near],ilat[id_near],*]
  npt_near++    
  IF KEYWORD_SET(verbose) THEN BEGIN
    PRINT,FORMAT='(%"->pt %03d [%s,lon=%06.2f,lat=%06.2f] ==> nearest grid pt position  [lon=%06.2f,lat=%06.2f,%6.2f km] / AMP=%6.2f & PHA=%6.2f ")',$
          inv[i],info[inv[i]],lon[inv[i]],lat[inv[i]],tatlas.lon[ilon[id_near]],tatlas.lat[ilat[id_near]],d[id_near]/1000.,tab_val[0,inv[i],0],tab_val[1,inv[i],0]
    map_geogrid,tatlas,LON=lon[inv[i]],LAT=lat[inv[i]],INFO=info[inv[i]],NEAREST=[ilon[id_near],ilat[id_near]],fscale=1.0
  ENDIF
  IF KEYWORD_SET(summary_list) THEN PRINTF, UNIT, FORMAT='(%"-->Pts %03d [%15s,lon=%06.2f,lat=%06.2f] ==> nearest grid pt position %06.2f,%06.2f,%6.2f km] / AMP=%6.2f PHA=%6.2f")',$
          inv[i],info[inv[i]],lon[inv[i]],lat[inv[i]],tatlas.lat[ilat[id_near]],d[id_near]/1000.,tab_val[0,inv[i],0],tab_val[1,inv[i],0]
  ENDIF ELSE BEGIN
   IF KEYWORD_SET(verbose) THEN PRINT,FORMAT='(%"->pt %03d [%15s,lon=%06.2f,lat=%06.2f] ==> nearest grid pt too far > %06.2f km [%06.2f] ")',$
                  inv[i],info[inv[i]],lon[inv[i]],lat[inv[i]],tresh_dist/1000.,min_d/1000.
   IF KEYWORD_SET(summary_list) THEN PRINTF, UNIT, FORMAT='(%"-->Pts %03d [%15s,lon=%06.2f,lat=%06.2f] ==> INETRPOLATION FAILED %6.2f km  > treshold=%6.2f km  ")',$
            inv[i],info[inv[i]],lon[inv[i]],lat[inv[i]],min_d/1000.,tresh_dist/1000.
  ENDELSE
ENDFOR 

 ;reduce val,lon,lat,info to the finite values 
s            = SIZE(tab_val,/DIMENSIONS)
id_nan       = WHERE(~FINITE(tab_val[0,*,0]),COMPLEMENT=ifinite,cpt_nan) ;index of NaN amplitude

;################################################################################
IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,FORMAT='(%"---INTERPOLATION SUMMARY ==>  total:%03d [bilinear=%03d + nearestGP=%03d + failed=%03d]")',$
                  npts,n_bili,npt_near,npts-(n_bili+npt_near)
                  Nx  = N_ELEMENTS(A[*,0,0])
  Ny  = N_ELEMENTS(A[0,*,0])
  Nt  = N_ELEMENTS(A[0,0,*])
   XINTERANIMATE, SET=[Nx, Ny, Nt], /SHOWLOAD 
  FOR I=0,(Nt-1) DO XINTERANIMATE, FRAME = I, IMAGE = A[*,*,I]
   XINTERANIMATE, /KEEP_PIXMAPS
ENDIF
IF KEYWORD_SET(summary_list) THEN BEGIN
  PRINTF, UNIT, FORMAT='(%"#---INTERPOLATION SUMMARY ==>  total:%03d [bilinear=%03d + nearestGP=%03d + failed=%03d]")',$
                  npts,n_bili,npt_near,npts-(n_bili+npt_near)
  IF (cpt_nan GE 1) THEN BEGIN
  FOR i=0,cpt_nan-1 DO PRINTF, UNIT, FORMAT='(%"-->Pts %03d [%15s,lon=%06.2f,lat=%06.2f] ==> Failed")',$
            id_nan[i],info[id_nan[i]],lon[id_nan[i]],lat[id_nan[i]]
  ENDIF
  CLOSE, UNIT
ENDIF
;################################################################################


IF (cpt_nan LT 1) THEN RETURN,tab_val
RETURN,tab_val[*,WHERE(~HISTOGRAM(id_nan,MIN=0, MAX=s[1]-1),/NULL),*]
END