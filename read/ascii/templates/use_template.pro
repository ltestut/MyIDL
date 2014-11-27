; $Id: use_template.pro, v 0.0 17/12/2004 Laurent Testut $
;
;+
; NAME:
;       USE_TEMPLATE
;
; PURPOSE:
;       read a predefined template to be used with READ_ASCII
;
; CATEGORY:
;       Read/Write procedure/fucntion
;
; CALLING SEQUENCE:
;       template = USE_TEMPLATE(template_name)
;
; INPUTS:
;       template_name : string of the template name ex:'lst'
;
;
; OUTPUTS:
;       The function returns a template (structure) defining the  ASCII files
;       Such templates may be used as inputs to function READ_ASCII.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
; -Le 12/01/2005 add xyz template
; -Le 26/01/2005 add pre template
; -Le 01/04/2005 add shm template
; -Le 12/05/2005 add mtm2 template (for file of baro.dat)
; -Le 20/05/2005 add phytot template (for file of .phytot)
; -Le 25/05/2005 add sum  template (for file of .sum)
; -Le 21/10/2005 add oiso template (for ctd oiso file)
; -Le 27/02/2006 add bef template (for australian tide gauge data)
; -Le 24/03/2006 add alti template (for Claire alti data file)
; -Le 26/10/2006 add list template (for harmonic analysis input data file)
; -Le 05/12/2006 add phy3 template (for the ker2_hf.phy)
; -Le 04/04/2007 add phy4 template (for the ker2_argos.phy)
; -Le 02/05/2007 add ncview template (for the ncview.dump)
; -Le 14/05/2007 add lst template (for the meteo .lst)
; -Le 19/06/2007 add rbr template (for the .rbr file)
; -Le 20/09/2007 add lct template (for the .lct file of tide pole readings)
; -Le 26/08/2008 add jma template (for the .jma of type jj/mm/aaaa hh:mm:ss)
; -Le 24/10/2008 add bodc template (for the .txt of type BODC)
; -Le 05/11/2008 add bodc template (for the .prd from EXTERNA earth tide software)
; -Le 17/11/2008 add blq template (for the .blq from OTL ocean tide loading)
; -Le 17/12/2008 add phynew template (pour les nouveau format .phy)
; -Le 19/12/2008 add pbm/pbmbr/uls/rad template (pour les fichiers SHOM Nicolas Pouvreau)
; -Le 07/04/2010 add jmarms template (for the .jma of type jj/mm/aaaa hh:mm:ss  val rms)
; -Le 21/08/2013 add mto_ddu2010    template (for the .txt of ddu mto file)
; -Le 21/08/2013 add mto_ddu2010_08 template (for the .txt of ddu mto file after 08 2010)
; 
;-


FUNCTION use_template, para

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  tpl=use_template(para)'

pbm  = {version:1.0,$
        datastart:0   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:'c'   ,$
        fieldcount:22 ,$
        fieldTypes:[2,2,2,2,2,4,2,2,4,2,2,4,2,2,4,2,2,4,2,2,4,2], $
        fieldNames:['num','pbm','y','he0','mi0','h0','he1','mi1','h1','he2','mi2','h2','he3','mi3','h3','he4','mi4','h4','he5','mi5','h5','day'] , $
        fieldLocations:[0,10,12,16,22,24,28,31,33,37,40,42,46,49,51,55,58,60,64,67,69,73]    , $
        fieldGroups:INDGEN(22) $
      }

pbmbr= {version:1.0,$
        datastart:3   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:'c'   ,$
        fieldcount:18 ,$
        fieldTypes:[2,2,2,2,2,4,2,2,4,2,2,4,2,2,4,2,2,2], $
        fieldNames:['num','pbm','y','he0','mi0','h0','he1','mi1','h1','he2','mi2','h2','he3','mi3','h3','neufs0','neufs1','day'] , $
        fieldLocations:[0,3,5,10,13,17,22,25,29,34,37,41,46,49,53,58,67,76]    , $
        fieldGroups:INDGEN(18) $
      }

uls  = {version:1.0,$
        datastart:1   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:'c'   ,$
        fieldcount:102 ,$
        fieldTypes:[MAKE_ARRAY(102,VALUE=2)], $
        fieldNames:['y','day','hh00','mm00','s00','h00','hh01','mm01','s01','h01','hh02','mm02','s02','h02','hh03','mm03','s03','h03','hh04','mm04','s04','h04','hh05','mm05','s05','h05','hh06','mm06','s06','h06','hh07','mm07','s07','h07','hh08','mm08','s08','h08','hh09','mm09','s09','h09','hh10','mm10','s10','h10','hh11','mm11','s11','h11','hh12','mm12','s12','h12','hh13','mm13','s13','h13','hh14','mm14','s14','h14','hh15','mm15','s15','h15','hh16','mm16','s16','h16','hh17','mm17','s17','h17','hh18','mm18','s18','h18','hh19','mm19','s19','h19','hh20','mm20','s20','h20','hh21','mm21','s21','h21','hh22','mm22','s22','h22','hh23','mm23','s23','h23','hh24','mm24','s24','h24'] , $
        fieldLocations:[0,2,5,7,9,11,15,17,19,21,25,27,29,31,35,37,39,41,45,47,49,51,55,57,59,61,65,67,69,71,75,77,79,81,85,87,89,91,95,97,99,101,105,107,109,111,115,117,119,121,125,127,129,131,135,137,139,141,145,147,149,151,155,157,159,161,165,167,169,171,175,177,179,181,185,187,189,191,195,197,199,201,205,207,209,211,215,217,219,221,225,227,229,231,235,237,239,241,245,247,249,251]    , $
        fieldGroups:INDGEN(102) $
      }

rad  = {version:1.0,$
        datastart:1   ,$
        ;delimiter:';'   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'c:\'   ,$
        fieldcount:12 ,$
        fieldTypes:[2,7,7,7,2,7,4,7,4,7,7,7], $
        ;fieldTypes:[2,7,7,2,4,4,4,4,4], $
        ;fieldNames:['num','date','mess','val','ecrty','seuil','pres','amem'] , $
        ;fieldNames:['num','flg1','date','flg2','mess','flg3','val','flg4','ecrty','flg5','seuil','flg6','pres','flg7','amem'] , $
        fieldNames:['num','flg1','date','flg2','mess','flg3','val','flg4','ecrty','flg5','flg6','flg7'] , $
        fieldLocations:[0,4,5,24,25,26,27,34,35,40,41,42]    , $
        fieldGroups:INDGEN(12) $
      } 

blq = {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'$$'   ,$
        fieldcount:11 ,$
        fieldTypes:[4,4,4,4,4,4,4,4,4,4,4], $
        fieldNames:['m2','s2','n2','k2','k1','o1','p1','q1','mf','mm','ssa'] , $
        fieldLocations:[0,8,16,22,29,36,43,50,57,64,71]    , $
        fieldGroups:indgen(11) $
      }


alti = {version:1.0,$
        datastart:2   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:6 ,$
        fieldTypes:[2,5,4,4,4,4], $
        fieldNames:['cyc','jul','lon','lat','sat','mrg'] , $
        fieldLocations:[0,5,19,31,43,56]    , $
        fieldGroups:indgen(6) $
      }

phy1= {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:10L ,$
        fieldTypes:[3,7,4,4,4,4,2,2,2,2], $
        fieldNames:['num','jul','twat','bot','swat','baro','n1','n2','n3','n4'] , $
        fieldLocations:[0,6,25,36,47,58,69,72,75,78]    , $
        fieldGroups:INDGEN(10) $
      }
phy2= {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:4L ,$
        fieldTypes:[7,4,4,4], $
        fieldNames:['jul','twat','bot','baro'] , $
        fieldLocations:[0,19,25,37]    , $
        fieldGroups:INDGEN(4) $
      }
rbr= {version:1.0,$
        datastart:29   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:5L ,$
        fieldTypes:[7,4,4,4,4], $
        fieldNames:['jul','cwat','twat','bot','depth'] , $
        fieldLocations:[0,19,29,39,49]    , $
        fieldGroups:INDGEN(5) $
      }

mto_ddu  = {version:1.0,$
        datastart:1   ,$
        delimiter:','   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'"'   ,$
        fieldcount:7L ,$
        fieldTypes:[7,4,4,4,4,4,4], $
        fieldNames:['jul','hour','baro','dwind','fwind','dwindmax','fwindmax'] , $
        fieldLocations:[0,10,13,19,23,25,28]    , $
        fieldGroups:INDGEN(7) $
      }
mto_ddu2010  = {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:''   ,$
        fieldcount:7L ,$
        fieldTypes:[7,4,4,4,4,4,4], $
        fieldNames:['jul','s','baro','dwind','fwind','dwindmax','fwindmax'] , $
        fieldLocations:[0,19,30,50,70,90,110]    , $
        fieldGroups:INDGEN(7) $
      }

mto_ddu2010_08  = {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:'"'   ,$
        fieldcount:7L ,$
        fieldTypes:[7,4,4,4,4,4,4], $
        fieldNames:['jul','baro','tair','dwind','fwind','dwindmax','fwindmax'] , $
        fieldLocations:[0,14,22,32,42,52,62]    , $
        fieldGroups:INDGEN(7) $
      }



phy3= {version:1.0,$
        datastart:1   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:5L ,$
        fieldTypes:[7,4,4,4,4], $
        fieldNames:['jul','twat','bot','cwat','baro'] , $
        fieldLocations:[0,19,29,39,49]    , $
        fieldGroups:INDGEN(5) $
      }

phy4= {version:1.0,$
        datastart:3   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:7L ,$
        fieldTypes:[7,4,4,4,2,2,2], $
        fieldNames:['jul','twat','bot','baro','n1','n2','n3'] , $
        fieldLocations:[0,19,29,39,49,52,55]    , $
        fieldGroups:INDGEN(7) $
      }

phytot = {version:1.0,$
          datastart:0   ,$
          delimiter:''   ,$
          missingvalue:!VALUES.F_NAN   ,$
          commentsymbol:';'   ,$
          fieldcount:5L ,$
          fieldTypes:[7,4,4,4,4], $
          fieldNames:['jul','twat','bot','baro','mto'] , $
          fieldLocations:[0,19,29,39,49]    , $
          fieldGroups:INDGEN(5) $
         }
phytest = {version:1.0,$
          datastart:1   ,$
          delimiter:''   ,$
          missingvalue:!VALUES.F_NAN   ,$
          commentsymbol:';'   ,$
          fieldcount:4L ,$
          fieldTypes:[7,4,4,4], $
          fieldNames:['jul','twat','bot','baro'] , $
          fieldLocations:[0,19,25,36]    , $
          fieldGroups:INDGEN(4) $
         }
phynew = {version:1.0,$
          datastart:1   ,$
          delimiter:''   ,$
          missingvalue:!VALUES.F_NAN   ,$
          commentsymbol:';'   ,$
          fieldcount:4L ,$
          fieldTypes:[7,4,4,4], $
          fieldNames:['jul','twat','bot','baro'] , $
          fieldLocations:[0,19,29,39]    , $
          fieldGroups:INDGEN(4) $
         }

lct   = {version:1.0,$
          datastart:2   ,$
          delimiter:''   ,$
          missingvalue:0   ,$ ;!VALUES.F_NAN   ,$
          commentsymbol:'-'   ,$
          fieldcount:7L ,$
          fieldTypes:[2,7,4,4,4,2,7], $
          fieldNames:['num','jul','lct','rms','nbl','flg','obs'] , $
          fieldLocations:[0,4,21,29,34,39,44]    , $
          fieldGroups:INDGEN(7) $
         }

sum    = {version:1.0,$
          datastart:17   ,$
          delimiter:''   ,$
          missingvalue:!VALUES.F_NAN   ,$
          commentsymbol:';'   ,$
          fieldcount:6L ,$
          fieldTypes:[5,4,4,4,4,4], $
          fieldNames:['jul','col2','col3','col4','col5','res'] , $
          fieldLocations:[0,13,24,35,46,57]    , $
          fieldGroups:INDGEN(6) $
         }
obs    = {version:1.0,$
          datastart:1   ,$
          delimiter:' '   ,$
          missingvalue:!VALUES.F_NAN   ,$
          commentsymbol:';'   ,$
          fieldcount:12L ,$
          fieldTypes:[5,4,4,4,4,4,4,4,4,4,4,4], $
          fieldNames:['jul','f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11'] , $
          fieldLocations:[0,12,19,26,33,40,47,54,61,68,75,82]    , $
          fieldGroups:INDGEN(12) $
         }
dateval = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:';'   ,$
           fieldcount:2L ,$
           fieldTypes:[7,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,19]    , $
           fieldGroups:INDGEN(2) $
          }
jma     = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:'#'   ,$
           fieldcount:2L ,$
           fieldTypes:[7,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,19]    , $
           fieldGroups:INDGEN(2) $
          }
refmar     = {version:1.0,$
            datastart:0   ,$
            delimiter:';'   ,$
            missingvalue:!VALUES.F_NAN   ,$
            commentsymbol:'#'   ,$
            fieldcount:2L ,$
            fieldTypes:[7,4,2], $
            fieldNames:['jul','val','src'] , $
            fieldLocations:[0,1,2]    , $
            fieldGroups:INDGEN(3) $
          }
jmarms     = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:'#'   ,$
           fieldcount:3L ,$
           fieldTypes:[7,4,4], $
           fieldNames:['jul','val','rms'] , $
           fieldLocations:[0,19,29]    , $
           fieldGroups:INDGEN(3) $
          }

prd     = {version:1.0,$
           datastart:30   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:';'   ,$
           fieldcount:2L ,$
           fieldTypes:[7,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,15]    , $
           fieldGroups:INDGEN(2) $
          }


dat     = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:';'   ,$
           fieldcount:4L ,$
           fieldTypes:[7,4,4,4], $
           fieldNames:['jul','val','x','y'] , $
           fieldLocations:[0,13,19,22]    , $
           fieldGroups:INDGEN(4) $
          }

julval = {version:1.0,$
           datastart:0   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:';'   ,$
           fieldcount:2L ,$
           fieldTypes:[5,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,17]    , $
           fieldGroups:INDGEN(2) $
          }

list   = {version:1.0,$
           datastart:14   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:'#'   ,$
           fieldcount:2L ,$
           fieldTypes:[5,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,13]    , $
           fieldGroups:INDGEN(2) $
          }	  
lst   = {version:1.0,$
           datastart:4   ,$
           delimiter:''   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:''   ,$
           fieldcount:16L ,$
           fieldTypes:[7,4,4,4,3,4,3,2,2,2,2,2,2,2,2,2], $
           fieldNames:['jul','pmer','t','td','dd','ff','vv','n','nbas','bbas','ww','w1','w2','cl','cm','ch'] , $
           fieldLocations:[0,10,19,26,33,38,44,51,54,59,65,69,72,75,78,81]    , $
           fieldGroups:INDGEN(16) $
          }	  
ncview   = {version:1.0,$
           datastart:4   ,$
           delimiter:' '   ,$
           missingvalue:!VALUES.F_NAN   ,$
           commentsymbol:''   ,$
           fieldcount:2L ,$
           fieldTypes:[5,4], $
           fieldNames:['jul','val'] , $
           fieldLocations:[0,11]    , $
           fieldGroups:INDGEN(2) $
          }
test = {version:1.0,$
        datastart:3   ,$
        delimiter:32b   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:''   ,$
        fieldcount:4 ,$
        fieldTypes:[3,3,3,3], $
        fieldNames:['jul','mois','jour','heure'] , $
        fieldLocations:[0,4,6,8]    , $
        fieldGroups:[0,1,2,3] $
      }

xyz  = {version:1.0,$
        datastart:0   ,$
        delimiter:32b   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:3 ,$
        fieldTypes:[5,5,5], $
        fieldNames:['x','y','z'] , $
        fieldLocations:[0,12,26]    , $
        fieldGroups:[0,1,2] $
      }
latlon= {version:1.0,$
        datastart:0   ,$
        delimiter:32b   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:3 ,$
        fieldTypes:[5,5,5], $
        fieldNames:['x','y','z'] , $
        fieldLocations:[0,5,12]    , $
        fieldGroups:[0,1,2] $
      }


shm  = {version:1.0,$
        datastart:0   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:'c'   ,$
        fieldcount:27 ,$
        fieldTypes:[2,2,2,MAKE_ARRAY(24,/INT,VALUE=4)], $
        fieldNames:['y','num','day','h0','h1','h2','h3','h4','h5','h6','h7','h8','h9','h10','h11','h12','h13','h14','h15','h16','h17','h18','h19','h20','h21','h22','h23'] , $
        fieldLocations:[0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104]    , $
        fieldGroups:INDGEN(27) $
      }

bef  = {version:1.0,$
        datastart:0   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:''   ,$
        fieldcount:17 ,$
        fieldTypes:[7,2,2,2,2,MAKE_ARRAY(12,/INT,VALUE=4)], $
        fieldNames:['name','y','m','d','apm','h0','h1','h2','h3','h4','h5','h6','h7','h8','h9','h10','h11'] , $
        fieldLocations:[0,7,11,13,16,21,26,31,36,41,46,51,56,61,66,71,76]    , $
        fieldGroups:INDGEN(17) $
      }

mtm  = {version:1.0,$
        datastart:1   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:''   ,$
        fieldcount:18 ,$
        fieldTypes:[2,7,2,2,2,2,MAKE_ARRAY(12,/INT,VALUE=4)], $
        fieldNames:['num','name','y','m','d','apm','h0','h1','h2','h3','h4','h5','h6','h7','h8','h9','h10','h11'] , $
        fieldLocations:[0,3,11,15,17,19,20,25,30,35,40,45,50,55,60,65,70,75]    , $
        fieldGroups:INDGEN(18) $
      }

mtm2  = {version:1.0,$
        datastart:1   ,$
        delimiter:''  ,$
        missingvalue:!VALUES.F_NAN  ,$
        commentsymbol:''   ,$
        fieldcount:18 ,$
        fieldTypes:[2,7,2,2,2,2,MAKE_ARRAY(12,/INT,VALUE=4)], $
        fieldNames:['num','name','y','m','d','apm','h0','h1','h2','h3','h4','h5','h6','h7','h8','h9','h10','h11'] , $
        fieldLocations:[0,3,11,15,17,19,20,26,32,38,44,50,56,62,68,74,80,86]    , $
        fieldGroups:INDGEN(18) $
      }

pre  = {version:1.0,$
        datastart:15   ,$
        delimiter:32b   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:2 ,$
        fieldTypes:[5,4], $
        fieldNames:['jul','val'] , $
        fieldLocations:[1,22]    , $
        fieldGroups:[0,1] $
      }

bodc  = {version:1.0,$
        datastart:11   ,$
        delimiter:''   ,$
        missingvalue:!VALUES.F_NAN   ,$
        commentsymbol:';'   ,$
        fieldcount:6 ,$
        fieldTypes:[7,7,4,7,4,7], $
        fieldNames:['num','date','val','flg1','res','flg2'] , $
        fieldLocations:[0,7,27,39,45,52]    , $
        fieldGroups:INDGEN(6) $
      }     

IF (para EQ 'rad') THEN RETURN, rad
IF (para EQ 'uls') THEN RETURN, uls
IF (para EQ 'pbmbr') THEN RETURN, pbmbr
IF (para EQ 'pbm') THEN RETURN, pbm
IF (para EQ 'phynew') THEN RETURN, phynew
IF (para EQ 'blq') THEN RETURN, blq
IF (para EQ 'prd') THEN RETURN, prd
IF (para EQ 'bodc') THEN RETURN, bodc
IF (para EQ 'alti') THEN RETURN, alti
IF (para EQ 'test') THEN RETURN, test
IF (para EQ 'lst') THEN RETURN, lst
IF (para EQ 'list') THEN RETURN, list
IF (para EQ 'ncview') THEN RETURN, ncview
IF (para EQ 'xyz') THEN RETURN, xyz
IF (para EQ 'pre') THEN RETURN, pre
IF (para EQ 'shm') THEN RETURN, shm
IF (para EQ 'rbr') THEN RETURN, rbr
IF (para EQ 'phy1') THEN RETURN, phy1
IF (para EQ 'phy2') THEN RETURN, phy2
IF (para EQ 'phy3') THEN RETURN, phy3
IF (para EQ 'phy4') THEN RETURN, phy4
IF (para EQ 'phytot') THEN RETURN, phytot
IF (para EQ 'phytest') THEN RETURN, phytest
IF (para EQ 'sum') THEN RETURN, sum
IF (para EQ 'obs') THEN RETURN, obs
IF (para EQ 'dateval') THEN RETURN, dateval
IF (para EQ 'dat') THEN RETURN, dat
IF (para EQ 'julval') THEN RETURN, julval
IF (para EQ 'mtm') THEN RETURN, mtm
IF (para EQ 'mtm2') THEN RETURN, mtm2
IF (para EQ 'oiso') THEN RETURN, oiso
IF (para EQ 'latlon') THEN RETURN, latlon
IF (para EQ 'bef') THEN RETURN, bef
IF (para EQ 'lct') THEN RETURN, lct
IF (para EQ 'mto_ddu') THEN RETURN, mto_ddu
IF (para EQ 'mto_ddu2010') THEN RETURN, mto_ddu2010
IF (para EQ 'mto_ddu2010_08') THEN RETURN, mto_ddu2010_08
IF (para EQ 'jma') THEN RETURN, jma
IF (para EQ 'refmar') THEN RETURN, refmar
IF (para EQ 'jmarms') THEN RETURN, jmarms


STOP, '! Template name unknown '
END
