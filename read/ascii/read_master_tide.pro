FUNCTION read_master_tide, filename, scale=scale, ut=ut , verbose=verbose
; read the master-tide.dat file prepared by Michael at NIO and return a mgr structure

 ;gestion des mots-cles et format du verbose
IF NOT KEYWORD_SET(scale) THEN scale = 0.01 ;the master-tide file is in cm and in local time  

wave_list=load_tidal_wave_list(/UPPERCASE,/QUIET)


 ;read the master-tide file count the line and fill the lines array
nlines =  FILE_LINES(filename)
lines  = STRARR(nlines)
OPENR, mgr_unit, filename, /GET_LUN
READF, mgr_unit, lines
FREE_LUN, mgr_unit

istart  = WHERE(stregex(lines,'Country',/FOLD_CASE,/BOOLEAN) EQ 1, nsta)   ;index of firsts station data 
nwa     = 66
mgr     = create_mgr(nsta,nwa)

name    = STRMID(lines[istart+1],47)            ;string array of all station
lat     = FLOAT(STRMID(lines[istart+2],20,4))   ;lat array of all station
latd    = FLOAT(STRMID(lines[istart+2],28,5))   ;lat decimal array of all station
lon     = FLOAT(STRMID(lines[istart+2],55,4))   ;lat array of all station
lond    = FLOAT(STRMID(lines[istart+2],63,5))   ;lat decimal array of all station
lat     = lat + latd/60.
lon     = lon + lond/60.

 ;fill the mgr structure
mgr.filename = filename 
mgr.name     = STRCOMPRESS(name,/REMOVE_ALL)
mgr.origine  = MAKE_ARRAY(nsta,/STRING,VALUE='NIO-Master-Tide')
mgr.enr      = MAKE_ARRAY(nsta,/STRING,VALUE='')
mgr.val      = MAKE_ARRAY(nsta,/STRING,VALUE='NIO')
mgr.lat      = lat
mgr.lon      = lon
mgr.nwav     = nwa
  
idline   = [12,13,14,16,17,18,19,20,21,22,23,24,26,27,28,29,30,31,32,33,34,36,37,38,40,41,42,43,45,46,47,48,49,51]
cpt_wave = 0
FOR i=0,N_ELEMENTS(idline)-1 DO BEGIN
  PRINT,i,idline[i]
  IF (i EQ 23 OR i EQ 32) THEN BEGIN  ;2 lines with only 1 wave
          wn  = STRCOMPRESS(STRMID(lines[istart+idline[i]],11,6),/REMOVE_ALL)   ;wave string array of all station
          amp = FLOAT(STRMID(lines[istart+idline[i]],21,5))                     ;amp string array of all station
          pha = FLOAT(STRMID(lines[istart+idline[i]],32,5))                     ;pha string array of all station
          inan = WHERE(amp EQ 999.0,cpt_nan)
          IF (cpt_nan GE 1) THEN BEGIN
             amp[inan]=!VALUES.F_NAN
             pha[inan]=!VALUES.F_NAN
          ENDIF
          mgr.code[cpt_wave] = wave2code(wn)   ;on remplit les code des nwa premieres ondes
          mgr.wave[cpt_wave] = wn              ;on remplit les nwa premieres ondes
          mgr.amp[cpt_wave]  = amp*scale
          IF KEYWORD_SET(ut) THEN BEGIN
              greenwich_pha      = pha-ut*tidal_wave_info(wn,WAVE_LIST=wave_list)
              mgr.pha[cpt_wave]  = ((360.+greenwich_pha) MOD 360.)
          ENDIF ELSE BEGIN
              mgr.pha[cpt_wave]  = pha
          ENDELSE
          cpt_wave++
  ENDIF ELSE BEGIN
      FOR j=0,1 DO BEGIN
          wn  = STRCOMPRESS(STRMID(lines[istart+idline[i]],11+j*35,6),/REMOVE_ALL)   ;wave string array of all station
          amp = FLOAT(STRMID(lines[istart+idline[i]],21+j*35,5))                     ;amp string array of all station
          pha = FLOAT(STRMID(lines[istart+idline[i]],32+j*35,5))                     ;pha string array of all station
          inan = WHERE(amp EQ 999.0,cpt_nan)
          IF (cpt_nan GE 1) THEN BEGIN
             amp[inan]=!VALUES.F_NAN
             pha[inan]=!VALUES.F_NAN
          ENDIF
          mgr.code[cpt_wave] = wave2code(wn)  ;on remplit les code des nwa premieres ondes
          mgr.wave[cpt_wave] = wn              ;on remplit les nwa premieres ondes
          mgr.amp[cpt_wave]  = amp*scale
          IF KEYWORD_SET(ut) THEN BEGIN
              greenwich_pha      = pha-ut*tidal_wave_info(wn,WAVE_LIST=wave_list)
              mgr.pha[cpt_wave]  = ((360.+greenwich_pha) MOD 360.)
          ENDIF ELSE BEGIN
              mgr.pha[cpt_wave]  = pha
          ENDELSE
          cpt_wave++
      ENDFOR
   ENDELSE
ENDFOR

write_mgr,mgr,FILENAME='/data/model_indien_nord/valid/mrg/src/unni/master_tide.mgr'

RETURN, mgr
END