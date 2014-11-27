FUNCTION  read_abice, filename, scale=scale
; fonction qui permet de lire le format de sortie des données GPS GEOAZUR

;22922.0000115741 72.64823768703658 10.57510932346847 -92.32120077122538 -0.0011236925899945852 0.0028047830840908965 10 4 12 0 0 1.000000 8 0.0 10.57510937 72.64823934 -92.3990 0.010 0 0.000 0.000 0.000 ????
;22922.0000231481 72.64823774004222 10.575109344612242 -92.32134156765353 -0.0010077286596405894 0.002790576906976705 10 4 12 0 0 2.000000 8 0.0 10.57511010 72.64824000 -92.4150 0.000 0 0.070 0.080 -0.010 ????
;22922.0000347222 72.64823779288169 10.575109365527045 -92.32148127021503 -0.0008930911601772278 0.0027762063452822254 10 4 12 0 0 3.000000 8 0.0 10.57511027 72.64824033 -92.3360 0.010 0 0.030 0.010 0.070 ????
;22922.0000462963 72.6482378455545 10.575109386212686 -92.32161987761779 -0.0007797811535251646 0.0027616715280763347 10 4 12 0 0 4.000000 8 0.0 10.57510916 72.64823994 -92.2890 0.000 0 -0.040 -0.120 0.040 ????

IF NOT KEYWORD_SET(scale) THEN scale=1.0

; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:' '   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:23 ,$
        fieldTypes:[5     ,5   ,5     ,5   ,5   , 5    , 2    ,2    ,2     ,2   ,2    ,4    ,2    ,4    ,5     ,5     , 5   ,4    ,2    ,4    ,4    ,4    ,7], $
       fieldNames:['jul','lon' ,'lat' ,'ht','dh', 'dh2', 'mth','day','year','hr','mn' ,'sec','x1' ,'x2' ,'lo2' ,'la2' ,'hf' ,'rms','y1' ,'y2' ,'y3' ,'y4' ,'what'] , $
;                   .(0)  .(1)  .(2)  .(3) .(4) .(5)   .(6)   .(7)  .(8)   .(9) .(10) .(11) .(12) .(13) .(14)  .(15)  .(16) .(17) .(18) .(19) .(20) .(21) .(22)
        fieldLocations:indgen(23), $
        fieldGroups:indgen(23) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)
print,'READ_ASCII   : ',filename 

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N,/RMS)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
;2010-12-29 11:32:00.000 
date  = JULDAY(data.mth,data.day,2000+data.year,data.hr,data.mn,data.sec)
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.hf*scale
st.rms = data.dh
RETURN, st
END


