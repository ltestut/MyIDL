FUNCTION  read_refmar, filename
; read data from refmar web site
IF NOT KEYWORD_SET(format_date) THEN format_date='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
templ = USE_TEMPLATE('refmar')
data  = READ_ASCII(filename,TEMPLATE=templ)
PRINT,'USE_TEMPLATE :  refmar'
PRINT,'READ_ASCII   : ',filename
N    = N_ELEMENTS(data.jul)
st   = create_julval(N)
date = DBLARR(N)

READS,data.jul[0:N-1],date,FORMAT=format_date
st.jul = date
st.val = data.(1)[0:N-1]

itrou = where(st.val eq 99.999, nb_trou)
IF (nb_trou ne 0) THEN BEGIN
  st[itrou].val=!VALUES.F_NAN
ENDIF
  RETURN, finite_st(st)
END

