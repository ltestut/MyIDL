PRO make_timeline, st, gap_size=gap_size, min_data=min_data,suffix=suffix, verbose=verbose
; build the template of the chrono from a given {jul,val} 
; work only for yearly chrono 
; both the gap size and the number of present data inside period could be specified
; make_timeline , st, gap_size=1h
  
IF NOT KEYWORD_SET(suffix) THEN suffix=')' 

IF NOT KEYWORD_SET(gap_size) THEN delta    = (1./24.) ELSE delta = (gap_size/24.)
IF NOT KEYWORD_SET(min_data) THEN min_data = 10.     ELSE min_data=min_data

prefix_chrono = 'chrono = fill_chrono(chrono,key='
time_fmt      = '(C(CDI2.2,CMOI2.2,CYI4.4,CHI2.2,CMI2.2))'
CALDAT, st.jul, month, day, year
yy    = year[UNIQ(year)]


OPENW,  UNIT, !timeline  , /GET_LUN
FOR i=0,N_ELEMENTS(yy)-1 DO BEGIN ;loop of every y   
id=WHERE((year EQ yy[i]),count)
IF (count GE 1) THEN BEGIN
  stmp                      = create_julval(count+2,/NAN)                            ;create the st for the given year
  stmp[0:1].jul             = [JULDAY(1,1,yy[i],0,0,0),JULDAY(12,31,yy[i],23,59,59)] ;add the first and last day of the year
  stmp[2:(count+2)-1].jul   = st[id].jul                                             ;select and ordered the data of the year
  stmp[2:(count+2)-1].val   = st[id].val                                             
  stmp                      = tri_julval(stmp)
  ndata                     = N_ELEMENTS(stmp.jul)
  time_sep  = -TS_DIFF(stmp.jul,1,/DOUBLE)    ;compute the time separation between each date in days
  i_gap     = WHERE(time_sep GT delta,cdelta) ;start index for the time separation GT the given gap OR end index of block
  block     = 1                               ;init the block counter (0 is reserved for the block type, "yearly","gps",...)
  CASE cdelta OF
      0: PRINTF,UNIT,prefix_chrono+STRING(yy[i],FORMAT='(I4)')+",start_block='"+STRING(stmp[0].jul,FORMAT=time_fmt)+"',end_block='"+STRING(stmp[-1].jul,FORMAT=time_fmt)+"',block="+STRING(block,FORMAT='(I-2)')+suffix
      1: BEGIN
            i_start = [0       , i_gap[0]+1]
            i_end   = [i_gap[0], ndata-1]      
         END
      2: BEGIN
             i_start = [0       , i_gap[0]+1 , i_gap[1]+1]
             i_end   = [i_gap[0], i_gap[1]   , ndata-1]
         END
   ELSE: BEGIN
           itmp    = i_gap[0:N_ELEMENTS(i_gap)-2]+1
           ishift  = (SHIFT(i_gap,-1))[0:N_ELEMENTS(i_gap)-2]
           i_start = [0        , itmp   ,i_gap[-1]+1]
           i_end   = [i_gap[0] , ishift ,ndata-1]
      END
  ENDCASE
  block_size = i_end-i_start         ;compute the block size from end and start index
  nblock     = N_ELEMENTS(block_size) 
  PRINTF,UNIT,FORMAT='(%"; year = %s")',yy[i]
  FOR j=0,nblock-1 DO IF (block_size[j] GT min_data) THEN PRINTF,UNIT,prefix_chrono+STRING(yy[i],FORMAT='(I4)')+",start_block='"+STRING(stmp[i_start[j]].jul,FORMAT=time_fmt)+$
                                                       "',end_block='"+STRING(stmp[i_end[j]].jul,FORMAT=time_fmt)+"',block="+STRING(block++,FORMAT='(I-2)')+suffix
  IF KEYWORD_SET(verbose) THEN FOR k=0,nblock-1 DO PRINT,k,' : ',print_date(stmp[i_start[k]].jul,/SINGLE),' ---> ',print_date(stmp[i_end[k]].jul,/SINGLE)                                                       
ENDIF
ENDFOR
FREE_LUN, UNIT
PRINT,"Ecriture du fichier timeline dans  ==>",!timeline
END
