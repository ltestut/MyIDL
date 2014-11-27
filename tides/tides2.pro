PRO tides2,x,A,yfit,pder
  ; F(x)= Af*cos(2pif.X)+Bf*sin(2pif.X)
  ; A[0]=Af
  ; A[1]=Bf
  
  n_var = N_ELEMENTS(A)/2
  m     = N_ELEMENTS(x)
  yfit  = fltarr(m)
  
  print,'nombre de frequence prise en compte',n_var
  print,'nombre de points pris en compte    ',m
  help,x,yfit
  
  dpi=2*!PI
  
  onde8=[8765.8128,4382.9064]
  ;onde8=[SA,SSA]
  
  
  
  freq=onde8/24.   ;periodes a prendre en compte pour la reconstruction du signal
  fmar=1/freq   ;frequences associ�es
  
  
  ; construction de la fonction F(x)= somme/freq [Af*cos(2pif.X)+Bf*sin(2pif.X)]
  FOR I=0,n_var-1 DO BEGIN
    yfit = yfit + A[2*I]*cos(dpi*fmar[I]*x)+A[2*I+1]*sin(dpi*fmar[I]*x)
  END
  
  
  ; calcul des derivees par rapport aux coefficients Ai te Bi
  IF N_PARAMS() GE 4 THEN $
    pder  = fltarr(m,n_var)
  pder  =[[cos(dpi*fmar[0]*x)],[sin(dpi*fmar[0]*x)]]
  
  FOR I=1,n_var-1 DO BEGIN
    pder=[[pder],[cos(dpi*fmar[I]*x)],[sin(dpi*fmar[I]*x)]]
  END
END
