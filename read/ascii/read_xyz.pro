; $Id: read_xyz.pro,v 1.00 12/01/2005 L. Testut $
;

;+
; NAME:
;	READ_XYZ
;
; PURPOSE:
;	Read an xyz ascii data file
;       see. the USE_TEMPLATE function to define the appropriate template
;	
; CATEGORY:
;	Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;	st=READ_XYZ(filename)
;	
;       use the fct/proc : -> USE_TEMPLATE
;                          -> READ_ASCII
;                          -> CREATE_TEMPLATE
; INPUTS:
;	filename      : string of the filename ex:'/local/home/ocean/testut/data.xyz' 
;
; OUTPUTS:
;	Structure of type {x,y,z}
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
FUNCTION  read_xyz, filename

IF (N_PARAMS() EQ 0)       THEN STOP, 'UTILISATION:  st=READ_XYZ(filename)'

; Define the template to be used
templ = USE_TEMPLATE('xyz')

; Read the data corresponding to the defined template
data  = READ_ASCII(filename,TEMPLATE=templ)

print,'READ_ASCII   : ',filename

RETURN, data
END
 
