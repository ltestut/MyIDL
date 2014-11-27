function SIGN, num
;+
;NAME:
;       SIGN
;
;PURPOSE:
;       To compute the sign of a number. This function mimics
;       Matlab's sign function.
;
;CALLING SEQUENCE:
;       Result = SIGN(num)
;
;INPUTS:
;       Num:    Any number or array
;
;OUTPUTS:
;       SIGN returns either 1, 0, or -1.
;              
;MODIFICATION HISTORY:
;       Amara Graps, BAER, December 1994.
;       (c) copyright Amara Graps 1995, 1996.
;-

t = SIZE(num)
testtype = t(0)

IF testtype NE 0 THEN BEGIN
        ;The value num is an array.. Find the sign of ALL of the elements
        ;create same size and kind of array
        n_ele = N_ELEMENTS(t)
        CASE t(n_ele-2) OF
                2: sgn = num * 0        ;integer
                3: sgn = num * 0L       ;long integer
                4: sgn = num * 0.0      ;floating
                5: sgn = num * 0.0D0    ;double floating
                ELSE: print, 'Not a good array type in sign!'
        ENDCASE
        copy_num= num

        ;neg values
        indx = WHERE(copy_num LT 0)    
        ;check for bad index
        ts = SIZE(indx)
        CASE 1 OF
                ts(0) EQ 0: ;no change
                ELSE: sgn(indx) = -1
        ENDCASE

        ;positive values
        indx = WHERE(copy_num GT 0)    
        ;check for bad index
        ts = SIZE(indx)
        CASE 1 OF
                ts(0) EQ 0: ;no change
                ELSE: sgn(indx) = +1
        ENDCASE

        ;zero values
        indx = WHERE(copy_num EQ 0)    
        ;check for bad index
        ts = SIZE(indx)
        CASE 1 OF
                ts(0) EQ 0: ;no change
                ELSE: sgn(indx) = 0
        ENDCASE

ENDIF ELSE BEGIN

        ;t(0) = 0, scalar.. what we want

        IF t(1) NE 6L then begin
                ;Not a complex scalar

                CASE 1 OF
                        num LT 0: sgn = -1
                        num EQ 0: sgn = 0          
                        num GT 0: sgn = 1
                        ELSE: print, 'Not a valid number!'
                ENDCASE
        ENDIF ELSE BEGIN
                ;This is a complex scalar
                sgn = num / abs(num)
        END     ;END
END

RETURN, sgn

END 