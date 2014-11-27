FUNCTION read_ctoh_along_track, filename
; read function for CTOH netcdf regional altimetry files (based on read_xtrack_netcdf)
; on doit connaitre a priori les indices des champs sla,tide,mog2d dans le fichier netcdf

stx0  = create_stx(1,1,/NAN)                ;initialisation de la structure multi-trace au format tableau de stx
FOR i_file=0,N_ELEMENTS(filename)-1 DO BEGIN
  print,"READ_XTRACK_NCDF   read_file ==> ",filename[i_file]
  pass     = STRMID(filename[i_file],5,3,/REVERSE_OFFSET)
  spl      = STRSPLIT(filename[i_file],'.',/EXTRACT)
  mission  = spl[-4]                         ;extract the mission name
  id       = NCDF_OPEN(filename[i_file])     ; ouverture du fichier netdcf correspondant a une trace
  d_flag   = NCDF_VARID(id,'dist_to_coast_leuliette') ;on regarde si le champ est present dans le fichier netdcf
  info     = NCDF_INQUIRE(id)                ; renvoie les infos sur le fichier NetCDF dans la structure info
  NCDF_DIMINQ,id,0,cycle,nbcycles            ; recuperation du nbre de cycles de la trace
  NCDF_DIMINQ,id,1,point,nbpoints            ; recuperation du nbre de points de la trace
  sla_var   = NCDF_VARINQ(id,6)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ sla
  tide_var  = NCDF_VARINQ(id,7)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ tide
  dac_var   = NCDF_VARINQ(id,8)              ; recuperation de l'information (datatype,dim,name,natts,ndims) du champ modg2d
  NCDF_ATTGET, id, NCDF_VARID(id,'lon'),'missing_value',nan  ;recuperation de la valeur des NaN
  NCDF_VARGET, id, NCDF_VARID(id,'lon'), lon                 ; longitude (npoints)
  NCDF_VARGET, id, NCDF_VARID(id,'lat'), lat                 ; latitude  (npoints)
  IF (d_flag GE 0) THEN NCDF_VARGET, id, NCDF_VARID(id,'dist_to_coast_leuliette'), d2coast         ; distance a la cote la plus proche (npoints)
  NCDF_VARGET, id, NCDF_VARID(id,'time'), t                  ; time (nbcycles,npoints)
  NCDF_VARGET, id, NCDF_VARID(id,'mssh'), mssh               ; mssh  (npoints)
  NCDF_VARGET, id, NCDF_VARID(id,'cycle'), cycle             ; number of cycles  (nbcycles)
  NCDF_VARGET, id, NCDF_VARID(id,sla_var.name), sla          ; sea level anomalies (ncycles,npoints)
  NCDF_VARGET, id, NCDF_VARID(id,tide_var.name), tide        ; tide (ncycles,npoints)
  NCDF_VARGET, id, NCDF_VARID(id,dac_var.name), dac      ; dac vent+pression (ncycles,npoints)
  sla   = flag_matrix(sla,seuil=90.)                          ; on flag les valeurs 99.99
  tide  = flag_matrix(tide,seuil=90.)                         ; on flag les valeurs 99.99
  dac   = flag_matrix(dac,seuil=90.)                          ; on flag les valeurs 99.99
  t     = flag_matrix(t,seuil=100.,/less)                     ; on flag les valeurs 99.99
  t     = where_matrix(t,/nan,/replace)
  NCDF_CLOSE,id
  ; construction de la structure stx pour une trace
  stx            = create_stx(nbpoints,nbcycles)
  stx.info       = mission
  stx.pass       = pass
  stx.cycle      = cycle
  stx.filename   = filename[i_file]
  stx.pt.lon     = lon
  stx.pt.lat     = lat
  IF (d_flag GE 0) THEN stx.pt.d2coast = d2coast
  stx.pt.mssh    = mssh
  ilon  = WHERE(stx.pt.lon  EQ nan, cptilon)
  ilat  = WHERE(stx.pt.lat  EQ nan, cptilat)
  imssh = WHERE(stx.pt.mssh EQ nan, cptimssh)
  IF (cptilon GT 0) THEN  stx.pt[ilon].lon=!VALUES.F_NAN
  IF (cptilat GT 0) THEN  stx.pt[ilat].lat=!VALUES.F_NAN
  IF (cptimssh GT 0) THEN stx.pt[imssh].mssh=!VALUES.F_NAN
  FOR i=0,nbpoints-1 DO BEGIN                              ;on remplit les series temporelles pour chaque point
    stx.pt[i].jul[*]   = t[*,i]
    stx.pt[i].sla[*]   = sla[*,i]
    stx.pt[i].tide[*]  = tide[*,i]
    stx.pt[i].dac[*]   = dac[*,i]
  ENDFOR
  
  ; nbre de point valid par cycle et de val valid par point
  Nvpc  = INTARR(nbcycles)                                          ; nbr de point valid par cycle
  Nvpp  = INTARR(nbpoints)                                          ; nbr de point valid par point
  FOR i=0,nbcycles-1 DO Nvpc[i]=TOTAL(FINITE(stx.pt[*].sla[i]))   ; nbr de point valid par cycle
  FOR i=0,nbpoints-1 DO Nvpp[i]=TOTAL(FINITE(stx.pt[i].sla[*]))   ; nbr de point valid par cycle
  Nvpp = (FLOAT(Nvpp)/FLOAT(nbcycles))*100.                        ; % de valeur valid par point
  stx.pt.valid  = Nvpp
  stx           = fill_info_track(stx,_EXTRA=_EXTRA)
  stx0          = concat_stx(stx0,stx) ; a modifier
ENDFOR
;stx=remove_nan_track(stx)
RETURN, stx0
END