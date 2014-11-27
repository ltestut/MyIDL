PRO chop_julval, st, file_out=file_out, _EXTRA=_EXTRA
; chop 

IF NOT KEYWORD_SET(file_out) THEN file_out=!txt
str = getfilename(file_out)
CALDAT, st.jul,mm,dd,yy
ymin=MIN(yy,MAX=ymax)

FOR i=ymin,ymax,1 DO BEGIN
    iy=WHERE(yy EQ i,count)
    write_jul2jma,where_julval(st,iy),FILENAME=str_replace(file_out,str.suffix,STRING(i,FORMAT='(I4)')+'.'+str.suffix),_EXTRA=_EXTRA
ENDFOR

END