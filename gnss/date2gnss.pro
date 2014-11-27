FUNCTION date2gnss, date, doy=doy, verbose=verbose
; function to return the GPS week from the calendar date
; /doy     : return the Day of Year instead of GPS week
CALDAT,date,mm,dd,yy
datum = JULDAY(1,6,1980,0,0,0)  ;GPS week 0 commence le dimanche
week  = FLOOR((date-datum)/7)
day   = FLOOR(date-JULDAY(1,1,yy,0,0,0))+1
IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'date2gnss    :  date     = ',print_date(date,/SINGLE)
 PRINT,'date2gnss    :  GPS week = ',week
 PRINT,'date2gnss    :   doy     = ',day
ENDIF
IF KEYWORD_SET(doy) THEN RETURN,day ELSE RETURN,week
END