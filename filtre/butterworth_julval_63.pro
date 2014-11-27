FUNCTION butterworth_julval_63, st, tcut=tcut, order=order, hf=hf, usage=usage
; Z is a 3D matrix where dimension 3 is the FFT of the time dimension: FFT(z,-1,DIMENSION=3)
ON_ERROR,2
IF KEYWORD_SET(usage) OR (N_PARAMS() EQ 0) THEN print,'USAGE: st=butterworth_julval(st,tcut=2 *in hour*, order=order, /usage)'

Nd        = N_ELEMENTS(st.jul)
dt        = sampling_julval(st)/(60.*60.) ;Sampling interval in hour
stf       = create_julval(Nd)       ;Filtred structure
stf.jul   = st.jul

IF (N_ELEMENTS(order) EQ 0) THEN order  = 1.

cutoff    = (Nd*dt)/tcut     ;Cutoff frequency     1 < cutoff < Nd/2

filter    = BUTTERWORTH(Nd,cutoff=cutoff,order=order)

stf.val=FFT(FFT(st.val,-1)*filter,1)

IF KEYWORD_SET(hf) THEN stf.val=st.val-stf.val

RETURN, stf
END
