FUNCTION read_track_gps, filename, scale=scale, filtred=filtred
; fonction qui permet de lire les fichiers de sortie de track GPS
; creer lire les fichiers traiter par P. Bonnefond pour FOAM

 ;patron de lecture du fichiers sample
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter: ' '  ,$
       missingvalue: 0   ,$
       commentsymbol: ''  ,$
       fieldcount:23 ,$
       fieldTypes:[5,5,5,4,4,4,2,2,2,2,2,2,4,4,4,4,4,4,4,4,4,4,7], $
       fieldNames:['jul','lon','lat','hf','v5','v6','mm','dd','yy','hh','mn','ss',$
                   'v13','v14','v15','v16','h','v18','v19','v20','v21','v22','v23'] ,$
       fieldLocations:indgen(23), $
       fieldGroups:indgen(23) $
      }
;Ci-joint la solution:
;champ 1 jour julien cnes
;champ 4 hauteur filtrée WGS84 (300s, courbe rouge)
;champ 17 hauteur  brute WGS84
;22277.5000115741 69.9420293506736 -49.8531298105045 39.7857266878911 1.233232215252787E-002 2.746613202410652E-002 12 29 10 12 0 1.000000 7 0.0 -49.85313416 69.94202423 39.4740 0.000 0 0.000 0.000 -0.240 ?      
;
 ;gestion des mots-clefs
IF NOT KEYWORD_SET(scale)   THEN scale=1. ;on passe par defaut en cm
IF NOT KEYWORD_SET(origine) THEN origine='undefined'

data = READ_ASCII(filename,TEMPLATE=tmp)

; on creer un structure de type spl et on range les donnees dedans 
st           = create_julval(N_ELEMENTS(data.jul))
st.jul  = data.jul + JULDAY(1,1,1950,0,0,0)
IF KEYWORD_SET(filtred) THEN st.val  = data.hf*scale ELSE st.val  = data.h*scale 
return, st
END