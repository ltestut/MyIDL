; $Id: read_sum.pro,v 1.00 25/05/2005 L. Testut $
;

;+
; NAME:
;	READ_SUM
;
; PURPOSE:
;	Read the .sum AH data file
;       see. the USE_TEMPLATE function to define the appropraite template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_SUM(filename,/res)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/test.lst' 
;       res=         : keyword to output the residual of the ah 
;
; OUTPUTS:
;	Structure of type {jul,val} (by default the prediction)
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
;
FUNCTION read_sum, filename, res=res

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_SUM(filename,res=res)'
; Define the template to be used
templ = USE_TEMPLATE('sum') ;ou phy1

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)


print,'USE_TEMPLATE :  sum'
print,'READ_ASCII   : ',filename

N    = N_ELEMENTS(data.jul) 
st   = create_julval(N)
st.jul = data.jul+JULDAY(1,1,1950,0,0,0)


IF (KEYWORD_SET(res) EQ 0) THEN BEGIN 
    st.val = data.col2 ;- data.res 
    RETURN, st
ENDIF ELSE BEGIN
    st.val = data.res
    RETURN, st
ENDELSE
END
 
