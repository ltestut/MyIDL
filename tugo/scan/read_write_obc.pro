FUNCTION read_write_obc, filename, tides=tides, write=write, scale=scale
; return a mgr structure to be plotted for checking
; /tides     : to read the cat tides.obc (default if to read single wave M2.obc)
; scale=0.01 : to scale the amplitude 
; /write     : to write the obc in the same format and location with scale transformation


IF NOT KEYWORD_SET(scale) THEN scale=1.

nlines =  FILE_LINES(filename)                                          ;number of lines of the file
OPENR, unit , filename, /GET_LUN                                        ;open the obc input file
IF KEYWORD_SET(write) THEN OPENW, unit2, filename+'.obc2', /GET_LUN     ;open the obc output file

IF KEYWORD_SET(tides) THEN BEGIN
  npts = 0
  nwa = 0
  name = ''
  READF, unit,FORMAT='(I4,I2,A1)',npts,nwa,name
ENDIF ELSE BEGIN
  npts=nlines-1
  nwa=1
ENDELSE
    
mgr          = create_mgr(npts,nwa)
mgr.nwav     = nwa
mgr.filename = filename 
mgr.name     = '' 
mgr.val      = 'OBC' 
wname        = ''
lon          = 0.0D
lat          = 0.0D

FOR i=0,nwa-1 DO BEGIN
  READF, unit, FORMAT='(A3)',wname
  IF KEYWORD_SET(write) THEN PRINTF,unit2,wname
  FOR j=0,npts-1 DO BEGIN
    READF,unit,FORMAT='(F9.6,X,F9.6,X,F8.6,X,F10.6)',lon,lat,amp,pha
    mgr[j].lon     = lon
    mgr[j].lat     = lat
    mgr[j].code[i] = wave2code(wname)       ;on remplit les code des nwa premieres ondes
    mgr[j].wave[i] = STRCOMPRESS(wname,/REMOVE_ALL)     
    mgr[j].amp[i]  = amp*scale
    mgr[j].pha[i]  = pha
  IF KEYWORD_SET(write) THEN PRINTF,unit2,FORMAT='(F9.6,X,F9.6,X,F8.6,X,F10.6)',lon,lat,amp*scale,pha 
  ENDFOR
ENDFOR
;434 10 M
;K1
;165.300003 -12.857096 0.180811 43.393608
;73.702873 13.570443 43.154587 154.618652
;165.300004 -12.767115 0.180807 43.522499
;165.300004 -12.587148 0.180801 43.780315
;
;
;127  2 M
;M2
;73.682449 13.623441 43.470459 154.274963
;73.661919 13.676882 44.223591 154.376160

CLOSE, UNIT
FREE_LUN, UNIT
IF KEYWORD_SET(write) THEN CLOSE, unit2
IF KEYWORD_SET(write) THEN FREE_LUN, unit2
IF KEYWORD_SET(write) THEN print,filename+'.obc2'

RETURN, mgr
END