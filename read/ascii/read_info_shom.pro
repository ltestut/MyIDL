FUNCTION read_info_shom, filename=filename
; lecture du fichier d'information sur les donnees shom info_shom_ddu.txt
; format type of
;session   TU  julcut_min          julcut cut_max      offset
;-------   --  ------------------- ------------------- ------
;1           0  02/05/1952 00:00:00 31/05/1952 23:00:00 0

IF NOT KEYWORD_SET(filename) THEN STOP,'Need filename'
 ;patron de lecture du fichier de configuration
cfg = {version:1.0,$
      datastart:0   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:';'   ,$
      fieldcount:5 ,$
      fieldTypes:[2,2,7,7,4], $
      fieldNames:['raw','tu','jmin','jmax','offset'] , $
      ;                  .(0) .(1)
      fieldLocations:[0,3,13,34,54], $
      fieldGroups:indgen(5) $
   }
   ;Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)
Nd    = N_ELEMENTS(data.raw)
date  = DBLARR(Nd)
dmin  = DBLARR(Nd)
dmax  = DBLARR(Nd)
READS,data.jmin[0:Nd-1],dmin,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
READS,data.jmax[0:Nd-1],dmax,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
tmp  = {session:0, tu:0, jmin:0.0D, jmax:0.0D, offset:0.0}
para = replicate(tmp,Nd)
para.session = data.raw
para.tu      = data.tu
para.jmin    = dmin
para.jmax    = dmax
para.offset  = data.offset
RETURN, para
END
