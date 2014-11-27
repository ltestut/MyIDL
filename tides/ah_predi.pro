; $Id: ah_predi.pro,v 1.00 23/05/2005 L. Testut $
;

;+
; NAME:
;	AH_PREDI
;
; PURPOSE:
;	Compute the time serie from the Harmonic Analysis coefficient of a {jul,val} structure
;  
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=AH_PREDI(st,coef)
;	
;       use the fct/proc : -> CREATE_JULVAL
;                         
;                         
; INPUTS:
;	coef  : Array of the AH coefficient
;
; OUTPUTS:
;	st    : Structure of type {jul,val}
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

FUNCTION ah_predi,st,A
; F(x) = Af*cos(2pif.X)+Bf*sin(2pif.X)
; A[0] = Af
; A[1] = Bf

n_var = N_ELEMENTS(A)/2
yfit  = MAKE_ARRAY(N_ELEMENTS(st.jul),VALUE=MEAN(st.val,/NAN))

print,'nombre de frequence prise en compte',n_var

dpi=2*!PI

onde8 =[12.42,12.,12.6576,23.9352,11.9664,25.8192,12.8712,26.868]
onde77=360./[13.94303558$
,14.95893134,15.04106864,27.42383374,27.89535482,27.96820844,28.43972952$
,28.51258314,28.98410422,29.45562530,29.52847892,29.95893332,30.00000000,30.08213728$
,30.54437470,31.01589578,57.42383374,57.96820844,58.98410422,59.06624150,86.40793796$
,86.95231266,87.42383374,44.02517286,42.92713980,15.00000000,13.39866088,16.13910170$
,15.58544334,29.06624150,28.90196694,28.90196694,56.87945904,43.47615633,45.00000000$
,29.02517286,28.94303558,0.54437470,1.01589578,1.09803306,0.47152108,1.64240776$
,2.18678246,1.56955414,2.11392884,0.08213728,0.04106864,16.05696442,14.02517286$
,30.04106668,27.34169646,27.42383374,43.94303558,45.04106860,58.43972952,60.00000000$
,58.05034572,56.95231266,87.96820844,88.05034572,116.95231266,27.96820844,29.52847892$
,29.45562530,27.88607116,28.51258314,12.85428620,12.92713980,13.47151450,14.56954760$
,14.91786470,15.12320590,15.51258970,14.49669390,14.48741030,16.68347640,30.62651200]

IF (n_var EQ 77)THEN freq=onde77/24.
IF (n_var EQ 8) THEN freq=onde8/24.

fmar    = 1/freq       ;frequences associ�es
st1     = CREATE_JULVAL(N_ELEMENTS(st.jul))
st1.jul = st.jul

; construction de la fonction F(x)= somme/freq [Af*cos(2pif.X)+Bf*sin(2pif.X)]
FOR I=0,n_var-1 DO BEGIN
yfit = yfit + A[2*I]*cos(dpi*fmar[I]*st.jul)+A[2*I+1]*sin(dpi*fmar[I]*st.jul)
END
st1.val=yfit
RETURN, st1
END