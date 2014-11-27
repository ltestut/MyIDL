function read_mgr_simple, filename, scale=scale, verbose=verbose 
; fonction de lecture des fichiers de sortie d'analyse harmonique (homage/analyse.3.20.exe) au format .mgr
; pour un fichier simple
; renvoie une structure de type mgr (/!\ non compatible avec IDL7)

 ;gestion des mots-cles et format du verbose
IF NOT KEYWORD_SET(scale) THEN scale=1.
fmt_verb='(A1,A-20,A1,A7,A1,A7,A1,A1,A-15,A1,A7,A3)'

 ;lecture du fichier .mgr et renvoie des lignes dans le tableau de chaines de caracteres 'lines'
nlines =  FILE_LINES(filename)
lines  = STRARR(nlines)
OPENR, mgr_unit, filename, /GET_LUN
READF, mgr_unit, lines
FREE_LUN, mgr_unit
 ;recuperation des indices des lignes d'entete
isep  = WHERE(stregex(lines,'_______',/FOLD_CASE,/BOOLEAN) EQ 1, nsep)       ;indice des lignes de separation
isep[0]  =  nlines                                                             ;indice de fin de fichier
ista  = WHERE(stregex(lines,'STATION',/FOLD_CASE,/BOOLEAN) EQ 1, nsta)       ;indice des lignes station
iori  = WHERE(stregex(lines,'ORIGINE',/FOLD_CASE,/BOOLEAN) EQ 1, nori)       ;indice des lignes origine
iloc  = WHERE(stregex(lines,'LOCALISATION',/FOLD_CASE,/BOOLEAN) EQ 1, nloc)  ;indice des lignes localisation
ienr  = WHERE(stregex(lines,'ENREGISTREMENT',/FOLD_CASE,/BOOLEAN) EQ 1, nenr);indice des lignes enregistrement
ival  = WHERE(stregex(lines,'VALIDATION',/FOLD_CASE,/BOOLEAN) EQ 1, nval)    ;indice des lignes validation
IF (nval EQ 0) THEN ival=ienr ;si pas de ligne 'VALIDATION' alors la derniere de l'entete est ienr
 ;recuperation des informations de debut et longueur des chaines de caracteres qui nous interessent
str_sta = STRSPLIT(lines[ista],':',LENGTH=lsta)
str_ori = STRSPLIT(lines[iori],':',LENGTH=lori)
str_loc = STRSPLIT(lines[iloc],' ',LENGTH=lloc)
b_sta   = INTARR(2) ;deb/longeur chaines de caracteres station
b_ori   = INTARR(2) ;deb/longeur chaines de caracteres origine 
b_lat   = INTARR(2) ;deb/longeur chaines de caracteres latitude
b_lon   = INTARR(2) ;deb/longeur chaines de caracteres longitude
b_sta[0] = str_sta[1] ;debut de la chaine de caractere
b_sta[1] = lsta[1]    ;longueur de la chaine de caractere
b_ori[0] = str_ori[1] ;debut de la chaine de caractere
b_ori[1] = lori[1]    ;longueur de la chaine de caractere
b_lat[0] = str_loc[2] ;debut de la chaine de caractere
b_lat[1] = lloc[2]    ;longueur de la chaine de caractere
b_lon[0] = str_loc[3] ;debut de la chaine de caractere
b_lon[1] = lloc[3]    ;longueur de la chaine de caractere
 ;calcul du nombre d'onde analysee pour chaque position
 ;remplissage des tableaux de nom,origine,lat et lon
nwa   = FLOOR(isep-ival-1)
sta   = STRMID(lines[ista],b_sta[0],b_sta[1])
ori   = STRMID(lines[iori],b_ori[0],b_ori[1])
lat   = STRMID(lines[iloc],b_lat[0],b_lat[1])
lon   = STRMID(lines[iloc],b_lon[0],b_lon[1])
 ;creation de la structure mgr a nsta=1 et nwa ondes
mgr     = create_mgr(nsta,MAX(nwa,/NAN))
str_wav = STRSPLIT(lines[ival+1:isep-1], ' ', LENGTH=lwav) ;extraction debut et longueur de chaines de caracteres
b_wna   = INTARR(2,nwa) ;deb/longeur chaines de caracteres wave_name
b_amp   = INTARR(2,nwa) ;deb/longeur chaines de caracteres amplitude
b_pha   = INTARR(2,nwa) ;deb/longeur chaines de caracteres phase
FOR j=0,nwa[0]-1 DO BEGIN ;on boucle sur l'ensemble des ondes
 b_wna[0,j] = (str_wav[j])[1] ;debut de la chaine de caractere
 b_wna[1,j] = (lwav[j])[1]    ;longueur de la chaine de caractere
 b_amp[0,j] = (str_wav[j])[2] ;debut de la chaine de caractere
 b_amp[1,j] = (lwav[j])[2]    ;longueur de la chaine de caractere
 b_pha[0,j] = (str_wav[j])[3] ;debut de la chaine de caractere
 b_pha[1,j] = (lwav[j])[3]    ;longueur de la chaine de caractere
 wname      = STRMID(lines[ival+1:isep-1],b_wna[0,*],b_wna[1,*])
 wamp       = STRMID(lines[ival+1:isep-1],b_amp[0,*],b_amp[1,*])
 wpha       = STRMID(lines[ival+1:isep-1],b_pha[0,*],b_pha[1,*])
ENDFOR
 ;on remplit la structure
mgr.name     = STRCOMPRESS(sta,/REMOVE_ALL)
mgr.origine  = STRCOMPRESS(ori,/REMOVE_ALL)
mgr.lat      = FLOAT(lat)
mgr.lon      = FLOAT(lon)
mgr.nwav     = nwa[0]
mgr.filename = filename 
mgr.code[0:nwa-1] = wave2code(wname)  ;on remplit les code des nwa premieres ondes
mgr.wave[0:nwa-1] = wname              ;on remplit les nwa premieres ondes
mgr.amp[0:nwa-1]  = FLOAT(wamp)*scale
mgr.pha[0:nwa-1]  = FLOAT(wpha)

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,'Nombre de stations du fichiers mgr  : ', nsta
 PRINT,'Informations stations               : '
 PRINT,FORMAT=fmt_verb,'>',STRCOMPRESS(mgr.name,/REMOVE_ALL),'(',STRING(mgr.lon,FORMAT='(F7.2)'),',',STRING(mgr.lat,FORMAT='(F7.2)'),')','[',STRCOMPRESS(mgr.origine,/REMOVE_ALL),']'
ENDIF
RETURN, mgr
END



;####################################################################################
FUNCTION read_mgr, filename, xtrack=xtrack, origine=origine, scale=scale, verbose=verbose
; fonction de lecture d'un fichier de type .mgr (sortie d'analyse harmonique) contenant
; une ou plusieurs position analysee.
; renvoie une structure de type mgr

 ;gestion des mot cles
IF NOT KEYWORD_SET(scale) THEN scale=1.
fmt_verb='(A1,A-20,A1,A7,A1,A7,A1,A1,A-15,A1,A7,A3)'

 ;lecture du fichier .mgr et renvoie des lignes dans le tableau lines
nlines = FILE_LINES(filename)
lines  = STRARR(nlines)
OPENR, mgr_unit, filename, /GET_LUN  ;ouverture du fichier .mgr
READF, mgr_unit, lines               ;on lit toutes les lignes du fichier .mgr
FREE_LUN, mgr_unit                   ;on ferme ensuite le fichier
 ;recuperation des indices des lignes d'entete
isep  = WHERE(stregex(lines,'_______',/FOLD_CASE,/BOOLEAN) EQ 1, nsep)       ;indice des lignes de separation
isep  =  SHIFT(isep,-1) & isep[nsep-1]=nlines                                 ;on decale le tableau
ista  = WHERE(stregex(lines,'STATION',/FOLD_CASE,/BOOLEAN) EQ 1, nsta)       ;indice des lignes station
iori  = WHERE(stregex(lines,'ORIGINE',/FOLD_CASE,/BOOLEAN) EQ 1, nori)       ;indice des lignes origine
iloc  = WHERE(stregex(lines,'LOCALISATION',/FOLD_CASE,/BOOLEAN) EQ 1, nloc)  ;indice des lignes localisation
ienr  = WHERE(stregex(lines,'ENREGISTREMENT',/FOLD_CASE,/BOOLEAN) EQ 1, nenr);indice des lignes enregistrement
ival  = WHERE(stregex(lines,'VALIDATION',/FOLD_CASE,/BOOLEAN) EQ 1, nval)    ;indice des lignes validation
IF (nsta GT 1) THEN BEGIN
;###############EXEMPLE ENTETE FICHIER MGR#####################
;________________________________________________________________________________
; 
; STATION No 0001  : track-ref.TP+J1.105.dat
; ORIGINE          : X-TRACK SLA
; LOCALISATION     :     0.013N   65.912E    0.00m Triangle :     0
; ENREGISTREMENT   : Debut: 01/11/1992  Fin: 01/06/2009  Duree:   259     
; VALIDATION       : Statistical QC@CTOH
;##############################################################
;initialisation des tableaux de debut et longueur des chaines de caracteres qui nous interessent
 b_sta       = INTARR(2,nsta) ;deb/longeur chaines de caracteres station
 b_num       = INTARR(2,nsta) ;deb/longeur chaines de caracteres numero de STATION
 b_track     = INTARR(2,nsta) ;deb/longeur chaines de caracteres numero de trace 
 b_ori       = INTARR(2,nsta) ;deb/longeur chaines de caracteres ORIGINE 
 b_lat       = INTARR(2,nsta) ;deb/longeur chaines de caracteres latitude
 b_lon       = INTARR(2,nsta) ;deb/longeur chaines de caracteres longitude
 b_enr       = INTARR(2,nsta) ;deb/longeur chaines de caracteres ENREGISTREMENT
 b_val       = INTARR(2,nsta) ;deb/longeur chaines de caracteres VALIDATION
;recuperation des informations de debut et longueur des chaines de caracteres qui nous interessent
 str_sta     = STRSPLIT(lines[ista],':',LENGTH=lsta)
 str_num     = STRSPLIT(lines[ista],' ',LENGTH=lnum)
 str_track   = STRSPLIT(lines[ista],'.',LENGTH=ltrack)
 str_ori     = STRSPLIT(lines[iori],':',LENGTH=lori)
 str_loc     = STRSPLIT(lines[iloc],' ',LENGTH=lloc)
 str_enr     = STRSPLIT(lines[ienr],': D',LENGTH=lenr,/REGEX)
 str_val     = STRSPLIT(lines[ival],':',LENGTH=lval)
  FOR i=0,nsta-1 DO BEGIN ;deb/longeur chaines de caracteres STATION
     b_sta[0,i] = (str_sta[i])[1] ;debut de la chaine de caractere
     b_sta[1,i] = (lsta[i])[1]    ;longueur de la chaine de caractere
     b_num[0,i] = (str_num[i])[2] ;debut de la chaine de caractere
     b_num[1,i] = (lnum[i])[2]    ;longueur de la chaine de caractere
     IF KEYWORD_SET(xtrack) THEN BEGIN
      b_track[0,i] = (str_track[i])[2] ;debut de la chaine de caractere
      b_track[1,i] = (ltrack[i])[2]    ;longueur de la chaine de caractere
     ENDIF
     b_ori[0,i] = (str_ori[i])[1]   ;debut de la chaine de caractere
     b_ori[1,i] = (lori[i])[1]      ;longueur de la chaine de caractere
     b_lat[0,i] = (str_loc[i])[2]   ;debut de la chaine de caractere
     b_lat[1,i] = (lloc[i])[2]      ;longueur de la chaine de caractere
     b_lon[0,i] = (str_loc[i])[3]   ;debut de la chaine de caractere
     b_lon[1,i] = (lloc[i])[3]      ;longueur de la chaine de caractere
     b_enr[0,i] = (str_enr[i])[1]-1 ;debut de la chaine de caractere
     b_enr[1,i] = (lenr[i])[1]      ;longueur de la chaine de caractere
     b_val[0,i] = (str_val[i])[1]   ;debut de la chaine de caractere
     b_val[1,i] = (lval[i])[1]      ;longueur de la chaine de caractere
  ENDFOR
 ;initialisation des tableaux pour remplir la structure mgr
 sta   = STRARR(nsta)
 ori   = STRARR(nori)
 lat   = FLTARR(nloc)
 lon   = FLTARR(nloc)
 nwa   = INTARR(nsta)
 enr   = STRARR(nenr)
 val   = STRARR(nval)
 ;calcul du nombre d'onde analysee pour chaque position
 ;remplissage des tableaux de nom,origine,lat et lon
 nwa   = isep-ival-1
 sta   = STRMID(lines[ista],b_sta[0,*],b_sta[1,*])
 num   = STRMID(lines[ista],b_num[0,*],b_num[1,*])
 IF KEYWORD_SET(xtrack) THEN track = STRMID(lines[ista],b_track[0,*],b_track[1,*])
 ori   = STRMID(lines[iori],b_ori[0,*],b_ori[1,*])
 lat   = STRMID(lines[iloc],b_lat[0,*],b_lat[1,*])
 lon   = STRMID(lines[iloc],b_lon[0,*],b_lon[1,*])
 enr   = STRMID(lines[ienr],b_enr[0,*],b_enr[1,*])
 val   = STRMID(lines[ival],b_val[0,*],b_val[1,*])

 ;creation de la structure mgr
 mgr=create_mgr(nsta,MAX(nwa,/NAN))

 FOR i=0,nsta-1 DO BEGIN ;on boucle sur l'ensemble des stations
  str_wav = STRSPLIT(lines[ival[i]+1:isep[i]-1], ' ', LENGTH=lwav) ;extraction debut et longueur de chaines de caracteres
  b_wna   = INTARR(2,nwa[i]) ;deb/longeur chaines de caracteres wave_name
  b_amp   = INTARR(2,nwa[i]) ;deb/longeur chaines de caracteres amplitude
  b_pha   = INTARR(2,nwa[i]) ;deb/longeur chaines de caracteres phase
   FOR j=0,nwa[i]-1 DO BEGIN ;on boucle sur l'ensemble des ondes
    b_wna[0,j] = (str_wav[j])[1] ;debut de la chaine de caractere
    b_wna[1,j] = (lwav[j])[1]    ;longueur de la chaine de caractere
    b_amp[0,j] = (str_wav[j])[2] ;debut de la chaine de caractere
    b_amp[1,j] = (lwav[j])[2]    ;longueur de la chaine de caractere
    b_pha[0,j] = (str_wav[j])[3] ;debut de la chaine de caractere
    b_pha[1,j] = (lwav[j])[3]    ;longueur de la chaine de caractere
    wname      = STRMID(lines[ival[i]+1:isep[i]-1],b_wna[0,*],b_wna[1,*])
    wamp       = STRMID(lines[ival[i]+1:isep[i]-1],b_amp[0,*],b_amp[1,*])
    wpha       = STRMID(lines[ival[i]+1:isep[i]-1],b_pha[0,*],b_pha[1,*])
   ENDFOR
 ;on remplit la structure
  IF KEYWORD_SET(xtrack) THEN BEGIN
   root_name  = FILE_BASENAME(sta[i],track[i]+'.dat') 
   mgr[i].name=root_name+STRCOMPRESS(track[i],/REMOVE_ALL)+'.'+STRCOMPRESS(num[i],/REMOVE_ALL)
   mgr[i].origine=STRCOMPRESS(track[i],/REMOVE_ALL)+'-'+STRCOMPRESS(num[i],/REMOVE_ALL)
  ENDIF ELSE BEGIN
   mgr[i].name     = STRCOMPRESS(sta[i],/REMOVE_ALL)
   mgr[i].origine  = STRCOMPRESS(ori[i],/REMOVE_ALL)
  ENDELSE
  IF KEYWORD_SET(origine) THEN mgr[i].origine  = origine
  mgr[i].enr      = STRCOMPRESS(enr[i])
  mgr[i].val      = STRCOMPRESS(val[i],/REMOVE_ALL)
  mgr[i].lat      = FLOAT(lat[i])
  mgr[i].lon      = FLOAT(lon[i])
  mgr[i].nwav     = nwa[i]
  mgr[i].filename = filename 
  mgr[i].code[0:nwa[i]-1] = wave2code(wname)  ;on remplit les code des nwa premieres ondes
  mgr[i].wave[0:nwa[i]-1] = wname              ;on remplit les nwa premieres ondes
  mgr[i].amp[0:nwa[i]-1]  = FLOAT(wamp)*scale
  mgr[i].pha[0:nwa[i]-1]  = FLOAT(wpha)
ENDFOR
 IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,'Nombre de stations du fichiers mgr  : ', nsta
  PRINT,'Informations stations               : '
    FOR i=0,nsta-1 DO PRINT,FORMAT=fmt_verb,'>',STRCOMPRESS(mgr[i].name,/REMOVE_ALL),'(',STRING(mgr[i].lon,FORMAT='(F7.2)'),',',STRING(mgr[i].lat,FORMAT='(F7.2)'),')','[',STRCOMPRESS(mgr[i].origine,/REMOVE_ALL),']',$
                                              ' nwave=',STRING(mgr[i].nwav,FORMAT='(I3)')
 ENDIF
 RETURN, mgr
ENDIF ELSE BEGIN
 mgr= read_mgr_simple(filename,verbose=verbose)
 RETURN,mgr
 ENDELSE
END
