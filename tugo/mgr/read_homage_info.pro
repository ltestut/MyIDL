FUNCTION read_homage_info, filename
; function to read the output from homage (.info)


;read the info file and output the content into a string array *lines*
nlines =  FILE_LINES(filename)
lines  = STRARR(nlines)
OPENR, mgr_unit, filename, /GET_LUN
READF, mgr_unit, lines
FREE_LUN, mgr_unit

;get the index of important information
isep  = WHERE(stregex(lines,'_______',/FOLD_CASE,/BOOLEAN) EQ 1, nsep)         ;index of line separator
isep[0]  =  nlines                                                             ;index of last line
;File analysed              : idl.1996.jma
iname   = WHERE(stregex(lines,'File analysed',/FOLD_CASE,/BOOLEAN) EQ 1, nf)             ;index of the file name
indata  = WHERE(stregex(lines,'Number of data read',/FOLD_CASE,/BOOLEAN) EQ 1, nndata)   ;index of the total number of data read
imean   = WHERE(stregex(lines,'Mean    ',/FOLD_CASE,/BOOLEAN) EQ 1, nmean)               ;index of mean of time serie
irms1   = WHERE(stregex(lines,'RMS before',/FOLD_CASE,/BOOLEAN) EQ 1, nrms1)             ;index of rms of time serie before analysis
irms2   = WHERE(stregex(lines,'RMS of residuals',/FOLD_CASE,/BOOLEAN) EQ 1, nrms2)       ;index of rms of time serie of residuals
istart  = WHERE(stregex(lines,'cod  wave',/FOLD_CASE,/BOOLEAN) EQ 1, nstart)            ;index of starting of wave information


year_tab  = FIX(STRMID(STRMID(lines[iname],30,25),7,4,/REVERSE))
ndata_tab = FIX(STRMID(lines[indata],30,15))
mean_tab  = FLOAT(STRMID(lines[imean],30,15))
rms1_tab  = FLOAT(STRMID(lines[irms1],30,15))
rms2_tab  = FLOAT(STRMID(lines[irms2],30,15))

;extract the for principal waves
w1=((strsplit(lines[istart+1],/EXTRACT)).toArray())[*,1]
w2=(strsplit(lines[istart+2],/EXTRACT)).toArray()
w3=(strsplit(lines[istart+3],/EXTRACT)).toArray()
w4=(strsplit(lines[istart+4],/EXTRACT)).toArray()

tmp = {year:0, ndata:0, mean:0.0, rms1:0.0, rms2:0.0,  $
       name:STRARR(4), amp:FLTARR(4), pha:FLTARR(4)}
st  = REPLICATE(tmp,nmean)    

st.year  = year_tab
st.ndata = ndata_tab
st.mean  = mean_tab
st.rms1  = rms1_tab   
st.rms2  = rms2_tab
FOR i=0,3 DO BEGIN
  st.name[i]  = ((strsplit(lines[istart+1+i],/EXTRACT)).toArray())[*,1]
  st.amp[i]   = ((strsplit(lines[istart+1+i],/EXTRACT)).toArray())[*,2]
  st.pha[i]   = ((strsplit(lines[istart+1+i],/EXTRACT)).toArray())[*,3]
ENDFOR

RETURN,st

END
;________________________________________________________________________________
;
;Program used for analyse   : homage.v0.0
;File analysed              : idl.1996.jma
;Date analyse               : Mon Aug 19 15:16:52 2013
;First date                 : 1/1/1996
;Last date                  : 31/12/1996
;
;Calcul time                : 0.000000 min ( = 0.000000 sec)
;CPU used                   : 1
;
;Station N°                 : 0
;Station name               : idl.1996_00000
;Localisation               : 0.000000N 0.000000E
;
;Number of data read        : 8748
;Mean                       : 104.737323
;RMS before analyse         : 41.914093
;RMS of residuals           : 10.878256
;Delta T min  (s)           : 3599.942413
;Delta T max  (s)           : 68400.028794
;Delta T mean (s)           : 3614.816505
;
;
;The 4 bigger result waves :
;----------------------------
;cod  wave           ampli      phase
;9  M2            49.121647   190.479172
;13  S2            20.846134   231.115051
;7  N2            11.023313   172.014023
;3  K1             7.136497   153.234360
;

