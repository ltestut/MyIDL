FUNCTION duration_julval, st, tmin=tmin, tmax=tmax, dmin=dmin, dmax=dmax
;compute and return the duration of the serie in days

dmin = MIN(st.jul,/NAN,MAX=dmax)
PRINT,'Original start date : ',print_date(dmin,/SINGLE)
PRINT,'Original end date   : ',print_date(dmax,/SINGLE)

IF KEYWORD_SET(tmin) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF KEYWORD_SET(tmax) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
duration  = dmax-dmin  ;duration in days
IF (duration LT 0) THEN STOP,'ATTENTION: tmin > tmax' 

print,"Interval duration                    : ",duration,'  Days / ',duration*24.,' Hours'
RETURN,duration
END