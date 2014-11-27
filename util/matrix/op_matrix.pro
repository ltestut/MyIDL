FUNCTION op_matrix, Z, op=op, treshold=treshold, less=less, mul=mul, $
                       fct=fct, time=time, m2=m2, $
                       serie=serie,lag=lag
                       
; perform operations on a 3D matrix
; mul=2.0       : multiply matrix elements by mul
; fct=a(i)      : multiply matrix elements by funtion ????
; op='min'      : compute the minimum values of the matrix
; op='max'      : compute the maximum values of the matrix
; op='range'    : compute the range=max-min values of the matrix
; op='rms'      : compute the standard deviation values of the matrix
; op='trend',time=geo.jul            : compute the trend values of the matrix
;                                      must provide the time vector
; op='trend',time=geo.jul,/DETRENDED : compute the trend values of the matrix
;                                      and output the detrended
; op='count',treshold=2.3            : compute the number of value GE treshold
; op='count',treshold=2.3,/LESS      : compute the number of value LT treshold
; op='correlate',serie=serie, lag=1  : compute the cross-correlation 
;                                      must provide the serie and the lag


s      = SIZE(z)      
Z_out  = Z
cfield = FLTARR(s[1],s[2])

IF KEYWORD_SET(mul) THEN BEGIN
  FOR I=0,s[3]-1 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] =$
                                             Z[INDGEN(s[1]),INDGEN(s[2]),I]*mul
  RETURN,Z_out
ENDIF ELSE IF KEYWORD_SET(fct) THEN BEGIN
  IF (s[3] NE N_ELEMENTS(fct)) THEN STOP,"Warning : fct has not the good size"
  FOR I=0,s[3]-1 DO Z_out[INDGEN(s[1]),INDGEN(s[2]),I] =$
                                          Z[INDGEN(s[1]),INDGEN(s[2]),I]*fct[I]
  RETURN,Z_out
ENDIF ELSE BEGIN
FOR I=0,s[1]-1 DO BEGIN
  FOR J=0,s[2]-1 DO BEGIN
    ID = WHERE(FINITE(Z[I,J,*]),count)
    IF (count GT 2) THEN BEGIN
      CASE (op) OF
       'rms'  : cfield[I,J] = STDDEV(Z[I,J,*],/NAN)
       'min'  : cfield[I,J] = MIN(Z[I,J,*],/NAN)
       'max'  : cfield[I,J] = MAX(Z[I,J,*],/NAN)
       'range': cfield[I,J] = MAX(Z[I,J,*],/NAN)-MIN(Z[I,J,*],/NAN)
       'mean' : cfield[I,J] = MEAN(Z[I,J,*],/NAN)
       'count': BEGIN
                 icount = WHERE(Z[I,J,*] GE treshold, csup,NCOMPLEMENT=cinf)
                 IF KEYWORD_SET(less) THEN cfield[I,J]=cinf $
                                                         ELSE cfield[I,J]=csup
                END
       'trend': BEGIN
                 r_coef = LINFIT(time[ID],Z[I,J,ID],SIGMA=err) 
                 IF KEYWORD_SET(detrended) THEN cfield[I,J,ID] = $
                                      z[I,J,ID]-(r_coef[0]+r_coef[1]*time[ID])$
                                           ELSE cfield[I,J] = r_coef[1]*365.  
                 END
       'fit'  : BEGIN
                 fit_cycle     = SVDFIT(time[ID],REFORM(Z[I,J,ID]),3,$
                         CHISQ=chi,FUNCTION_NAME='annual_cycle',SINGULAR=sing)
                 cfield[I,J]   = SQRT(TOTAL(fit_cycle[0:1]*fit_cycle[0:1]))
                   ;dephase calcule par rapport à l'origine des dates
                 phi           = ATAN(fit_cycle[1],fit_cycle[0])  
                  ;phase à l'origine - dephasage = phase depuis le debut de la serie
                 m2[I,J]       = deg((2*!PI*(time[ID[0]]/365.) MOD (2 * !PI))-phi)
;                   dpi   = 2*!PI
;                   freq  = 1./365.
;                   st    = create_julval(count)
;                   stfit = create_julval(count)
;                   st.jul    = time[ID]
;                   stfit.jul = time[ID]
;                   st.val    = REFORM(Z[I,J,ID])
;                   stfit.val = fit_cycle[0]*COS(dpi*freq*stfit.jul)+fit_cycle[1]*SIN(dpi*freq*stfit.jul)+fit_cycle[2]
                  END
  'correlate' : BEGIN
                IF NOT KEYWORD_SET(lag) THEN lag=0
                cfield[I,J]=C_CORRELATE(REFORM(Z[I,J,ID]),serie[ID],lag)
                END
      ENDCASE
    ENDIF ELSE BEGIN
      cfield[I,J]          = !VALUES.F_NAN
      IF (op EQ 'fit') THEN m2[I,J] = !VALUES.F_NAN 
    ENDELSE
  ENDFOR
ENDFOR

RETURN,cfield
ENDELSE
END
