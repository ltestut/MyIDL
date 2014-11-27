FUNCTION create_aviso_alongtrack_st, ntrack, ndata

sta  = { DeltaT              :LONARR(ndata)      ,$ ;ivar=0  : diff de temps entre 2 mesures sf=1E-6 [s]
         Tracks              :LONARR(ntrack)     ,$ ;ivar=1  :numero de la trace 
         NbPoints            :LONARR(ntrack)     ,$ ;ivar=2  :nb de pts de la trace
         Cycles              :LONARR(ntrack)     ,$ ;ivar=3  :numero du cycle
         Longitudes          :LONARR(ndata)      ,$ ;ivar=4  :longitude sf=1E-6 [deg Est]
         Latitudes           :LONARR(ndata)      ,$ ;ivar=5  :latitude  sf=1E-6 [deg Nord]
         BeginDates          :DBLARR(ntrack)     ,$ ;ivar=6  :date de debut de la trace pour le cycle [jour]
         DataIndexes         :LONARR(ndata)      ,$ ;ivar=7  :index dans la trace theorique
         TimeDay             :INTARR(ndata)      ,$ ;ivar=8  :nbre de jour depuis le 1/1/1950 0:0:0
         TimeSec             :LONARR(ndata)      ,$ ;ivar=9  :nbre de sec le jour ci-dessus (entre 0 et 86400)
         TimeMicroSec        :LONARR(ndata)      ,$ ;ivar=10 :nbre de micro-sec a ajouter
         CorSSH              :LONARR(ndata)      ,$ ;ivar=11 :SSH / ellipsoide sf=0.0001 [m]
         dry_tropo_corr      :INTARR(ndata)      ,$ ;ivar=12 :correction tropo seche sf=0.0001 [m]
         dynamic_atmosph_corr:INTARR(ndata)      ,$ ;ivar=13 :correction DAC  sf=0.0001 [m]
         ocean_tide          :LONARR(ndata)      ,$ ;ivar=14 :correction de maree sf=0.0001 [m]
         solid_earth_tide    :INTARR(ndata)      ,$ ;ivar=15 :correction de maree terrestre sf=0.0001 [m]
         sea_state_bias      :INTARR(ndata)      ,$ ;ivar=16 :correction de maree terrestre sf=0.0001 [m]
         pole_tide           :INTARR(ndata)      ,$ ;ivar=17 :correction de maree polaire sf=0.0001 [m]
         iono_corr           :INTARR(ndata)      ,$ ;ivar=18 :correction ionospherique sf=0.0001 [m]
         wet_tropo_corr      :INTARR(ndata)      ,$ ;ivar=19 :correction tropo humide sf=0.0001 [m]
         mean_sea_surface    :INTARR(ndata)      ,$ ;ivar=20 :MSS sf=0.0001 [m]
         swh                 :INTARR(ndata)      ,$ ;ivar=21 :hauteur significative des vagues en bande Ku sf=0.001 [m]
         sigma0              :INTARR(ndata)      ,$ ;ivar=22 :coefficient de retrodifuusion en bande Ku sf=0.001 [dB]
         bathymetry          :LONARR(ndata)      ,$ ;ivar=23 :bathymetry sf=0.001 [m]
         inter_mission_bias  :INTARR(ndata)       $ ;ivar=24 :biais entre T/P et Jason sf=0.001 [m]
         }
RETURN,sta
END