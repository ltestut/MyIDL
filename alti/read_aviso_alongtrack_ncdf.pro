FUNCTION read_aviso_alongtrack_ncdf, track=track
; fonction qui permet le lire les donnees le long de la trace (monomission)
; 
;file='D:\idl\data\aviso\j1_along_track\CorSSH_Ref_J1_Cycle210.nc'
file='/data/ctoh/SLA_Ref_TP_Cycle091.nc'
file='/data/ctoh/SLA_Ref_J2_Cycle102.nc'

;id=ncdf_info(file)
;print,"READ_AVISO_ALONGTRACK_NCDF   read_file ==> ",file
id       = NCDF_OPEN(file)          ; ouverture du fichier netdcf
;info     = NCDF_INQUIRE(id)         ; renvoie les infos sur le fichier NetCDF dans la structure info
;- DIMENSIONS
NCDF_DIMINQ,id,0,dim_0_name,ntracks     ; recuperation du nbre de traces du fichier 
NCDF_DIMINQ,id,1,dim_1_name,cycle_nbr   ; recuperation du numero de cycle 
NCDF_DIMINQ,id,2,dim_2_name,ndata       ; recuperation du nbre total de points du fichier

;- on recupere le nombre de variables

;- VARIABLES ET ATTRIBUTS
NCDF_VARGET, id, NCDF_VARID(id,'DeltaT')     , deltat                    ; time gap between two measurements in mean profile
NCDF_ATTGET, id, NCDF_VARID(id,'DeltaT')     , 'scale_factor' , dtscale  ; scale factor
NCDF_VARGET, id, NCDF_VARID(id,'Tracks')     , track_number              ; numero de la trace
NCDF_VARGET, id, NCDF_VARID(id,'NbPoints')   , track_npt                 ; nbre de points de la trace
NCDF_VARGET, id, NCDF_VARID(id,'Cycles')     , cycles                    ; numero de cycle de la trace
NCDF_VARGET, id, NCDF_VARID(id,'Longitudes') , longitude                 ; longitude de tous les points du fichier
NCDF_VARGET, id, NCDF_VARID(id,'Latitudes')  , latitude                  ; latitude de tous les points du fichier
NCDF_ATTGET, id, NCDF_VARID(id,'Longitudes') , 'scale_factor' , lonscale ; scale factor
NCDF_ATTGET, id, NCDF_VARID(id,'Latitudes')  , 'scale_factor' , latscale ; scale factor
NCDF_VARGET, id, NCDF_VARID(id,'BeginDates') , date_deb                  ; date de debut de chaque cycle/tracks
NCDF_VARGET, id, NCDF_VARID(id,'DataIndexes'), track_idpt                ; index theorique
NCDF_VARGET, id, NCDF_VARID(id,'SLA')        , sla                       ; sla

izero = where(track_npt EQ 0, count)
IF (count GT 0) THEN track_npt[izero]=!VALUES.F_NAN

; init the hash table for pass 1
pass = HASH(track_number[0],INDGEN(track_npt[0]))
ids  = 0
FOR i=1,N_ELEMENTS(track_npt)-1 DO BEGIN
 ids   = ids+track_npt[i]
 index = ids+INDGEN(track_npt[i])
 pass=pass+HASH(track_number[i],[index])
ENDFOR

lon   = longitude*lonscale
lat   = latitude*latscale
stime = TRANSPOSE(date_deb)+JULDAY(1,1,1950,0,0,0)
dt    = dtscale*deltat
for i=0,ntracks-1 do print,FORMAT='(%"tracks N %i ==> start_date = %s")',track_number[i],print_date(stime[i],/SINGLE)

print,'toto'

END