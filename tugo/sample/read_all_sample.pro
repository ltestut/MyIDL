FUNCTION read_all_sample, filenames, scale=scale, init=init, origine=origine
; fonction qui permet de lire tous les fichiers sample

 ;patron de lecture du fichiers sample
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter: ''  ,$
       missingvalue: 0   ,$
       commentsymbol: ''  ,$
       fieldcount:5 ,$
       fieldTypes:[5,4,4,4,4], $
       fieldNames:['jul','h','u','v','pa'] ,$
       fieldLocations:[0,14,25,34,44], $
       fieldGroups:indgen(5) $
      }

 ;gestion des mots-clefs
IF NOT KEYWORD_SET(scale)   THEN scale=100. ;on passe par defaut en cm
IF NOT KEYWORD_SET(origine) THEN origine='undefined'

nfiles     = N_ELEMENTS(filenames)
spl_list   = STRSPLIT(FILE_BASENAME(filenames), '.', /EXTRACT) ;numero du sample
spl_tab    = spl_list.ToArray()
spl_number = FLOOR(FLOAT(spl_tab[*,1])-1.0)

IF KEYWORD_SET(init) THEN BEGIN
 init_sample=read_sample_init(init,FMT=fmt)
 lon  = init_sample.lon[spl_number]
 lat  = init_sample.lat[spl_number]
 name = init_sample.name[spl_number]
 IF (FMT EQ 0) THEN name=FILE_BASENAME(filenames)
ENDIF ELSE BEGIN
 lon=MAKE_ARRAY(nfiles,VALUE=!VALUES.D_NAN)
 lat=MAKE_ARRAY(nfiles,VALUE=!VALUES.D_NAN)
 name=FILE_BASENAME(filenames)
ENDELSE

 ;creation de la stucture sample complete
read_init  = READ_ASCII(filenames[0],TEMPLATE=tmp)
n_values   = N_ELEMENTS(read_init.jul)
spl        = create_sample(n_values,NSPL=nfiles)

FOR i=0,nfiles-1 DO BEGIN
 read_st          = READ_ASCII(filenames[i],TEMPLATE=tmp)
 spl[i].lon       = lon[i]
 spl[i].lat       = lat[i]
 spl[i].name      = name[i]
 spl[i].origine   = origine
 spl[i].filename  = filenames[i]
 spl[i].jul = read_st.jul + JULDAY(1,1,1950,0,0,0)
 spl[i].h   = read_st.h*scale
 spl[i].u   = read_st.u*scale
 spl[i].v   = read_st.v*scale
 spl[i].pa  = read_st.pa*scale
ENDFOR
return, spl
END