FUNCTION fill_chrono_block,block,_EXTRA=_EXTRA
;fill or update chrono blocks with extra configuration values
nt     = N_TAGS(_EXTRA)
keys   = STRLOWCASE(TAG_NAMES(_EXTRA))
IF (block EQ 0) THEN PRINT,"/!\ block=0 is reserved for chrono type "
 ;test if the user try to overwright an existing non init start or end_date
istart = WHERE(keys EQ 'start_block',cpt_start)
iend   = WHERE(keys EQ 'end_block'  ,cpt_end)
IF (cpt_start EQ 1) OR (cpt_end EQ 1) THEN BEGIN  ;----------------------------------------test of overwriting of start or end date
  modif_start =( block['start_block'] NE (init_chrono_block())['start_block'] )           ;if start_date differs from init_date
  modif_end   =( block['end_block']   NE (init_chrono_block())['end_block'] )             ;if end_date differs diff from init_date
  IF modif_start THEN PRINT,"/!\ You are modifiying start_block :",_EXTRA.(istart),block['start_block'] 
  IF modif_end   THEN PRINT,"/!\ You'are modifiying end_block   :",_EXTRA.(iend)  ,block['end_block']
ENDIF
FOR i=0,nt-1 DO block[keys[i]]=_EXTRA.(i)
RETURN,block
END

FUNCTION fill_chrono,chrono,key=key,block=block,_EXTRA=_EXTRA
; function to fill or update a chrono
; if no _EXTRA keyword then original chrono is returned
; if key does not exist then a key is created and add to the chrono
; if a block does not exist then a block is created and add to the chrono 
IF (N_ELEMENTS(_EXTRA) EQ 0) THEN RETURN,chrono  ;if no extra keyword return the original chrono
IF (N_ELEMENTS(key) EQ 0) THEN BEGIN ;------------if no key is mention then update every keys and every block
  FOREACH key,chrono.keys() DO FOR ib=1,chrono[key].count()-1 DO chrono[key,ib] = fill_chrono_block(chrono[key,ib],_EXTRA=_EXTRA)
ENDIF ELSE BEGIN                     ;------------if one or more keys are mentionned then update these keys
  FOREACH k,key DO BEGIN                ;---------loop on each key
  haskey=chrono.haskey(k)                        ;test if the key exist or not (if not it is created and inherit the type)
    IF NOT haskey THEN chrono = chrono + create_chrono(k,TYPE=chrono_type(chrono),_EXTRA=_EXTRA)
      IF (N_ELEMENTS(block) EQ 0) THEN BEGIN  ;--if no block mentionned all block are updated
         FOR ib=1,chrono[k].count()-1 DO chrono[k,ib] = fill_chrono_block(chrono[k,ib],_EXTRA=_EXTRA)
      ENDIF ELSE BEGIN                          ;update only the given block
         IF (block GT (chrono[k].count()-1) ) THEN chrono[k].add,init_chrono_block() ;if block does not exist it is created 
         chrono[k,block] = fill_chrono_block(chrono[k,block],_EXTRA=_EXTRA)
      ENDELSE
  ENDFOREACH                            ;--------endloop on each and every keys
ENDELSE                              ;-----------endif one or more keys are mentionned
RETURN,chrono
END