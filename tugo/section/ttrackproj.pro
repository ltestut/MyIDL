FUNCTION ttrackproj, track, tangentielle=tangentielle
; compute the component of the velocity in the along-across track coordinate system

npt   = N_ELEMENTS(track.pt.lon)
nt    = N_ELEMENTS(track.pt[0].u)
tproj = create_ttrack(npt-1,nt)
lon   = track.pt.lon
lat   = track.pt.lat
dst   = FLTARR(npt-1)       ;distance between pair of point i+1 and i
theta = FLTARR(npt-1)       ;azimuth in radians (east of North)
um       = FLTARR(nt,npt-1) ;Mean zonal velocity of the pair 
vm       = FLTARR(nt,npt-1) ;Mean meridional velocity of the pair
u_parall = FLTARR(nt,npt-1) ;Along  track U coordinate 
v_parall = FLTARR(nt,npt-1) ;Along  track V coordinate
u_normal = FLTARR(nt,npt-1) ;Across track U coordinate
v_normal = FLTARR(nt,npt-1) ;Across track V coordinate

tproj.filename     = track.filename
tproj.name         = track.name+'-proj'
tproj.val_info     = track.val_info
tproj.pt.lon       = track.pt[0:npt-2].lon
tproj.pt.lat       = track.pt[0:npt-2].lat
tproj.pt.depth     = track.pt[0:npt-2].depth
tproj.pt.h         = track.pt[0:npt-2].h
tproj.pt.jul       = track.pt[0:npt-2].jul
tproj.pt.val       = track.pt[0:npt-2].val


FOR i=0,npt-2 DO BEGIN
 arc_azimuth,lon[i+1],lat[i+1],lon[i],lat[i],d,az,/METERS
 dst[i]   = d                              ;distance le long du grand cercle entre les extremites du segment
 theta[i] = rad(90.-az)                    ;azimuth in degrees east of North
 print,90.-az
 um[*,i]  = track.pt[i].u ;(track.pt[i+1].u+track.pt[i].u)/2. ;mean zonal velocity of the pair
 vm[*,i]  = track.pt[i].v  ;(track.pt[i+1].v+track.pt[i].v)/2. ;mean meridional velocity of the pair
 u_parall[*,i] = (um[*,i]*cos(theta[i])+vm[*,i]*sin(theta[i]))*cos(theta[i])
 v_parall[*,i] = (um[*,i]*cos(theta[i])+vm[*,i]*sin(theta[i]))*sin(theta[i])
 u_normal[*,i] = (vm[*,i]*cos(theta[i])-um[*,i]*sin(theta[i]))*cos(theta[i]+rad(90.))
 v_normal[*,i] = (vm[*,i]*cos(theta[i])-um[*,i]*sin(theta[i]))*sin(theta[i]+rad(90.))
ENDFOR
 tproj.pt.dist = dst
IF KEYWORD_SET(tangentielle) THEN BEGIN
 tproj.pt.u       = u_parall
 tproj.pt.v       = v_parall
ENDIF ELSE BEGIN
 tproj.pt.u       = u_normal
 tproj.pt.v       = v_normal
ENDELSE
RETURN,tproj
END