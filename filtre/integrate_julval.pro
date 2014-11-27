FUNCTION integrate_julval,st_in, n, hf=hf, no_fill_with_nan=no_fill_with_nan,verbose=verbose
; function to smooth and decimate a time serie in order to simulate the integration process of a gauge system 

t_spl = sampling_julval(st_in)              ;time sampling in seconds
;switch on /NO_FILL_WITH_NAN in case a memory problem
IF KEYWORD_SET(no_fill_with_nan) THEN st=st_in ELSE st=fill_nan_julval(st_in,SAMP=t_spl,verbose=verbose) ;fill the serie with NaN to have regular time step
N_edge=FLOOR(N/2)+1

IF KEYWORD_SET(verbose) THEN BEGIN
  PRINT,'INTEGRATE_JULVAL  : Original sampling                    = ',t_spl ,' sec'
  PRINT,'INTEGRATE_JULVAL  : Smoothing period & pts equivalent    = ',N*t_spl,' sec i.e. ',N,' pts'
  PRINT,'INTEGRATE_JULVAL  : Truncate the first and last          = ',N_edge,' pts'
ENDIF

;create the smoothed structure
stf     = create_julval(N_ELEMENTS(st.jul))
stf.jul = st.jul
stf.val = SMOOTH(st.val,N,/NAN,/EDGE_TRUNCATE)
IF KEYWORD_SET(hf) THEN stf.val=st.val-stf.val

RETURN,edgecut_julval(stf,N_edge)
END
