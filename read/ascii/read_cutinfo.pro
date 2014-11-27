FUNCTION read_cutinfo, filename
; lecture du fichier d'information sur les donnees cutinfo.txt 
IF NOT KEYWORD_SET(filename) THEN print,"Need filename info"
;patron de lecture du fichier de configuration 
;---------------------------------------------
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:';'   ,$
      fieldcount:3 ,$
      fieldTypes:[7,7,7], $
      fieldNames:['jmin','jmax','info'] , $
;                  .(0) .(1)        
      fieldLocations:[0,19,39], $
      fieldGroups:indgen(3) $
      }

; Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)
Nd    = N_ELEMENTS(data.jmin)
dmin  = DBLARR(Nd)
dmax  = DBLARR(Nd)
READS,data.jmin[0:Nd-1],dmin,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
READS,data.jmax[0:Nd-1],dmax,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'

tmp  = {jmin:0.0D, jmax:0.0D}
para = replicate(tmp,Nd)
para.jmin    = dmin
para.jmax    = dmax
RETURN, para
END