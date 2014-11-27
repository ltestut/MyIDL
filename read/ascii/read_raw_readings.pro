FUNCTION read_raw_readings, filename
; fonction qui permer de lire les fichiers de lectures brutes a l'echelle de maree
; format de la forme :
;# No  Date      Heure    Nobs Q F  Lectures instantanees
;  66 01/11/2009 05:00:00   49 4 0 106.0 103.0 102.0 104.0 102.0 103.0 104. etc ...

IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=READ_RAW_READINGS(filename)'

;Patron de lecture du fichier de configuration 
;---------------------------------------------
cfg = {version:1.0,$
      datastart:13   ,$
      delimiter:''   ,$
      missingvalue:!VALUES.F_NAN   ,$
      commentsymbol:'#'   ,$
      fieldcount:55 ,$
      fieldTypes:[2,7,2,2,2,MAKE_ARRAY(50,/INT,VALUE=4)], $
      fieldNames:['num','jul','nob','qc', 'flg','r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', $
                                          'r10','r11','r12','r13','r14','r15','r16','r17','r18','r19', $
                                          'r20','r21','r22','r23','r24','r25','r26','r27','r28','r29', $
                                          'r30','r31','r32','r33','r34','r35','r36','r37','r38','r39', $
                                          'r40','r41','r42','r43','r44','r45','r46','r47','r48','r49','r50'] , $
;                 .(0)  .(1)   .(2)  .(3) .(4)     
      fieldLocations:[0,3,23,28,30,33+indgen(50)*6], $
      fieldGroups:indgen(55) $
      }

; Read the raw data file
data  = READ_ASCII(filename,TEMPLATE=cfg)

      
; Create the raw_readings structure 
        N    = N_ELEMENTS(data.jul) 
        st   = create_readings(N,/RAW)
        date = DBLARR(N)
           
; Cut the string of the date field to build the corresponding date 
READS,data.jul[0:N-1],date,FORMAT='(C(CDI2,X,CMOI2,X,CYI4,X,CHI2,X,CMI2,X,CSI2))'
print,date[N-1],FORMAT='(C())'
st.jul = date        

; Read the number of the reading (num), the number of observation (nob) and the a priori quality control (qc)
st.num       = data.num
st.nob       = data.nob
st.qc        = data.qc
st.flg       = data.flg
FOR i=0,N-1 DO BEGIN
st[i].val = [data.r1(i), data.r2(i), data.r3(i), data.r4(i), data.r5(i), data.r6(i), data.r7(i), data.r8(i), data.r9(i), $
                data.r10(i),data.r11(i),data.r12(i),data.r13(i),data.r14(i),data.r15(i),data.r16(i),data.r17(i),data.r18(i),data.r19(i), $
                data.r20(i),data.r21(i),data.r22(i),data.r23(i),data.r24(i),data.r25(i),data.r26(i),data.r27(i),data.r28(i),data.r29(i), $
                data.r30(i),data.r31(i),data.r32(i),data.r33(i),data.r34(i),data.r35(i),data.r36(i),data.r37(i),data.r38(i),data.r39(i), $
                data.r40(i),data.r41(i),data.r42(i),data.r43(i),data.r44(i),data.r45(i),data.r46(i),data.r47(i),data.r48(i),data.r49(i),data.r50(i)]
END
RETURN, st
END