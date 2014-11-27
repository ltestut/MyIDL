FUNCTION create_chrono, key, nblock=nblock, type=type, _EXTRA=_EXTRA
; create a chrono hash table
; a chrono is basically a LIST of HASH table (except the first value of the list
; which is a string indicating the type of chrono) 
; you have to define the type='weekly','yearly'
; the key is generally correspond to a line in the timeline (year,week,)
; npara        = ((chrono[key])[1]).count() 
; chrono[key]  =
; (chrono[key])[0]           = STRING type 'yearly'
; (chrono[key])[1-nblock]    = HASH   table for each block
; ((chrono[key])[1])[]            = HASH   table for each block
; ((chrono[key])[1]).count()      = N configuration parameter per block
; ((chrono[key])[1]).keys()       = LIST of configuration parameter
; ((chrono[key])[1])['info']      = HASH text info
;
; _EXTRA keyword can be passed to change the initialisation default value

IF NOT KEYWORD_SET(type) THEN type='yearly'
value = LIST(type)                            ;init the list with the type of chrono
value.add,init_chrono_block(_EXTRA=_EXTRA)    ;add a HASH block to the list
chrono = HASH(key,value)
RETURN,chrono
END