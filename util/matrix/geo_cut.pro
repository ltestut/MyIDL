FUNCTION geo_cut, geo, tmi=tmi, tma=tma, quiet=quiet, _EXTRA=_EXTRA
; cut within geographic or temporal limit

;get the geomatrix type 
gtype = geo_type(geo)

;decoupage geographique
glimit=geo_limit(geo,_EXTRA=_EXTRA)
IF (glimit[1] LT 0.) THEN glimit[1]=360.+glimit[1]  ;switch to positive lon
IF (glimit[3] LT 0.) THEN glimit[3]=360.+glimit[3]  ;switch to positive lon

IF NOT KEYWORD_SET(quiet) THEN BEGIN
 PRINT,"--------------------- [GEO_CUT] -------------------------------"
 PRINT,FORMAT='(%"Cut geomatrix        : %6.2fE / %6.2fE / %6.2fE / %6.2fE")',$
                  glimit[1],glimit[3],glimit[0],glimit[2]
 PRINT,"---------------------------------------------------------------"
ENDIF
icol = WHERE((geo.lon GE glimit[1]) AND (geo.lon LE glimit[3]),cpt_col)
irow = WHERE((geo.lat GE glimit[0]) AND (geo.lat LE glimit[2]),cpt_row)

IF (cpt_row LT 1 OR cpt_col LT 1) THEN STOP,"/!\ geo_cut : not enough point inside limit"

IF odd(gtype['type']) THEN BEGIN ;odd number type 1,3,5 (time varying field)
 IF NOT KEYWORD_SET(tmi) THEN tmi=geo.jul[0]
 IF NOT KEYWORD_SET(tma) THEN tma=geo.jul[-1]
 itime = WHERE((geo.jul GE tmi) AND (geo.jul LE tma),cpt_jul)
 nt    = N_ELEMENTS(geo.jul[itime])
ENDIF

CASE (gtype['type']) of
      0: BEGIN ; val(nx,ny)
         geo_out     = geo_create(cpt_col,cpt_row)
         geo_out.val = geo.val[icol,irow,0] ;/!\ ENORME SUBTILITE !!!!!
         END
      1: BEGIN ; val(nx,ny,nt)
         geo_out     = geo_create(cpt_col,cpt_row,nt)
         geo_out.jul = geo.jul[itime]
         geo_out.val = geo.val[icol,irow,*]
      END
      2: BEGIN ;u(nx,ny), v(nx,ny)
         geo_out      = geo_create(cpt_col,cpt_row,/VECTOR)
         geo_out.u[*,*] = geo.u[icol,irow,0]
         geo_out.v[*,*] = geo.v[icol,irow,0]
      END
      3: BEGIN ;u(nx,ny,nt), v(nx,ny,nt)
         geo_out      = geo_create(cpt_col,cpt_row,nt,/VECTOR)
         geo_out.jul  = geo.jul[itime]
         geo_out.u[*,*] = geo.u[icol,irow,*]
         geo_out.v[*,*] = geo.v[icol,irow,*]
      END
      4: BEGIN ;val(nx,ny), u(nx,ny), v(nx,ny)
         geo_out           = geo_create(cpt_col,cpt_row,/SCALAR,/VECTOR)
         geo_out.u[*,*]    = geo.u[icol,irow,0]
         geo_out.v[*,*]    = geo.v[icol,irow,0]
         geo_out.val[*,*]  = geo.val[icol,irow,0]
      END
      6: BEGIN ;val(nx,ny,nt), u(nx,ny,nt), v(nx,ny,nt)
         geo_out      = geo_create(cpt_col,cpt_row,nt,/SCALAR,/VECTOR)
         geo_out.jul  = geo.jul[itime]
         geo_out.u[*,*] = geo.u[icol,irow,*]
         geo_out.v[*,*] = geo.v[icol,irow,*]
      END
ENDCASE
geo_out.lon       = geo.lon[icol]
geo_out.lat       = geo.lat[irow]
geo_out.info      = geo.info
geo_out.filename  = geo.filename
RETURN,geo_out
END