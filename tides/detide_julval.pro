; $Id: detide_julval.pro,v 1.00 21/01/2010 L. Testut $
;

;+
; NAME:
; DETIDE_JULVAL
;
; PURPOSE:
; detide of a {jul,val} time serie with different tide killer filter
; 
; CATEGORY:
; Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
; std=detide_julval(st)
;
;       use the fct/proc : -> DECIMATE_HOURLY
;                          -> DECIMATE_JULVAL
; INPUTS:
; st     : Structure of type {jul,val}
;
; OUTPUTS:
; std   : Structure of type {jul,val} filtred
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
; /!\ BE CAREFUL IF YOU HAVE DATA WITH SAMPLING > 1*Hr
;
; MODIFICATION HISTORY:
;-
;

FUNCTION detide_julval, st_in, method=method, hf=hf, daily=daily, quiet=quiet
IF (N_PARAMS() EQ 0) THEN STOP, "st=detide_julval(st)"
IF (N_ELEMENTS(method) EQ 0)THEN method='nmj'
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
scale_factor= TOTAL(kernel)      ; Sum of the window filter for scaling


; on decime d'abord les donnes pour avoir des donnees horaires
st  = decimate_hourly(st_in)

IF NOT KEYWORD_SET(QUIET) THEN BEGIN
 PRINT,"DETIDE_JULVAL : Use of method    :",method
 PRINT,"DETIDE_JULVAL : Initial sampling :",sampling_julval(st_in)/3600., ' H'
 PRINT,"DETIDE_JULVAL : Working sampling :",sampling_julval(st)/3600., ' H'
 PRINT,"/!\ BE CAREFUL IF YOU HAVE DATA WITH SAMPLING > 1*Hr"
ENDIF

; on convolu la structure avec le noyau du filtre
filtred = CONVOL(st.val, kernel, scale_factor,/NAN)
Nd      = N_ELEMENTS(filtred)
Nk      = N_ELEMENTS(kernel)

; on flag les valeurs nulles.
filtred[0:Nk-1]     = 0. ;on flag les bord
filtred[Nd-Nk:Nd-1] = 0.
izero          = WHERE(filtred EQ 0.)
filtred[izero] = !VALUES.F_NAN
ifinite        = WHERE(FINITE(filtred))

;; replication de la structure
stf=st
stf.val = filtred ;par defaut on renvoie les donnees filtree 

IF KEYWORD_SET(HF) THEN BEGIN
   val_hf           = st[ifinite].val-filtred[ifinite]
   stf[izero].val   = !VALUES.F_NAN
   stf[ifinite].val = val_hf
ENDIF ELSE IF KEYWORD_SET(daily) THEN BEGIN
   stf.val = filtred
   stf = decimate_julval(stf,/DAILY)
ENDIF
RETURN, stf
END
