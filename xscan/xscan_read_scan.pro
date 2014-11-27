FUNCTION xscan_read_scan, filename
; definition du patron de lecture
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter:''   ,$
       missingvalue:!VALUES.F_NAN   ,$
       commentsymbol:''   ,$
       fieldcount:4 ,$
       fieldTypes:[2,3,4,4], $
       fieldNames:['id','nbr','lon','lat'] , $
        fieldLocations:[0,6,12,24], $
        fieldGroups:indgen(4) $
      }
; lecture du fichier a partir du patron de lecture tmp
data        = READ_ASCII(filename,TEMPLATE=tmp)
id_valid    = WHERE(data.id GE 1,cpt_id)
coord_valid = WHERE(FINITE(data.lon),cpt_coord,/L64)

 ;creation de la structure de type segment
seg   = create_segment(cpt_id,cpt_coord)
seg.id  = data.id[id_valid]
seg.nbr = data.nbr[id_valid]
seg.lon = data.lon[coord_valid]
seg.lat = data.lat[coord_valid]

 ;on calcul la connectivite utile pour le polyline
con      = [seg.nbr[0],INDGEN(seg.nbr[0])]
cpt_list = 0
FOR i=1,cpt_id-1 DO BEGIN
cpt_list += seg.nbr[i-1]  
ilist    =  cpt_list+ INDGEN(seg.nbr[i])
con      = [con,seg.nbr[i],ilist]
ENDFOR
seg.con = con
RETURN, seg
END

