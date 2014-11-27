PRO plot_yvsy, st1, st2, title=title, plotitle=plotitle, ins=ins, tmin=tmin, tmax=tmax, sym=sym, win=win, ps=ps

IF (N_PARAMS() EQ 0) THEN BEGIN
    print, 'UTILISATION:'
    print, 'PLOT_yvsy, st1, st2, title=title, ins=ins, tmin=tmin, tmax=tmax, sym=sym, win=win'
    print, ''
    print, 'INPUT:  st1           --> de type {jul,val}'
    print, 'INPUT:  st2           --> de type {jul,val}'
    print, ' (1) Si pas de titre ==> Fenetre X '
    print, ' (2) Si titre        ==> title.plot_julval.ps'
    print, ' (3) Si ins=1        ==> insertion dans un graphic'
    RETURN
ENDIF

loadct,10
!P.MULTI=[0,1,1]

; GESTION DU FORMAT DE SORTIE
; ---------------------------
CASE 1 OF
    (N_ELEMENTS(ps) EQ 0) AND (N_ELEMENTS(ins) EQ 0): BEGIN
        set_plot, 'X'
        device, retain=2, decomposed=0
        output='Xwindow'
        IF (N_ELEMENTS(win) EQ 0) THEN win=0
        window, win, title=plotitle, xsize=800,ysize=800
    END
    KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0): BEGIN
        original_device= !D.NAME
        set_plot, 'PS'
        !P.FONT= 0
         root='/local/windows/D/communications/revues/ocean_dynamics/resultats/rattachement/shom/'
        output = STRING(strcompress(plotitle,/REMOVE_ALL),'.plot_yvsy.ps')
        device, /portrait, /color, filename=root+output, $
          /narrow, font_size=5,$
          xsize=18, ysize=22,xoffset=2.,yoffset=4.
    END
    (N_ELEMENTS(ins) EQ 1): BEGIN
        output='insertion de plot_fft' 
        IF (N_ELEMENTS(title) EQ 0) THEN title='POWER SPECTRAL DENSITY'
    END
ENDCASE
info1=info_st(st1,tmin=tmin,tmax=tmax)
info2=info_st(st2,tmin=tmin,tmax=tmax)

yr = [MIN(st2[info2.ind].val,/NAN),MAX(st2[info2.ind].val,/NAN)]
xr = [MIN(st1[info1.ind].val,/NAN),MAX(st1[info1.ind].val,/NAN)]    
print,'XR============================',xr

IF (N_ELEMENTS(sym)   EQ 0)  THEN sym  = 2
IF (N_ELEMENTS(ytitle) EQ 0) THEN ytitle= ''

r_coef    = LINFIT(st1[info1.ind].val, st2[info2.ind].val,SIGMA=err)
ysubtitle = STRING('-[Coef_regr=',STRCOMPRESS(STRING(r_coef[1]),/REMOVE_ALL),']-')

PLOT, st1[info1.ind].val, st2[info2.ind].val , /DATA, $
  title    = title,  subtitle = ysubtitle   ,$
  xtitle   = info1.str[2],  ytitle   = info2.str[2]   ,$
  xstyle   = 2 ,  ystyle   = 2    ,$
  xrange   = xr, yrange   = yr    ,$
  XTICKS        = 0    ,$  
  XTICKLEN      = 1    ,$
  XGRIDSTYLE    = 1    ,$
  XTICKLAYOUT   = 0    ,$
  psym          = sym ,$
  POSITION      =[0.2,0.2,0.8,0.8]

OPLOT,  st1[info1.ind].val, (st1[info1.ind].val*r_coef[1]+r_coef[0]) , color=150

FIN : print,'OUTPUT ======>',output
IF (KEYWORD_SET(ps) AND (N_ELEMENTS(ins) EQ 0)) THEN device, /close_file

;; Derniere Modif le 28/05/2005
END
