FUNCTION read_tidal_constituent, filename=filename
; lecture du fichier des constituents de maree 
IF NOT KEYWORD_SET(filename) THEN filename=!idl_root_path+'idl/workspace_idl8/lib/tides/tides_coef_ddu.txt'
;patron de lecture du fichier de configuration 
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:';'   ,$
      fieldcount:5 ,$
      fieldTypes:[7,7,4,4,4], $
      fieldNames:['name','arg','vit','amp','pha'] , $
      fieldLocations:[0,10,25,40,52], $
      fieldGroups:indgen(5) $
      }
; Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)
Nd    = N_ELEMENTS(data.name)
tmp  = {name:'', arg:'', vit:0.0, amp:0.0, pha:0.0}
para = replicate(tmp,Nd)
para.name = data.name
para.arg  = data.arg
para.vit  = data.vit
para.amp  = data.amp
para.pha  = data.pha
RETURN, para
END

;/////////////////////////////////////////////////////////////////////////////////
FUNCTION predi_tide, tmin=tmin, tmax=tmax, filename=filename, msl=msl
IF NOT KEYWORD_SET(msl) THEN msl=0.
IF (N_ELEMENTS(tmin) NE 0) THEN READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
IF (N_ELEMENTS(tmax) NE 0) THEN READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))

onde = read_tidal_constituent()


; Construction de la base de temps
; --------------------------------
time   = TIMEGEN(start=dmin,final=dmax,unit='hours',step_size=1)
st     = create_julval(N_ELEMENTS(time))
st.jul = time
st.val = msl

FOR i=0,N_ELEMENTS(onde)-1 DO BEGIN
    print,onde[i].name,onde[i].vit
st.val = st.val + onde[i].amp*cos(rad(onde[i].vit*((st.jul-0.)*24.)-onde[i].pha))
ENDFOR


RETURN,st
END