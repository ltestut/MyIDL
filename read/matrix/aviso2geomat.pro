FUNCTION aviso2geomat, filename, clim=clim
; lecture de fichier netcdf_aviso et mise dans une structure de type geomat
; clim = 'global-monthly'  : keyword to charge different kind of grid


id   = NCDF_OPEN(filename)    ; ouverture du fichier
info = NCDF_INQUIRE(id)       ; => renvoie les info sur le fichier NetCDF dans la structure info


CASE clim OF 
  'global-monthly'  : BEGIN
                      NCDF_DIMINQ,id,0,n0,s0  ;*n0* dim-name and size *s0* of dimension 0 : NbLatitudes
                      NCDF_DIMINQ,id,1,n1,s1  ;*n1* dim-name and size *s1* of dimension 1 : NbLongitudes
                      time      = FLTARR(1)  ;t
                      lat       = FLTARR(s0)  ;y
                      lon       = FLTARR(s1)  ;x
                      H         = FLTARR(s0,s1)  ;H(x,y,t)
                      flg       = 1.84467e+019
                      geo       = create_geomat(s1,s0,1) ; initialisation de la structure geomat
                      date      = JULDAY(FIX(STRMID(filename,4,2,/REVERSE)),15,FIX(STRMID(filename,10,4,/REVERSE)),0,0,0)
                      END
  'msl-map'           : BEGIN
                        NCDF_DIMINQ,id,0,n0,s0  ;*n0* dim-name and size *s0* of dimension 0 : NbLongitudes
                        NCDF_DIMINQ,id,1,n1,s1  ;*n1* dim-name and size *s1* of dimension 1 : NbLatitudes
                        lat       = FLTARR(s1)  ;y
                        lon       = FLTARR(s0)  ;x
                        H         = FLTARR(s0,s1)  ;H(x,y,t)
                        flg       = 1.84467e+019
                        geo       = create_geomat(s0,s1) ; initialisation de la structure geomat
                        NCDF_VARGET, id, NCDF_VARID(id,'longitude'), lon
                        NCDF_VARGET, id, NCDF_VARID(id,'latitude'), lat
                        NCDF_VARGET, id, NCDF_VARID(id,'sea_level_trends'), H
                        geo.lon = lon
                        geo.lat = lat
                        H    = flag_matrix(H,seuil=flg,/verbose)
                        geo.val = H
                        RETURN, geo
                      END
  ELSE : BEGIN
  NCDF_DIMINQ,id,0,n0,s0  ;*n0* dim-name and size *s0* of dimension 0 : time
  NCDF_DIMINQ,id,1,n1,s1  ;*n1* dim-name and size *s1* of dimension 1 : NbLatitudes
  NCDF_DIMINQ,id,2,n2,s2  ;*n2* dim-name and size *s2* of dimension 2 : NbLongitudes
  time      = FLTARR(s0)  ;t
  lat       = FLTARR(s1)  ;y
  lon       = FLTARR(s2)  ;x
  H         = FLTARR(s1,s2,s0)  ;H(x,y,t)
  flg       = 1.84467e+019
  geo       = create_geomat(s2,s1,s0) ; initialisation de la structure geomat
  NCDF_VARGET, id, NCDF_VARID(id,'time'), t
  END
ENDCASE

NCDF_VARGET, id, NCDF_VARID(id,'NbLatitudes'), lat
NCDF_VARGET, id, NCDF_VARID(id,'NbLongitudes'), lon
NCDF_VARGET, id, NCDF_VARID(id,'Grid_0001'), H
NCDF_CLOSE,  id  ; fermeture du fichier
; /!\ Attention AVISO passe de jour depuis 1950 en heure depuis 1950.
IF KEYWORD_SET(clim) THEN BEGIN
  IF (clim EQ 'global-monthly') THEN time=date
  H    = flag_matrix(H,seuil=flg,/verbose)
  H    = TRANSPOSE(H)  ; on transpose la matrice pour avoir H[lon,lat,time]
ENDIF ELSE BEGIN
  time = (t/24.)+JULDAY(1,1,1950,12,0,0)
  H    = flag_matrix3D(H,seuil=flg,/verbose)
ENDELSE

geo.lon = lon
geo.lat = lat
geo.jul = time
geo.val = H

RETURN, geo
END