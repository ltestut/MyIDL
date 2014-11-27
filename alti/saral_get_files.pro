PRO test_ftp_files
; test ftp connection with given file
oUrl = OBJ_NEW('IDLnetUrl', URL_SCHEME='ftp', $
      URL_HOST='avisoftp.cnes.fr',URL_Port=21, $
      URL_USERNAME='anonymous', URL_PASSWORD='',$
      FTP_CONNECTION_MODE=0,$
URL_PATH='AVISO/pub/saral/ssha_gdr_t_old/cycle_001/SRL_GPR_2PTP001_0001_20130314_053927_20130314_062945.zip')
PRINT, oURL->Get(FILENAME=!desk+'toto.zip')
END


PRO saral_get_files, type=type, family=family, version=version,$
                     cycle=cycle,pass=pass, $
                     product=product, listing=listing,$
                     store=store
;;TODO make the documentation
; /PRODUCT      : List all available product
; /LISTING      : Listing of a given product
;; TODO add a /OPTIONS to print usage and available product for this satellite
 ;init a dictionary to config the ftp connexion


; TYPE='R' for reduced 1Hz only for certaint parameters (family-SSHA) 
;OGDR family
; OGDR native  product :
; OGDR reduced product :
 
;; Some explanation for Dick
; You'll see and the ftp site that there is different family product
;
query           = DICTIONARY()
query.host      = 'avisoftp.cnes.fr'
query.scheme    = 'ftp'
query.mode      = 0
url_product     ='AVISO/pub/saral/'
query.product   = query.scheme+'://'+query.host+'/'+url_product
query.tmp       = '' ;to be removed when new patch is active
IF NOT KEYWORD_SET(store) THEN query.store=!idl_aviso_arx+'saral/' ELSE $
                               query.store=store

 ;open the URL connection
oUrl = OBJ_NEW('IDLnetUrl', URL_SCHEME=query.scheme, $
   URL_HOST=query.host,URL_Port=21, $
   URL_USERNAME='anonymous', URL_PASSWORD='',FTP_CONNECTION_MODE=query.mode)

 ;list the available product
IF KEYWORD_SET(product) THEN BEGIN
  PRINT,'List of available product : '   
  prod_list=oURL.GetFtpDirList(URL=query.product,/SHORT)
  FOR i=0,N_ELEMENTS(prod_list)-1 DO PRINT,FORMAT='(%"   ../%s")',prod_list[i]
  RETURN 
ENDIF

 ;select a product type
IF NOT KEYWORD_SET(family)  THEN query.family='G' ELSE query.family=family
IF NOT KEYWORD_SET(type)    THEN query.type='R' ELSE query.type=type
IF NOT KEYWORD_SET(version) THEN query.version='t' ELSE query.version=version
IF NOT KEYWORD_SET(cycle)   THEN query.cycle=STRING(FORMAT='(I03)',1) ELSE $
                                  query.cycle=STRING(FORMAT='(I03)',cycle)
IF NOT KEYWORD_SET(pass)    THEN query.pass=STRING(FORMAT='(I04)',1) ELSE $
                                  query.pass=STRING(FORMAT='(I04)',pass)

 ;;TODO treat all possible case
CASE query.family OF
'O' : BEGIN
       IF (query.type EQ 'N') THEN query.folder=STRLOWCASE(query.family)+'dr_'$
          +query.version+query.tmp
       IF (query.type EQ 'R') THEN query.folder='ssha_ogdr_'+query.version
       IF (query.type EQ 'S') THEN query.folder='sigdr_'+query.version
      END

'I' : BEGIN
       IF (query.type EQ 'N') THEN query.folder=STRLOWCASE(query.family)+$
         'gdr_'+query.version
       IF (query.type EQ 'R') THEN query.folder='ssha_igdr_'+query.version
       IF (query.type EQ 'S') THEN query.folder='sigdr_'+query.version
      END

'G' : BEGIN
      IF (query.type EQ 'N') THEN query.folder=STRLOWCASE(query.family)+'dr_'$
                          +query.version+query.tmp
      IF (query.type EQ 'R') THEN query.folder='ssha_gdr_'+query.version+$
                          query.tmp
      END
ENDCASE


 ;define the url of the product type
query.url_path=url_product+query.folder+'/'
PRINT,'Looking at     : ',query.product+query.folder

IF KEYWORD_SET(listing) THEN BEGIN
 PRINT,FORMAT='(%" %s product listing: ")',query.folder
 content_list=oURL.GetFtpDirList(URL=query.product+query.folder+'/',/SHORT)
 FOR i=0,N_ELEMENTS(content_list)-1 DO PRINT,FORMAT='(%"   ../%s")',content_list[i]
 RETURN
ENDIF

 ;get the list of available files in the selected product
FOREACH cyc, query.cycle DO BEGIN
   file_list=oURL.GetFtpDirList(URL=query.product+query.folder+'/cycle_'+$
                                cyc,/SHORT)
   print,'Number of files in directory :',N_ELEMENTS(file_list)
   FOREACH track, query.pass DO BEGIN
   search_root=STRUPCASE('SRL_'+query.family+'P'+query.type+'_2P'+$
         query.version+'P'+cyc+'_'+track+'_***')

   file=file_list[WHERE(STRMATCH(file_list,search_root,/FOLD_CASE))]
   oUrl.SetProperty, URL_PATH=query.url_path+'cycle_'+cyc+'/'+file[0]
   downloadfile=oURL.Get(FILENAME=query.store+file[0])
   PRINT,'File downloaded  : ',downloadfile
   PRINT,'File stored in   : ',query.store+file
   FILE_UNZIP, query.store+file[0]
   ENDFOREACH
ENDFOREACH

OBJ_DESTROY, oUrl
END