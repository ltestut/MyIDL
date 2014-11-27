FUNCTION read_1hz_krohne, filename, start_date=start_date, end_date=end_date, step_size=step_size, nech=nech, $
                         ref=ref, slev=slev


IF NOT KEYWORD_SET(start_date) THEN start_date = JULDAY(08,18,2008,13,40,00)
IF NOT KEYWORD_SET(end_date)   THEN end_date   = JULDAY(08,19,2008,09,00,00)
IF NOT KEYWORD_SET(step_size)  THEN step_size  = 20                             ;ech en minutes
IF NOT KEYWORD_SET(nech)       THEN nech       = 40                             ;nbre d'echantillons

tmp = {version:1.0,$
        datastart:0   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:1 ,$
        fieldTypes:[4], $
        fieldNames:['val'] , $
        fieldLocations:[0]    , $
        fieldGroups:indgen(1) $
      }

; calcul de la base de temps
; --------------------------

print,"input start_date ",print_date(start_date,/SINGLE)
print,"input end_date   ",print_date(end_date,/SINGLE)

round_time=TIMEGEN(START=start_date,FINAL=end_date,STEP_SIZE=step_size,UNITS='Minutes')
Nr  = N_ELEMENTS(round_time)
Nt  = Nr*nech
st  = create_julval(Nt)
time= DBLARR(Nt)
print,"output start_date ",print_date(round_time[0],/SINGLE)
print,"output end_date   ",  print_date(round_time[Nr-1],/SINGLE)

cpt = 0
FOR i=0,Nr-1 DO BEGIN
   FOR j=0,nech-1 DO BEGIN
   time[cpt] = round_time[i]+((j-nech/2)/(3600.*24.))
   cpt=cpt+1
   ENDFOR
ENDFOR
st.jul = time

; Read the data corresponding to the defined template
; --------------------------------------------------
data  = READ_ASCII(filename,TEMPLATE=tmp)
print,'READ_ASCII   : ',filename

print,'Nr  =>',Nr
print,'Ndata in input file =>',N_ELEMENTS(data.val),' / ',Nt
print,'last element',data.val[N_ELEMENTS(data.val)-1]

IF KEYWORD_SET(slev) THEN BEGIN        ;renvoie le niveau d'eau
   IF NOT KEYWORD_SET(ref) THEN ref=250.  ;==> reference par rapport au bas de la tige (400cm ker, 250cm spa)
   val=ref-data.val         
   print,"Calcul du niveau de la mer, ref =",ref
ENDIF ELSE BEGIN             
   val=data.val              ;renvoie le tirant d'air par defaut
   print,"lecture du tirant d'air"
ENDELSE
st.val=val
RETURN, st
END