FUNCTION use_zone, zone=zone, _EXTRA=_EXTRA
; renvoie les limites geographique a partir d'un mot cle 

IF (zone EQ 'misc')    THEN zonel=[0,10,0,5.]
IF (zone EQ 'europe')  THEN zonel=[-10,20,30,60.]
IF (zone EQ 'france')  THEN zonel=[-6,5,44,51.]
IF (zone EQ 'manche')  THEN zonel=[-6,1,48,51.]
IF (zone EQ 'brest')   THEN zonel=[-6,-2,48,50]
IF (zone EQ 'roscoff') THEN zonel=[-4.8,-3.2,48.2,49.]
IF (zone EQ 'spa')     THEN zonel=[76.,78.,-39,-37]
IF (zone EQ 'arabian') THEN zonel=[20.,90.,0,30]

IF (zone EQ 'mertz' )  THEN zonel=[138.5,150,-69,-63.5]

limit=[zonel[2],zonel[0],zonel[3],zonel[1]]
RETURN, limit
END