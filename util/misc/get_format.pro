FUNCTION get_format, str_size
IF (str_size EQ 4)  THEN F='(C(CYI4.4))'
IF (str_size EQ 6)  THEN F='(C(CMOI2.2,CYI4.4))'
IF (str_size EQ 8)  THEN F='(C(CDI2.2,CMOI2.2,CYI4.4))'
IF (str_size EQ 10) THEN F='(C(CDI2.2,CMOI2.2,CYI4.4,CHI2.2))'
IF (str_size EQ 12) THEN F='(C(CDI2.2,CMOI2.2,CYI4.4,CHI2.2,CMI2.2))'
IF (str_size EQ 14) THEN F='(C(CDI2.2,CMOI2.2,CYI4.4,CHI2.2,CMI2.2,CSI2.2))'
RETURN, F 
END


