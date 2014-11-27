FUNCTION concat_mgr, _EXTRA=extra
; concatenate multi mgr structure
; 

tag  = TAG_NAMES(extra)  ;name of the keyword used to add the mgr : concat_mgr(m1=,t2=,P3=)
nmgr = N_TAGS(extra)     ;number of mgr to concat
sum  = 0                 ;init the total number of station = nbre of mgr * nbre of station per mgr
nwav = 0                 ;init the maximum of wave found in the mgr
FOR i=0,nmgr-1 DO  sum  = sum + N_ELEMENTS(extra.(i)) 
FOR i=0,nmgr-1 DO  nwav = nwav > MAX(extra.(i).nwav)

print,"######################  CONCAT_MGR  #########################"
print,"CONCAT_MGR    :                mgr tag names =",tag
print,"CONCAT_MGR    : Number of mgr to concatenate =",nmgr
print,"CONCAT_MGR    : Total Number of station      =",sum

mgr      = create_mgr(sum,nwav)
name     = LIST()
origine  = LIST()
enr      = LIST()
val      = LIST()
lat      = LIST()
lon      = LIST()
filename = LIST() 
num_wav  = LIST() 
code     = INTARR(nwav,sum)
wave     = STRARR(nwav,sum)
amp      = FLTARR(nwav,sum)
pha      = FLTARR(nwav,sum)
cpt      = 0L

FOR i=0,nmgr-1 DO BEGIN ;loop on all mgr to extract and concatenate elements
  nsta          =  N_ELEMENTS(extra.(i).name) ;number of station for this mgr
  name.Add      ,extra.(i).name,/EXTRACT
  filename.Add  ,extra.(i).filename,/EXTRACT
  origine.Add   ,extra.(i).origine,/EXTRACT
  enr.Add       ,extra.(i).enr,/EXTRACT
  val.Add       ,extra.(i).val,/EXTRACT
  lon.Add       ,extra.(i).lon,/EXTRACT
  lat.Add       ,extra.(i).lat,/EXTRACT
  num_wav.Add   ,extra.(i).nwav,/EXTRACT
  FOR j=0,nsta-1 DO BEGIN
      nw               = extra.(i)[j].nwav ;number of waves for this station
      code[0:nw-1,cpt] = extra.(i)[j].code[0:nw-1]
      wave[0:nw-1,cpt] = extra.(i)[j].wave[0:nw-1]
      amp[0:nw-1, cpt] = extra.(i)[j].amp[0:nw-1]
      pha[0:nw-1, cpt] = extra.(i)[j].pha[0:nw-1]
      cpt++
  ENDFOR
ENDFOR
mgr.name      = name.ToArray(TYPE='STRING')
mgr.filename  = filename.ToArray(TYPE='STRING')
mgr.origine   = origine.ToArray(TYPE='STRING')
mgr.enr       = enr.ToArray(TYPE='STRING')
mgr.val       = val.ToArray(TYPE='STRING')
mgr.lat       = lat.ToArray(TYPE='DOUBLE')
mgr.lon       = lon.ToArray(TYPE='DOUBLE')
mgr.nwav      = num_wav.ToArray(TYPE='INT')
mgr.code      = code
mgr.wave      = wave
mgr.amp      = amp
mgr.pha      = pha

RETURN, mgr
END