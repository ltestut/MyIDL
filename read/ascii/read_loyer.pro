FUNCTION  read_loyer, filename


; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:' '   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:3 ,$
        fieldTypes:[5,4,4], $
       fieldNames:['day','val','rms'] , $
;                   .(0)  .(1)  .(2)
        fieldLocations:[0,16,36], $
        fieldGroups:indgen(3) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)


print,'READ_ASCII   : '

; Compute the date
date   = data.day & count = N_ELEMENTS(date)
st     = create_rms_julval(count)
st.jul = data.day + JULDAY(01,01,1950,0,0,0)
st.val = data.val*100. ; on passe en cm
st.rms=  data.rms*100. ;

print,"start date   =>",print_date(st[0].jul)
print,"end   date   =>",print_date(st[count-1].jul)
print,"Min-Max para =>",min(st.val,max=max_para),max_para


RETURN, st
END

