; $Id: interpol_julval.pro, v 1.00 05/12/2006 L. Testut $
;

;+
; NAME:
;	interpol_julval
;
; PURPOSE:
;	Linearly interpolates a time serie of type {jul:0.0D, val:0.0} on a reference time series of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=interpol_julval(st,st_ref,/usage)
;
;       use the fct/proc : -> CREATE_JULVAL
;
; INPUTS:
;       st      : Structure of type {jul:0.0D, val:0.0} to be interpolated
;       st_ref  : Structure of type {jul:0.0D, val:0.0} on which the .val is interpolated
;       /usage  : Give the usage of the procedure/fucntion
;
; OUTPUTS:
;	Structure of type {jul:0.0D, val:0.0} interpolated on st_ref.jul
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
; Le 27/01/2010 Add the gap_size keyword to fill the interpolated gap with NaN
;-


FUNCTION interpol_julval,st_in,st_ref_in, gap_size=gap_size, verbose=verbose, round_hourly=round_hourly, _EXTRA=_EXTRA
; fonction qui va interpole un structure de type julval sur la base de temps
; d'une serie de reference.
; 
; gap_size : seuil de taille des trous qui doivent etre comble par des NaN 
IF NOT KEYWORD_SET(gap_size) THEN BEGIN  
   delta = (1./24.)       ;taille des trous recherche en jours
ENDIF ELSE BEGIN
   delta = (gap_size/24.) ;taille des trous recherche en jours
ENDELSE

IF KEYWORD_SET(round_hourly) THEN BEGIN
 CALDAT, MIN(st_in.jul), m_start, d_start, y_start, h_start, mn_start, s_start ;1st observation day
 CALDAT, MAX(st_in.jul), m_end  , d_end  , y_end  , h_end  , mn_end  , s_end   ;last observation day
 base_temps    = TIMEGEN(start=JULDAY(m_start,d_start,y_start,h_start-1,0,0),final=JULDAY(m_end,d_end,y_end,h_end+1,0,0),unit='hours', step_size=1)
 st_ref_in     = create_julval(N_ELEMENTS(base_temps))
 st_ref_in.jul = base_temps
 IF KEYWORD_SET(verbose) THEN PRINT,"Create round hourly time base  : ",print_date(st_ref_in[0].jul,/SINGLE),'--->',print_date(st_ref_in[-1].jul,/SINGLE)
ENDIF

 ; determination de la periode commune
minab      = MIN(st_ref_in.jul,/NAN) > (MIN(st_in.jul,/NAN))
maxab      = MAX(st_ref_in.jul,/NAN) < (MAX(st_in.jul,/NAN))
st         = finite_st(julcut(st_in,DMIN=minab,DMAX=maxab))          ; on retaille les series au memes dates 
st_ref     = finite_st(julcut(st_ref_in,DMIN=minab,DMAX=maxab))  ; on retaille les series au memes dates
;st_ref     = finite_st(julcut(st_ref_in,DMIN=minab+1,DMAX=maxab-1))  ; on retaille les series au memes dates

IF KEYWORD_SET(verbose) THEN BEGIN
 PRINT,FORMAT='(A,C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02))'," Start of time serie to be interpolated : ",MIN(st_in.jul,/NAN)
 PRINT,FORMAT='(A,C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02))',"    Start of reference time serie       : ",MIN(st_ref_in.jul,/NAN)
 PRINT,FORMAT='(A,C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02))',"    End of reference time serie         : ",MAX(st_ref_in.jul,/NAN) 
 PRINT,FORMAT='(A,C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02))'," End of time serie to be interpolated   : ",MAX(st_in.jul,/NAN)
 PRINT,FORMAT='("Times series cut between ",C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02)," and ",C(CDI02,"/",CMOI02,"/",CYI4,X,CHI02,":",CMI02,":",CSI02))',minab,maxab
ENDIF
                                                                     ; on elimine le NaN dans la serie a interpoler
tab_diff = -TS_DIFF(st.jul,1,/DOUBLE)                               ; on cacule les diff temporelle
Nd       = N_ELEMENTS(tab_diff)
ech_tab  = tab_diff[0:Nd-2]
id_delta = WHERE(ech_tab GT delta,count)                       ; index des trous > delta
IF (count GE 1 AND KEYWORD_SET(verbose)) THEN BEGIN
 print,"Taille des trous recherche = ",delta*24.,"H"
 print,"Nbre de trou               = ",count
   FOR I=0L,count-1 DO BEGIN
   print,i,'->',print_date(st[id_delta[i]].jul,/SINGLE)," taille du trou  ",ech_tab[id_delta[i]]*24.,'  H' 
   ENDFOR
ENDIF

; on interpole la serie brute de decoffrage
sti     = create_julval(N_ELEMENTS(st_ref.jul))
sti.jul = st_ref.jul
sti.val = INTERPOL(st.val,st.jul,st_ref.jul,/LSQUADRATIC)

;on flag dans la serie interpolee les trou
IF (count GE 1) THEN BEGIN
   FOR i=0,count-1 DO BEGIN
   sti=flag_julval(sti,DMIN=st[id_delta[i]].jul,DMAX=st[id_delta[i]].jul+ech_tab[id_delta[i]])
   ENDFOR
ENDIF
RETURN,sti
END
