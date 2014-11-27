FUNCTION default_time_axis, tmin, tmax, dmin, dmax
; calcul a partir des dates min et max de la structure (dmin/dmax) ou des entrees (tmin/tmax)
; de plot_* l'axe des temps par defaut.
 
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
            date_label=LABEL_DATE(DATE_FORMAT = ['%N/%Y'])
           !X.TICKFORMAT   = ['LABEL_DATE']
           !X.TICKUNITS    = ['Time']
           !X.TICKUNITS=['Year']            
        END
        4 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%Y'])
            !X.TICKUNITS=['Year']
            !X.TICKINTERVAL = FLOOR((dmin-dmax)/3650.)
        END
        6 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%N/%Z'])
            !X.TICKUNITS=['Months']
            !X.TICKINTERVAL = FLOOR((dmin-dmax)/120.)
        END
        8 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%D/%N/%Z'])
            !X.TICKUNITS=['Days']
            !X.TICKINTERVAL = FLOOR((dmin-dmax)/10.)
        END
        10 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%D/%N:%H'])
            !X.TICKUNITS=['Hours']
            !X.TICKINTERVAL = FLOOR((dmin-dmax))
        END
        12 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%D/%N:%H:%I'])
            !X.TICKUNITS=['Minutes']
            !X.TICKINTERVAL = FLOOR((dmin-dmax))
        END
        14 : BEGIN
            date_label=LABEL_DATE(DATE_FORMAT = ['%H:%I:%S'])
            !X.TICKUNITS=['Seconds']
            !X.TICKINTERVAL = FLOOR((dmin-dmax))
        END
ENDCASE
RETURN, date_label
END