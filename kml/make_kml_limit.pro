PRO make_kml_limit, limit=limit
; write a polygone KML border by limits
; 0      1      2      3 
;lonmin,lonmax,latmin,latmax
st     = create_llval(5)
st.lon = [limit[0],limit[1],limit[1],limit[0],limit[0]]
st.lat = [limit[2],limit[2],limit[3],limit[3],limit[2]]
write_ll2kml,st
END