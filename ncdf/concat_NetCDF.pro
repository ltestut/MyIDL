PRO concat_NetCDF

;modifications a apporter
;lire 744 comme le plus grand d'elts pour le temps (normalement
;correspond a un mois de 31 jours)


;c LECTURE DES FICHIERS (MATRICE DE DIM 3 [X,Y,Temps])
;GOTO, DESSIN

rep_data='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/'


read_netcdf,'lat',Lat,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
lat_tot=Lat

read_netcdf,'h',H,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
h_tot=H
    size_X=N_ELEMENTS(H[*,0,0])
    size_Y=N_ELEMENTS(H[0,*,0])
    size_max_time=N_ELEMENTS(H[0,0,*])

read_netcdf,'u',U,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
u_tot=U

read_netcdf,'v',V,f='/data/ocean/travail_en_cours/maraldi/data/without_shelf/9waves_2ndforcing_flag/kerguelen-2001.01.huv.nc'
v_tot=V

FOR i=2, 12 DO BEGIN
    
    nom_de_fichier= (i LE 9)? rep_data + 'kerguelen-2001.0'+STRCOMPRESS(STRING(i),/REMOVE_ALL)+'.huv.nc' : $
      rep_data + 'kerguelen-2001.'+STRCOMPRESS(STRING(i),/REMOVE_ALL)+'.huv.nc'
    read_netcdf,'lat',Lat,f=nom_de_fichier
    read_netcdf,'time',Time,f=nom_de_fichier
    read_netcdf,'h',H,f=nom_de_fichier
    print, nom_de_fichier
    
                                ;lat_tot=[lat_tot,Lat]
    size_time=N_ELEMENTS(H[0,0,*])

    IF (size_time NE size_max_time) THEN BEGIN	
        H_aux=MAKE_ARRAY(size_X,size_Y,size_max_time)
        H_aux[*,*,0:size_time-1]=H
        H_aux[*,*,size_time:size_max_time-1]=REPLICATE(!VALUES.F_NAN,size_X,size_Y,size_max_time-size_time)
        h_tot=[h_tot,H_aux]
    ENDIF ELSE BEGIN
        h_tot=[h_tot,H]
    ENDELSE
    
ENDFOR

print, 'FIN'

END
