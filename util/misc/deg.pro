; $Id: deg.pro,v 1.00 09/03/2010 C. Mayet $
;

;+
; NAME:
; DEG
;
; PURPOSE:
; Transform radian to degree
; 
; CATEGORY:
; utile procedure/fucntion
;
; CALLING SEQUENCE:
; d=DEG(r)
;
;
; INPUTS:
; r   : radian
;
; OUTPUTS:
; d value of r in degrees
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
;
;-


FUNCTION deg, r

d=DOUBLE(r*360/(2*!pi))
return, d

END