FUNCTION geo_type, geo, verbose=verbose
; return the geomat type
; type 0 : "geomat" scalar                       / val(nx,ny)
; type 1 : "geomat" time varying scalar          / val(nx,ny,nt)
; type 2 : "geomat" vector                      / u(nx,ny)      & v(nx,ny)
; type 3 : "geomat" time varying vector         / u(nx,ny,nt)   & v(nx,ny,nt)
; type 4 : "geomat" scalar+vect  / val(nx,ny) & u(nx,ny) & v(nx,ny)
; type 5 : "geomat" time varying scalar+vector /val(nx,ny,nt)&u(nx,ny,nt)&v(nx,ny,nt)


 CASE (geo.type) OF
  0: g=HASH('info','static scalar field : geo.val[nx,ny]',$
            'size',SIZE(geo.val,/DIMENSIONS))
  1: g=HASH('info','time varying scalar field : geo.val[nx,ny,nt]',$
            'size',SIZE(geo.val,/DIMENSIONS),'dmin',MIN(geo.jul,MAX=dmax),$
            'dmax',dmax)
  2: g=HASH('info','static vector field : geo.u[nx,ny] geo.v[nx,ny]',$
            'size',SIZE(geo.u,/DIMENSIONS))
  3: g=HASH('info','time varying vector field : geo.u[nx,ny,nt] geo.v[nx,ny,nt]',$
            'size',SIZE(geo.u,/DIMENSIONS),'dmin',MIN(geo.jul,MAX=dmax),$
            'dmax',dmax)
  4: g=HASH('info','static scalar + vector field : geo.val[nx,ny] geo.u[nx,ny] geo.v[nx,ny]',$
            'size',SIZE(geo.val,/DIMENSIONS))
  5: g=HASH('info','time varying scalar + vector field : geo.val[nx,ny,nt] geo.u[nx,ny,nt] geo.v[nx,ny,nt]',$
            'size',SIZE(geo.val,/DIMENSIONS),'dmin',MIN(geo.jul,MAX=dmax),$
            'dmax',dmax)
ENDCASE

g['type']=geo.type

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,"--------------------- [GEO_TYPE] ------------------------------"
 PRINT,FORMAT="('geomatrix type      : ',I2,' => ',A-75)",geo.type,g['info']
 PRINT,"geomatrix dimension : ",g['size']
 IF g.HasKey('dmin') THEN PRINT,FORMAT="('geomatrix start/end : ',A-19,' => ',A-19)",$
   print_date(g['dmin'],/SINGLE),print_date(g['dmax'],/SINGLE)
 PRINT,"---------------------------------------------------------------"
ENDIF
RETURN,g
END