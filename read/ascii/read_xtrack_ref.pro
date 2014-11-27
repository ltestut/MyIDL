; $Id: read_xtrack_ref.pro,v 1.00 19/10/2007 L. Testut $
;

;+
; NAME:
;	READ_XTRACK_REF
;
; PURPOSE:
;	Read the track-ref.TP.xxx.dat data file from XTRACK chain 
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_XTRACK_REF(filename,para=para)
;	
;       use the fct/proc : -> 
;                          -> 
;                          -> 
; INPUTS:
;	filename      : string of the filename ex:'track-ref.TP.xxx.dat' 
;
; OUTPUTS:
;	Structure of type {jul,val,mes,lat,lon,num}
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;
;-
;

FUNCTION read_nop, filename
;---------------------------------------------------------;
;---------------------------------------------------------;
; Return the number of nominal point contained in the file;
; for a particular track                                  ;
;---------------------------------------------------------;
;---------------------------------------------------------;

nop = 0

OPENR, UNIT, filename, /GET_LUN
str=''
WHILE ( STRMATCH(str, '*Number*') NE 1) DO BEGIN
    readf ,UNIT, str 
ENDWHILE
   readf ,UNIT, nop
CLOSE, UNIT
RETURN,nop
END

FUNCTION read_xtrack_ref, filename, para=para

IF (N_PARAMS() EQ 0) THEN STOP,"UTILISATION:  st=READ_XTRACK_REF(filename, para='ssh')"
;RAJOUTER UN KEYWORD PARA ET UN CASE POUR CHOISIR LES PARAMETRES A EXTRAIRE !!!

; Format des fichiers sorties de XTRACK
; -------------------------------------
form ='(F12.6,24F8.4)'

; Initialisation des chaines de caracteres et structure de lecture
; ----------------------------------------------------------------
npt     = read_nop(filename) ;nombre de point nominal le long de cette trace
Ncycle  = 360                ;nombre maximum de cycle
str     =''
str_lon =''
str_lat =''
str_mes =''
tmp     = {jul:DBLARR(Ncycle), val:FLTARR(Ncycle), mes:0L, lat:0.0, lon:0.0, num:0L}
st      = replicate(tmp,npt) ; initialisation d'un tableau de structure pour chaque point de la trace qui contient information et serie temporelle du point
                       ; st[i].jul[mes] : tableau des dates juliennes de la serie pour le point i   [0 si pas de mesure valide] 
                       ; st[i].val[mes] : tableau des valeurs de la serie pour le point i           [NaN si pas de mesure valide]
                       ; st[i].mes      : nombre de mesures valides de la serie pour le point i 
                       ; st[i].lat      : latitude du point i 
                       ; st[i].lon      : longitude du point i 
                       ; st[i].num      : numero du point i 


print,'Nombre de point le long de la trace',npt

OPENR, UNIT, filename, /GET_LUN
WHILE (STRMATCH(str, '*#---------*') NE 1) DO READF ,UNIT, str ;On saute le debut du fichier pour se place sur *Pt : 1*
   FOR ipt=0,npt-1 DO BEGIN
   READF, UNIT, str
   inop  = FIX(strmid(str,strpos(str,':')+1,strlen(str)))     ;numero du point sur la trace
   READF , UNIT, str_lon
   READF , UNIT, str_lat
   READF , UNIT, str_mes
   lon   = FLOAT(strmid(str_lon,strpos(str_lon,':')+1,strlen(str_lon)))  ;longitude du point sur la trace
   lat   = FLOAT(strmid(str_lat,strpos(str_lat,':')+1,strlen(str_lat)))  ;latitude du point sur la trace
   imes  = FIX(strmid(str_mes,strpos(str_mes,':')+1,strlen(str_mes)))   ;nombre de mesure temporelle de ce point
   st[ipt].lat= lat
   st[ipt].lon= lon
   st[ipt].num= inop
   st[ipt].mes= imes
      FOR j=0,imes-1 DO BEGIN
      READF, UNIT, FORMAT=form, time_cnes, var1,  var2,  var3,  var4,  var5,  var6,  var7,  var8,  var9,  var10, $
    			      var11, var12, var13, var14, var15, var16, var17, var18, var19, var20, $
    			      var21, var22, var23, var24

      ;sla_alti= var1-var20 ;-var2-var11-var12      ;;;; var1-var2-var11-var12-var19-var20-var21 ;;;; var1-var2-var11-var12    ;;; var1-var2-var11-var12-var13-var20-var15   
      ;sla_alti= var1-var2-var11-var12-var19-var20-var21 
      sla_alti=var1
      st[ipt].jul[j]=time_cnes
      st[ipt].val[j]=sla_alti
      ENDFOR
      READF, UNIT, str ;On saute 1 lignes pour se replacer sur Pt : 
   ENDFOR
CLOSE, UNIT

print,'inop - lon - lat - ipt   : ',inop,lon,lat,ipt

;N    = N_ELEMENTS(data.jul) 
;st   = create_julval(N)
;st.jul = data.jul+JULDAY(1,1,1950,0,0,0)
;st.val = data.val


RETURN, st
END
 
