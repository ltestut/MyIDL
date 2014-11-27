FUNCTION init_scrs_ppp_info
; init an HASH table to store the information
; from the output of a SCRS processing
def_start='06/01/1980 00:00'  ;default starting date = 1 GPS WEEK
def_end  ='06/01/1980 00:00'  ;default ending date
def_year = 1980
def_doy  = 6
def_week = doy2gpsweek(def_doy,def_year)
def_samp = 0
info=ORDEREDHASH('rinex_name','rinex.11o',$
                'rinex_basename','rinex',$
                'ref_system','ITRF??',$
                'year',def_year,'doy',def_doy,'week',def_week,$
                'start',def_start,'end',def_end,'sampling',def_samp,$
                'duration',0.0,$
                'longitude' ,0.0,'dlon',FLOAT(0.0),$
                'latitude'  ,0.0,'dlat',FLOAT(0.0),$
                'height'    ,0.0 ,'dht' ,FLOAT(0.0),$
                'url_host'  ,'www.',$
                'path_pdf'   ,'.pdf',$
                'path_res', '.res',$
                'path_full', '.zip')
RETURN,info
END

FUNCTION read_scrs_ppp_mail,filename
; read email from SCRSS PPP automaticly generated and return an HASH info table
; extract some important feature of the GNSS position and data location on the
; web (dat url for pdf and residuals) 
nlines =  FILE_LINES(filename)
lines  = STRARR(nlines)
info   = init_scrs_ppp_info()

OPENR, ppp, filename, /GET_LUN
READF, ppp, lines
FREE_LUN, ppp
 ;get index from header
iname     = WHERE(STREGEX(lines,'Subject: SCRS-PPP Solution pour '$
   ,/FOLD_CASE,/BOOLEAN) EQ 1, nname)  
icoord=WHERE(STREGEX(lines,'(ITRF08)',/FOLD_CASE,/BOOLEAN) EQ 1, ncoord)
IF (ncoord EQ 0) THEN BEGIN
 icoord=WHERE(STREGEX(lines,'(ITRF05)',/FOLD_CASE,/BOOLEAN) EQ 1)
 info['ref_system']='ITRF05'
ENDIF ELSE BEGIN
 info['ref_system']='ITRF08'
ENDELSE
  
ipdf=WHERE(STREGEX(lines,'.pdf>'    ,/FOLD_CASE,/BOOLEAN) EQ 1, npdf)
ires=WHERE(STREGEX(lines,'_res.zip>',/FOLD_CASE,/BOOLEAN) EQ 1, nres)
ifull=WHERE(STREGEX(lines,'full_output.zip>',/FOLD_CASE,/BOOLEAN) EQ 1, nfull)

str_name    = STRSPLIT(lines[iname],' ',LENGTH=lname,/EXTRACT)
str_lat     = STRSPLIT(lines[icoord[0]] ,' ',LENGTH=llat ,/EXTRACT)
str_lon     = STRSPLIT(lines[icoord[1]] ,' ',LENGTH=llon ,/EXTRACT)
str_ht      = STRSPLIT(lines[icoord[2]] ,' ',LENGTH=lht  ,/EXTRACT)
str_pdf     = STRSPLIT(lines[ipdf[0]]   ,'/',/EXTRACT)
str_res     = STRSPLIT(lines[ires[0]]   ,'/',/EXTRACT)
str_full    = STRSPLIT(lines[ifull[0]]   ,'/',/EXTRACT)


  ;build info name
url_host    = str_pdf[1]   ;get the HOSTNAME of web site
path_pdf    = STRMID(STRJOIN(str_pdf[2:-1],'/'),0,$
                                       STRPOS(STRJOIN(str_pdf[2:-1],'/'),'>'))
path_res    = STRMID(STRJOIN(str_res[2:-1],'/'),0,$
                                       STRPOS(STRJOIN(str_res[2:-1],'/'),'>'))
path_full   = STRMID(STRJOIN(str_full[2:-1],'/'),0,$
                                       STRPOS(STRJOIN(str_full[2:-1],'/'),'>'))
                                       
rinex_name  = str_name[-1]
rinex_split = STRSPLIT(rinex_name,'.',/EXTRACT)
rinex_basename=rinex_split[0]
lat  = SIGN(FLOAT(str_lat[2]))*(ABS(FLOAT(str_lat[2]))+FLOAT(str_lat[3])/60.+$
                                                       FLOAT(str_lat[4])/3600.)
lon  = SIGN(FLOAT(str_lon[2]))*(ABS(FLOAT(str_lon[2]))+FLOAT(str_lon[3])/60.+$
                                                       FLOAT(str_lon[4])/3600.)
ht   = FLOAT(str_ht[3])


slat = STRING(lat,FORMAT='(F10.6)')
slon = STRING(lon,FORMAT='(F10.6)')
sht  = str_ht[3]
dlat = str_lat[-2]
dlon = str_lon[-2]
dht  = str_ht[-2]

info['rinex_name']     = rinex_name
info['rinex_basename'] = rinex_basename
info['longitude']      = lon
info['dlon']           = FLOAT(dlon)
info['latitude']       = lat
info['dlat']           = FLOAT(dlat)
info['height']         = ht
info['dht']            = FLOAT(dht)
info['url_host']       = url_host
info['path_pdf']       = path_pdf
info['path_res']       = path_res
info['path_full']      = path_full
            
;PRINT,FORMAT='(%"name:%s / height:%8.3f " )',info['rinex_name'],info['height']
RETURN,info
END

FUNCTION read_scrs_sum, filename, info=info
; read the .sum summary file from a PPP SCRS processing and get the information
; on the start and end date (duration) and sampling 
nlines =  FILE_LINES(filename)
lines  = STRARR(nlines)
OPENR, UNIT, filename, /GET_LUN
READF, UNIT, lines
FREE_LUN, UNIT
 ;get index
idate=WHERE(STREGEX(lines,'Debut ',/FOLD_CASE,/BOOLEAN))
jstart=0.0D
jend=0.0D
FOR i=0,1 DO BEGIN
  str= STRSPLIT(lines[idate+i],' ',/EXTRACT) ;split the date
  day= STRSPLIT(str[2],'/',/EXTRACT) ;split in day
  hr = STRSPLIT(str[3],':',/EXTRACT) ;split in hour/minute
  date_fmt=day[2]+'/'+day[1]+'/'+day[0]+' '+hr[0]+':'+hr[1]
  IF i THEN info['end']=date_fmt ELSE info['start']=date_fmt 
ENDFOR
  str_samp=STRSPLIT(lines[idate+2],':',/EXTRACT) ;split the sampling line
  info['sampling']=str_samp[1]
  READS,info['start'],jstart,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2))'
  READS,info['end'],jend,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2))'
  CALDAT,jstart,mm,dd,yy,hh,mn,ss
  info['year']=yy
  info['week']=date2gnss(jstart)
  info['doy']=date2gnss(jstart,/DOY)
  info['duration']=(jend-jstart)*24.
RETURN,info
END

FUNCTION read_scrs_csv, filename
; read the .csv from the output_full.zip
data   = READ_ASCII(filename,DATA_START=1,DELIMITER=',',MISSING_VALUE=!VALUES.F_NAN)
Nd     = N_ELEMENTS(data.field1[0,*])
st     = create_julval(Nd)
st.jul = JULDAY(1,REFORM(data.field1[4,*]),REFORM(data.field1[5,*]),$
                  REFORM(data.field1[3,*]))
st.val = REFORM(data.field1[2,*])
RETURN,st
END

PRO scrs_ppp_mail_archive_summary, mail_dir=mail_dir, file_out=file_out,$
                                   download=download
; read a series of SCRS PPP email 
; 1) build an ascii summary report
; 2) download and unzip SCRS output
; 3) read the .sum file and get start, end and sampling info

IF NOT KEYWORD_SET(file_out) THEN file_out=!txt
IF NOT KEYWORD_SET(mail_dir) THEN mail_dir=$
   'C:\Users\ltestut\Desktop\scrs_mail\'

files=FILE_SEARCH(mail_dir,'*.eml')

IF KEYWORD_SET(download) THEN $
oUrl = OBJ_NEW('IDLnetUrl',URL_SCHEME='http',$
   URL_HOST='webapp.csrs.nrcan.gc.ca', $
   URL_USERNAME='anonymous', URL_PASSWORD='',$
   PROXY_HOSTNAME='wwwcache.univ-lr.fr',PROXY_PORT=3128,$
   PROXY_USERNAME='', PROXY_PASSWORD='',$
   URL_PATH='')

OPENW, UNIT, file_out, /GET_LUN
PRINTF,UNIT,"SCRS PPP Summary Report"
yy=0                                 ;init the year counter
FOREACH file,files DO BEGIN
 info     = read_scrs_ppp_mail(file) ;get info on geo-position from mail
 zip_path = mail_dir+info['rinex_basename'] ;set the download zip path
 IF KEYWORD_SET(download) THEN BEGIN
    oUrl.SetProperty,URL_PATH=info['path_full'] ;set the path of _full.zip
    PRINT,ourl->Get(FILENAME=zip_path+'.zip')   ;download the full.zip output
    FILE_UNZIP,zip_path+'.zip',zip_path         ;unzip the output
    FILE_DELETE,zip_path+'.zip'                 ;delete zip file
 ENDIF
 ;read the .sum file and fill the sinfo HASH table
 sinfo=read_scrs_sum(zip_path+'/'+info['rinex_basename']+'.sum',INFO=info)
 IF info['year'] NE yy THEN PRINTF,UNIT,"# ",STRING(info['year'],FORMAT='(I4)')$
                            ,'  -- '+sinfo['ref_system']+' --'
 yy=info['year']

;;TODO ADD an automatic plotting of the .csv file range=sinfo['height']+/- 1cm
 ;plot the time series of the output
; st=read_scrs_csv(zip_path+'/'+info['rinex_basename']+'.csv')


 ;print the summary line on the report
PRINTF,UNIT,FORMAT='(%"week-doy:%d-%03d / %s -- %s [%5.1f h]/ name:%s / height:%8.3f +/- %5.3f m" )',$
 sinfo['week'],sinfo['doy'],sinfo['start'],sinfo['end'],sinfo['duration'],$
 sinfo['rinex_name'],$
 sinfo['height'],sinfo['dht']
    
ENDFOREACH
FREE_LUN, UNIT
CLOSE, UNIT
If KEYWORD_SET(download) THEN oUrl->Cleanup
PRINT,"SCRS Summary Report in ",file_out
END