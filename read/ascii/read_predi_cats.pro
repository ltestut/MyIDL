FUNCTION  read_predi_cats, filename, para=para, year=year, day_of_year=day_of_year

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_PREDI_CATS(filename,para='haut',year=2007,day_of_year=315)"
IF (KEYWORD_SET(para)EQ 0) THEN STOP, "! Need the tag parameter to read"
IF (KEYWORD_SET(day_of_year) EQ 0) THEN STOP, '! Need the first day [1 - 365] of the GPS week "
IF (KEYWORD_SET(year) EQ 0) THEN year=2007


; Definition of the template
trm = {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:5 ,$
        fieldTypes:[5,5,5,5,5], $
       fieldNames:['day','sec','val','xxx',  'yyy'] , $
;                   .(0)  .(1)  .(2)  .(3)   .(4)
        fieldLocations:[0,16,32,48,65], $
        fieldGroups:indgen(5) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ trm.fieldNames)

print,'READ_ASCII   : ',filename & print,'Extract para : ',trm.fieldNames[IP]

; Compute the date
date   = data.sec & count = N_ELEMENTS(date)
st     = create_julval(count)
st.jul = JULDAY(01,day_of_year,year,0,0,0)+date
st.val = data.(IP)

print,"start date   =>",print_date(st[0].jul)
print,"end   date   =>",print_date(st[count-1].jul)
print,"Min-Max para =>",min(st.val,max=max_para),max_para


RETURN, st
END

