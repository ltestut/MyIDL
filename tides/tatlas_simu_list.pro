FUNCTION tatlas_simu_list, zone=zone
;inventory of the tatlas database this function is useful to 
;select a list (vector) of tatlas name and use them in a loop 


;###################################################################
;#########################  WEST INDIAN SHELF   ####################
;###################################################################
zone = 'arb'
;--------------------------------------------------------------------------------
;                       simu Gulf Of Khambhat Saheed
;--------------------------------------------------------------------------------
;simu_name= 'goc_sq_saheed'
;
;--------------------------------------------------------------------------------
;                       simu WIS low-resolution different CD value
;--------------------------------------------------------------------------------
;simu_name = 'kha-lr_cd_'+['2.5e-10','2.5e-8','2.5e-7','2.5e-6','2.5e-5',$
;                          '2e-4'   ,'2.5e-4','3e-4'  ,'4e-4'  ,'5e-4'  ,'6e-4','7e-4','8e-4','9e-4',$
;                 '1.2e-3','2e-3'   ,'2.5e-3','3e-3'  ,'4e-3'  ,'5e-3'  ,'6e-3','7e-3','8e-3','9e-3',$
;                          '2e-2'   ,'2.5e-2','3e-2'  ,'4e-2'  ,'5e-2'  ,'6e-2','7e-2','8e-2','9e-2',$
;                          '2.5e-1' ,'2.5e0',$                          
;                          'unni-5m','unni']
;--------------------------------------------------------------------------------
;                       simu WIS low-resolution different bathymetry
;--------------------------------------------------------------------------------
;simu_name = 'kha-lr_sp_'+['etopo1','etopo2v2g','etopo5',$
;                'sindhu2','sindhu5',$
;                'fes2013','gebco08','gridone',$
;                'smithsandwell']

;                          
;--------------------------------------------------------------------------------
;                       simu WIS low-resolution whithout Khambhat and different CD value
;--------------------------------------------------------------------------------
;simu_name= 'no-kha-lr_cd_'+['1.0E-03','2.0E-03','3.0E-03','4.0E-03','5.0E-03','6.0E-03',$
;                            '7.0E-03','8.0E-03','9.0E-03','1.0E-02','2.0E-02','3.0E-02',$
;                            '4.0E-02','5.0E-02','6.0E-02','7.0E-02','8.0E-02','9.0E-02',$
;                            '1.0E-01']
;
;--------------------------------------------------------------------------------
;                      simu WIS low-resolution different CW value or algo
;--------------------------------------------------------------------------------
;simu_name = 'kha-lr_cw_'+['0000','0050','0100','0200','0500','1000','1500','2000']
;simu_name = 'kha-lr_cw-zmax_'+['300','350','400','450','500','550','600','650','700','750','800','850','900','950']
;simu_name = 'kha-lr_cw-algo_'+['01','02','03','04','05','06','07']
;simu_name = 'kha-lr_cw-200_H_100-700_rugofile_test'
;simu_name = 'kha-lr_cw-200_H_100-1000_rugofile_2e-3'
;simu_name = 'kha-lr_cw-200_H_100-2000_rugofile_1e-3'
;simu_name = 'kha-lr_cw-200_H_100-2000_rugofile_9e-4'
;simu_name = 'kha-lr_cw-300_H_200-700_rugofile_test'
;simu_name = 'kha-lr_cw-300_H_100-2000_rugofile_test'
;simu_name = 'kha-lr_cw-1000_H_100-1000_rugofile_test'

;
;--------------------------------------------------------------------------------
;                       simu WIS low-resolution different rugosity files
;--------------------------------------------------------------------------------
;simu_name = 'kha-lr_two-rugo_'+['00','01','02','03','04','05','06','07','08','09',$
;                                '10','11','12','13','14','15']
;                                                    
;--------------------------------------------------------------------------------
;                        simu WIS high-resolution different CD value
;--------------------------------------------------------------------------------
;simu_name= 'kha-hr_cd_'+['1e-4','2e-4','3e-4','4e-4','5e-4','6e-4','7e-4','8e-4','9e-4',$
;                         '1e-3','1.2e-3','1.3e-3','1.4e-3','1.5e-3','1.6e-3','1.7e-3','1.8e-3','1.9e-3',$
;                         '2e-3']
;              

;--------------------------------------------------------------------------------
;                       simu WIS Shelf high-resolution different CD value
;--------------------------------------------------------------------------------
;simu_name= 'shelf-hr_sp_cd_'+['0e-3','1e-3','1.2e-3','2e-3','3e-3','4e-3','5e-3','6e-3','7e-3','8e-3','9e-3']
;simu_name= 'shelf-hr_sp_cd_'+['1.2e-3','1.4e-3','1.6e-3','1.8e-3','2.2e-3','2.4e-3','2.6e-3','2.8e-3']               
;simu_name= 'shelf-hr_sp_cdf_'+['1.2e-3','1.6e-3'] ;full waves 23
;simu_name= 'shelf-hr_sp_sindhu2_cdf_1.2e-3'
;simu_name= 'shelf-hr_sp_sindhu2_testut_cdf_1.2e-3' ;                
;simu_name= 'shelf-hr_sq_cd_'+['1.2e-3','2.5e-3']
;simu_name= 'shelf-hr_sp_cw_0_cd_'+['1.2e-3','2.5e-3']
;simu_name= 'shelf-hr_sp_rugo_1_cd_1.2e-3'
;simu_name= 'shelf-hr_sp_rugo_2_cd_1.2e-3'

;simu_name= 'shelf-hr_sp_cdf_1.6e-3
              
;--------------------------------------------------------------------------------
;                       simu WIS Shelf high-resolution different Bathymetry
;--------------------------------------------------------------------------------
;simu_name= 'shelf-hr_sp_'+['etopo1','etopo2v2g','etopo5',$
;                'sindhu2','sindhu5',$
;                'fes2013','gebco08','gridone',$
;                'smithsandwell']

;--------------------------------------------------------------------------------
;                       simu WIS Shelf high-resolution different OBC
;--------------------------------------------------------------------------------
;simu_name= 'arb_shelf-hr_sp_obc_'+['fes2012-hydro','fes2004','alti',$
;                'got4.7','tpxo7.2']


;--------------------------------------------------------------------------------
;                       simu WIS Shelf Break mean-resolution 
;--------------------------------------------------------------------------------
simu_name= 'shelf_break-mr_sp_cd_'+['1.2e-3']


;###################################################################
;#########################  BAY OF BENGAL       ####################
;###################################################################
zone     = 'bob'
;simu_name= 'tamil_sq_cd_2.5e-3'
simu_name= 'test1'

;###################################################################
;#########################  NORTH INDIAN OCEAN  ####################
;###################################################################
;zone     = 'nindian'
;simu_name= ['tpxo7.2']

;###################################################################
;#########################  GLOBAL TIDAL ATLAS  ####################
;###################################################################
;zone      = 'glob'
;simu_name = ['fes2004','fes2012-hydro','fes2013-hydro','fes2012','got4.7','got4.8','tpxo6.2','tpxo7.0','tpxo7.2','tpxo8','dtu10','eot10a',$
;             'cats02.01','cats2008','cada00.10']
                             


RETURN, simu_name
END