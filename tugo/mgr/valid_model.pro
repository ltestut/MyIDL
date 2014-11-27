PRO valid_model, zone=zone, output=output
; programme qui a partir d'un mgr donne va construire le mgr equivalent pour
; tout les modeles disponibles et faire les comparaisons

IF NOT KEYWORD_SET(zone)   THEN zone='/data/model_salomon/valid/results/table/'
IF NOT KEYWORD_SET(output) THEN output='/data/model_'+zone+'/valid/results/table/'

mname=['fes2004','fes2012','got4.7','got4.8','tpxo6.2','tpxo7.0','dtu10']

;wlist=['K1','O1','M2','S2','Q1','K2']
wlist=['M2','S2','K2','N2','K1','O1','P1','Q1']

ref_name = 'obs_uhslc'
mgr_ref  = load_mgr(zone=zone,obs='uhslc')

FOR i=0,N_ELEMENTS(mname)-1 DO BEGIN ;on parcours tous les modeles
 tmis=valid_tide_model(mgr_ref,load_mgr(ZONE=zone,MODEL=mname[i]),$
                     WLIST=wlist,$
                    OUTPUT=output+'valid_'+zone+'_'+ref_name+'_vs_'+mname[i]+'.txt')
 compare_mgr,mgr_ref,load_mgr(ZONE=zone,MODEL=mname[i]),OUTPUT=output+'detail_valid_'+zone+'_'+ref_name+'_vs_'+mname[i]+'.txt'                   
ENDFOR

CLOSE,/ALL
END