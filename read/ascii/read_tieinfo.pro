FUNCTION read_tieinfo, filename
; lecture du fichier d'information sur les valeur de biais tie_info.txt 
IF NOT KEYWORD_SET(filename) THEN print,"Need filename info"
;patron de lecture du fichier de configuration 
;---------------------------------------------
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:';'   ,$
      fieldcount:4 ,$
      fieldTypes:[7,7,4,7], $
      fieldNames:['jmin','jmax','offset','info'] , $
;                  .(0) .(1)        
      fieldLocations:[0,19,39,49], $
      fieldGroups:indgen(4) $
      }

; Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)
Nd    = N_ELEMENTS(data.jmin)
dmin  = DBLARR(Nd)
dmax  = DBLARR(Nd)
READS,data.jmin[0:Nd-1],dmin,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
READS,data.jmax[0:Nd-1],dmax,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'

tmp  = {jmin:0.0D, jmax:0.0D, offset:0.0}
para = replicate(tmp,Nd)
para.jmin    = dmin
para.jmax    = dmax
para.offset  = data.offset
RETURN, para
END