PRO plot_simu_sensivity_test, scale=scale,wave=wave, buffer=buffer

IF NOT KEYWORD_SET(scale)  THEN scale=100.
IF NOT KEYWORD_SET(wave)   THEN wave='K1'

out_path = '/windows/C/work/communications/articles/2012_testut_marine_geodesy_indian_tides/review/'
output   = out_path+wave+'_obc.ps'

simu_name     = tatlas_simu_list(zone=zone)                                  ;select the list of simulation to be tested
mgr_obs       = nindian_mgr_selected_list(SELECTION=selected_tg,KEY='all')  ;select a list of tige gauges
xtitle        ='Station Number'
ytitle        ='RMS error (cm)'
plot_path     ='/data/tmp/'
xrange        = [1,N_ELEMENTS(selected_tg)]
yrange        = [0.1,45.]


;###########################################
;       list of sensivity parameter
;###########################################
;para_name = ['0e-3','1e-3','2e-3','3e-3','4e-3','5e-3','6e-3','7e-3','8e-3','9e-3']
;para_name = ['0e-3','1e-3','1.2e-3','1.4e-3','1.6e-3','1.8e-3','2e-3']
;para_name = ['0e-3','1e-3','2e-3','3e-3','4e-3','5e-3','6e-3','7e-3','8e-3','9e-3']
;para_name = ['0e-3','1e-3','2e-3','3e-3','4e-3','5e-3','6e-3','7e-3']
;para_name = ['1e-3','1.2e-3','1.4e-3','1.6e-3','1.8e-3','2e-3','2.2e-3','2.4e-3','2.6e-3','2.8e-3']
;para_name = ['1e-3','1.2e-3','1.4e-3','1.6e-3','1.8e-3','2e-3','2.2e-3']
;             0        1        2        3        4         5      6        
para_name= ['fes2012-hydro','fes2004','alti','got4.7','tpxo7.2']


;###########################################
;       list of simulation
;###########################################
;simu1   = 'kha-lr_sp_'+['etopo1','etopo2v2g','etopo5','sindhu2','sindhu5','fes2013','gebco08','gridone','smithsandwell']
;simu2   = 'shelf-hr_sp_'+['etopo1','etopo2v2g','etopo5','sindhu2','sindhu5','gebco08','gridone','smithsandwell']      
;simu_name = simu2
;simu_name= 'shelf-hr_sp_cd_'+para_name
simu_name= 'shelf-hr_sp_obc_'+para_name


;###########################################
;       legend  of simulation
;###########################################
;
;leg_name = 'CD = '+para_name
;leg_name = 'CD = '+['1.2e-3','1.4e-3','1.6e-3','1.8e-3','2e-3','2.2e-3','2.4e-3','2.6e-3','2.8e-3'] ;8 valeurs
;leg_name = 'CD = '+['0e-3','1e-3','1.2e-3','1.4e-3','1.6e-3','1.8e-3','2e-3']
;leg_name = "Bathy="+["etopo-1'","etopo-2'","etopo-5'","sindhu-2'","sindhu-5'","gebco-0.5'","gebco-1'","s&sandwell-1'"]
leg_name = "OBC="+para_name

;                       0          1          2           3            4            5            6            7       

;       'Dark Violet','Plum','Deep Pink','Orange','Red','Light Gray','Black','Thistle')
;        0       1     2      3             4             5               6               7               8       9
;l=LIST('Tomato','Red','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue','Sky Blue','Light Sky Blue','gray')
;l=LIST('Gray','Tomato','Red','Orange','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue')
;lk1_broad  =LIST('Black','Red','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue','Sky Blue','Light Sky Blue','gray')
;lk1_narrow =LIST('Red','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue','Sky Blue','Light Sky Blue')
;lm2_broad  =LIST('Black','Orange','Red','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue','Sky Blue','Light Sky Blue','gray')
;lm2_narrow =LIST('Orange','Tomato','Red','Blue','Dodger Blue','Deep Sky Blue','Deep Sky Blue','Sky Blue','Light Sky Blue','gray')
;lbathy     =LIST('Dark Violet','Plum','Deep Pink','Orange','Red','Blue','Dodger Blue','gray')
lobc        =LIST('Dark Violet','Plum','Red','Blue','gray')



l=lobc
thick=MAKE_ARRAY(N_ELEMENTS(simu_name),VALUE=1.2)
thick[3]=3.

;#######################################################################
;#################### GRAPHICAL PART : BAKCGROUND ######################
;#######################################################################
ctbl=HASH()
ctbl['Dark Salmon']       =[233,150,122]  & ctbl['Salmon']            =[250,128,114]   & ctbl['Light Salmon']      =[255,160,122]   
ctbl['Orange']            =[255,165,000]  & ctbl['Dark Orange']       =[255,140,000]   & ctbl['Coral']             =[255,127,080]   
ctbl['Light Coral']       =[240,128,128]  & ctbl['Tomato']            =[255,099,071]   & ctbl['Orange Red']        =[255,069,000]   
ctbl['Red ']              =[255,000,000]   

ctbl['Hot Pink']          =[255,105,180]  & ctbl['Deep Pink']         =[255,020,147]   & ctbl['Pink']              =[255,192,203]   
ctbl['Light Pink']        =[255,182,193]  & ctbl['Pale Violet Red']   =[219,112,147]   & ctbl['Maroon']            =[176,048,096]   
ctbl['Medium Violet Red'] =[199,021,133]  & ctbl['Violet Red']        =[208,032,144]   & ctbl['Violet']            =[238,130,238]   
ctbl['Plum ']             =[221,160,221]  & ctbl['Orchid']            =[218,112,214]   & ctbl['Medium Orchid']     =[186,085,211]   
ctbl['Dark Orchid']       =[153,050,204]  & ctbl['Dark Violet ']      =[148,000,211]   & ctbl['Blue Violet ']      =[138,043,226]   
ctbl['Purple ']           =[160,032,240]  & ctbl['Medium Purple ']    =[147,112,219]   & ctbl['Thistle ']          =[216,191,216]   

ctbl['Black']             =[000,000,000]  & ctbl['Dark Slate Gray']   =[049,079,079]   & ctbl['Dim Gray']          =[105,105,105]   
ctbl['Slate Gray']        =[112,138,144]  & ctbl['Light Slate Gray']  =[119,136,153]   & ctbl['Gray']              =[190,190,190]   
ctbl['Light Gray']        =[211,211,211]   

;BLUE TABLE
ctbl['Midnight Blue']     =[025,025,112]  & ctbl['Navy']              =[000,000,128]   & ctbl['Cornflower Blue']   =[100,149,237]   
ctbl['Dark Slate Blue']   =[072,061,139]  & ctbl['Slate Blue']        =[106,090,205]   & ctbl['Medium Slate Blue'] =[123,104,238]   
ctbl['Light Slate Blue']  =[132,112,255]  & ctbl['Medium Blue']       =[000,000,205]   & ctbl['Royal Blue']        =[65,105,225]   
ctbl['Blue']              =[000,000,255]  & ctbl['Dodger Blue']       =[030,144,255]   & ctbl['Deep Sky Blue']     =[000,191,255]   
ctbl['Sky Blue']          =[135,206,250]  & ctbl['Light Sky Blue']    =[135,206,250]   & ctbl['Steel Blue']        =[070,130,180]   
ctbl['Light Steel Blue']  =[176,196,222]  & ctbl['Light Blue']        =[173,216,230]   & ctbl['Powder Blue']       =[176,224,230]   
ctbl['Pale Turquoise']    =[175,238,238]  & ctbl['Dark Turquoise']    =[000,206,209]   & ctbl['Medium Turquoise']  =[072,209,204]   
ctbl['Turquoise']         =[64,224,208]   & ctbl['Cyan']              =[000,255,255]   & ctbl['Light Cyan']        =[224,255,255]   
ctbl['Cadet Blue']        =[095,158,160]

 ;window creation
xsize  =  1000
ysize  =   600
IF KEYWORD_SET(buffer) THEN w = window(dimensions=[xsize,ysize],/BUFFER) ELSE w = window(dimensions=[xsize,ysize])
;w.refresh, /disable
leg_pos  = [0.5,0.75]
p_pos    = [0.3,0.2,0.7,0.8]
t_head   = TEXT(leg_pos[0],leg_pos[1],[' WAVE='+STRING(wave)], TARGET=w,COLOR='black',ALIGNMENT=0.5)                
p        = PLOT(INDGEN(2),/CURRENT,XRANGE=xrange,YRANGE=yrange,AXIS_STYLE=0,$
                           XTITLE=xtitle,YTITLE=ytitle,$
                           POSITION=p_pos)
;name_axis = AXIS('X',TARGET=p,LOCATION=[0,YRANGE[1]],TEXTPOS=1,TICKINTERVAL=1,$
;                     TICKNAME=selected_tg,TEXT_ORIENTATION=-90.,TICKFONT_SIZE=6,$
;                     MINOR=0)
                           
FOR i=0,N_ELEMENTS(simu_name)-1 DO BEGIN
 num = string(i,FORMAT='(I2.2)')
 sn  = simu_name[i]
 PRINT,FORMAT='(%"===========================  SIMU # %d --> %s  ")',num,sn
 tatlas    = load_tatlas(ZONE=zone,MODEL=simu_name[i],WAVE=wave)
 mgr_mod   = tatlas2mgr(tatlas,mgr_obs,tresh=50000)
 reduce_mgr2common,mgr_obs,mgr_mod,mgr1,mgr2, n1, nb_wave, common_wave, ncomb
 ;apply a station selection or sort again the TG
 mgr1_select = sort_mgr(mgr1,NAME_LIST=selected_tg) 
 mgr2_select = sort_mgr(mgr2,NAME_LIST=selected_tg)
 tmis        = compare_mgr(mgr1_select,mgr2_select,scale=scale,/NO_REDUCE,/MUTE)
 sig_wave    = SQRT(TOTAL(tmis.sta.wave.de*tmis.sta.wave.de)/(2*N_ELEMENTS(tmis.sta.wave.de))) 
 p           = PLOT(tmis.sta.wave.de,/OVERPLOT,COLOR=l[i],THICK=THICK[i])
 legende     = TEXT(p_pos[0]+0.01,p_pos[3]-0.03*(i+1),leg_name[i],TARGET=p,FONT_SIZE=12,COLOR=l[i],ALIGNMENT=0.)               
 legsigma    = TEXT(p_pos[2]+0.01,p_pos[3]-0.03*(i+1),'rms= '+STRING(FORmat='(F6.2)',sig_wave),TARGET=p,FONT_SIZE=12,COLOR=l[i],ALIGNMENT=0.)               

ENDFOR

w.Refresh
print,output
w.save, output


END