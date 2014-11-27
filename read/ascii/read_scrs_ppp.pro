FUNCTION  read_scrs_ppp, filename, pos=pos
; fonction qui permet de lire le format de sortie du logiciel online SCRS-PPP (NRCAN)
; /POS : read the .pos file (default is to read the .csv) 

; format .pos
;DIR FRAME        STN         DOY YEAR-MM-DD HR:MN:SS.SSS NSV GDOP    SDC    SDP       DLAT(m)       DLON(m)       DHGT(m)         CLK(ns)   TZD(m)  SLAT(m)  SLON(m)  SHGT(m) SCLK(ns)  STZD(m) LAT(d) LAT(m)    LAT(s) LON(d) LON(m)    LON(s)   HGT(m) Hauteur_CGVD28_HTv2.0 ORDONNEE(m) ABSCISSE(m) ZONE      ECHELLE HEMI  AM ECHELLE_COMBINE 
;BWD ITRF(IGS05) PAFB 363.4805556 2010-12-29 11:32:00.000   8  0.0   1.13 0.0133        -0.369        -0.495        -8.403     -489474.665   2.3812    0.068    0.021    0.055    0.082   0.0020    -49     51 12.88780     69     56 29.19311        39.536   NNNN        4477223.726  567674.614   42      0.99965625 S  0 0.99965005 

; format .csv
;latitude_decimal_degree,longitude_decimal_degree,ellipsoidal_height_m,decimal_hour,day_of_year,year,rcvr_clk_ns
;-66.6615717,140.0084225,-35.664,6.66667,20,2008,126395.085

; Definition of the template
IF KEYWORD_SET(pos) THEN BEGIN
trm = {version:1.0,$
        datastart:8   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:5 ,$
        fieldTypes:[7     ,7    ,7     ,4   ,7     ], $
       fieldNames:['txt1','date','txt2','ht','txt3'] , $
;                   .(0)  .(1)  .(2)   .(3)   .(4)  .(5)  .(6)   .(7)    .(8)       .(9)    .(10)
        fieldLocations:[0,33,58,242,254], $
        fieldGroups:indgen(5) $
      }
ENDIF ELSE BEGIN
; Definition of the template
trm = {version:1.0,$
        datastart:1   ,$
        delimiter:','   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:''   ,$
        fieldcount:7 ,$
        fieldTypes:[5     ,5    ,4     , 5   , 2   ,2     ,5], $
        fieldNames:['lat','lon','ht'   ,'hd' ,'doy','year','clock'] , $
        fieldLocations:INDGEN(7), $
        fieldGroups:INDGEN(7) $
      }
ENDELSE

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)
print,'READ_ASCII   : ',filename 
N    = N_ELEMENTS(data.ht) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
IF KEYWORD_SET(POS) THEN READS,data.date[0:N-1],date,FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI2,X,CMI2,X,CSI2))' ELSE date = JULDAY(1,data.doy,data.year,data.hd)

print,"start : ",print_date(date[0],/SINGLE)
print,"end   : ",print_date(date[-1],/SINGLE)


st.jul = date
st.val = data.ht
RETURN, st
END


