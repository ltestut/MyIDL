PRO build_alti_mgr
; build the .sav and .mgr database

; /!\ a l'ordre des dim dans les fichiers CTOH  

ctoh_nc_path= '/data/ctoh/ah/nea/'
zone        = 'nea'
sat         = 'TP+J1+J2'


file   = FILE_SEARCH(ctoh_nc_path,'ctoh.harmonics.ref.'+sat+'.'+zone+'.*.nc')
suffix = 'N'
suffix = ''
FOR i=0,N_ELEMENTS(file)-1  DO BEGIN
 track_num = STRMID(file[i],5,3,/REVERSE_OFFSET)
  mgr       = read_ctoh_harmonics_ncdf(file[i],TRACK_NUM=track_num+suffix,SCALE=1.) ;scale =1 [m]
  make_mgr_archive,mgr, NAME='nea/nea_'+track_num+suffix+'_track.sav',$
                       DESCR='MGR des donnees de la trace  : '+track_num+suffix

ENDFOR
END