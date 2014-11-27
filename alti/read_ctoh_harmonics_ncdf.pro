FUNCTION read_ctoh_harmonics_ncdf, filename, track_num=track_num, scale=scale, verbose=verbose,_EXTRA=_EXTRA
; function de lecture des fichiers harmoniques netcdf du CTOH
; on doit connaitre a priori les indices des champs sla,tide,mog2d dans le fichier netcdf

IF NOT KEYWORD_SET(scale) THEN scale=1.
IF NOT KEYWORD_SET(track_num) THEN track_num=''

fmt_verb='(A1,A-20,A1,A7,A1,A7,A1,A1,A-15,A1,A7,A3)'

print,"READ_CTOH_HARMONICS_NCDF   read_file ==> ",filename
id       = NCDF_OPEN(filename)      ; ouverture du fichier netdcf correspondant a une ou plusieurs trace
info     = NCDF_INQUIRE(id)         ; renvoie les infos sur le fichier NetCDF dans la structure info
; /!\ a l'ordre des dim dans les fichiers CTOH  
; NCDF_DIMINQ,id,0,record,nd         ; recuperation du nbre de donnees 
; NCDF_DIMINQ,id,1,constituent,nwa   ; recuperation du nbre d'onde analysees
; /!\ a l'ordre des dim dans les fichiers CTOH Trace DECALEE
 NCDF_DIMINQ,id,0,constituent,nwa   ; recuperation du nbre d'onde analysees
 NCDF_DIMINQ,id,2,record,nd   ; recuperation du nbre d'onde analysees

;on recupere de quoi faire le titre du mgr 
;NCDF_ATTGET, id , 'title', value , /GLOBAL
NCDF_ATTGET, id , 'software', ori , /GLOBAL
NCDF_ATTGET, id , 'time_series_first_date_used',start_date,/GLOBAL ; = "01-03-1993" ;
NCDF_ATTGET, id , 'time_series_last_date_used',end_date,/GLOBAL ; = "19-05-2011" ;
NCDF_ATTGET, id , 'time_series_validation',valid,/GLOBAL 
sdd=STRMID(start_date,0,2) & smm=STRMID(start_date,3,2) & syy=STRMID(start_date,6,4)
edd=STRMID(end_date,0,2)   & emm=STRMID(end_date,3,2)   & eyy=STRMID(end_date,6,4)
enr=STRING(' Debut: ',sdd,'/',smm,'/',syy,$
    '  Fin: ',edd,'/',emm,'/',eyy,'  Duree:   ',$
    STRCOMPRESS(STRING(JULDAY(FIX(emm),FIX(edd),FIX(eyy))-JULDAY(FIX(smm),FIX(sdd),FIX(syy))),/REMOVE_ALL))
origine=STRING(STRING(ori)+'/track:'+STRING(track_num))

;on recupere la valeur NaN de amplitude
NCDF_ATTGET, id, NCDF_VARID(id,'amplitude'),'_FillValue',nan  ;recuperation de la valeur des NaN

;recuperation des variables
NCDF_VARGET, id, NCDF_VARID(id,'lon'), lon                   ; longitude (nd)
NCDF_VARGET, id, NCDF_VARID(id,'lat'), lat                   ; latitude  (nd)
NCDF_VARGET, id, NCDF_VARID(id,'sample'), sample             ; sample (nd)
NCDF_VARGET, id, NCDF_VARID(id,'amplitude'), amp             ; amplitude (nwa,nd)
NCDF_VARGET, id, NCDF_VARID(id,'phase_lag'), pha             ; phase (nwa,nd)
NCDF_VARGET, id, NCDF_VARID(id,'bg_contamination_error'), bg ; error (nwa,nd)
NCDF_VARGET, id, NCDF_VARID(id,'mean_square_error'), merr    ; mean_error (nwa,nd)
NCDF_VARGET, id, NCDF_VARID(id,'constituentname'), wname     ; wave_name (nwa)
NCDF_CLOSE,id

; construction de la structure mgr pour la ou les trace
mgr = create_mgr(nd,nwa)

ineg     = WHERE(lon LT 0.,cneg)
IF (cneg GT 0) THEN lon[ineg]=360+lon[ineg] ;on passe toute les longitudes en 0-360


mgr.name     = STRING(track_num,FORMAT='(I03)')+'-'+STRCOMPRESS(STRING(1+INDGEN(nd),FORMAT='(I04)'),/REMOVE_ALL)
mgr.origine  = origine
mgr.lat      = lat ;FLOAT(lat)
mgr.lon      = lon ;FLOAT(lon)
mgr.nwav     = nwa
mgr.filename = filename 
mgr.origine  = STRCOMPRESS(origine,/REMOVE_ALL)
mgr.enr      = enr
mgr.val      = STRCOMPRESS(STRING(valid),/REMOVE_ALL)
mgr.code[0:nwa-1] = wave2code(STRING(wname))  ;on remplit les code des nwa premieres ondes
mgr.wave[0:nwa-1] = STRING(wname)              ;on remplit les nwa premieres ondes
mgr.amp[0:nwa-1]  = FLOAT(amp)*scale
mgr.pha[0:nwa-1]  = FLOAT(pha)


IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'Nombre de stations du fichiers mgr  : ', nd
 PRINT,'Informations stations               : '
 FOR i=0,nd-1 DO PRINT,FORMAT=fmt_verb,'>',STRCOMPRESS(mgr[i].name,/REMOVE_ALL),$
      '(',STRING(mgr[i].lon,FORMAT='(F7.2)'),',',STRING(mgr[i].lat,FORMAT='(F7.2)'),')','[',STRCOMPRESS(mgr[i].origine,/REMOVE_ALL),']'
ENDIF
RETURN, mgr
END