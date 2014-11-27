PRO selfe_mgr2in, mgr_in, limit=limit
; prog to select a list location from a mgr and write a
; to input a station locations input (station.in) file for SELFE
; This file is needed if iout_sta=1 in param.in and is in a build pointformat:
; on-off flags for each output variables
; np: same as in hgrid.gr3;
; do i=1,np --> i,xsta(i),ysta(i),zsta(i) !zsta(i) is z-coordinates (from MSL)



IF NOT KEYWORD_SET(limit) THEN limit=get_mgr_limit(mgr_in)
PRINT,FORMAT='(%" Geographic limit = %7.3f°E /%7.3f°E /%7.3f°N /%7.3f°N")',$
   limit[0],limit[1],limit[2],limit[3]

mgr=cut_mgr(mgr_in,LIMIT=limit)


 ;write a station.in file
header='1 0 0 0 0 0 1 1 0  !elev, air pressure, windx, windy, T, S, u, v, w'
N=N_ELEMENTS(mgr)
cpt=0

OPENW,  UNIT, !desk+'station.in'  , /GET_LUN 
PRINTF, UNIT, header
PRINTF, UNIT, FORMAT='(I5)',N
FOR i=0L,N-1 DO PRINTF,UNIT,FORMAT='(%" %03d %11.4f %11.4f 0.0 !%s")',$
   ++cpt,mgr[i].lon,mgr[i].lat,mgr[i].name
FREE_LUN, UNIT
PRINT,"Write ---  ",!desk+'station.in'
END