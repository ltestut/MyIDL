FUNCTION output_variable_list,sat
; output the variable list on the Desktop
fmt        = '(A-20,"|",3(A-12,"|"),A-6,"|",2(A-12,"|"),A-2)'
fmt        = '(A-30,"|",I-3,"|",A-40)'
pass             = STRING(FORMAT='(I04)',sat.info['pass_number'])
cycle            = STRING(FORMAT='(I03)',sat.info['cycle_number'])
track_info       = sat.info['mission_name']+' / '+sat.info['title']+$
   ' Pass : '+pass+' / Cycle : '+cycle
OPENW, UNIT, !txt, /GET_LUN
PRINTF,UNIT,track_info
PRINTF,UNIT,'----------------------- 1 Hz -------------------------------------'
id40hz=WHERE((STRMATCH(sat.val.keys(), '*40hz', /FOLD_CASE) EQ 1),/NULL,$
             COMPLEMENT=id1hz)
FOREACH index,id1hz DO $
PRINTF,UNIT,FORMAT=fmt,(sat.val.keys())[index],$
                   SIZE(sat.val[(sat.val.keys())[index]],/N_DIMENSIONS),$
                   (sat.att[(sat.val.keys())[index]])[5]
PRINTF,UNIT,'----------------------- 40 Hz -----------------------------------'
IF id40hz NE !NULL THEN FOREACH index,id40hz DO $
                   PRINTF,UNIT,FORMAT=fmt,(sat.val.keys())[index],$
                   SIZE(sat.val[(sat.val.keys())[index]],/N_DIMENSIONS),$
                   (sat.att[(sat.val.keys())[index]])[5]
FREE_LUN,UNIT
PRINT,"Paramter list in :",!txt
RETURN,0
END

FUNCTION read_saral_gdr, filename=filename
; read the SARAL ogdr data and return a structure of the form 
; sat={val:DICTIONARY('para',value), att:DICTIONARY('para',attribut_value),
;     info:DICTIONARY(info_att), native:0/1}

path=!idl_aviso_arx+'saral/'

IF NOT KEYWORD_SET(filename) THEN filename=path+$
   'SRL_IPN_2PTP010_0468_20140208_130816_20140208_135834.CNES.nc'
;   'SRL_IPR_2PTP005_0468_20130817_130806_20130817_135824.CNES.nc'
;   'SRL_GPR_2PTP005_0468_20130817_130806_20130817_135824.CNES.nc'
;   'SRL_GPR_2PTP001_0001_20130314_053927_20130314_062945.CNES.nc'
id         = NCDF_OPEN(filename)       ; open ntcdf file                    
info       = NCDF_INQUIRE(id)          ; get info on the netcdf file

; list of attribut to extract
attribut   = LIST('_FillValue','scale_factor','add_offset','units',$
                  'standard_name','long_name','comment') 
data       = DICTIONARY() ; dictionary of parameter value    {range:[...]} 
data_att   = DICTIONARY() ; dictionary of parameter attribut {range:LIST()} 
info_att   = DICTIONARY() ; dictionary of global info        {references:".."}

FOR i=0,info.Nvars-1 DO BEGIN ;loop on netcdf variable 
 var_st = NCDF_VARINQ(id,I)                     ;get variable info (name)
 NCDF_VARGET, id, NCDF_VARID(id,var_st.Name),val;get variable value
 svar     = SIZE(val)                           ;get variable size
 att_list = LIST()                              ;init the list of attribut val
 FOREACH att, attribut DO BEGIN                   ;loop on variable attribut
  ; test the existence of attribut 
  test = NCDF_ATTINQ(id , NCDF_VARID(id,var_st.Name) , att)  
  IF (test.datatype NE 'UNKNOWN') THEN BEGIN
    NCDF_ATTGET, id, NCDF_VARID(id,var_st.Name),att, att_val
    IF (test.datatype EQ 'CHAR') THEN att_val=STRING(att_val)
  ENDIF ELSE BEGIN
     att_val=''                       ; default if attribut is not defined
  ENDELSE
  att_list.Add,att_val                ; add attribut value to list
 ENDFOREACH
 data[var_st.Name]=val             ;add variable to dictionary
 data_att[var_st.Name]=att_list    ;add variable attribut to dictionary
ENDFOR 

FOR k=0,info.Ngatts-1 DO BEGIN   ; loop on each global attribut
  NCDF_ATTGET,id,/GLOBAL,NCDF_ATTNAME(id,/GLOBAL,K),val ; get attribut value
  info_att[NCDF_ATTNAME(id,/GLOBAL,K)]=STRING(val)      ; add info variable
ENDFOR
sat={val:data, att:data_att, info:info_att}
sat.info.native=data.haskey('lon_40hz') ; add native keyword to info dictionary
void = output_variable_list(sat)
RETURN,sat
END