FUNCTION wave2code_scalar, wavename
; fonction qui renvoie le code associe au nom d'une onde
code=999 ;par defaut
IF (wavename EQ 'Psi1' OR wavename EQ 'PSi1' OR wavename EQ 'PSI1')     THEN code=0
IF (wavename EQ 'O1')     THEN code=1
IF (wavename EQ 'P1')     THEN code=2
IF (wavename EQ 'K1')     THEN code=3
IF (wavename EQ 'E2')     THEN code=4
IF (wavename EQ '2N2')    THEN code=5
IF (wavename EQ 'Mu2' OR wavename EQ 'MU2') THEN code=6
IF (wavename EQ 'N2')     THEN code=7
IF (wavename EQ 'Nu2' OR wavename EQ 'NU2') THEN code=8
IF (wavename EQ 'M2')     THEN code=9
IF (wavename EQ 'La2' OR wavename EQ 'LA2') THEN code=10
IF (wavename EQ 'L2')     THEN code=11
IF (wavename EQ 'T2')     THEN code=12
IF (wavename EQ 'S2')     THEN code=13
IF (wavename EQ 'K2')     THEN code=14
IF (wavename EQ 'MSN2')   THEN code=15
IF (wavename EQ '2SM2')   THEN code=16
IF (wavename EQ 'MN4')    THEN code=17
IF (wavename EQ 'M4')     THEN code=18
IF (wavename EQ 'MS4')    THEN code=19
IF (wavename EQ 'MK4')    THEN code=20
IF (wavename EQ '2MN6')   THEN code=21
IF (wavename EQ 'M6')     THEN code=22
IF (wavename EQ 'MSN6')   THEN code=23
IF (wavename EQ 'MK3')    THEN code=24
IF (wavename EQ '2MK3')   THEN code=25
IF (wavename EQ 'S1')     THEN code=26
IF (wavename EQ 'Q1')     THEN code=27
IF (wavename EQ 'OO1')    THEN code=28
IF (wavename EQ 'J1')     THEN code=29
IF (wavename EQ 'MKS2')   THEN code=30
IF (wavename EQ 'MSK2')   THEN code=31
IF (wavename EQ 'OP2')    THEN code=32
IF (wavename EQ 'N4')     THEN code=33
IF (wavename EQ 'M3')     THEN code=34
IF (wavename EQ 'S3')     THEN code=35
IF (wavename EQ 'M(KS)2') THEN code=36
IF (wavename EQ 'M(SK)2') THEN code=37
IF (wavename EQ 'Mm'   OR wavename EQ 'MM')  THEN code=38
IF (wavename EQ 'MSf'  OR wavename EQ 'MSF') THEN code=39
IF (wavename EQ 'Mf'   OR wavename EQ 'MF')  THEN code=40
IF (wavename EQ 'MSm'  OR wavename EQ 'MSM') THEN code=41
IF (wavename EQ 'Mtm'  OR wavename EQ 'MTM') THEN code=42
IF (wavename EQ 'Mqm'  OR wavename EQ 'MQM') THEN code=43
IF (wavename EQ 'MStm' OR wavename EQ 'MSTM' OR wavename EQ 'Mstm') THEN code=44
IF (wavename EQ 'MSqm' OR wavename EQ 'MSQM' OR wavename EQ 'Msqm') THEN code=45
IF (wavename EQ 'Ssa'  OR wavename EQ 'SSA') THEN code=46
IF (wavename EQ 'Sa'   OR wavename EQ 'SA')  THEN code=47
IF (wavename EQ 'SO1')    THEN code=48
IF (wavename EQ 'MP1')    THEN code=49
IF (wavename EQ 'R2')     THEN code=50
IF (wavename EQ 'OQ2')    THEN code=51
IF (wavename EQ 'MSN2')   THEN code=52
IF (wavename EQ 'SO3')    THEN code=53
IF (wavename EQ 'SK3')    THEN code=54
IF (wavename EQ 'SN4')    THEN code=55
IF (wavename EQ 'S4')     THEN code=56
IF (wavename EQ '2MKS4')  THEN code=57
IF (wavename EQ '3MS4')   THEN code=58
IF (wavename EQ '2MS6')   THEN code=59
IF (wavename EQ '2MK6')   THEN code=60
IF (wavename EQ '3MS8')   THEN code=61
IF (wavename EQ '2MS2')   THEN code=62
IF (wavename EQ '2MN2')   THEN code=63
IF (wavename EQ 'SNM2')   THEN code=64
IF (wavename EQ '2MK2')   THEN code=65
IF (wavename EQ '3MSN2')  THEN code=66
IF (wavename EQ '2Q1')    THEN code=67
IF (wavename EQ 'Sig1' OR wavename EQ 'SIG1') THEN code=68; *wave_name="Sig1"; }
IF (wavename EQ 'Ro1'  OR wavename EQ 'RO1' OR wavename EQ 'Rho1' OR wavename EQ 'RHO1')    THEN code=69
IF (wavename EQ 'Ki1'  OR wavename EQ 'SIG1') THEN code=70
IF (wavename EQ 'Pi1'  OR wavename EQ 'PI1') THEN code=71
IF (wavename EQ 'Phi1' OR wavename EQ 'PHI1') THEN code=72
IF (wavename EQ 'Tta1' OR wavename EQ 'TTA1' OR wavename EQ 'Teta1' OR wavename EQ 'TETA1') THEN code=73
IF (wavename EQ 'M1')     THEN code=74
IF (wavename EQ 'M12')    THEN code=75
IF (wavename EQ 'KQ1')    THEN code=76
IF (wavename EQ 'KJ2')    THEN code=77
IF (wavename EQ 'MNS2'  OR wavename EQ 'MNs2' OR wavename EQ 'Mns2' OR wavename EQ 'MnS2')    THEN code=101
IF (wavename EQ 'MO3'  OR wavename EQ 'Mo3')  THEN code=102
IF (wavename EQ 'SK4'  OR wavename EQ 'Sk4')  THEN code=103
IF (wavename EQ '2SM6'  OR wavename EQ '2Ms6' OR wavename EQ '2ms6')    THEN code=104
IF (wavename EQ 'MSK6'  OR wavename EQ 'MSk6')  THEN code=105
IF (wavename EQ 'F6'   OR wavename EQ 'f6')  THEN code=999
RETURN,code
END

FUNCTION wave2code, wavename
; function qui renvoie le code pour une ou plusieurs ondes

nwave=N_ELEMENTS(wavename)

IF (nwave EQ 1) THEN BEGIN
 code  = wave2code_scalar(wavename)
 RETURN,code
ENDIF ELSE BEGIN
  code =  INTARR(nwave)
  FOR i=0,nwave-1 DO BEGIN
  code[i] = wave2code_scalar(wavename[i])
  ENDFOR
  RETURN,code
ENDELSE
END