FUNCTION  read_geodimeter, filename, scale=scale, para=para, year=year, day_of_year=day_of_year, h_base=h_base
; fonction qui permet de lire le format de sortie du logiciel trimble TTC
; day_of_year : c'est le numero de jour de l'annee du premier jour de la semaine GPS

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_GEODIMETER(filename,para='haut',year=2007,day_of_year=315)"
IF NOT KEYWORD_SET(para)   THEN para='haut'
IF (KEYWORD_SET(day_of_year) EQ 0) THEN STOP, '! Need the first day [1 - 365] of the GPS week "
IF (KEYWORD_SET(year) EQ 0) THEN year=2007


; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:11 ,$
        fieldTypes:[5,5,5,4,4,4,4,4,2,7,7], $
       fieldNames:['sec','lat','lon','haut',  'dx' ,'dy', 'dz','pdop' ,'nsat' ,'station',  'type'] , $
;                   .(0)  .(1)  .(2)   .(3)   .(4)  .(5)  .(6)   .(7)    .(8)       .(9)    .(10)
        fieldLocations:[0,15,29,43,52,59,66,73,78,81,90], $
        fieldGroups:indgen(11) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)

; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ trm.fieldNames)
scl   = 1.
IF NOT KEYWORD_SET(scale) THEN scale = 1.  

print,'READ_ASCII   : ',filename & print,'Extract para : ',trm.fieldNames[IP]

; Compute the date
date   = data.sec & count = N_ELEMENTS(date)
st     = create_julval(count,/RMS)
st.jul = JULDAY(01,day_of_year,year,0,0,0)+date/(3600.*24.)
st.val = data.(IP)*scale ; on passe en cm
IF (para EQ 'haut') THEN st.rms = data.dz*100.
IF (para EQ 'lon') THEN st.rms = data.dx*100.
IF (para EQ 'lat') THEN st.rms = data.dy*100.
  
IF KEYWORD_SET(h_base) THEN st.val=st.val+(h_base*scale)

print,"start date   =>",print_date(st[0].jul)
print,"end   date   =>",print_date(st[count-1].jul)
print,"Min-Max para =>",min(st.val,max=max_para),max_para


RETURN, st
END

