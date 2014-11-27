FUNCTION  read_dat, filename

; Define the template to be used
templ = USE_TEMPLATE('dat')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'USE_TEMPLATE :  dat'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
date = DBLARR(N)

; Cut the string of the date field to build the corresponding date 
READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date
st.val = data.(1)[0:N-1]/10.
RETURN, st
END
 
