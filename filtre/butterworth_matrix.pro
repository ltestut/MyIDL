FUNCTION butterworth_matrix, Z, time, _EXTRA=_EXTRA
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "Z-filtered=butterworth_matrix(Z-fft    , *Z-fft is a 3D matrix where dimension 3 is the FFT of the time dimension: FFT(z,-1,DIMENSION=3)"
 print, "                              time     , *time vector in julian day* "
 print, "                              tcut=12  , *cut period in hour*, order=2 *order of the filter*,  "
 print, "                              /hf      , *to get the high pass filter* "
 print, "                              bwidth=5 , *to have a bandpassfilter around tcut* "
STOP
ENDIF
s         = SIZE(Z)
Nd        = N_ELEMENTS(time)
echxm     = TOTAL(-TS_DIFF(time[0:Nd-2],1),/NAN)/FLOAT(Nd)
dt        = ROUND(echxm*24.*60.)/60.            ;Sampling interval in the frequency domain (in cph)
df        = 1./(Nd*dt) 

IF (N_ELEMENTS(tcut) EQ 0)  THEN tcut   = 2*dt   ;By default no filtering cutoff=Nd/2 in low pass filterfing
IF (N_ELEMENTS(order) EQ 0) THEN order  = 2.     ;By default order=2

print,' Sampling interval   =',dt,' h'

; Compute the butterworth filter
; ------------------------------
filter=butterworth_julval(time,_EXTRA=_EXTRA,/filter)
time=systime(1)
FOR I=0,s[3]-1 DO z[INDGEN(s[1]),INDGEN(s[2]),I]=z[INDGEN(s[1]),INDGEN(s[2]),I]*filter[I]
print,"Time for multiply with filter",systime(1)-time
time=systime(1)

zfiltered = FLOAT(FFT(z,1,DIMENSION=3))
print,"Time for computing inverse FFT",systime(1)-time

RETURN, zfiltered 
END
