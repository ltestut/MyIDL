FUNCTION load_tidal_wave_list, uppercase=uppercase, quiet=quiet
; programme de lecture du fichier de liste d'ondes de maree
file = !idl_root_path+'idl/workspace_idl8/lib/tides/tidal_wave_list.txt'

tmp = {version:1.0,$
        datastart:3   ,$
        delimiter:' '   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'#'   ,$
        fieldcount:7 ,$
        fieldTypes:[7,4,5,5,5,5,4], $
        fieldNames:['name','pot','speed1','speed2','period1','period2','lat'] , $
        fieldLocations:[0,10,20,37,50,67,83]    , $
        fieldGroups:indgen(7) $
      }

; Read the data corresponding to the defined template
; --------------------------------------------------
data  = READ_ASCII(file,TEMPLATE=tmp)
IF NOT KEYWORD_SET(quiet) THEN print,'READ_ASCII   : ',file
;       wave     Ap             deg/h         /h            h          days      deg 
tmp  = {name:'',pot:0.0,speed1:0.0D,speed2:0.0D,period1:0.0D,period2:0.0D,lat:0.0}
wave = replicate(tmp,N_ELEMENTS(data.name))
FOR i=0,N_TAGS(data)-1 DO wave.(i) = data.(i)
IF KEYWORD_SET(uppercase) THEN BEGIN
  FOR i=0,N_ELEMENTS(wave.name)-1 DO wave[i].name = STRUPCASE(wave[i].name)
ENDIF

RETURN,wave
END
