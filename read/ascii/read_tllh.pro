FUNCTION read_tllh, filename, para=para

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_LLHT(filename,para='haut')"
IF (KEYWORD_SET(para)EQ 0) THEN para='haut'

; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:4 ,$
        fieldTypes:[5,5,5,5], $
        fieldNames:['sec','lat','lon','haut'] , $
;                   .(0)  .(1)  .(2)   .(3)   
        fieldLocations:[0,16,32,48], $
        fieldGroups:indgen(4) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ trm.fieldNames)

print,'READ_ASCII   : ',filename & print,'Extract para : ',trm.fieldNames[IP]

; Compute the date (en heure depuis le 14/11/2007)
date   = data.sec & count = N_ELEMENTS(date)
st     = create_julval(count)
st.jul = JULDAY(11,14,2007,0,0,0)+date/24.
st.val = data.(IP)*1.

print,"start date   =>",print_date(st[0].jul)
print,"end   date   =>",print_date(st[count-1].jul)
st.val = st.val - MEAN(st.val,/NAN) ;on enleve une valeur moyenne
print,"Min-Max para =>",min(st.val,max=max_para),max_para


id = WHERE(ABS(st.val) GT 10.,count)
print,"Nombre de donnees enlevees :",count
st[id].val=!VALUES.F_NAN ;on met toutes les valeurs > 10. a NaN


RETURN, st
END