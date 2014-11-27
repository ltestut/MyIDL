FUNCTION wave_index, mgr , wave
; return the index where mgr.wave is equal to the input wave

nsta    = N_ELEMENTS(mgr)
nwav    = N_ELEMENTS(mgr[0].wave)

index   = WHERE(mgr.wave EQ wave,count)

icol  = index MOD nwav
irow  = index/nwav

RETURN, icol
END