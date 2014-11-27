FUNCTION butterworth_julval, st, tcut=tcut, order=order, hf=hf, bwidth=bwidth, $
         filter=filter, $
         show=show, verb=verb
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "st=butterworth_julval(st      , *input {jul,val} structure*  "
 print, "                      tcut=12 , *cut period in hour*         "
 print, "                      order=2 , *order of the filter*        "
 print, "                      /hf       *to get the high pass filter*"
 print, "                      bwidth=5  *to have a bandpassfilter around tcut* "
 print, "                      /filter   *return the filter instead of the filtered serie*"
 print, "                      /verb     *to get info on the filtering process"
STOP
ENDIF

  st1=finite_st(st)

IF KEYWORD_SET(filter) THEN BEGIN
  Nd        = N_ELEMENTS(st1.val)           ;total number of data
  dt        = sampling_julval(st1)/3600.    ;sampling interval in hour
  df        = 1./(Nd*dt) 
ENDIF ELSE BEGIN
  dt        = sampling_julval(st1)/3600.    ;sampling interval in hour
  Nd        = N_ELEMENTS(st1.val)           ;total number of data
  df        = 1./(Nd*dt)                   ;sampling interval in the frequency domain (in cph)
  stf       = create_julval(Nd)            ;filtred structure
  stf.jul   = st1.jul
ENDELSE

; Compute the filter
; ------------------
distfun    = DINDGEN(Nd)   ;distance function varies from   0 --> Nd/2 --> 0
                           ;corresponding to period         T --> 2dt  --> T
distfun    = distfun < (Nd - distfun)
distfun[0] = 1d-4           ; Avoid division by 0


IF (N_ELEMENTS(tcut) EQ 0)  THEN tcut   = 2*dt   ;By default no filtering cutoff=Nd/2 in low pass filterfing
IF (N_ELEMENTS(order) EQ 0) THEN order  = 2.     ;By default order=2


; Choose the filter type
; ----------------------
bandtype  = 0                          ;Low pass filter by default
IF KEYWORD_SET(hf) THEN bandtype  = 1           ;High pass filter
IF (N_ELEMENTS(bwidth) NE 0) THEN BEGIN         ;Bandpass filter
   bandtype  = 2 
   bandwidth = bwidth   ;Bandwidth 
ENDIF

cutoff    = (Nd*dt)/tcut     ;Cutoff frequency     1 < cutoff < Nd/2

        if (bandtype EQ 0) then begin ; Compute lowpass filter.
            fter = 1.0d / (1.0d + (distfun / cutoff)^(2 * order)) 
        endif else if (bandtype EQ 1) then begin ; Compute highpass filter.
            fter = 1.0d / (1.0d + (cutoff / distfun)^(2 * order))
        endif else begin        ;Bandpass or bandreject
            fter = distfun^2 - cutoff^2 ;Dist squared
            zeroes = WHERE(abs(fter) EQ 0.0, count)
            if (count NE 0) then fter[zeroes] = 1d-4 ;Avoid divide by 0
            fter = 1.0d / (1.0d + $ ; Compute bandreject filter.
                             ((distfun * bandwidth) / fter) ^ (2 * order))
            
            if (bandtype EQ 2) then $ ; Compute bandpass filter.
              fter = 1.0 - fter
        endelse

IF KEYWORD_SET(verb) THEN BEGIN
  type='Low pass filter'
  IF KEYWORD_SET(hf) THEN type='High pass filter'
  IF (N_ELEMENTS(bwidth) NE 0) THEN type='Band pass filter ['+STRING((1/((cutoff+bwidth)*df)))+';'+STRING((1/((cutoff-bwidth)*df)))+']'
  print, type, ' of order ',order
  print, "Cutoff Period  =",tcut, '  Hours', '==> cutoff = ',cutoff
ENDIF


IF KEYWORD_SET(filter) THEN return, fter

stfft=FFT(st1.val,/DOUBLE)
IF KEYWORD_SET(show) THEN BEGIN
 plot,1/(distfun*df),ABS(stfft)/MAX(stfft,/NAN),/xlog ,/ylog,$
 xticklen=1. , xgridstyle=1 ,$
 yticklen=1. , ygridstyle=1
 oplot, 1/(distfun*df),fter,  thick=4, color=150
 oplot, 1/(distfun*df),fter*ABS(stfft)/MAX(stfft,/NAN),  thick=2, color=250 
ENDIF

stf.val=FFT(stfft*SQRT(fter),1)


RETURN, stf
END
