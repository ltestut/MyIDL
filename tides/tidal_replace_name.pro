FUNCTION tidal_replace_name, wave

CASE (wave) OF
  'SIGMA1'   : wave='SIG1'  
  'RHO1'     : wave='RO1'  
  'THETA1'   : wave='TTA1'  
  '2N2 2NM2' : wave='2MN2S2'
  'LAMBDA2'  : wave='LA2'
  'MU2 2MS2' : wave='MNUS2'
  'OP2 MSK2' : wave='OP2'
  'L2 2MN2'  : wave='L2'
  'KJ2 MKN2' : wave='KJ2'
  'KHI1'     : wave='KI1'
  'OQ2 MNK2' : wave='OQ2'
  '2NMS4'    : wave='2MNS4'
  'M8'       : wave='Z0'
  'A87'      : wave='Z0'
  '3MN4ML4'  : wave='Z0'
  '2MMUS4'   : wave='Z0'
  '2MNUS4'   : wave='Z0'
  'MNU4'     : wave='Z0'
  'MSK4'     : wave='Z0'
  '2MSK4'    : wave='Z0'
  '2MKS4'    : wave='Z0'
  '2SMK4'    : wave='Z0'
  'MT4'      : wave='Z0'
  '2SNM4'    : wave='Z0'
  '3MNS6'    : wave='Z0'
  '3MNUS6'   : wave='Z0'
  '2NM6'     : wave='Z0'
  '2MNU6'    : wave='Z0'
  '3MSK6'    : wave='Z0'
  '4MN.2ML6' : wave='Z0'
  '2MT6'     : wave='Z0'
  '3MSN6'    : wave='Z0'
  '2MSN8'    : wave='Z0'
  '2MS6'     : wave='Z0'
  'F6'       : wave='Z0'
  ELSE : wave=wave          
ENDCASE

RETURN,wave
END

