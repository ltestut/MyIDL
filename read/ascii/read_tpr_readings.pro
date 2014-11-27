; docformat = 'rst'

FUNCTION use_tpr_template,template
 ;-return a selected template
IF (N_PARAMS() EQ 0) THEN STOP,'use_tpr_template needs one parameter' 
CASE template OF
 'moy_rms' : BEGIN                     ;-template for the moy_rms.txt file
        tmp = {version:1.0,datastart:0,delimiter:'',$
        missingvalue:!VALUES.F_NAN,commentsymbol:'#',$
        fieldcount:4,fieldTypes:[2,7,4,4],$
        fieldNames:['num','jul','moy', 'rms'],$
        fieldLocations:[0,3,23,31],fieldGroups:indgen(4)}
             END
             
ENDCASE
RETURN,tmp
END

FUNCTION read_tpr_readings, filename, template=template, zero=zero
 ;-
 ; build the Kerguelen tide pole readings @1hr
 ; moy = moy + zero
 ;+

IF NOT KEYWORD_SET(filename) THEN filename=!rosame_synchro+'modeme\data\moy_rms.txt'
IF NOT KEYWORD_SET(template) THEN template='moy_rms'
IF NOT KEYWORD_SET(zero)     THEN zero    =0

 ;-read the file
 data  = READ_ASCII(filename,TEMPLATE=use_tpr_template(template))

 ;-create the readings structure and the date vector
 N    = N_ELEMENTS(data.jul)
 st   = create_rms_julval(N)
 date = DBLARR(N)

 ;-cut the string of the date field to build the corresponding date
 READS,data.jul,date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
 PRINT,date[-1],FORMAT='(C())'
 st.jul = date
 st.val = data.moy+zero
 st.rms = data.rms
 RETURN, st
END