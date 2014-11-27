FUNCTION edgecut_julval, st, N
; function to remove the N first and last point of a julval structure
st_in = st
Ntot  = N_ELEMENTS(st_in.jul)
st_in[0:N-1].val         = !VALUES.F_NAN
st_in[Ntot-N:Ntot-1].val = !VALUES.F_NAN
RETURN, finite_st(st_in)
END
