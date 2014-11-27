FUNCTION read_tidal_dat2mgr, filename, origine=origine, scale=scale, lon=lon, lat=lat, name=name                                                
; lecture des donnees de constituents issuent d'article 
; 1) mise au format mgr et ecriture d'un fichier liste par onde (output_wave) dans output_unit                                    

IF NOT KEYWORD_SET(origine) THEN origine='NIO'
IF NOT KEYWORD_SET(scale)   THEN scale=0.01
;enr = 'Debut: 00/07/2003  Fin: 00/10/2003  Duree:   120'
enr = 'Debut: 00/10/2002  Fin: 00/04/2003  Duree:   210'

;enr = 'Debut: 26/04/2006  Fin: 06/06/2006  Duree:   040' ;Kochi

;on charge la liste d'onde qui met en relation nom/frequence/periode
wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)

; definition du patron de lecture
tmp = {version:1.0,$
       datastart:0   ,$
       delimiter:' '   ,$
       missingvalue:!VALUES.F_NAN   ,$
       commentsymbol:''   ,$
       fieldcount:3 ,$
       fieldTypes:[7,4,4], $
       fieldNames:['wave','amp','pha'] , $
        fieldLocations:[0,3,9], $
        fieldGroups:indgen(3) $
      }

; lecture du fichier a partir du patron de lecture tmp
data          = READ_ASCII(filename,TEMPLATE=tmp)
id            = WHERE(data.wave NE '' AND data.amp GT 0.1,count)     ;on ne prend en compte que les ondes nommees et > 0.2 cm 
nwa           = N_ELEMENTS(data.amp[id])
mgr           = create_mgr(1,nwa)
greenwich_pha = data.pha[id]-5.5*tidal_wave_info(data.wave[id],WAVE_LIST=wave_list)
IF KEYWORD_SET(verbose) THEN BEGIN
 im2 = WHERE(data.wave EQ 'M2')
 PRINT,FORMAT='(3(A6,X,F9.2))',$
 ' g=   ',data.pha[im2],' / G= ',greenwich_pha[im2], ' / G= ',(360.+greenwich_pha[im2]) MOD 360.
ENDIF

ineg          = WHERE(greenwich_pha LT 0.,cneg)
IF (cneg GT 0) THEN greenwich_pha[ineg]=360+greenwich_pha[ineg] ;on passe toute les phases en 0-360
 
; on remplit la structure mgr
mgr.name     = name
mgr.origine  = STRCOMPRESS(origine,/REMOVE_ALL)
mgr.lat      = lat
mgr.lon      = lon
mgr.nwav     = nwa
mgr.filename = filename 
mgr.enr      = enr 
mgr.val      = 'Sanil&al.' 
mgr.code[0:nwa-1] = wave2code(data.wave[id])       ;on remplit les code des nwa premieres ondes
mgr.wave[0:nwa-1] = data.wave[id]                  ;on remplit les nwa premieres ondes
mgr.amp[0:nwa-1]  = FLOAT(data.amp[id])*scale
mgr.pha[0:nwa-1]  = data.pha[id] ;(360.+greenwich_pha) MOD 360.  

RETURN,mgr
END