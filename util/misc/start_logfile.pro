PRO start_logfile, file=file
; permet d'ouvrir un logfile
IF (!VERSION.OS EQ 'Win32') THEN root="C:\Documents and Settings\TESTUT\Bureau\" ELSE root='/home/testut/Desktop/'
logdate=string(strmid(systime(0),8,2),format='(i2.2)')+strmid(systime(0),4,3)+strmid(systime(0),22,2)
IF NOT KEYWORD_SET(file) THEN file=root+'log_'+logdate+'.txt'

;if file_test(file) then print,'Log file found. no logging'
;if not file_test(file) then print,'Beginning log file...' & journal,file
print,'Beginning log file...' & journal,file
PRINT,"START_LOGILE :",file
END