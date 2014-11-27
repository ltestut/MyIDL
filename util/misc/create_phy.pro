; $Id: create_phy.pro,v 1.00 20/05/2005 L. Testut $
;

;+
; NAME:
;	CREATE_PHY
;
; PURPOSE:
;	Create a structure of type {jul:0.0D, twat:0.0, bot:0.0,
;	baro:0.0, mto:0.0 }
;	
; CATEGORY:
;	utile procedure/fucntion
;
; CALLING SEQUENCE:
;	st=CREATE_PHY(N)
;
;       use the fct/proc : -> REPLICATE
;
; INPUTS:
;	N   : Number of replication of the structure definition
;
; OUTPUTS:
;	Structure of type {jul,twat,bot,baro,mto}
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

FUNCTION  create_phy, N

IF (N LT 1) THEN STOP, '!! ERROR in CREATE_PHY : N must be greater than 0'

tmp = {jul:0.0D, twat:0.0, bot:0.0, baro:0.0, mto:0.0}
st  = replicate(tmp,N)

RETURN, st
END
