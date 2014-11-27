FUNCTION read_shom2mgr, filename, origine=origine, scale=scale, output_wave=output_wave, output_unit=output_unit, verbose=verbose                                                
; lecture des donnees de constituents issuent de la BD du SHOM
; 1) mise au format mgr et ecriture d'un fichier liste par onde (output_wave) dans output_unit                                    

IF NOT KEYWORD_SET(origine) THEN origine='SHOM'
IF NOT KEYWORD_SET(scale)   THEN scale=0.01
enr = 'Debut: 00/00/0000  Fin: 00/00/0000  Duree:   000'

;on charge la liste d'onde qui met en relation nom/frequence/periode
wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)

; definition du patron de lecture
tmp = {version:1.0,$
       datastart:2   ,$
       delimiter:''   ,$
       missingvalue:!VALUES.F_NAN   ,$
       commentsymbol:''   ,$
       fieldcount:7 ,$
       fieldTypes:[7,4,4,4,2,2,2], $
       fieldNames:['wave','amp','pha','dod','a','b','c'] , $
        fieldLocations:[0,9,15,21,28,34,39], $
        fieldGroups:indgen(7) $
      }

;lecture de la ligne d'entete du fichier pour determiner lon,lat et le nom
head  = STRARR(1)
OPENR, unit, filename, /GET_LUN
READF, unit, head
;"0 1655  244800     665800    50KARACHI                  1985  1     1093   121 4 Z07UHSLC"
;"  1529  205400     702200    55VERAVAL                                           Z06SHOMAR  
                                            
ilon=0&ilondec=0&ilat=0&ilatdec=0&sta=''&dec=0&nday=0&lacune=0&methode=0&ref=''&confiance=0&origine=''
READS,head,ilat,ilatdec,ilon,ilondec,dec,sta,nday,lacune,methode,ref,confiance,origine,$
    FORMAT='(6X,I4,I4,    4X,I3,I4,4X,I2,A25,8x,I8,I6,I2,A2,I2,A10)'
; lecture du fichier a partir du patron de lecture tmp
data          = READ_ASCII(filename,TEMPLATE=tmp)
id            = WHERE(data.wave NE '' AND data.amp GT 0.2,count)     ;on ne prend en compte que les ondes nommees et > 0.2 cm 
nwa           = N_ELEMENTS(data.amp[id])
mgr           = create_mgr(1,nwa)
greenwich_pha = data.pha[id]-(FLOAT(dec)/10.)*tidal_wave_info(data.wave[id],WAVE_LIST=wave_list)
IF KEYWORD_SET(verbose) THEN BEGIN
 im2 = WHERE(data.wave EQ 'M2')
 PRINT,FORMAT='(3(A6,X,F9.2))',$
 ' g=   ',data.pha[im2],' / G= ',greenwich_pha[im2], ' / G= ',(360.+greenwich_pha[im2]) MOD 360.
ENDIF

ineg          = WHERE(greenwich_pha LT 0.,cneg)
IF (cneg GT 0) THEN greenwich_pha[ineg]=360+greenwich_pha[ineg] ;on passe toute les phases en 0-360
 
; on remplit la structure mgr
mgr.name     = STRCOMPRESS(sta,/REMOVE_ALL)
mgr.origine  = STRCOMPRESS(origine,/REMOVE_ALL)
mgr.lat      = FLOAT(ilat+(ilatdec/100.)/60.)
mgr.lon      = FLOAT(ilon+(ilondec/100.)/60.)
mgr.nwav     = nwa
mgr.filename = filename 
mgr.enr      = enr 
mgr.val      = 'SHOMAR' 
mgr.code[0:nwa-1] = wave2code(data.wave[id])       ;on remplit les code des nwa premieres ondes
mgr.wave[0:nwa-1] = data.wave[id]                  ;on remplit les nwa premieres ondes
mgr.amp[0:nwa-1]  = FLOAT(data.amp[id])*scale
mgr.pha[0:nwa-1]  = data.pha[id] ;(360.+greenwich_pha) MOD 360. ;FLOAT(data.pha[id]);  

CLOSE, unit
FREE_LUN, unit


IF KEYWORD_SET(output_wave) THEN iout = WHERE(mgr.wave EQ output_wave,count)
;print,count,mgr.wave[iout]

;PRINT,FORMAT='(A25,2(F6.2),X,A7,X,F3.1,X,I4,X,F6.2,X,F6.2)',sta,FLOAT(ilon+(ilondec/100.)/60.),FLOAT(ilat+(ilatdec/100.)/60.),origine,FLOAT(dec/10.),nday,$
;                                         mgr.amp[iout],mgr.pha[iout]

IF KEYWORD_SET(output_unit) THEN PRINTF,output_unit,FORMAT='(A25,2(F6.2),X,A7,X,F3.1,X,I4,X,F6.2,2X,F6.2)',sta,FLOAT(ilon+(ilondec/100.)/60.),FLOAT(ilat+(ilatdec/100.)/60.),origine,FLOAT(dec/10.),nday,$
                                         mgr.amp[iout],mgr.pha[iout]

RETURN,mgr
END