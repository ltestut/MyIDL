FUNCTION read_hydras, filename, start_date=start_date, scale=scale,$
                      sampling=sampling
;lit les fichiers brutes d'hydras
;
; sampling = 2 : give the sampling interval of data


;start_date=JULDAY(07,12,2007,00,02,00) ; Mayes
;start_date=JULDAY(03,15,2007,17,18,00)  ;next_ker2
;start_date=JULDAY(05,20,2007,00,02,00) ;Saint-Malo
;start_date=JULDAY(12,16,2007,00,02,00)  ;Baie Obs
;start_date=JULDAY(05,03,2008,21,10,00)  ;Baie Obs 2



;patron de lecture du fichier de configuration 
;---------------------------------------------
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:' '   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:'K'   ,$
      fieldcount:2 ,$
      fieldTypes:[4,7], $
      fieldNames:['val','heure'] , $
;                  .(0) .(1)        
      fieldLocations:[0,8], $
      fieldGroups:indgen(2) $
      }

; Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)

IF NOT KEYWORD_SET(scale) THEN scale=1.
IF NOT KEYWORD_SET(sampling) THEN sampling=1.


; Create the raw_readings structure 
N    = N_ELEMENTS(data.val) 
st   = create_julval(N)
date = TIMEGEN(N,START=start_date,STEP_SIZE=sampling,UNITS='Minutes')

st.val=data.val*scale
st.jul=date
      
RETURN, st

END