FUNCTION init_chrono_block, _EXTRA=_EXTRA
; init the principal block of a chrono hash table with default values
; EXTRA keyword can be passed to change the defaut values

nt     = N_TAGS(_EXTRA)

 ;init default value
start_block    = '01012000120000'
end_block      = '01022000121212'
frame_position = 0.25
block_thick    = 0.5
block_color    = 'grey'
block_transp   = 50
ct_style       = 0                 ;contour style [0=]
ct_color       = 'black'
ct_thick       = 1.
txt_font       = 'Courier'
txt_color      = 'black'
txt_size       =  12

info           = HASH('default','')           ; info hash table

block          = HASH('start_block',start_block,'end_block',end_block,'frame_position',frame_position,$
                      'block_thick',block_thick,'block_color',block_color,'block_transp',block_transp,$
                      'ct_style',ct_style,'ct_color',ct_color,'ct_thick',ct_thick,$
                      'txt_font',txt_font,'txt_color',txt_color,'txt_size',txt_size,$
                      'info',info)


IF (nt GE 1) THEN BEGIN ;modify default keyword                          
  keys   = STRLOWCASE(TAG_NAMES(_EXTRA))
  FOR i=0,nt-1 DO block[keys[i]]=_EXTRA.(i) 
ENDIF                    
RETURN,block
END