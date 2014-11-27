PRO run_tugo_bathy_obc, blank=blank, sequential=sequential, obc_run=obc_run
;prog to run tugo simulation on multiple bathymetry
 
 ;path or the simulation, rerefence and generated .intg file
zone         = 'shelf';'wic'
my_path      = '/data/model_indien_nord/zone_'+zone+'/simu_tide/'
my_rugo_path = '/data/model_indien_nord/zone_'+zone+'/data/'
IF KEYWORD_SET(obc_run) THEN out_intg='run_obc.intg' ELSE out_intg='run_bathy.intg'
IF KEYWORD_SET(obc_run) THEN simu_type='obc'    ELSE simu_type='bathy'

 ;define the mode of simulation spectral or sequential (linear or non-linear)
IF KEYWORD_SET(sequential) THEN BEGIN
 in_intg  = my_path+'sequential.intg'
 mode         = 'sequential'
 idm          = 'sq'
ENDIF ELSE BEGIN
 in_intg    = my_path+'spectral.intg'
 mode       = 'spectral'
 idm        = 'sp'
ENDELSE


 ;basic simu info for arx
atlas_root   = 'arb/arb_shelf-hr_'+idm+'_obc_'
obc          = '??'         ;when obc run you have to choose the bathy
assimilation = 'no'
bathy        = 'sindhu5'    ;when obc run you have to choose the bathy 


CD, my_path, CURRENT=here
 ;read the base config and define the main permanent input
config=init_intg(in_intg)
config['model','relative_minimum_depth']         = '10.'
config['model','minimum_depth']                  = '8.'
config['dissipation','bottom_friction_type']     = 'QUADRATIC' ;'LINEAR'  
config['dissipation','linear_friction_coeff']    = '1.2E-03'
config['dissipation','quadratic_friction_coeff'] = '2.5E-03'
config['dissipation','internal_drag_slope']      = '0'
config['dissipation','internal_drag_hmin']       = '100'
config['dissipation','internal_drag_hmax']       = '100'

bathy_list   = ['etopo1','etopo2v2g','etopo5',$
                'sindhu2','sindhu5',$
                'fes2013','gebco08','gridone',$
                'smithsandwell']

obc_list     = ['fes2012-hydro','fes2004','alti',$
                'got4.7','tpxo7.2']

para_list = obc_list
IF KEYWORD_SET(blank) THEN para_list=para_list[0] 

FOR i=0,N_ELEMENTS(para_list)-1 DO BEGIN
   simu_name   = STRING(para_list[i])                  ;simu extension
   output_dir  = 'run_'+mode+'_obc_'+simu_name              ;output directory
   atlas_name  = atlas_root+simu_name+'.sav'            ;atlas name
   sch_format  = '.'+simu_name+'.nc'                    ;search_format 
   s2c2nc_cmd  = output_dir+'/ -p '+'.'+simu_name       ;s2c2nc command
   atlas_desc  =  zone+' HR model / '+mode+' mode / Cw='+config['dissipation','internal_drag_slope']+$
                       ' [zmin='+config['dissipation','internal_drag_hmin']+',zmax='+config['dissipation','internal_drag_hmax']+$
                       '] / cd = '+config['dissipation','quadratic_friction_coeff']+':'+config['dissipation','bottom_friction_type']
   atlas_info  =  zone+'['+STRUPCASE(idm)+'-Q:'+simu_type+'='+simu_name+']'
   print,"    + simu_type     : ", simu_type      
   print,"    + simu_name     : ", simu_name      
   print,"    + Output dir    : ", output_dir   
   print,"    + Search format : ", sch_format
   print,"    + Atlas name    : ", atlas_name
   print,"    + Atlas desc    : ", atlas_desc
   print,"    + Atlas info    : ", atlas_info

   ;#########WRITE THE OUTPUT AND NEW CONFIG FILE ########################
   config['model','output_path']   = output_dir
   logical                         = write_intg(config,FILE_OUT=my_path+out_intg)
 

  IF KEYWORD_SET(blank) THEN BEGIN
    PRINT,""
    PRINT," /!\ For a BATHY test create the link toward the good OBC"
    PRINT," /!\ For a OBC   test create the link toward the good BATHY"     
    PRINT,""

    PRINT,here
    IF KEYWORD_SET(obc_run) THEN BEGIN
     PRINT,'ln -sf ../data/tides_'+simu_name+'_M2K1.obc ../data/tides.obc'
     obc=simu_name
    ENDIF ELSE BEGIN
     PRINT,'ln -sf ../data/topo-'+simu_name+'.s2r ../data/topo.s2r'
     PRINT,'ln -sf ../data/slope-'+simu_name+'.v2r ../data/slope.v2r'
     bathy=simu_name
    ENDELSE
     PRINT,'tugo '+out_intg
     PRINT,'/home/testut/bin/bash/s2c2nc -m meshll.nei -d '+output_dir+'/ -p '+'.'+simu_name
     PRINT,FORMAT='(%"make_tatlas_archive, %s, NAME=%s, DESCR=%s, SEARCH_FORMAT=%s, INFO=%s,MODE=%s,OBC=%s,BATHY=%s,ASSIMILATION=%s")',$
           my_path,atlas_name,atlas_desc,sch_format,atlas_info,mode,obc,bathy,assimilation
   ENDIF ELSE BEGIN
    IF KEYWORD_SET(obc_run) THEN BEGIN
     SPAWN,'ln -sf ../data/tides_'+simu_name+'_M2K1.obc ../data/tides.obc'
     obc=simu_name
    ENDIF ELSE BEGIN
     SPAWN,'ln -sf ../data/topo-'+simu_name+'.s2r ../data/topo.s2r'
     SPAWN,'ln -sf ../data/slope-'+simu_name+'.v2r ../data/slope.v2r'
     bathy=simu_name
    ENDELSE
     SPAWN,'tugo '+out_intg
     IF KEYWORD_SET(sequential) THEN BEGIN
     ENDIF ELSE BEGIN
     PRINT,'/home/testut/bin/bash/s2c2nc -m meshll.nei -d '+output_dir+'/ -p '+simu_name
     SPAWN,'/home/testut/bin/bash/s2c2nc -m meshll.nei -d '+output_dir+'/ -p '+simu_name
     make_tatlas_archive, my_path ,$
        NAME=atlas_name,DESCR=atlas_desc,SEARCH_FORMAT=sch_format,$
        INFO=atlas_info,MODE=mode, OBC=obc, BATHY=bathy, ASSIMILATION=assimilation
     ENDELSE
   ENDELSE
ENDFOR


END