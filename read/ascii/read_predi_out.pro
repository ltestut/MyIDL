FUNCTION read_predi_out, filename

IF (N_PARAMS() EQ 0)       THEN STOP, "UTILISATION:  st=READ_PREDI_OUT(filename,para='haut',year=2007,day_of_year=315)"

; Definition of the template
trm = {version:1.0,$
        datastart:0   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:4 ,$
        fieldTypes:[4,4,5,4], $
       fieldNames:['lat','lon','jul','val'] , $
;                   .(0)  .(1)  .(2)   .(3) 
        fieldLocations:[0,7,14,27], $
        fieldGroups:indgen(4) $
      }

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=trm)

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
st.jul = data.jul+JULDAY(1,1,1950,0,0,0)
st.val = data.val
RETURN, st
END