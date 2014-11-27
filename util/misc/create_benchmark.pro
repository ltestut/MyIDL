FUNCTION create_benchmark, npt, nan=nan
; create a benchmark structure with *npt* points

tmp  = {name:'' ,   descr:'', install:0, remove:0, $
        lon:0.0D,   lat:0.0D, id:HASH(),$
        kmlstyle:'benchmark-red',kmldescr:'',$
        cote:LIST(), coted:LIST(), coteref:LIST(), cotep:LIST(),$
        ellh:LIST(), ellhd:LIST(), ellhref:LIST(),$        
        alt:LIST() ,altref:LIST() , $        
        ref:LIST() ,img:LIST()}
        
 ;replicate the structure for npt
bm  = replicate(tmp,npt)
RETURN, bm
END