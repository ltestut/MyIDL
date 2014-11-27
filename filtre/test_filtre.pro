; Construction de la base de temps
t0 = JULDAY(1,1,2002)
t  = TIMEGEN(start=t0,final=JULDAY(1,1,2003),$
           unit='hours', step_size=1)

; Construction d'un signal
As = [1.,0.5,0.7,0.6]
TS = [60.,47.,38.,55.] & Ws=(2*!PI)/Ts
PS = [0.,30.,13.,37.] & Ps=(!PI/180.)*Ps
sig= FLTARR(N_ELEMENTS(t))
FOR i=0,N_ELEMENTS(As)-1 DO sig=sig+As[i]*sin(Ws[i]*(t-t0)+Ps[i])

; Construction d'un bruit
At    = [1.1,1.5,0.8,0.6,0.9,0.4,0.2,0.5]
;Tt    = [14.,0.5,1.] & Wt=(2*!PI)/Tt
Tt    = [12.42,12.,12.6576,23.9352,11.9664,25.8192,12.8712,26.868]/24. & Wt=(2*!PI)/Tt   ;8 ondes
Pt    = [0.,0.,0.,0.,0.,0.,0.,0.]  & Pt=(!PI/180.)*Pt
tides = FLTARR(N_ELEMENTS(t))
noise = RANDOMU(seed,N_ELEMENTS(t))

FOR i=0,N_ELEMENTS(At)-1 DO tides=tides+At[i]*sin(Wt[i]*(t-t0)+Pt[i])

signal=sig+tides+noise

; Creation d'une structure julval
st=create_julval(N_ELEMENTS(t))
st.jul=t
st.val=sig+tides+noise

stf=vazquez_filter(st,2,sampling=1,/plot)
butterworth_filter,st,stf2,tc=2,pass=1

plot_julval,st,stf,tmin='2002',tmax='2003'



END
