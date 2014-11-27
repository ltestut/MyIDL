; $Id: ddm.pro,v 1.00 9/05/2005 L. Testut $
;

;+
; NAME:
;	DDM
;
; PURPOSE:
;	Compute the daily mean value of hourly sampled tidal data of type
;	{jul,val} at the specified date of an array or by default at noon of the input day.
;       You can also compute : 
;         the median value (for a 25 hours window)
;         the arithmetic mean around N hours. 
;       Your date array should have the same
;       kind of hour than your input structure st (ex. round hour, half). This 
;       mean that there is at the moment no interpolation of data, then compute
;       the daily mean at 12h:42:00 with st.jul every round hour (12h,13h,14h,..)
;       is not possible.
;	
; CATEGORY:
;	Read/Write procedure/function
;
; CALLING SEQUENCE:
;	st=ddm(st,date,method=method,/verbose)
;	
;       use      --> demerliac kernel
;                --> finite_st (function)
;                --> create_julval (function)
;                --> decimate_at_noon (function)
; INPUTS:
;	st      : structure of type {jul,val}
;       date    : date in julian day, or array of date
;       method  : method used to compute the daily mean
;                 'dem' for demerliac filtering
;                 'nmj' for niveau moyen journalier (eyries ?)
;                 'mh24'for an artihmetic mean on 24 hour
;                 'mh25'for an artihmetic mean on 25 hour
;                 'doo' for doodson filtering
;                 'median' for a median value (window of 25 elements is used)
;                 'xx' where x is a number to compute arithmetic mean on xx hours 
;
; OUTPUTS:
;	Structure {jul,val} with jul=date and val=filtered_values 
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
; - le 9/05/05  add Doodson filter
; - le 5/06/05  add the possibility to output a single value
; - le 4/06/05  add the nmh25 filter and the verbose choice
; - le 7/07/05  fix the bug I=LONARR and not INTARR
; - le 2/02/06  add the median filter & improve the usage
; - le 16/11/06 modify the loop to take into account the mean only if there is Nk value 
; - le 09/05/08 add the default computation centered at noon of the input date
;- 

; EXAMPLE 1:
; ---------
; If you want to know the daily mean value of the sea level on 20/09/2004 at 17h
; using a Doodson filter from your hourly {jul,val} structure st, then type:
;
;    IDL> stf = ddm(st,JULDAY(09,20,2004,17),method='doo',/verbose)
;    Method=doo  Nk=39 Sf=30.000   [39/39]==> 20/09/2004 17:0h mean = 114.872
;
; Nk     -> is the size of the kernel (the filter window)
; Sf     -> the scale factor (e.g. the sum of the window filter elements)
; [x/Nk] -> the number of element used to compute the daily mean (by default x=Nk)
; 
; EXAMPLE 2:
; ---------
; If you want to know the arithmetic mean of a serie on 20/09/2004 at 17h
; using a 120 hours window from your hourly {jul,val} structure st, then type:
;
;    IDL> print,ddm(st,JULDAY(09,20,2004,17),method='120',/verbose)
;    Method=120  Nk=120 Sf=120.000   [120/120]==> 20/09/2004 17:0h mean = 106.658
;
; EXAMPLE 3:
; ---------
; You want to mean of 25-hourly observation of a serie centered at noon then type:
;
;    IDL> print,ddm(st,method='mh25',/verbose)

FUNCTION ddm, st, tdate, method=method, verbose=verbose, _EXTRA=_EXTRA

;VERIFIER QUE LE CALCUL DU NIVEAU MOYEN EST CORRECT 

IF (N_ELEMENTS(method) EQ 0)THEN method='nmj'
IF (N_ELEMENTS(tdate) EQ 0)THEN tdate=decimate_at_noon(st,/gap, _EXTRA=_EXTRA)


CASE 1 OF	
    (method EQ 'dem'): BEGIN
        kernel=[1.,3.,8.,15.,21.,32.,45.,55.,72.,91.,105.,128.,153.,171., $
                200.,231.,253.,288.,325.,351.,392.,435.,465.,512.,558., $
                586.,624.,658.,678.,704.,726.,738.,752.,762.,766., $
                768., $
                766.,762.,752.,738.,726.,704.,678.,658.,624.,586.,$
                558.,512.,465.,435.,392.,351.,325.,288.,253.,231.,200.,$
                171.,153.,128.,105.,91.,72.,55.,45.,32.,21.,15.,8.,3.,1.]
    END
    (method EQ 'nmj'): BEGIN    
        kernel=[1.,1.,1.,1.,1.,1.,2.,2.,2.,2.,2.,2.,3.,3.,3.,3.,3.,3.,3.,3.,3.,3., $
                3.,3.,2.,2.,2.,2.,2.,2.,1.,1.,1.,1.,1.,1.]
    END
    (method EQ 'mh24'): BEGIN    
        kernel=[0.5,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,0.5]
    END
    (method EQ 'mh25'): BEGIN    
        kernel=[1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.]
    END
    (method EQ 'doo'): BEGIN    
        kernel=[1,0,1,0,0,1,0,1,1,0,2,0,1,1,0,2,1,1,2,0,$
                2,1,1,2,0,1,1,0,2,0,1,1,0,1,0,0,1,0,1]
    END
    (method EQ 'median'): BEGIN    
        kernel=[1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.,1.]
    END    
    (method EQ method): BEGIN
        kernel=MAKE_ARRAY(LONG(method),/FLOAT,VALUE=1.)
    END
ENDCASE

st          = FINITE_ST(st)      ; Remove all NaN of the structure 
scale_factor= TOTAL(kernel)      ; Sum of the window filter for scaling
Nk          = N_ELEMENTS(kernel) ; Size of the kernel (the filter window)
Nk2         = (Nk-1)/2
tab         = DBLARR(Nk)
id1         = LONARR(Nk)
Nd          = N_ELEMENTS(tdate)                         ; Number of elements of the input date array
val         = MAKE_ARRAY(Nd,/FLOAT,VALUE=!VALUES.F_NAN) ; Init a float Nd tab to NaN 
deltat      = DOUBLE(0.1/(24.*3600.))                   ; Deltat of 0.1 second to compare date 

FOR K=0L,Nd-1 DO BEGIN                                       ; Loop on the number of input date
    CALDAT, tdate[K], month, day, year, hour, minute, second ; Split the kieme date on month,day,...
    cnt = 0
    FOR I=0L,Nk-1 DO BEGIN                                     ; Loop on the number of Kernel element
        tab[I]=JULDAY(month,day,year,hour+I-Nk2,minute,second) ; Create an Nk array around the given kieme date  
        id1[I]=WHERE(ABS(st.jul-tab[I]) LT deltat,cnt1)        ; Look if there is finite values in st for those date
        cnt=cnt+cnt1
    ENDFOR
    IF (cnt EQ Nk) THEN BEGIN 
        IF (method EQ 'median') THEN BEGIN
            val[K]=MEDIAN(st[id1].val*kernel) ; Compute the median of the hourlay Nk value 
        ENDIF ELSE BEGIN 
            val[K]=TOTAL(st[id1].val*kernel)/scale_factor ; Compute the daily mean if Nk value are available
        IF KEYWORD_SET(verbose) THEN print,'Method=',method,'  Nk=',STRCOMPRESS(STRING(Nk),/REMOVE_ALL),$
' Sf=',STRCOMPRESS(STRING(scale_factor,FORMAT='(F9.3)'),/REMOVE_ALL),'   [',STRCOMPRESS(STRING(cnt),/REMOVE_ALL),'/',STRCOMPRESS(STRING(Nk),/REMOVE_ALL),']','==> ',print_date(tdate[K]),' mean = ',STRCOMPRESS(STRING(val[K],FORMAT='(F9.3)'),/REMOVE_ALL)
            
        ENDELSE
    ENDIF 
;
;    IF KEYWORD_SET(verbose) THEN print,'Method=',method,'  Nk=',STRCOMPRESS(STRING(Nk),/REMOVE_ALL),$
;' Sf=',STRCOMPRESS(STRING(scale_factor,FORMAT='(F9.3)'),/REMOVE_ALL),'   [',STRCOMPRESS(STRING(cnt),/REMOVE_ALL),'/',STRCOMPRESS(STRING(Nk),/REMOVE_ALL),']','==> ',print_date(tdate[K]),' mean = ',STRCOMPRESS(STRING(val[K],FORMAT='(F9.3)'),/REMOVE_ALL)
ENDFOR

stf = CREATE_JULVAL(Nd)
stf.jul = tdate 
stf.val = val

RETURN,stf
END

