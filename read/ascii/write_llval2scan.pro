; fonction qui ecrit un fichier de type .scan
FUNCTION write_llval2scan, st, filename=filename, seg_num=seg_num

filename_info = getfilename(filename)
N             = N_ELEMENTS(st.lon)
out           = filename_info.name+'.scan' ;on ajoute le sufixe .scan
;out           = filename
cpt_pt        = 0L                              ;initialisation du compteur pour les multisegments xscan (lat=0,lon=0)
cpt_seg       = 0L

print, 'ecriture du fichier  ',out 

IF NOT KEYWORD_SET(seg_num) THEN seg_num=1

IF (KEYWORD_SET(filename)) THEN BEGIN
 Iz = WHERE((st.lon EQ 0.) AND (st.lat EQ 0.),count)
 ;print, count
 OPENW,  UNIT, out  , /GET_LUN        ;; ouverture en ecriture du fichier
 IF (count EQ 0) THEN PRINTF, UNIT, FORMAT='(I13,I13)', seg_num, N
 IF (count GE 1) THEN PRINTF, UNIT, FORMAT='(I13,I13)', seg_num, iz[1]-1
    FOR I=0L,N-1 DO BEGIN
        IF ((st[I].lon EQ 0.) AND (st[I].lat EQ 0.)) THEN BEGIN
           cpt_seg = cpt_seg+1    
           cpt_pt=0L   ;on initialise a zero a chaque changement de segment
           IF (cpt_seg NE count) THEN BEGIN
              PRINTF, UNIT, FORMAT='(I6,I6)', cpt_seg, iz[cpt_seg]-iz[cpt_seg-1]-1
           ENDIF ELSE BEGIN
              PRINTF, UNIT, FORMAT='(I6,I6)', cpt_seg, N-iz[cpt_seg-1]-1
           ENDELSE   
        ENDIF ELSE BEGIN 
          cpt_pt=cpt_pt+1
          PRINTF, UNIT,FORMAT='(I12,X,F11.5,5X,F11.5)',cpt_pt,st[I].lon,st[I].lat
       ENDELSE
    ENDFOR
 FREE_LUN, UNIT
ENDIF
RETURN,out
END