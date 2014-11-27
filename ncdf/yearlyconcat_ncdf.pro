FUNCTION yearlyconcat_ncdf, rep_data,lat,lon

; initialisation de la structure julval avec le mois de janvier
file = rep_data+'kerguelen-2001.01.huv.nc'
st   = read_ncdf2julval(file,lat,lon)

print,'Lecture du fichier',file

FOR i=2,3  DO BEGIN
    
    file= (i LE 3)? rep_data + 'kerguelen-2001.0'+STRCOMPRESS(STRING(i),/REMOVE_ALL)+'.huv.nc' : $
      rep_data + 'kerguelen-2001.'+STRCOMPRESS(STRING(i),/REMOVE_ALL)+'.huv.nc'
    
    print,'Lecture du fichier',file
    st1=read_ncdf2julval(file,lat,lon)
    st=concat_julval(st,st1)
ENDFOR
RETURN, st
END
