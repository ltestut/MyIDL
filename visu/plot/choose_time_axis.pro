PRO choose_time_axis, ta=ta, layout=layout
; permet de choisir une annotation appropriee pour l'axe des temps (axe X)
;  
IF NOT KEYWORD_SET(layout) THEN BEGIN 
   !X.TICKLAYOUT = 0
   IF NOT KEYWORD_SET(ta) THEN RETURN
ENDIF ELSE BEGIN
   !X.TICKLAYOUT = layout
   IF NOT KEYWORD_SET(ta) THEN RETURN
ENDELSE
    
; annotation tous les 100 ans
IF (ta EQ '100y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 100
    !X.MINOR        = 10
ENDIF
; annotation tous les 50 ans
IF (ta EQ '50y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 50
    !X.MINOR        = 10
ENDIF
; annotation tous les 25 ans
IF (ta EQ '25y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 25
    !X.MINOR        = 10
ENDIF
; annotation tous les 20 ans
IF (ta EQ '20y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 20
    !X.MINOR        = 10
ENDIF
; annotation tous les 10 ans
IF (ta EQ '10y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 10
    !X.MINOR        = 10
ENDIF
; annotation tous les 5 ans
IF (ta EQ '5y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 5
    !X.MINOR        = 5
ENDIF
; annotation tous les 2 ans
IF (ta EQ '2y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 2
    !X.MINOR        = 12
ENDIF
; annotation tous les 1 an
IF (ta EQ '1y') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Year']
    !X.TICKINTERVAL = 1
    !X.MINOR        = 12
ENDIF
; annotation tous les 6 mois
IF (ta EQ '6m') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%N','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Month','Time']
    !X.TICKINTERVAL = 6   
    !X.MINOR        = 6
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 3 mois
IF (ta EQ '3m') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%N','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Month','Time']
    !X.TICKINTERVAL = 3   
    !X.MINOR        = 3
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 2 mois
IF (ta EQ '2m') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%N','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Month','Time']
    !X.TICKINTERVAL = 2   
    !X.MINOR        = 2
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 1 mois
IF (ta EQ '1m') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%N','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Month','Time']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 1 mois sans l'annee
IF (ta EQ 'only_month') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%M'])
    !X.TICKFORMAT   = ['LABEL_DATE']
    !X.TICKUNITS    = ['Month']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF

; annotation tous les 15 jours
IF (ta EQ '15j') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%D','%N/%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Day','Time']
    !X.TICKINTERVAL = 15   
    !X.MINOR        = 5
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 10 jours
IF (ta EQ '10j') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%D','%M','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Day','Month','Year']
    !X.TICKINTERVAL = 10   
    !X.MINOR        = 10
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 5 jours
IF (ta EQ '5j') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%D','%M','%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Day','Month','Year']
    !X.TICKINTERVAL = 5   
    !X.MINOR        = 5
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 2 jours
IF (ta EQ '2j') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%D','%M%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Day','Month']
    !X.TICKINTERVAL = 2   
    !X.MINOR        = 2
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 1 jours
IF (ta EQ '1j') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%D','%M%Y'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Day','Month']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 12 heures
IF (ta EQ '12h') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Hour','Time']
    !X.TICKINTERVAL = 12   
    !X.MINOR        = 12
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 6 heures
IF (ta EQ '6h') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Hour','Time']
    !X.TICKINTERVAL = 6   
    !X.MINOR        = 6
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 1 heures
IF (ta EQ '1h') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Hour','Time']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF                
; annotation tous les 30  min
IF (ta EQ '30mn') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H:%I','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Minute','Time']
    !X.TICKINTERVAL = 30   
    !X.MINOR        = 3
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 20  min
IF (ta EQ '20mn') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H:%I','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Minute','Time']
    !X.TICKINTERVAL = 20   
    !X.MINOR        = 2
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 10  min
IF (ta EQ '10mn') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H:%I','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Minute','Time']
    !X.TICKINTERVAL = 10   
    !X.MINOR        = 2
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 5  min
IF (ta EQ '5mn') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H:%I','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Minute','Time']
    !X.TICKINTERVAL = 5   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 1  min
IF (ta EQ '1mn') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%H:%I','%D/%M'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Minute','Time']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 30  secondes
IF (ta EQ '30s') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%I:%s','%D/%M %Hh'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Second','Time']
    !X.TICKINTERVAL = 30   
    !X.MINOR        = 3
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 10  secondes
IF (ta EQ '10s') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%I:%s','%D/%M %Hh'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Second','Time']
    !X.TICKINTERVAL = 10   
    !X.MINOR        = 5
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF
; annotation tous les 1  secondes
IF (ta EQ '1s') THEN BEGIN
    date_label      = LABEL_DATE(DATE_FORMAT = ['%s','%D/%M %H:%I'])
    !X.TICKFORMAT   = ['LABEL_DATE','LABEL_DATE']
    !X.TICKUNITS    = ['Second','Time']
    !X.TICKINTERVAL = 1   
    !X.MINOR        = 1
    !X.TICKLEN      = 0.05
    !X.GRIDSTYLE    = 0
ENDIF

;       30 : BEGIN ;tout les 30 secondes
;            date_label=LABEL_DATE(DATE_FORMAT = ['%S','%D/%M %H:%I'])
;            !X.TICKUNITS    =['Seconds','Time']
;            !X.TICKINTERVAL = 30   
;            !X.TICKLEN      = 0.05
;            !X.GRIDSTYLE    = 0
;            END
;       31 : BEGIN ;tout les 10 secondes
;            date_label=LABEL_DATE(DATE_FORMAT = ['%S','%D/%M %H:%I'])
;            !X.TICKUNITS    =['Seconds','Time']
;            !X.TICKINTERVAL = 10  
;            !X.TICKLEN      = 0.05
;            !X.GRIDSTYLE    = 0
;            END
;       32 : BEGIN ;tout les 1 secondes
;            date_label=LABEL_DATE(DATE_FORMAT = ['%S','%D/%M %H:%I'])
;            !X.TICKUNITS    =['Seconds','Time']
;            !X.TICKINTERVAL = 1  
;            !X.TICKLEN      = 0.05
;            !X.GRIDSTYLE    = 0
;            END
;
;
;  ENDCASE
;ENDIF


END