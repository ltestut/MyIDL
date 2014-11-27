; $Id: create_info.pro,v 1.00 28/05/2005 L. Testut $
;

;+
; NAME:
; CREATE_INFO
;

; PURPOSE:
; Create a structure of type {str:0.0D, val:0.0}
; 
; CATEGORY:
; utile procedure/fucntion
;
; CALLING SEQUENCE:
; st=CREATE_JULVAL(N)
;
;       use the fct/proc : -> REPLICATE
;
; INPUTS:
; N   : Number of replication of the structure definition
;
; OUTPUTS:
; Structure of type {jul,val}
;
; COMMON BLOCKS:
; None.
;
; SIDE EFFECTS:
; None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
; Le 06/01/05 STOP when N<1
; Le 2009 modifier par N.P

;-

FUNCTION  create_info, N, bil_unit=bil_unit

IF NOT KEYWORD_SET(bil_unit) THEN BEGIN
   IF (N_PARAMS() EQ 0) THEN STOP, 'info=create_info(N)'
   info = {str:STRARR(4), ind:LON64ARR(N)}  
ENDIF ELSE BEGIN
   IF (N_PARAMS() EQ 0) THEN STOP, 'info=create_info(N)'
   info = {str:STRARR(10), ind:LON64ARR(N)}  
ENDELSE


RETURN, info
END

;
;
;
;; $Id: create_info.pro,v 1.00 28/05/2005 L. Testut $
;;
;
;;+
;; NAME:
;;  CREATE_INFO
;;
;
;; PURPOSE:
;;  Create a structure of type {str:0.0D, val:0.0}
;;  
;; CATEGORY:
;;  utile procedure/fucntion
;;
;; CALLING SEQUENCE:
;;  st=CREATE_JULVAL(N)
;;
;;       use the fct/proc : -> REPLICATE
;;
;; INPUTS:
;;  N   : Number of replication of the structure definition
;;
;; OUTPUTS:
;;  Structure of type {jul,val}
;;
;; COMMON BLOCKS:
;;  None.
;;
;; SIDE EFFECTS:
;;  None.
;;
;; RESTRICTIONS:
;;
;;
;; MODIFICATION HISTORY:
;; Le 06/01/05 STOP when N<1
;;-
;
;FUNCTION  create_info, N
;
;IF (N_PARAMS() EQ 0) THEN STOP, 'info=create_info(N)'
;
;info = {str:STRARR(4), ind:LON64ARR(N)}
;
;RETURN, info
;END
