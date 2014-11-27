FUNCTION read_prakash_tide, filename, scale=scale

;on charge la liste d'onde qui met en relation nom/frequence/periode
wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)
enr      = 'Debut: 00/00/0000  Fin: 00/00/0000  Duree:   000'
ut       = 5.5

station_name = ['Ratnagiri','Verem','Karwar','Malpe','Kavaratti','Cochin','Colachel','Marmagao']    
lat          = [    16.889 , 15.500, 14.803 , 13.333,     10.572,   9.969,     8.171,    15.417]      
lon          = [    73.285 , 73.800, 74.114 , 74.683,     72.635,  76.244,    77.255,    73.800]

; constituents obtained (WS-Cochin Port) using a  pressure gauge in same area in 2007.
;station_name = ['Cochin']    
;lat          = [ 9.969]      
;lon          = [ 76.244]

nsta        = N_ELEMENTS(station_name)
nfield      = nsta*2+3
b           = BYTE(INDGEN(nsta*2)+65)
stra        = STRARR(nsta*2)
FOR i=0,nsta*2-1 DO stra[i]=STRING(b[i])
field_names = ['wave','speed',stra,'zz']
field_types = [7,5,MAKE_ARRAY(nsta*2,VALUE=4),7]

 ;patron de lecture du fichier
tmp = {version:1.0,$
       datastart:5   ,$
       delimiter: ' '  ,$
       missingvalue: 0   ,$
       commentsymbol: '#'  ,$
       fieldcount:nfield ,$
       fieldTypes:field_types, $
       fieldNames:field_names ,$
       fieldLocations:INDGEN(nfield), $
       fieldGroups:INDGEN(nfield) $
      }

 ;gestion des mots-clefs
IF NOT KEYWORD_SET(scale)   THEN scale=0.01 ;on passe par defaut en m

data = READ_ASCII(filename,TEMPLATE=tmp)
nwa  = N_ELEMENTS(data.wave)
; on creer un structure de type spl et on range les donnees dedans 
mgr           = create_mgr(nsta,nwa)

; on remplit la structure mgr
FOR i=0,nsta-1 DO BEGIN
 mgr[i].name     = station_name[i]
 mgr[i].origine  = 'NIO-Mehra'
 mgr[i].lat      = lat[i]
 mgr[i].lon      = lon[i]
 mgr[i].nwav     = nwa
 mgr[i].filename = filename 
 mgr[i].enr      = enr 
 mgr[i].val      = 'P.Mehra' 
 mgr[i].code[0:nwa-1] = wave2code(data.(0))       ;on remplit les code des nwa premieres ondes
 mgr[i].wave[0:nwa-1] = data.(0)                  ;on remplit les nwa premieres ondes
 mgr[i].amp[0:nwa-1]  = data.(2+2*i)*scale
 greenwich_pha        = data.(2+2*i+1)-ut*tidal_wave_info(data.(0),WAVE_LIST=wave_list)
 mgr[i].pha[0:nwa-1]  = ((360.+(greenwich_pha MOD 360.)) MOD 360.) ;FLOAT(data.pha[id]);  
ENDFOR
write_mgr,mgr,FILENAME='/data/model_indien_nord/valid/mrg/src/mehra/mehra.mgr'
RETURN, mgr
END