FUNCTION  read_trame_ddu, filename, para=para, ref=ref, tirair=tirair

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_TRAME(filename,template_name,para=parameter)'
IF (KEYWORD_SET(para)EQ 0) THEN STOP, '! Need the tag parameter to read'

; Define the template to be used
;templ = USE_TEMPLATE('trm')

trm = {version:1.0,$
        datastart:0   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:15 ,$
        fieldTypes:[2,2,2,2,2,2,2,2,4,4,4,4,4,4,4], $
       fieldNames:['day','mth','year','hour','min','sec','nsta','nmrg','bot','twat','cwat','baro','tbat','slev','ect'] , $
;                   .(0)  .(1)  .(2)   .(3)   .(4)  .(5)  .(6)  .(7)   .(8)  .(9)   .(10)  .(11)  .(12)  .(13)  .(14)
        fieldLocations:[0,3,6,9,12,15,18,22,27,35,40,45,52,57,65], $
        fieldGroups:indgen(15) $
      }

templ=trm
; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


; Find the tag number of the keyword string parameter para=
IP    = WHERE(para EQ templ.fieldNames)

print,'USE_TEMPLATE : trm' & print,'READ_ASCII   : ',filename & print,'Extract para : ',templ.fieldNames[IP]

; Compute the date
date  = DBLARR(N_ELEMENTS(data.day)) & count = N_ELEMENTS(data.day) & date = JULDAY(data.mth,data.day,(data.year+2000),data.hour,data.min,data.sec)
;id   = WHERE(data.min MOD 2 EQ 0, count)
st   = create_julval(count)
;date = date[id]

;print,date[N-1],FORMAT='(C())'
st.jul = date
;val    = data.(IP)[ID]

IF (para EQ 'twat') THEN BEGIN
    tab=[-2.536,3.661E-2,-8.241E-6,1.156E-8]
    val=tab[0]+tab[1]*data.twat+tab[2]*data.twat*data.twat+tab[3]*data.twat*data.twat*data.twat
ENDIF

IF (para EQ 'cwat') THEN BEGIN
    tab=[-6.554e-1,7.282e-2]
    val=tab[0]+tab[1]*data.cwat
ENDIF


IF (para EQ 'bot') THEN BEGIN
    tab=[-2.536,3.661E-2,-8.241E-6,1.156E-8]
    temp=tab[0]+tab[1]*data.twat+tab[2]*data.twat*data.twat+tab[3]*data.twat*data.twat*data.twat
    sal=35.
    print,mean(temp)
    t=temp
; Compute the density in (kg/l) from temperature and salinity
    p0  = 5890. + 38.*t - 0.375*t*t + 3.*sal
    a1  = 1779.5 + 11.25*t - 0.0745*t*t - (3.8 + 0.01*t)*sal
    a0  = 0.6980
    rho = p0/(a1 + a0*p0)
;    print,rho

    IF (mean(temp) LT 10.) THEN BEGIN
        tabp=[-5.667341e3,1.295774e-2,-8.303957e-9,2.846386e-15]
        val=(tabp[0]+tabp[1]*data.bot+tabp[2]*data.bot*data.bot+tabp[3]*data.bot*data.bot*data.bot)*10.
        val=(val-data.baro)*10000./(rho*1000.*9.78049)
    ENDIF
ENDIF

IF (para EQ 'slev') THEN BEGIN
  IF NOT KEYWORD_SET(ref) THEN ref=400.        ;ref= 400.0  ==> reference par rapport au bas de la tige hasteloi
  val=ref-data.slev                 ;ref= 423.6  ==> reference par rapport au zero hydro a Kerguelen
  IF KEYWORD_SET(tirair) THEN val=data.slev  ;renvoie le tirant d'air
ENDIF

IF (para EQ 'baro') THEN BEGIN
  val=data.baro
ENDIF

IF (para EQ 'ect') THEN BEGIN
  val=data.ect
ENDIF

st.val=val ;[id]


RETURN, st
END

