FUNCTION input_svd,Z, A 
; Transform a matrix H[x,y,z] into A[t,r]
IF (N_PARAMS() EQ 0) THEN STOP, 'A=INPUT_SVD(Z)'

S  = SIZE(Z)
nt = S[3]
nr = S[1]*S[2]
A  = FLTARR(nt,nr)

FOR I=0,nt-1 DO A[I,*]=Z[*,*,I]

RETURN, A
END
