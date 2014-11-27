; $Id: rad.pro,v 1.00 20/12/2005 L. Testuts $
;

;+
; NAME:
;	RAD
;
; PURPOSE:
;	Transform degre to radian
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	r=RAD(d)
;
;
; INPUTS:
;	d   : degree
;
; OUTPUTS:
;	r value of d in radians
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
;
;-

FUNCTION  rad, d

r=DOUBLE((2*!pi*d)/360.)

RETURN, r
END
