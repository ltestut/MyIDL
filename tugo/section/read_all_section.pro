FUNCTION read_all_section, filenames, scale=scale, origine=origine
; fonction qui permet de lire tous les fichiers section d'une simulation

 ;patron de lecture du fichiers sample
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter: ''  ,$
       missingvalue: 0   ,$
       commentsymbol: ''  ,$
       fieldcount:2 ,$
       fieldTypes:[5,4], $
       fieldNames:['jul','val'] ,$
       fieldLocations:[0,12], $
       fieldGroups:indgen(2) $
      }

 ;gestion des mots-clefs
IF NOT KEYWORD_SET(scale)   THEN scale=1. ;on passe par defaut en cm
IF NOT KEYWORD_SET(origine) THEN origine='undefined'

nfiles     = N_ELEMENTS(filenames)
sec_list   = STRSPLIT(FILE_BASENAME(filenames), '.', /EXTRACT) ;numero du sample
sec_tab    = sec_list.ToArray()
sec_number = FLOOR(FLOAT(sec_tab[*,1]))
name       = FILE_BASENAME(filenames)

 ;creation de la stucture section complete
read_init  = READ_ASCII(filenames[0],TEMPLATE=tmp)
n_values   = N_ELEMENTS(read_init.jul)
sec        = create_section(n_values,NSEC=nfiles)

FOR i=0,nfiles-1 DO BEGIN
 PRINT,filenames[i]
 read_st          = READ_ASCII(filenames[i],TEMPLATE=tmp)
 sec[i].name      = name[i]
 sec[i].origine   = origine
 sec[i].filename  = filenames[i]
 sec[i].jul       = read_st.jul + JULDAY(1,1,1950,0,0,0)
 sec[i].val       = read_st.val*scale
ENDFOR
return, sec
END