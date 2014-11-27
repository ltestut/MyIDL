FUNCTION compute_timeline_block_min_max,type,key,tmin,tmax,resolution=resolution
; transforme the date coordinate into x coordinate 
dmin=0.0D & dmax=0.0D
READS,tmin,dmin,FORMAT=get_format(STRLEN(tmin))
READS,tmax,dmax,FORMAT=get_format(STRLEN(tmax))
CASE (type) OF
  'yearly' :BEGIN
            xmin=(dmin-JULDAY(1,1,key,0,0,0))*resolution
            xmax=(dmax-JULDAY(1,1,key,0,0,0))*resolution
            END
  'weekly' :BEGIN
            datum=key*7.+JULDAY(1,6,1980,0,0,0)
            xmin=(dmin-datum)*resolution
            xmax=(dmax-datum)*resolution
          END
ENDCASE
RETURN,[xmin,xmax]
END