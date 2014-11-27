FUNCTION transform_date, str
; transform from 01021999203055 to 01/02/1999 20:30:55 
tstr=strmid(str,0,2)+'/'+strmid(str,2,2)+'/'+strmid(str,4,4)+' '+strmid(str,8,2)+':'+strmid(str,10,2)+':'+strmid(str,12,2)
RETURN, tstr
END
PRO print_chrono,chrono, verbose=verbose
; dispay the chrono
cpt_line=0
skey    = SORT((chrono.keys()).toarray())

PRINT,FORMAT='(%"Chrono Nbre keys    %d")',chrono.count()
FOREACH key,(chrono.keys())[skey] DO BEGIN        ;loop on the number of key (year,week,...)
  cpt_line++
  PRINT,FORMAT='(%"%d --> key[nblock]/type : %d[%d]/%s ")',cpt_line,key,chrono[key].count()-1,(chrono[key])[0]
  FOR i=1,chrono[key].count()-1 DO BEGIN ;loop on the number of block for this period
    PRINT,FORMAT='(%"    *%d[%d] From %s <--> %s   ")',key,i,transform_date(((chrono[key])[i])['start_block']),transform_date(((chrono[key])[i])['end_block'])
    IF KEYWORD_SET(verbose) THEN FOREACH cpara,((chrono[key])[i]).keys() DO PRINT,'                  ',cpara,' : ',((chrono[key])[i])[cpara]
  ENDFOR
ENDFOREACH


END