; $Id: ncdf_info.pro,v 1.00 14/10/2005 L. Testut $
;

;+
; NAME:
;	NCDF_INFO
;
; PURPOSE:
;	Print info on a NetCDF file and return its Id number
;
; CATEGORY:
;	Function
;
; CALLING SEQUENCE:
;	id=NCDF_INFO(filename,inf='')
;
;       use the fct/proc IDL NCDF_*
;
; INPUTS:
;	filename      : string of the filename ex:'/home/testut/test.julval'
;       inf           -> 'glob' print only the global attributs
;                     -> 'dim'  print only the dimensions
;                     -> 'var'  print only the variables and its attributs
;                     -> default is to plot all
; OUTPUTS:
;	Id of the open file
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

FUNCTION ncdf_info, filename, inf=inf

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=NCDF_INFO(filename,/inf)'

id=NCDF_OPEN(filename)
info=NCDF_INQUIRE(id) 
PRINT,'Ndim:',STRCOMPRESS(STRING(info.Ndims),/REMOVE_ALL),$
    '  Nvar:',STRCOMPRESS(STRING(info.Nvars),/REMOVE_ALL),$
    '  Nattglob:',STRCOMPRESS(STRING(info.Ngatts),/REMOVE_ALL),$
    '  Id_dim_ill:',STRCOMPRESS(STRING(info.RecDim),/REMOVE_ALL)
PRINT,''

IF (KEYWORD_SET(inf)) THEN BEGIN
    CASE 1 OF
        (inf EQ 'glob'): BEGIN
            print,'ATTRIBUTS GLOBAUX'
            print,'-----------------'
            FOR K=0,info.Ngatts-1 DO BEGIN
                attg_st=NCDF_ATTINQ(id,/GLOBAL,NCDF_ATTNAME(id,/GLOBAL,K)) ;=> renvoie les info sur les att {DATATYPE:'' LENGTH:OL} dans la structure attg_st
                NCDF_ATTGET,id,/GLOBAL,NCDF_ATTNAME(id,/GLOBAL,K),val ;=> recupere la valeur de l'attribut dans val
                print,'-> ',NCDF_ATTNAME(id,/GLOBAL,K),': ',STRING(val)
            ENDFOR
            print,''
        END

        (inf EQ 'dim'): BEGIN
            print,'DIMENSIONS'
            print,'----------'
            illimited=''
            FOR I=0,info.Ndims-1 DO BEGIN
                IF (I EQ info.RecDim) THEN illimited=' !! Dimension illimitee !!'
                NCDF_DIMINQ,id,I,name,size
                print,'Info dimension:',STRCOMPRESS(STRING(I),/REMOVE_ALL),' => ',STRCOMPRESS(STRING(name),/REMOVE_ALL),':',size,illimited
            ENDFOR
            print,''
        END

        (inf EQ 'var'): BEGIN
            print,'VARIABLES ET ATTRIBUTS'
            print,'----------------------'
            FOR I=0,info.Nvars-1 DO BEGIN
                var_st=NCDF_VARINQ(id,I)
                print,'Info variable: ',STRCOMPRESS(STRING(I),/REMOVE_ALL),' => ',STRCOMPRESS(STRING(var_st.Name),/REMOVE_ALL),' : ',STRCOMPRESS(STRING(var_st.DataType)),$
                       ' : [Ndim=',STRCOMPRESS(STRING(var_st.Ndims),/REMOVE_ALL),']',' : [Natt=',STRCOMPRESS(STRING(var_st.Ndims),/REMOVE_ALL),']'
                IF (var_st.Natts GT 0) THEN BEGIN
                    FOR J=0,var_st.Natts-1 DO BEGIN
                        att_st=NCDF_ATTINQ(id,I,NCDF_ATTNAME(id,I,J))
                        NCDF_ATTGET,id,I,NCDF_ATTNAME(id,I,J),val
                        print,'                                                         |==>',NCDF_ATTNAME(id,I,J),': ',STRING(val)
                    ENDFOR
                    print,''
                ENDIF
            ENDFOR
        END
    ENDCASE
ENDIF ELSE BEGIN
    print,'ATTRIBUTS GLOBAUX'
    print,'-----------------'
    FOR K=0,info.Ngatts-1 DO BEGIN
        attg_st=NCDF_ATTINQ(id,/GLOBAL,NCDF_ATTNAME(id,/GLOBAL,K)) ;=> renvoie les info sur les att {DATATYPE:'' LENGTH:OL} dans la structure attg_st
        NCDF_ATTGET,id,/GLOBAL,NCDF_ATTNAME(id,/GLOBAL,K),val ;=> recupere la valeur de l'attribut dans val
        print,'-> ',NCDF_ATTNAME(id,/GLOBAL,K),': ',STRING(val)
    ENDFOR
    print,''
    print,'DIMENSIONS'
    print,'----------'
    illimited=''
    FOR I=0,info.Ndims-1 DO BEGIN
        IF (I EQ info.RecDim) THEN illimited=' !! Dimension illimitee !!'
        NCDF_DIMINQ,id,I,name,size
        print,'Info dimension:',STRCOMPRESS(STRING(I),/REMOVE_ALL),' => ',STRCOMPRESS(STRING(name),/REMOVE_ALL),':',size,illimited
    ENDFOR
    print,''
    print,'VARIABLES ET ATTRIBUTS'
    print,'----------------------'
    FOR I=0,info.Nvars-1 DO BEGIN
        var_st=NCDF_VARINQ(id,I)
        print,'Info variable: ',STRCOMPRESS(STRING(I),/REMOVE_ALL),' => ',STRCOMPRESS(STRING(var_st.Name),/REMOVE_ALL),' : ',STRCOMPRESS(STRING(var_st.DataType)),' : [Ndim=',STRCOMPRESS(STRING(var_st.Ndims),/REMOVE_ALL),']',$
        ' : [Natt=',STRCOMPRESS(STRING(var_st.Natts),/REMOVE_ALL)
        IF (var_st.Natts GT 0) THEN BEGIN
            FOR J=0,var_st.Natts-1 DO BEGIN
                att_st=NCDF_ATTINQ(id,I,NCDF_ATTNAME(id,I,J))
                NCDF_ATTGET,id,I,NCDF_ATTNAME(id,I,J),val
                print,'                                                         |==>',NCDF_ATTNAME(id,I,J),': ',STRING(val)
            ENDFOR
            print,''
        ENDIF
    ENDFOR
ENDELSE
NCDF_CLOSE,id
RETURN, id
END
