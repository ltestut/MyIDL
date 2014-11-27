; $Id: rms_diff_julval.pro,v 1.00 10/05/2007 L. Testut $
;

;+
; NAME:
;	RMS_DIFF_JULVAL
;
; PURPOSE:
;	Compute the rms difference of 2 time series type {jul:0.0D, val:0.0}
;       The trend of each time serie is removed 
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=RMS_DIFF_JULVAL(st1,st2)
;
;       use the fct/proc : -> CREATE_JULVAL
;                          -> FINITE_ST
;                          -> SYNCHRO_JULVAL
;                          -> REMOVE_TREND
; INPUTS:
;       st1     : Structure of type {jul:0.0D, val:0.0}
;       st2     : Structure of type {jul:0.0D, val:0.0}
;
; OUTPUTS:
;	Time serie difference of type {jul:0.0D, val:0.0}
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
; - Le 08/10/2007 add the rmt keyword to allow to remove the trend before differencing 
; - Le 17/10/2008 add the sum keyword to allow to add instead of diff the value 
; - Le 08/09/2008 add all the stuff of the VDC comparison (scale error) + file_ouput keyword
; - Le 11/01/2012 add the stat keyword to output ctat info (cor, rms_diff)

; 
;-

FUNCTION  rms_diff_julval, st1, st2, rmt=rmt, sum=sum, quiet=quiet, stat=stat, file_out=file_out,_EXTRA=_EXTRA

IF (N_PARAMS() EQ 0) THEN STOP, 'st=RMS_DIFF_JULVAL(st1,st2,/rmt to remove linear trend, /sum to add the value)'
st1     = FINITE_ST(st1)
st2     = FINITE_ST(st2)
IF KEYWORD_SET(rmt) THEN BEGIN
st1     = REMOVE_TREND(st1)
st2     = REMOVE_TREND(st2)
ENDIF

synchro_julval, st1, st2, stsync1,stsync2,  _EXTRA=_EXTRA

stdiff     = CREATE_JULVAL(N_ELEMENTS(stsync1.jul))
stdiff.jul = stsync1.jul
stdiff.val = stsync2.val-stsync1.val
IF KEYWORD_SET(sum) THEN stdiff.val = stsync1.val+stsync2.val

Y0       = stsync1.val
Y        = stsync2.val 
DY       = Y-Y0
sigma    = STDDEV(DY,/NAN)
sig1     = STDDEV(Y0,/NAN)
sig2     = STDDEV(Y,/NAN)
cor      = CORRELATE(Y0,Y)
IF KEYWORD_SET(stat) THEN stat=[sig1,sig2,sigma,cor]


IF NOT KEYWORD_SET(quiet) THEN BEGIN
 r_coef   = LINFIT(Y0,Y)                                  ; Coef. de regression entre l'etalon et le mrg 
 r2_coef  = LINFIT(Y0,DY)                                 ; Coef. de regression entre l'etalon et la difference (pente de vdc = erreur d'echelle)
 r3_coef  = LINFIT(stdiff.jul,stdiff.val,SIGMA=err_diff)  ; Coef. de regression entre le temps et la difference (derive relative des instruments)
 
 print,"NBRE DE DIFFERENCES UTILISEES     ", N_ELEMENTS(DY)
 print,"CORRELATION DES 2 SIGNAUX         ", cor
 print,"MOYENNE DE LA DIFFERENCE (Y-Yref) ", MEAN(DY)
 print,"   ===>  LE ZERO INSTRUMENTAL EST A ",STRCOMPRESS(STRING(mean(-1.*DY),FORMAT='(F8.3)'),/REMOVE_ALL), " DU ZERO DE LA REF"
 print,"DIFFERENCE RMS DES 2 SIGNAUX      ",sigma,"  Cm"
 print,"DROITE DE REGRESSION              ",r_coef[1] 
 print,"ERREUR D'ECHELLE                  ",r2_coef[1]*100.
 print,"DERIVE RELATIVE                   ",r3_coef[1]*3650.,'mm/yr +/-',err_diff[1]*3650.
 
ENDIF

IF (KEYWORD_SET(file_out)) THEN BEGIN
 OPENW,  UNIT, file_out+'.txt'  , /GET_LUN        ;; ouverture en ecriture du fichier
 PRINTF, UNIT, "FICHIER RAPPORT DE LA DIFFERENCE DES SERIES"
 PRINTF, UNIT, "-------------------------------------------"
 PRINTF, UNIT,FORMAT='(A20,X,C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2))','Date de debut      :',stsync1[0].jul     
 PRINTF, UNIT,FORMAT='(A20,X,C(CDI2.2,"/",CMOI2.2,"/",CYI4.4,X,CHI2.2,":",CMI2.2,":",CSI2.2))','Date de fin        :',stsync1[N_ELEMENTS(stsync1.jul)-1].jul
 PRINTF, UNIT,FORMAT='(A20,X,I8)'  ,'Nbre diff utilisees:',N_ELEMENTS(DY)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Difference moyenne :',MEAN(DY,/NAN)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Ecart-type de diff :',STDDEV(DY)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Zi/Z_ref si(str,st):',MEAN(-1.*DY)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2,X,A9,X,F6.2)','Tendance de diff   :',r3_coef[1]*3650.,'mm/yr +/-',err_diff[1]*3650.
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Corr. des signaux  :',CORRELATE(Y0,Y)
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)','Droite de regress. :',r_coef[1]
 PRINTF, UNIT,FORMAT='(A20,X,F8.2)',"Err. d'echelle     :",r2_coef[1]*100.
 CLOSE, UNIT
 FREE_LUN, UNIT
ENDIF

RETURN, stdiff
END
