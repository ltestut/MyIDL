FUNCTION tatlas_mgr_domain_intersection, tatlas, mgr, mgr_out=mgr_out
; compute the domain intersection and cut in consequence the tatlas and mgr

 ;init the output
mgr_out      = mgr
tatlas_out   = tatlas
dl           = 0.5   ;0.5 degre 
 ;compute mgr limits
minlon_mgr   = MIN(mgr.lon, /NaN, MAX=maxlon_mgr)
minlat_mgr   = MIN(mgr.lat, /NaN, MAX=maxlat_mgr)
l_mgr        = [minlon_mgr,maxlon_mgr,minlat_mgr,maxlat_mgr]
 ;compute tatlas limits
minlon_atl   = MIN(tatlas.lon, /NaN, MAX=maxlon_atl)
minlat_atl   = MIN(tatlas.lat, /NaN, MAX=maxlat_atl)
l_atlas      = [minlon_atl,maxlon_atl,minlat_atl,maxlat_atl]
print,FORMAT='("mgr     :",4(F6.2,X))',l_mgr
print,FORMAT='("atlas   :",4(F6.2,X))',l_atlas

 ;inside clue (4:mgr inside ; 0:atlas inside ; else intersect) 
mgr_inside   = ((minlon_mgr GT minlon_atl)+(maxlon_mgr LT maxlon_atl)+$
                (minlat_mgr GT minlat_atl)+(maxlat_mgr LT maxlat_atl))
 
CASE (mgr_inside) OF
  0 : mgr_out    = cut_mgr(mgr,LIMIT=[l_atlas[0]-dl,l_atlas[1]+dl,l_atlas[2]-dl,l_atlas[3]+dl])     ;if atlas inside mgr
  4 : tatlas_out = tatlas_cut(tatlas,LIMIT=[l_mgr[0]-dl,l_mgr[1]+dl,l_mgr[2]-dl,l_mgr[3]+dl]) ;if mgr inside atlas
  ELSE : BEGIN                          ;if they intersect
        inter_limit=[(l_mgr[0]>l_atlas[0]),(l_mgr[1]<l_atlas[1]),$
                     (l_mgr[2]>l_atlas[2]),(l_mgr[3]<l_atlas[3])]
        tatlas_out = tatlas_cut(tatlas,LIMIT=[inter_limit[0]-dl,inter_limit[1]+dl,inter_limit[2]-dl,inter_limit[3]+dl])
        mgr_out    = cut_mgr(mgr,LIMIT=[inter_limit[0]-dl,inter_limit[1]+dl,inter_limit[2]-dl,inter_limit[3]+dl])
         END
ENDCASE 
RETURN,tatlas_out
END

