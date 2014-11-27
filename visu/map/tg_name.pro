FUNCTION tg_name 
tmp  = {lon:0.0, lat:0.0, name:''}
tg   = replicate(tmp,6)

tg[0].lon= -5.542   & tg[0].lat= 50.103  & tg[0].name= 'Newlin' 
tg[1].lon= -3.966   & tg[1].lat= 48.716  & tg[1].name= 'Roscoff' 
tg[2].lon= -4.5     & tg[2].lat= 48.383  & tg[2].name= 'Brest' 
tg[3].lon= -4.783   & tg[3].lat= 48.366  & tg[3].name= 'Le Conquet' 
tg[4].lon= 70.220   & tg[4].lat=-49.345  & tg[4].name= 'ker'
tg[5].lon= 69.9366  & tg[5].lat=-49.8533 & tg[5].name= 'ker09'

RETURN, tg
END