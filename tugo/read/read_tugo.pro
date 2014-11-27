FUNCTION read_tugo, filename, tide=tide, uv=uv, huv=huv,transport=transport, var_name=var_name,  verbose=verbose,  info=info
; lecture de fichier netcdf de sortie de tugo et mise dans une structure de type geomat
; on peut lire des fichiers de sorties de modele de maree (sequentiel ou spectral) ainsi
; que des sortie de modele forces par le vent et la pression on peut aussi extraire des parametres comme la bathy
; sinon on stocke dans une geomatrice de type geo.val
; /tide : permet de lire un ntcdf de type sortie de modele de maree et stocke dans une strucutre tgeomat (champ AMP et PHA)

 ;ouvertur du fichier netcdf (.nc) et lecture des variable lon,lat
fid  = NCDF_OPEN(filename)     ; ouverture du fichier
NCDF_VARGET, fid, NCDF_VARID(fid,'lon'),  lon  ;lon(nlon,nlat) ou lon(x,y)
NCDF_VARGET, fid, NCDF_VARID(fid,'lat'),  lat  ;lat(nlon,nlat) ou lat(x,y)
  
 ;recuperation des dimensions x et y
dim_x= N_ELEMENTS(lon[*,0]) ;ncdf_read_dim(NAME1='x', NAME2='X', NCDF_ID=fid)
dim_y= N_ELEMENTS(lon[0,*]) ;ncdf_read_dim(NAME1='y', NAME2='Y', NCDF_ID=fid)

IF NOT KEYWORD_SET(tide) THEN tide=0

CASE (tide) OF
   1 : BEGIN                                               ;NETCDF DE TYPE MAREE
       IF NOT KEYWORD_SET(uv) THEN BEGIN                ; type Ha,Hg
         IF NOT KEYWORD_SET(var_name) THEN var_name='H'
         geo      = create_geomat(dim_x,dim_y, /tide)      ; initialisation de la structure geomat geo(lon,lat)
         geo.lon  = lon[*,0]  &  geo.lat = lat[0,*]
         ineg     = WHERE(geo.lon LT 0.,cneg)
         IF (cneg GT 0) THEN geo.lon[ineg]=360+geo.lon[ineg] ;on passe toute les longitudes en 0-360
         ;lecture de la variable specifie dans le mot-cle : var_name
         NCDF_VARGET, fid, NCDF_VARID(fid,var_name+'a'), var_amp
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_name+'a'), 'missing_value', flg_a
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_name+'a'), 'scale_factor', scl_a
         NCDF_VARGET, fid, NCDF_VARID(fid,var_name+'g'), var_pha
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_name+'g'), 'missing_value', flg_g
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_name+'g'), 'scale_factor', scl_g
         IF (flg_a GT 0 AND flg_g GT 0 ) THEN BEGIN
           Xa = flag_matrix(var_amp,seuil=flg_a) ;/!\ au difference de flag des sorties de modeles
           Xg = flag_matrix(var_pha,seuil=flg_g) ;/!\ au difference de flag des sorties de modeles
         ENDIF ELSE BEGIN
           Xa = flag_matrix(var_amp,seuil=flg_a, /less)
           Xg = flag_matrix(var_pha,seuil=flg_g, /less)
         ENDELSE    
         Xa    = TEMPORARY(Xa)*scl_a &  Xg = TEMPORARY(Xg)*scl_g
         neg   = WHERE( Xg LT 0. , cnt_neg)                            ; passage de -180/180 à 0/360
         IF (cnt_neg GT 0 ) THEN Xg[neg]=Xg[neg]+360
         geo.amp = Xa & geo.pha  = Xg
       ENDIF ELSE BEGIN                                   ; type Ua,Ug,Va,Vg
         geo      = create_geomat(dim_x,dim_y, /tide, /UV) ; initialisation de la structure geomat geo(lon,lat)
         geo.lon  = lon[*,0]
         geo.lat  = lat[0,*]
         ineg     = WHERE(geo.lon LT 0.,cneg)
         IF (cneg GT 0) THEN geo.lon[ineg]=360+geo.lon[ineg] ;on passe toute les longitudes en 0-360
         ;amplitude
         var_U='U' & var_V='V'
         NCDF_VARGET, fid, NCDF_VARID(fid,var_U+'a'), U_amp
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_U+'a'), 'missing_value', flg_ua
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_U+'a'), 'scale_factor', scl_ua
         NCDF_VARGET, fid, NCDF_VARID(fid,var_V+'a'), V_amp
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_V+'a'), 'missing_value', flg_va
         NCDF_ATTGET, fid, NCDF_VARID(fid,var_V+'a'), 'scale_factor', scl_va
         IF (flg_ua GT 0) THEN BEGIN
           Ua = flag_matrix(U_amp,seuil=flg_ua) ;/!\ au difference de flag des sorties de modeles
           Va = flag_matrix(V_amp,seuil=flg_va) ;/!\ au difference de flag des sorties de modeles     
         ENDIF ELSE BEGIN
           Ua = flag_matrix(U_amp,seuil=flg_ua, /less)
           Va = flag_matrix(V_amp,seuil=flg_va, /less)
        ENDELSE    
        Ua = TEMPORARY(Ua)*scl_ua & Va =TEMPORARY(Va)*scl_va
        geo.u = Ua & geo.v = Va    
        ;phase
        NCDF_VARGET, fid, NCDF_VARID(fid,var_U+'g'), U_pha
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_U+'g'), 'missing_value', flg_ug
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_U+'g'), 'scale_factor', scl_ug
        NCDF_VARGET, fid, NCDF_VARID(fid,var_V+'g'), V_pha
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_V+'g'), 'missing_value', flg_vg
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_V+'g'), 'scale_factor', scl_vg
        IF (flg_ug GT 0) THEN BEGIN
           Ug = flag_matrix(U_pha,seuil=flg_ug) ;/!\ au difference de flag des sorties de modeles
           Vg = flag_matrix(V_pha,seuil=flg_vg) ;/!\ au difference de flag des sorties de modeles
        ENDIF ELSE BEGIN
           Ug = flag_matrix(U_pha,seuil=flg_ug, /less)
           Vg = flag_matrix(V_pha,seuil=flg_vg, /less)
        ENDELSE
        Ug   = TEMPORARY(Ug)*scl_ug & Vg = TEMPORARY(Vg)*scl_vg
        negU = WHERE( Ug LT 0. , cnt_negU)                  ; passage de -180/180 à 0/360
        negV = WHERE( Vg LT 0. , cnt_negV)                   ; passage de -180/180 à 0/360     
        IF (cnt_negU GT 0 ) THEN Ug[negU]=Ug[negU]+360
        IF (cnt_negV GT 0 ) THEN Vg[negV]=Vg[negV]+360
        geo.ug  = Ug & &geo.vg  = Vg
        iflagU  = WHERE(geo.ug EQ 0., cflagU)
        iflagV  = WHERE(geo.vg EQ 0., cflagV)
        IF (cflagU GT 0) THEN geo.ug[iflagU]=!VALUES.F_NAN
        IF (cflagV GT 0) THEN geo.ug[iflagV]=!VALUES.F_NAN
       ENDELSE
       ;infos
       geo.wave = get_wave_name(FILE_BASENAME(filename))
       IF NOT KEYWORD_SET(INFO) THEN info = FILE_BASENAME(FILE_DIRNAME(filename))
       geo.info=info
       geo.filename=filename
       ;verbose
       IF KEYWORD_SET(verbose) THEN BEGIN
       lim_geo=STRING(MIN(geo.lon),FORMAT='(F8.2)')+'/'+STRING(MAX(geo.lon),FORMAT='(F8.2)')+'/'+STRING(MIN(geo.lat),FORMAT='(F8.2)')+'/'+STRING(MAX(geo.lat),FORMAT='(F8.2)')
       print,'tugo2geomat  : limite geographique          = ',STRCOMPRESS(lim_geo)     
       print,'tugo2geomat  :     WAVE                     = ',geo.wave
       print,'tugo2geomat  :     INFO                     = ',geo.info
       ENDIF    
  END
  0 : BEGIN                                                ;NETCDF DE TYPE AUTRE
      IF KEYWORD_SET(huv) THEN BEGIN
        ;lecture des variables de elevation & courant
        IF NOT KEYWORD_SET(var_name) THEN var_name='elevation'
        NCDF_VARGET, fid, NCDF_VARID(fid,var_name), var
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_name), 'missing_value', flg_val
;        NCDF_ATTGET, fid, NCDF_VARID(fid,var_name), 'scale_factor', scl
        IF KEYWORD_SET(transport) THEN BEGIN
          NCDF_VARGET, fid, NCDF_VARID(fid,'Hubar'), varu
          NCDF_VARGET, fid, NCDF_VARID(fid,'Hvbar'), varv  
        ENDIF ELSE BEGIN
          NCDF_VARGET, fid, NCDF_VARID(fid,'ubar'), varu
          NCDF_VARGET, fid, NCDF_VARID(fid,'vbar'), varv
        ENDELSE
        NCDF_ATTGET, fid, NCDF_VARID(fid,'ubar'), 'missing_value', flg
        ;determination des dimensions de la variable (2D ou 3D)
        s     = SIZE(varu)
        dim_t = 0
        IF (s[0] NE 2) THEN BEGIN
          NCDF_VARGET, fid,NCDF_VARID(fid,'time') , time 
          dim_t    = N_ELEMENTS(time)
          geo      = create_geomat(dim_x,dim_y,dim_t,/HUV) ; initialisation de la structure geomat geo(lon,lat,time)
          geo.u    = flag_matrix(varu,seuil=flg)
          geo.v    = flag_matrix(varv,seuil=flg)
          geo.val  = flag_matrix(var ,seuil=flg_val)
          geo.jul  = time/(24.*3600.)+JULDAY(1,1,1950,0,0,0)
       ENDIF ELSE BEGIN ;cas des matrice temporelle moyenne avec ncra par ex. 
          geo      = create_geomat(dim_x,dim_y,/HUV) ; initialisation de la structure geomat geo(lon,lat)
          geo.u    = flag_matrix(varu,seuil=flg)
          geo.v    = flag_matrix(varv,seuil=flg)
          geo.val  = flag_matrix(var ,seuil=flg_val)
          geo.info = info
       ENDELSE 
       geo.filename = filename
       geo.lon      = lon[*,0]
       geo.lat      = lat[0,*]
       ineg    = WHERE(geo.lon LT 0.,cneg)
       IF (cneg GT 0) THEN geo.lon[ineg]=360+geo.lon[ineg] ;on passe toute les longitudes en 0-360
       ;verbose  
       IF KEYWORD_SET(verbose) THEN BEGIN
         lim_geo=STRING(MIN(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MIN(geo.lat),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lat),FORMAT='(F5.2)')
         PRINT,'tugo2geomat  : Date de debut du fichier = ',print_date(stime[0],/SINGLE)
         PRINT,'tugo2geomat  : Date de fin du fichier   = ',print_date(stime[N_ELEMENTS(stime)-1],/SINGLE)
         PRINT,'tugo2geomat  : limite geographique      =',STRCOMPRESS(lim_geo)     
         PRINT,'tugo2geomat  : extraction du parametre  = u,v'
         PRINT,'tugo2geomat  :          valeur du flag  = ',flg
         PRINT,'tugo2geomat  :          facteur echelle = ',scl
      ENDIF
      ENDIF ELSE IF KEYWORD_SET(uv) THEN BEGIN
        ;lecture des variables de courant
        IF KEYWORD_SET(transport) THEN BEGIN
          NCDF_VARGET, fid, NCDF_VARID(fid,'Hubar'), varu
          NCDF_VARGET, fid, NCDF_VARID(fid,'Hvbar'), varv  
        ENDIF ELSE BEGIN
          NCDF_VARGET, fid, NCDF_VARID(fid,'ubar'), varu
          NCDF_VARGET, fid, NCDF_VARID(fid,'vbar'), varv
        ENDELSE
        NCDF_ATTGET, fid, NCDF_VARID(fid,'ubar'), 'missing_value', flg
        ;determination des dimensions de la variable (2D ou 3D)
        s     = SIZE(varu)
        dim_t = 0
        IF (s[0] NE 2) THEN BEGIN
          NCDF_VARGET, fid,NCDF_VARID(fid,'time') , time 
          dim_t    = N_ELEMENTS(time)
          geo      = create_geomat(dim_x,dim_y,dim_t,/UV) ; initialisation de la structure geomat geo(lon,lat,time)
          geo.u    = flag_matrix(varu,seuil=flg)
          geo.v    = flag_matrix(varv,seuil=flg)
          geo.jul  = time/(24.*3600.)+JULDAY(1,1,1950,0,0,0)
       ENDIF ELSE BEGIN ;cas des matrice temporelle moyenne avec ncra par ex. 
          geo      = create_geomat(dim_x,dim_y,/UV) ; initialisation de la structure geomat geo(lon,lat)
          geo.u    = flag_matrix(varu,seuil=flg)
          geo.v    = flag_matrix(varv,seuil=flg)
          geo.info = info
       ENDELSE 
       geo.filename = filename
       geo.lon      = lon[*,0]
       geo.lat      = lat[0,*]
       ineg    = WHERE(geo.lon LT 0.,cneg)
       IF (cneg GT 0) THEN geo.lon[ineg]=360+geo.lon[ineg] ;on passe toute les longitudes en 0-360
       ;verbose  
       IF KEYWORD_SET(verbose) THEN BEGIN
         lim_geo=STRING(MIN(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MIN(geo.lat),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lat),FORMAT='(F5.2)')
         PRINT,'tugo2geomat  : Date de debut du fichier = ',print_date(stime[0],/SINGLE)
         PRINT,'tugo2geomat  : Date de fin du fichier   = ',print_date(stime[N_ELEMENTS(stime)-1],/SINGLE)
         PRINT,'tugo2geomat  : limite geographique      =',STRCOMPRESS(lim_geo)     
         PRINT,'tugo2geomat  : extraction du parametre  = u,v'
         PRINT,'tugo2geomat  :          valeur du flag  = ',flg
         PRINT,'tugo2geomat  :          facteur echelle = ',scl
      ENDIF

      ENDIF ELSE BEGIN               ;H(x,y) ou H(x,y,t)
        IF NOT KEYWORD_SET(var_name) THEN var_name='elevation'
         ;lecture de la variable specifie dans le mot-cle : var_name
        NCDF_VARGET, fid, NCDF_VARID(fid,var_name), var
        NCDF_ATTGET, fid, NCDF_VARID(fid,var_name), 'missing_value', flg
;        NCDF_ATTGET, fid, NCDF_VARID(fid,var_name), 'scale_factor', scl
        ;determination des dimensions de la variable (2D ou 3D)
        s = SIZE(var)
        IF (s[0] EQ 2) THEN BEGIN                           ;matrice 2D (ex : bathymetrie)
          geo     = create_geomat(dim_x,dim_y)              ;geo(lon,lat)
          H       = flag_matrix(var,seuil=flg)
          geo.val = H
        ENDIF ELSE BEGIN                                    ;matrice 3D (ex : elevation)      
          NCDF_VARGET, fid, NCDF_VARID(fid,'time'), time 
          dim_t = N_ELEMENTS(time)
          stime = time/(24.*3600.)+JULDAY(1,1,1950,0,0,0)
          geo     = create_geomat(dim_x,dim_y,dim_t)          ;geo(lon,lat,time)
          H       = flag_matrix(var,seuil=flg)
          ;H       = TRANSPOSE(H,[2,1,0]) ; on transpose la matrice pour avoir H[lon,lat,time]
          geo.val = H
          geo.jul = stime
        ENDELSE
        geo.lon = lon[*,0]
        geo.lat = lat[0,*]
        ineg    = WHERE(geo.lon LT 0.,cneg)
        IF (cneg GT 0) THEN geo.lon[ineg]=360+geo.lon[ineg] ;on passe toute les longitudes en 0-360
        IF NOT KEYWORD_SET(INFO) THEN info = FILE_BASENAME(FILE_DIRNAME(filename))
        geo.info=info+' '+var_name
        geo.filename = filename
        ;verbose  
        IF KEYWORD_SET(verbose) THEN BEGIN
          lim_geo=STRING(MIN(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lon),FORMAT='(F5.2)')+'/'+STRING(MIN(geo.lat),FORMAT='(F5.2)')+'/'+STRING(MAX(geo.lat),FORMAT='(F5.2)')
          PRINT,'tugo2geomat  : Date de debut du fichier = ',print_date(stime[0],/SINGLE)
          PRINT,'tugo2geomat  : Date de fin du fichier   = ',print_date(stime[N_ELEMENTS(stime)-1],/SINGLE)
          PRINT,'tugo2geomat  : limite geographique      =',STRCOMPRESS(lim_geo)     
          PRINT,'tugo2geomat  : extraction du parametre  = ',var_name
          PRINT,'tugo2geomat  :          valeur du flag  = ',flg
          PRINT,'tugo2geomat  :          facteur echelle = ',scl
        ENDIF
      ENDELSE  
      IF NOT KEYWORD_SET(uv) THEN BEGIN                 
     ENDIF ELSE BEGIN                                     ;H(x,y) ou H(x,y,t)
     ENDELSE 
  END
ENDCASE
print,geo.type
t=geotype(geo,/VERBOSE)
NCDF_CLOSE, fid
RETURN, geo
END