; $Id: create_julval.pro,v 1.00 21/12/2004 L. Testut $
;

;+
; NAME:
;	CREATE_JULVAL
;
; PURPOSE:
;	Create a structure of type {jul:0.0D, val:0.0}
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=CREATE_JULVAL(N)
;
;       use the fct/proc : -> REPLICATE
;
; INPUTS:
;	N   : Number of replication of the structure definition
;
; OUTPUTS:
;	Structure of type {jul,val}
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
; Le 06/01/05 STOP when N<1
; Le 12/01/08 Add the /NAN keyword to initialize structure with NAN
; Le 03/07/09 Add the /RMS keyword to replace the CREATE_RMS_JULVAL
; Le 30/11/11 when N=0 create a NaN 1 element st
;-

FUNCTION  create_julval, N, nan=nan, rms=rms

IF (N LT 1) THEN BEGIN
 PRINT, '/!\ CREATE_JULVAL : N = ',N
 PRINT, '/!\ CREATE_JULVAL : create a 1 element NaN st'
 st =create_julval(1,/NAN)
ENDIF ELSE BEGIN
 tmp = {jul:0.0D, val:0.0}
 IF KEYWORD_SET(rms) THEN tmp = {jul:0.0D, val:0.0, rms:0.0}
  IF KEYWORD_SET(nan) THEN BEGIN
   tmp = {jul:0.0D, val:!VALUES.F_NAN} 
   IF KEYWORD_SET(rms) THEN tmp = {jul:0.0D, val:!VALUES.F_NAN, rms:0.0} 
  ENDIF 
 st  = replicate(tmp,N)
ENDELSE

RETURN, st
END
