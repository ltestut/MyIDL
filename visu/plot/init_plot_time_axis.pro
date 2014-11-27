PRO init_plot_time_axis, tmin, tmax, dmin, dmax ,$
                        date_label=date_label,$
                        time_tickformat=time_tickformat,$
                        time_tickunits =time_tickunits,$
                        time_tickinterval =time_tickinterval
                        


smin = 0. & smax = 0.      ; initialisation des 
kmin = N_ELEMENTS(tmin) & kmax = N_ELEMENTS(tmax) ;test de la presence du mot-cle tmin & tmax

IF (kmin NE 0) THEN BEGIN
   smin=STRLEN(tmin)
   READS,tmin,dmin,FORMAT=get_format(smin)
ENDIF
IF (kmax NE 0) THEN BEGIN
   smax=STRLEN(tmax)
   READS,tmax,dmax,FORMAT=get_format(smax)
ENDIF
IF (dmax LT dmin) THEN BEGIN
 STOP,'ATTENTION: tmin > tmax'
ENDIF
stot=smax>smin ;on choisit le format le plus precis

CASE stot OF ;choix du label en fct de tmin et tmax
        0 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%N/%Y'])
            time_tickunits    = ['Time']
           ;time_tickunits     =['Year']            
        END
        4 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%Y'])
            time_tickunits    = ['Year']
            time_tickinterval = FLOOR((dmin-dmax)/3650.)
        END
        6 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%N/%Z'])
            time_tickunits    = ['Months']
            time_tickinterval = FLOOR((dmin-dmax)/120.)
        END
        8 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%D/%N/%Z'])
            time_tickunits    = ['Days']
            time_tickinterval = FLOOR((dmin-dmax)/10.)
        END
        10 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%D/%N:%H'])
            time_tickunits    = ['Hours']
            time_tickinterval = FLOOR((dmin-dmax))
        END
        12 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%D/%N:%H:%I'])
            time_tickunits    = ['Minutes']
            time_tickinterval = FLOOR((dmin-dmax))
        END
        14 : BEGIN
            date_label        = LABEL_DATE(DATE_FORMAT = ['%H:%I:%S'])
            time_tickunits    = ['Seconds']
            time_tickinterval = FLOOR((dmin-dmax))
        END
ENDCASE
time_tickformat   = ['LABEL_DATE']
END