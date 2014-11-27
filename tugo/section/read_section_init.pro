FUNCTION read_section_init, filename, origine=origine
; lecture du fichier de configuration des fichiers sections de tugo
; section.dat ou tugo.section

IF NOT KEYWORD_SET(origine) THEN origine='tugo'

tmp = {version:1.0,$
      datastart:1   ,$
      delimiter: ''  ,$
      missingvalue: 0   ,$
      commentsymbol: ''  ,$
      fieldcount:4 ,$
      fieldTypes:[5,5,5,5], $
      fieldNames:['lon_start','lat_start','lon_end','lat_end'] ,$
      fieldLocations:[0,9,25,36], $
      fieldGroups:indgen(4) $
      }
init_sct  = READ_ASCII(filename,TEMPLATE=tmp)
nsct = N_ELEMENTS(init_sct.lon_start)
seg  = create_segment(nsct,nsct*2)
tab_lon = [init_sct.lon_start[0],init_sct.lon_end[0]]
tab_lat = [init_sct.lat_start[0],init_sct.lat_end[0]]
FOR i=1,nsct-1 DO tab_lon=[tab_lon,init_sct.lon_start[i],init_sct.lon_end[i]]
FOR j=1,nsct-1 DO tab_lat=[tab_lat,init_sct.lat_start[j],init_sct.lat_end[j]]
;seg = {id:LON64ARR(nseg), nbr:LON64ARR(nseg), con:LON64ARR(ncoord+nseg),$
;       lon:DBLARR(ncoord), lat:DBLARR(ncoord)}
seg.id        = INDGEN(nsct)+1
seg.nbr       = 2
seg.lon       = tab_lon
seg.lat       = tab_lat

 ;on calcul la connectivite utile pour le polyline
con      = [seg.nbr[0],INDGEN(seg.nbr[0])]
cpt_list = 0
FOR i=1,nsct-1 DO BEGIN
cpt_list += seg.nbr[i-1]  
ilist    =  cpt_list+ INDGEN(seg.nbr[i])
con      = [con,seg.nbr[i],ilist]
ENDFOR
seg.con = con
RETURN, seg
END