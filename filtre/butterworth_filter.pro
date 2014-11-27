FUNCTION butterworth_filter, tcut=tcut, order=order, hf=hf, bwidth=bwidth
ON_ERROR,2
IF (N_PARAMS() EQ 0) THEN BEGIN
 print, "USAGE:'
 print, "filter=butterworth_filter(tcut = 12, *cut period in hour* "
 print, "                          order=  2, *order of the filter*  "
 print, "                          /hf      , *to get the high pass filter* "
 print, "                          bwidth=5 , *to have a bandpassfilter around tcut* "
 print, "                          /verb    , *to get info on the filtering process"
STOP
ENDIF

dt        = sampling_julval(st)/(60.*60.) ;Sampling interval in hour
Nd        = N_ELEMENTS(st.val)           ; Total number of data
df        = 1./(Nd*dt)              ;Sampling interval in the frequency domain (in cph)
stf       = create_julval(Nd)       ;Filtred structure
stf.jul   = st.jul

; Compute the filter
; ------------------
distfun    = DINDGEN(Nd)   ;  Distance function varies from   0 --> Nd/2 --> 0
                       ; Corresponding to period         T --> 2dt  --> T
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
            filter = 1.0d / (1.0d + (distfun / cutoff)^(2 * order)) 
        endif else if (bandtype EQ 1) then begin ; Compute highpass filter.
            filter = 1.0d / (1.0d + (cutoff / distfun)^(2 * order))
        endif else begin        ;Bandpass or bandreject
            filter = distfun^2 - cutoff^2 ;Dist squared
            zeroes = WHERE(abs(filter) EQ 0.0, count)
            if (count NE 0) then filter[zeroes] = 1d-4 ;Avoid divide by 0
            filter = 1.0d / (1.0d + $ ; Compute bandreject filter.
                             ((distfun * bandwidth) / filter) ^ (2 * order))
            
            if (bandtype EQ 2) then $ ; Compute bandpass filter.
              filter = 1.0 - filter
        endelse

IF KEYWORD_SET(verb) THEN BEGIN
  type='Low pass filter'
  IF KEYWORD_SET(hf) THEN type='High pass filter'
  IF (N_ELEMENTS(bwidth) NE 0) THEN type='Band pass filter ['+STRING((1/((cutoff+bwidth)*df)))+';'+STRING((1/((cutoff-bwidth)*df)))+']'
  print, type, ' of order ',order
  print, "Cutoff Period  =",tcut, '  Hours', '==> cutoff = ',cutoff
ENDIF


IF KEYWORD_SET(filter) THEN return, filter

;filter = BUTTERWORTH( Nd  , CUTOFF=cutoff , ORDER=order)
 
;fft_julval,st,stfft
stfft=FFT(st.val,-1)
IF KEYWORD_SET(show) THEN BEGIN
 plot,1/(distfun*df),ABS(stfft)/MAX(stfft,/NAN),/xlog ,/ylog,$
 xticklen=1. , xgridstyle=1 ,$
 yticklen=1. , ygridstyle=1
 oplot, 1/(distfun*df),filter,  thick=4, color=150
 oplot, 1/(distfun*df),filter*ABS(stfft)/MAX(stfft,/NAN),  thick=2, color=250 
ENDIF

stf.val=FFT(stfft*SQRT(filter),1)


RETURN, stf
END
