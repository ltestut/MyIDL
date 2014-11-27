FUNCTION read_xtrack_ncdf_old, filename, valid_cyc, _EXTRA=_EXTRA
; function de lecture des fichiers netcdf sortie de xtrack
; on doit connaitre a priori les indices des champs sla,tide,mog2d dans le fichier netcdf

stx0  = create_stx(1,1,/NAN) ;initialisation de la structure 
FOR i_file=0,N_ELEMENTS(filename)-1 DO BEGIN
 print,"READ_XTRACK_NCDF   read_file ==> ",filename[i_file]
 id       = NCDF_OPEN(filename[i_file])     ; ouverture du fichier netdcf
 info     = NCDF_INQUIRE(id)                ; renvoie les infos sur le fichier NetCDF dans la structure info
 NCDF_DIMINQ,id,0,cycle,nbcycles            ; recuperation du nbre de cycles de la trace
 NCDF_DIMINQ,id,1,point,nbpoints            ; recuperation du nbre de points de la trace
 NCDF_ATTGET,id,/GLOBAL,'missing_value',nan ; recuperation de la valeur des NaN
 sla_var   = NCDF_VARINQ(id,6)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ sla
 tide_var  = NCDF_VARINQ(id,7)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ tide
 mog2d_var = NCDF_VARINQ(id,8)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ mog2d
 NCDF_VARGET, id, NCDF_VARID(id,'lon'), lon              ; longitude (npoints)
 NCDF_VARGET, id, NCDF_VARID(id,'lat'), lat              ; latitude  (npoints)
 NCDF_VARGET, id, NCDF_VARID(id,'mssh'), mssh            ; mssh  (npoints)
 NCDF_VARGET, id, NCDF_VARID(id,'cycle'), cycle          ; number of cycles  (ncycles)
 NCDF_VARGET, id, NCDF_VARID(id,sla_var.name), sla       ; sea level anomalies (ncycles,npoints)
 NCDF_VARGET, id, NCDF_VARID(id,tide_var.name), tide     ; tide (ncycles,npoints)
 NCDF_VARGET, id, NCDF_VARID(id,mog2d_var.name), mog2d   ; mog2d vent+pression (ncycles,npoints)
 NCDF_VARGET, id, NCDF_VARID(id,'time'), t               ; time (ncycles,npoints)
 sla   = flag_matrix(sla,seuil=90.)                 ; on flag les valeurs 99.99
 tide  = flag_matrix(tide,seuil=90.)                 ; on flag les valeurs 99.99
 mog2d = flag_matrix(mog2d,seuil=90.)                 ; on flag les valeurs 99.99
 t     = flag_matrix(t,seuil=100.,/less)            ; on flag les valeurs 99.99
 t     = where_matrix(t,/nan,/replace)
 NCDF_CLOSE,id
; construction de la structure stx
 stx  = create_stx(nbpoints,nbcycles)
 stx.lon  = lon
 stx.lat  = lat
 stx.mssh = mssh
 ilon  = WHERE(stx.lon EQ nan, cptilon)
 ilat  = WHERE(stx.lat EQ nan, cptilat)
 imssh = WHERE(stx.mssh EQ nan, cptimssh)
 IF (cptilon GT 0) THEN  stx[ilon].lon=!VALUES.F_NAN
 IF (cptilat GT 0) THEN  stx[ilat].lat=!VALUES.F_NAN
 IF (cptimssh GT 0) THEN stx[imssh].mssh=!VALUES.F_NAN
 FOR i=0,nbpoints-1 DO BEGIN
    stx[i].jul[*]   = t[*,i]
    stx[i].sla[*]   = sla[*,i]
    stx[i].tide[*]  = tide[*,i]
    stx[i].mog2d[*] = mog2d[*,i]
 ENDFOR

; nbre de point valid par cycle
 Nvpc  = INTARR(nbcycles)
 Nloop = nbcycles-1
 FOR i=0,Nloop DO Nvpc[i]=TOTAL(FINITE(stx[*].sla[i]))  ; nbr de point vcalid par cycle
   ivalid    = WHERE(Nvpc GT 50,count)                         ; index des cycles valid
   valid_cyc = INTARR(count)
   IF (count GT 5) THEN valid_cyc = ivalid
   stx0     = fill_info_track(stx,_EXTRA=_EXTRA)
 ;  stx0    = concat_stx(stx0,stx) ; a modifier
 ENDFOR
;stx=remove_nan_track(stx)
RETURN, stx0
END