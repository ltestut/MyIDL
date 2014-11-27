PRO write_julval2shm, st, file_out=file_out
; write a  juval structure into SHOM shm format (.hhs)
; /!\ need a {jul,val} structure without time gap flag=9999
; /!\ should be hourly value in cm

fmt1= '(I4,X,I3.3,X,I3,24I4)' ;output format .hhs (format SHOM)

 ;replace NaN with 9999
inan = WHERE(FINITE(st.val,/NAN),count)
print,"WRITE_JULVAL2SHM         => Number of NaN :",count
print,"WRITE_JULVAL2SHM (write) => ",file_out
IF (count GE 1) THEN st[inan].val=9999

 ;cut the beginning of the time serie if not starting a 00h00
CALDAT,st[0].jul,month, day, year, hour, min, sec
IF (hour NE 0) THEN st=julcut(st,dmin=JULDAY(month,day+1,year,0,0,0))
CALDAT, st.jul, month, day, year, hour, min, sec
num_station = 000
 ;write data Ecriture des donnees au format SHM (hhs)
Nd    = N_ELEMENTS(st.val)
OPENW,  UNIT, file_out  , /GET_LUN
FOR I=0L,Nd-25,24 DO BEGIN
 ;compute the day number
 num_jour=JULDAY(month[I],DAY[I],YEAR[I],0,0,0)-JULDAY(1,1,YEAR[I],0,0,0)+1
 PRINTF, UNIT,FORMAT=fmt1,year[I],num_station,num_jour,st[I+00:I+23].val
ENDFOR
CLOSE,UNIT
END
