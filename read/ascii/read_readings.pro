FUNCTION read_readings, filename, zero=zero, flg_num=flg_num
; function to read the kerguelen tide pole readings

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_READINGS(filename, zero=2.3cm)'
IF NOT KEYWORD_SET(zero) THEN zero=62.5 ;by default the datum is the zero hydro

 ; template  
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:';'   ,$
      fieldcount:8 ,$
      fieldTypes:[2,7,2,2,2,4,4,4], $
      fieldNames:['num','jul','nob','qc', 'flg', 'moy', 'rms', 'rmsm'] , $
;                  .(0) .(1)   .(2) .(3)   .(4)  .(5)   .(6)    .(7)      
      fieldLocations:[0,3,23,28,30,32,39,46], $
      fieldGroups:indgen(8) $
      }

 ; read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)

 ; create the raw_readings structure 
N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
date = DBLARR(N)
            
; Cut the string of the date field to build the corresponding date 
READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date        
st.val = data.moy+zero

; remove the flag > 0
; ------------------- 
iflg = WHERE(data.(4) GT 0,count)
print,"Number of flagged values = ",count
IF (count GT 0) THEN BEGIN
   st[iflg].val=!VALUES.F_NAN
ENDIF

; remove a list of reading session
; -------------------------------- 
IF (N_ELEMENTS(flg_num) GT 0) THEN BEGIN
      FOR k=0,N_ELEMENTS(flg_num)-1 DO BEGIN
      print,"Suppression de la lecture numero :",flg_num[k]
      inum        =  WHERE(data.(0) EQ flg_num[k],count)
      st[inum].val= !VALUES.F_NAN
      ENDFOR
ENDIF
st =finite_st(st)
RETURN, st
END