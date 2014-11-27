FUNCTION cumul_matrix, Z1, Z2
;Z1=Z1+Z2
s1      = SIZE(Z1)
s2      = SIZE(Z2)
IF ((s1[1] NE s2[1]) OR (s1[2] NE s2[2]) OR (s1[3] NE s2[3])) THEN $
    STOP,"Warning : Z1 and Z2 not the same size" 
FOR K=0,s1[3]-1 DO Z1[INDGEN(s1[1]),INDGEN(s1[2]),K] = $
         Z1[INDGEN(s1[1]),INDGEN(s1[2]),K] + Z2[INDGEN(s2[1]),INDGEN(s2[2]),K]
RETURN,Z1
END
