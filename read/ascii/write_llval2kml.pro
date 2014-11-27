FUNCTION write_llval2kml, st, filename=filename, out_name=out_name
; fonction qui ecrit un fichier de type .kml (pour Google Earth)

IF NOT KEYWORD_SET(out_name) THEN out_name = 'my_file'

filename_info = getfilename(filename,DELIMITER='\')
N             = N_ELEMENTS(st.lon)
file_out      = filename_info.path+'\'+out_name ;on ajoute le sufixe .kml
;out           = filename_info.namestem+'.kml' ;on ajoute le sufixe .kml
out           = file_out+'.kml' ;on ajoute le sufixe .kml

print, 'ecriture du fichier  ', out

IF (KEYWORD_SET(filename)) THEN BEGIN
 OPENW,  UNIT, out  , /GET_LUN        ;; ouverture en ecriture du fichier
 
 PRINTF, UNIT, '<?xml version="1.0" encoding="UTF-8"?>'
 PRINTF, UNIT, '<kml xmlns="http://earth.google.com/kml/2.2">'
 PRINTF, UNIT, '<Document>'
 PRINTF, UNIT, '     <name>', filename_info.namestem, '</name>
 PRINTF, UNIT, '     <open>1</open>'
 
 I  =  0L
 f  =  1
 j  =  1
 segt_name          = file_out+'_segt_'+STRING(f)
 segt_name          = STRCOMPRESS(segt_name, /REMOVE_ALL)

 while ( I LT N-1 ) do begin
  
  ;; pour le premier point, ecrire l'en tete du premier segment
    if ( (i EQ 0) AND (st[I].lon EQ 0. AND st[I].lat EQ 0.)) then begin
    
        PRINTF, UNIT, '      <Placemark>'
        PRINTF, UNIT, '           <name>', segt_name, '</name>
        PRINTF, UNIT, '           <LineString>'
        PRINTF, UNIT, '                <tessellate>1</tessellate>'
        PRINTF, UNIT, '                <coordinates>'
        i  =  i+1        
    endif
    
    ;; si la premiere ligne contient des valeurs, ecrire l'en tete et la ligne de valeurs
    if ( (i EQ 0) AND (st[I].lon NE 0. OR st[I].lat NE 0.)) then begin
        
        PRINTF, UNIT, '      <Placemark>'
        PRINTF, UNIT, '           <name>', segt_name, '</name>
        PRINTF, UNIT, '           <LineString>'
        PRINTF, UNIT, '                <tessellate>1</tessellate>'
        PRINTF, UNIT, '                <coordinates>'
        PRINTF, UNIT, FORMAT='(F9.5,A,F9.5,A,I1)', st[I].lon,',',st[I].lat,',',0
        i  =  i+1        
    endif 
    
       
    ;; pour les autres lignes, n'ayant pas de séparateur et j < 5000, ecrire la ligne
    if ( (I GT 0) AND (j LE 2000) AND ( st[I].lat NE 0. OR st[I].lon NE 0. ) ) then begin
    PRINTF, UNIT, FORMAT='(F9.5,A,F9.5,A,I1)', st[I].lon,',',st[I].lat,',',0
    i  =  i+1
    j  =  j+1
    endif
    
    ;; pour les séparateurs, ecrire le fin du segment et le début du segment suivant
    
    if ( (I GT 0) AND ( st[I].lon EQ 0. AND st[I].lat EQ 0.) AND (J NE 2000) ) then begin
        PRINTF, UNIT, '                </coordinates>'
        PRINTF, UNIT, '           </LineString>'
        PRINTF, UNIT, '      </Placemark>'
        
        f  =  f+1
        segt_name          = filename_info.namestem+'_segt_'+STRING(f)
        segt_name          = STRCOMPRESS(segt_name, /REMOVE_ALL)
      
        j  =  1
        
        PRINTF, UNIT, '      <Placemark>'
        PRINTF, UNIT, '           <name>', segt_name,'</name>
        PRINTF, UNIT, '           <LineString>'
        PRINTF, UNIT, '                <tessellate>1</tessellate>'
        PRINTF, UNIT, '                <coordinates>'
        i  =  i+1
    endif 
    
    ;; pour les coupures à 5000 pts, ecrire la fin du segment, le début du suivant et dupliquer le point de liaison
    
    if ( (I GT 0) AND ( J EQ 2000 )) then begin
        PRINTF, UNIT, '                </coordinates>'
        PRINTF, UNIT, '           </LineString>'
        PRINTF, UNIT, '      </Placemark>'
        
        f  =  f+1
        segt_name          = filename_info.namestem+'_segt_'+STRING(f)
        segt_name          = STRCOMPRESS(segt_name, /REMOVE_ALL)
       
        j  =  1
        
        PRINTF, UNIT, '      <Placemark>'
        PRINTF, UNIT, '           <name>', segt_name,'</name>
        PRINTF, UNIT, '           <LineString>'
        PRINTF, UNIT, '                <tessellate>1</tessellate>'
        PRINTF, UNIT, '                <coordinates>'
        PRINTF, UNIT, FORMAT='(F9.5,A,F9.5,A,I1)', st[I-1].lon,',',st[I-1].lat,',',0
        
        i  =  i+1
    endif 
    
    
    
 endwhile

 PRINTF, UNIT, FORMAT='(F9.5,A,F9.5,A,I1)', st[N-1].lon,',',st[N-1].lat,',',0
 PRINTF, UNIT, '                </coordinates>'
 PRINTF, UNIT, '           </LineString>'
 PRINTF, UNIT, '      </Placemark>'
 PRINTF, UNIT, '</Document>'
 PRINTF, UNIT, '</kml>'
 FREE_LUN, UNIT

ENDIF
print, 'done'
return, out

END