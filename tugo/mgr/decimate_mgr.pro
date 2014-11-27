FUNCTION decimate_mgr, mgr,dec=dec
IF NOT KEYWORD_SET(dec) THEN dec=4
nsta      = N_ELEMENTS(mgr)


id = INDGEN(nsta/dec)*dec

mgr1 = where_mgr(mgr,id)

RETURN, mgr1
END