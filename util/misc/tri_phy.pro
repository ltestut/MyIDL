; $Id: tri_phy.pro,v 1.00 21/05/2005 L. Testut $
;

;+
; NAME:
;	TRI_PHY
;
; PURPOSE:
;	Sort a structure of type {jul,twat,bot,baro,mto} 
;	
; CATEGORY:
;	Util procedure/fucntion
;
; CALLING SEQUENCE:
;	st=TRI_PHY(struct)
;	
;       use the fct/proc : -> SORT
;
; INPUTS:
;	Struct     : structure of type phy {jul,twat,bot,baro,mto}
;
;
; OUTPUTS:
;	Structure of type phy 
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

FUNCTION tri_phy, st

ITS     = SORT(st.jul)
st.jul  = st[ITS].jul
st.twat = st[ITS].twat
st.bot  = st[ITS].bot
st.baro = st[ITS].baro
st.mto  = st[ITS].mto

RETURN, st
END
