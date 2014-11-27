PRO info_tab, tab, info

Nd    = N_ELEMENTS(tab)
itrou = WHERE(FINITE(tab),count)
Nnan  = Nd-count

info=STRING('-[Ndata=',STRCOMPRESS(STRING(Nd),/REMOVE_ALL),']-',$
            '-[Nnan=' ,STRCOMPRESS(STRING(Nnan),/REMOVE_ALL),']-',$
            '-[Moy='  ,STRCOMPRESS(STRING(MEAN(tab,/NAN)),/REMOVE_ALL),']-',$
            '-[Std='  ,STRCOMPRESS(STRING(STDDEV(tab,/NAN)),/REMOVE_ALL),']-')
print,info

END
