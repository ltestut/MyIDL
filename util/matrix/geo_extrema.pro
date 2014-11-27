PRO geo_extrema, geo_in, limit=limit, scale=scale
; affiche les extrema d'une geomatrice



; a terminer pour le geotype > 2

 ;determnation du type et des limites de la geomatrice
IF KEYWORD_SET(limit) THEN BEGIN
 geo = geocut(geo_in,limit=limit)
ENDIF ELSE BEGIN
 geo = geo_in
ENDELSE

 ;determination du type de la matrice
gtype = geotype(geo,/VERBOSE)

IF NOT KEYWORD_SET(scale) THEN scale=100.

CASE (gtype) of
  0: BEGIN ;cas de la matrice val(nx,ny)
     s         = SIZE(geo.val)
     ncol      = s[1]
     id_min    = WHERE(geo.val EQ MIN(geo.val,/NAN), cpt_min)
     id_max    = WHERE(geo.val EQ MAX(geo.val,/NAN), cpt_max)
     IF (cpt_min GE 1 AND cpt_max GE 1) THEN BEGIN
      icol_min  = id_min[0] MOD ncol
      irow_min  = id_min[0]/ncol
      icol_max  = id_max[0] MOD ncol
      irow_max  = id_max[0]/ncol
      PRINT,FORMAT="('Valeurs MIN/MAX de la matrice        : AMP = ',F8.2,' / ',F8.2)",geo.va[id_min],geo.va[id_max]
      PRINT,FORMAT="('         MIN [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_min],geo.lat[irow_min]
      PRINT,FORMAT="('         MAX [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_max],geo.lat[irow_max]
     ENDIF
  END
  1: BEGIN ;cas de la matrice type maree amp(nx,ny), pha(nx,ny)
     s         = SIZE(geo.amp)
     ncol      = s[1]
     id_min    = WHERE(geo.amp EQ MIN(geo.amp,/NAN), cpt_min)
     id_max    = WHERE(geo.amp EQ MAX(geo.amp,/NAN), cpt_max)
     IF (cpt_min GE 1 AND cpt_max GE 1) THEN BEGIN
      icol_min  = id_min[0] MOD ncol
      irow_min  = id_min[0]/ncol
      icol_max  = id_max[0] MOD ncol
      irow_max  = id_max[0]/ncol
      PRINT,FORMAT="('Valeurs MIN/MAX de la matrice        : AMP = ',F8.2,' / ',F8.2)",geo.amp[id_min]*scale,geo.amp[id_max]*scale
      PRINT,FORMAT="('         MIN [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_min],geo.lat[irow_min]
      PRINT,FORMAT="('         MAX [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_max],geo.lat[irow_max]
     ENDIF
     id_min    = WHERE(geo.pha EQ MIN(geo.pha,/NAN), cpt_min)
     id_max    = WHERE(geo.pha EQ MAX(geo.pha,/NAN), cpt_max)
     IF (cpt_min GE 1 AND cpt_max GE 1) THEN BEGIN
      icol_min  = id_min[0] MOD ncol
      irow_min  = id_min[0]/ncol
      icol_max  = id_max[0] MOD ncol
      irow_max  = id_max[0]/ncol
      PRINT,FORMAT="('Valeurs MIN/MAX de la matrice        : PHA = ',F8.2,' / ',F8.2)",geo.amp[id_min]*scale,geo.amp[id_max]*scale
      PRINT,FORMAT="('         MIN [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_min],geo.lat[icol_min]
      PRINT,FORMAT="('         MAX [lon,lat]  ======>  [ ',F6.2,' , ',F6.2,']')",geo.lon[icol_max],geo.lat[icol_max]
     ENDIF
  END
  2: BEGIN ;cas de la matrice val(nx,ny,nt)
     IF NOT KEYWORD_SET(tmi) THEN tmi=geo.jul[0]
     IF NOT KEYWORD_SET(tma) THEN tma=geo.jul[N_ELEMENTS(geo.jul)-1]
     itime = WHERE((geo.jul GE tmi) AND (geo.jul LE tma),cpt_jul)
      nt    = N_ELEMENTS(geo.jul[itime])
      geo_out     = create_geomat(cpt_col,cpt_row,nt)
      geo_out.jul = geo.jul[itime]
      geo_out.lon = geo.lon[icol]
      geo_out.lat = geo.lat[irow]
      geo_out.val = geo.val[icol,irow,*]
  END
  3: BEGIN ;cas de la matrice type vent u(nx,ny), v(nx,ny)
      geo_out      = create_geomat(cpt_col,cpt_row,/UV)
      geo_out.lon       = geo.lon[icol]
      geo_out.lat       = geo.lat[irow]
      geo_out.u[*,*]    = geo.u[icol,irow,0]
      geo_out.v[*,*]    = geo.v[icol,irow,0]
      geo_out.info      = geo.info
      geo_out.filename  = geo.filename
  END
  4: BEGIN ;cas de la matrice val(nx,ny,nt)
     IF NOT KEYWORD_SET(tmi) THEN tmi=geo.jul[0]
     IF NOT KEYWORD_SET(tma) THEN tma=geo.jul[N_ELEMENTS(geo.jul)-1]
     itime = WHERE((geo.jul GE tmi) AND (geo.jul LE tma),cpt_jul)
      nt    = N_ELEMENTS(geo.jul[itime])
      geo_out     = create_geomat(cpt_col,cpt_row,nt,/UV)
      geo_out.jul = geo.jul[itime]
      geo_out.lon = geo.lon[icol]
      geo_out.lat = geo.lat[irow]
      geo_out.u         = geo.u[icol,irow,*]
      geo_out.v         = geo.v[icol,irow,*]
      geo_out.info      = geo.info
      geo_out.filename  = geo.filename
  END
ENDCASE
END