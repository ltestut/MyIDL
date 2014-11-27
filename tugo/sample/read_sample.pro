FUNCTION read_sample, filename, scale=scale, init=init, origine=origine
; fonction qui permet de lire les fichiers sample
; crees par tugo et qui les range dans une structure de type sample

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
spl_name   = STRSPLIT(FILE_BASENAME(filename), '.', /EXTRACT) ;numero du sample
spl_number = FLOOR(FLOAT(spl_name[1])-1.0)
IF NOT KEYWORD_SET(scale)   THEN scale=100. ;on passe par defaut en cm
IF NOT KEYWORD_SET(origine) THEN origine='undefined'
IF KEYWORD_SET(init) THEN BEGIN
 init_sample=read_sample_init(init)
 lon  = init_sample.lon[spl_number]
 lat  = init_sample.lat[spl_number]
 name = init_sample.name[spl_number]
 IF (name EQ 'z') THEN name=FILE_BASENAME(filename)
ENDIF ELSE BEGIN
 lon=!VALUES.D_NAN
 lat=!VALUES.D_NAN
 name=FILE_BASENAME(filename)
ENDELSE


read_st  = READ_ASCII(filename,TEMPLATE=tmp)

; on creer un structure de type spl et on range les donnees dedans 
spl           = create_sample(N_ELEMENTS(read_st.jul))
spl.lon       = lon
spl.lat       = lat
spl.name      = name
spl.origine   = origine
spl.filename  = filename
spl.jul = read_st.jul + JULDAY(1,1,1950,0,0,0)
spl.h   = read_st.h*scale
spl.u   = read_st.u*scale
spl.v   = read_st.v*scale
spl.pa  = read_st.pa*scale
return, spl
END