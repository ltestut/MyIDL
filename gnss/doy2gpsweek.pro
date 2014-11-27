FUNCTION doy2gpsweek, doy, year, date=date,verbose=verbose
; function to return the GPS week from the doy and the year
datum = JULDAY(1,6,1980,0,0,0)   ;GPS week 0 commence le dimanche
cdate = JULDAY(1,doy,year,0,0,0) ;calendar date
week  = FLOOR((cdate-datum)/7)
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'doy2gpsweek    :   doy/year = ',doy,'/',year
 PRINT,'doy2gpsweek    :  date      = ',print_date(cdate,/SINGLE)
 PRINT,'doy2gpsweek    :  GPS week  = ',week
ENDIF
IF KEYWORD_SET(date) THEN RETURN,cdate ELSE RETURN,week
END