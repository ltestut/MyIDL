FUNCTION tatlas_domain_intersection, tatlas1, tatlas2, t2_out=t2_out, quiet=quiet, verbose=verbose
; compute the domain intersection of 2 tatlas and cut in consequence the tatlas
; 
;init the output
t1_out   = tatlas1
t2_out   = tatlas2
dl       = 0.
 ;compute tatlas limits
minlon_atl1   = MIN(tatlas1.lon, /NaN, MAX=maxlon_atl1)
minlat_atl1   = MIN(tatlas1.lat, /NaN, MAX=maxlat_atl1)
minlon_atl2   = MIN(tatlas2.lon, /NaN, MAX=maxlon_atl2)
minlat_atl2   = MIN(tatlas2.lat, /NaN, MAX=maxlat_atl2)
l_atlas1      = [minlon_atl1,maxlon_atl1,minlat_atl1,maxlat_atl1]
l_atlas2      = [minlon_atl2,maxlon_atl2,minlat_atl2,maxlat_atl2]
 ;

 ;inside clue (0:atl2 inside ; 4:atl1 inside ;  else intersect) 
atl_inside   = ((minlon_atl1 GT minlon_atl2)+(maxlon_atl1 LT maxlon_atl2)+$
                (minlat_atl1 GT minlat_atl2)+(maxlat_atl1 LT maxlat_atl2))
IF NOT KEYWORD_SET(quiet) THEN BEGIN
 PRINT,'#####################  TATLAS_DOMAIN_INTERSECTION  ##############################'
 PRINT,FORMAT='("atlas1 [",A-15,"]  :",4(F6.2,X))',tatlas1.info,l_atlas1
 PRINT,FORMAT='("atlas2 [",A-15,"]  :",4(F6.2,X))',tatlas2.info,l_atlas2
ENDIF

CASE (atl_inside) OF
  0 : BEGIN
      t1_out  = tatlas_cut(tatlas1,LIMIT=[l_atlas2[0]-dl,l_atlas2[1]+dl,l_atlas2[2]-dl,l_atlas2[3]+dl]) ;alt2 inside then alt1 is cut and return
      IF NOT KEYWORD_SET(quiet) THEN PRINT,FORMAT='(A10," inside ",A10," : latter is cut to ",4(F6.2,X))',tatlas2.info,tatlas1.info,l_atlas2
      END
  4 : BEGIN
      t2_out  = tatlas_cut(tatlas2,LIMIT=[l_atlas1[0]-dl,l_atlas1[1]+dl,l_atlas1[2]-dl,l_atlas1[3]+dl]) ;alt1 inside then alt2 is cut and return
      IF NOT KEYWORD_SET(quiet) THEN PRINT,FORMAT='(A10," inside ",A10," : latter is cut to ",4(F6.2,X))',tatlas1.info,tatlas2.info,l_atlas1
      END
  ELSE : BEGIN                          ;if they intersect
         inter_limit=[(l_atlas1[0]>l_atlas2[0]),(l_atlas1[1]<l_atlas2[1]),$
                     (l_atlas1[2]>l_atlas2[2]),(l_atlas1[3]<l_atlas2[3])]
         t1_out = tatlas_cut(tatlas1,LIMIT=[inter_limit[0]-dl,inter_limit[1]+dl,inter_limit[2]-dl,inter_limit[3]+dl])
         t2_out = tatlas_cut(tatlas2,LIMIT=[inter_limit[0]-dl,inter_limit[1]+dl,inter_limit[2]-dl,inter_limit[3]+dl])
         IF NOT KEYWORD_SET(quiet) THEN PRINT,FORMAT='(A10," intersect ",A10," : both are cut to ",4(F6.2,X))',tatlas1.info,tatlas2.info,l_atlas1                 
         END
ENDCASE 
RETURN,t1_out
END

