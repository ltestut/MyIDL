PRO mas_analyse, st, lon=lon, lat=lat, code=code
; compute the harmonical analysis of a st with mas.exe
; and store the result in harCODE in !mas_exe directory
IF NOT KEYWORD_SET(code) THEN code='data'
IF NOT KEYWORD_SET(lon)  THEN lon=0.
IF NOT KEYWORD_SET(lat)  THEN lat=0.

 ;write the data in shm (.hhs) format after filling with NaN data
st       = fill_nan_julval(st)
file_shm = !mas_out+'h'+STRCOMPRESS(STRUPCASE(code),/REMOVE_ALL)+'.hhs'
write_julval2shm,st,FILE_OUT=file_shm

st_check = read_shm(file_shm) ;lecture du fichier du horaire
print,'WRITE_MAS_INPUT check mean shom value =',MEAN(st_check.val,/NAN)

   ; on convertit la latitude et la longitude
degres=convert_deg2dec(lat) & deg_lat=degres & min_lat=FLOOR(ABS((lat-degres)*0.6)*100)
degres=convert_deg2dec(lon) & deg_lon=degres & min_lon=FLOOR(ABS((lon-degres)*0.6)*100)
ligne_lon=STRCOMPRESS(deg_lon,/REMOVE_ALL)+' '+STRCOMPRESS(min_lon,/REMOVE_ALL)
ligne_lat=STRCOMPRESS(deg_lat,/REMOVE_ALL)+' '+STRCOMPRESS(min_lat,/REMOVE_ALL)
PRINT,"Lat/Lon du maregraphe = ",ligne_lon,'/',ligne_lat
 ;write the input for mas.exe
file_out=!mas_exe+'reponse_ah.txt'
OPENW, UNIT, file_out  , /GET_LUN
PRINTF,UNIT,'1 3 5 13'
PRINTF,UNIT,file_shm
PRINTF,UNIT,'o'
PRINTF,UNIT,ligne_lat
PRINTF,UNIT,ligne_lon
PRINTF,UNIT,STRCOMPRESS(STRUPCASE(code),/REMOVE_ALL)
PRINTF,UNIT,'0'
FREE_LUN, UNIT
CLOSE, UNIT
PRINT,'WRITE_MAS_INPUT  (harFILE) = har'+STRCOMPRESS(STRUPCASE(code),/REMOVE_ALL)
CD,!mas_exe
SPAWN,'mas_2005.exe<reponse_ah.txt' ;run mas.exe on given data
PRINT,"Hamonic file in ",!mas_exe+STRCOMPRESS(STRUPCASE(code),/REMOVE_ALL)+'.har'
END

FUNCTION mas_predict, code=code,start=start,nday=nday
; compute the prediction based on a preliminary mas_analyse
; look for harcode in the !max_exe directory
; split the start='DDMMYYYY' in 'DD MM YYYY'
; 

 ;write the reponse_pre.txt to feed mas.exe for prediction
file_out   = !mas_exe+'reponse_pre.txt'
OPENW,  UNIT, file_out  , /GET_LUN
PRINTF,UNIT,'14 18'
PRINTF,UNIT,'har'+STRCOMPRESS(STRUPCASE(code),/REMOVE_ALL)
PRINTF,UNIT,'0'
             ;1st day of prediction 'DD MM YYYY'
PRINTF,UNIT, STRMID(start,0,2)+' '+STRMID(start,2,2)+' '+STRMID(start,4,4)                        
PRINTF,UNIT, STRCOMPRESS(nday,/REMOVE_ALL) ;nbr of day of prediction
PRINTF,UNIT,'24'                           ;nbr prediction/day
FREE_LUN, UNIT
CLOSE, UNIT
CD,!mas_exe
SPAWN,'mas_2005.exe<reponse_pre.txt',/LOG_OUTPUT   ;run MAS
st=read_shm(!mas_exe+STRCOMPRESS(code,/REMOVE_ALL)+'.pre') 
RETURN,st
END

FUNCTION mas_tidal_residuals, st, _EXTRA=_EXTRA 
; detide a time serie an return the residual
; better to perform a preliminary analysis 

 ;compute the defaut start and nday based on the structure
CALDAT,st[0].jul,month, day, year, hour, min, sec ;get info of day-1
start=STRING(day,FORMAT='(I2.2)')+STRING(month,FORMAT='(I2.2)')+$
                                  STRING(year,FORMAT='(I4.4)')
nday=FLOOR(st[-1].jul-st[0].jul+21)
code='DATA'

IF N_ELEMENTS(_EXTRA) THEN BEGIN
 keylist=TAG_NAMES(_EXTRA)
 FOREACH key,keylist DO BEGIN
   PRINT,key
   IF key EQ 'START' THEN start=_EXTRA.START 
   IF key EQ 'NDAY'  THEN nday=_EXTRA.NDAY  
   IF key EQ 'CODE'  THEN code=_EXTRA.code
 ENDFOREACH
ENDIF
print,start,nday

pre      = mas_predict(CODE=code,START=start,NDAY=nday)
st_res   = rms_diff_julval(st,pre)    ;compute residuals
RETURN,st_res
END

PRO ah_mas_toolbox
END