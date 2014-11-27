PRO list_roblou_to_list, tab_track
;---------------------------------------
;
;
; Calcul les correlation entre :
;   - la SLA d'un mgr
;   - la SLA des extractions albicoca
;
;
;---------------------------------------


path_track  = '/home/ocean/testut/windows/tmp/xtrack/extractions_1Hz/track_179/'

num_along_pts = 730L ; nb max de points de ref le long de la trace
num_cycle = 362L
num_mes = DBLARR(num_cycle)


;-------------------------------;
; ecriture du fichier de sortie ;
;-------------------------------;

itrack=0L
;;;file=STRCOMPRESS(path_track+'sealevel_corrLOAD_corrIB_corrTIDEreg/SLA_track-ref_TP_'+STRING(tab_track(itrack),FORMAT='(I3.3)')+'.list',/REMOVE_ALL)
file=STRCOMPRESS(path_track+'SLA_track-ref_TP_'+STRING(tab_track(itrack),FORMAT='(I3.3)')+'.list',/REMOVE_ALL)
print, file

CLOSE,15
UNIT=15
OPENW,15,file
PRINTF, 15, '#-- HEADER -------------------------------------------'
PRINTF, 15, '# Column 1 : date in days referred to'
PRINTF, 15, '#            CNES date (01-JAN-1950 00:00:00.0)'
PRINTF, 15, '# Column 2 : sea level anomaly (in meters)'
PRINTF, 15, '#-- HEADER END ---------------------------------------'
PRINTF, 15, 'Number of points :'

tab_lon_lat = DBLARR(2L,num_along_pts)

kpts=0L
; Boucle sur le numero de la trace
itrack=0L
file_ref = STRCOMPRESS(path_track+'/track-ref.TP.'+STRING(tab_track(itrack),FORMAT='(I3.3)')+'.dat',/REMOVE_ALL)
print, file_ref
CLOSE, 16
OPENR,16,file_ref
chaine=''
FOR i=0L,29L DO READF ,16, chaine
num_pts = STRING(chaine)
PRINTF, 15, num_pts

; Boucle sur le chaque point de la trace
time=DOUBLE(0.)
FOR i=0L,num_pts-1L DO BEGIN
   READF ,16, chaine & READF ,16, chaine & READF ,16, chaine
    longueur_chaine=STRLEN(chaine)
    tab_lon_lat(0,i)=STRMID(chaine,6,longueur_chaine)
    READF ,16, chaine
    longueur_chaine=STRLEN(chaine)
    tab_lon_lat(1,i)=STRMID(chaine,6,longueur_chaine)
    READF ,16, chaine
    longueur_chaine=STRLEN(chaine)
    mes = STRMID(chaine,6,longueur_chaine)
    num_mes(itrack) = mes
    PRINTF, 15, '#-----------------------------------------------------'
    PRINTF, 15, 'Pt  : ', STRCOMPRESS(i+1L,/REMOVE_ALL)
    PRINTF, 15, 'lon : ', STRCOMPRESS(tab_lon_lat(0,i),/REMOVE_ALL)
    PRINTF, 15, 'lat : ', STRCOMPRESS(tab_lon_lat(1,i),/REMOVE_ALL)
    PRINTF, 15, 'Mes : ', STRCOMPRESS(mes,/REMOVE_ALL)

    FOR j=0L,mes-1L DO BEGIN
        time_cnes=DOUBLE(0.)
    	READF, 16, time_cnes, var1,  var2,  var3,  var4,  var5,  var6,  var7,  var8,  var9,  var10, $
    			      var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, $
    			      var21, var22, var23, var24, $
    	FORMAT='(F12.6,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4,F8.4)'
   	sla_alti= var1-var2-var11-var12      ;;;; var1-var2-var11-var12-var19-var20-var21 ;;;; var1-var2-var11-var12    ;;; var1-var2-var11-var12-var13-var20-var15    

    	PRINTF, 15, FORMAT='(F12.6,F10.4)', DOUBLE(time_cnes), sla_alti  ;;; var1-var2-var11-var12
    ENDFOR
ENDFOR

CLOSE,15


END
