;+
; :Description:
;    creation des archives .sav des fichiers sections d'une simulation tugo
;
; :Params:
;    filename : nom du fichier d'input de tugo sections.dat
;
; :Keywords:
;    section_path : repertoire de stockage des fichiers section.*
;    origine      : origine de la simulation (ex: origine='mertz_b9b1')
;
; :Author: TESTUT
;-
PRO make_tugo_section_arx, filename, section_path=section_path, origine=origine
; procedure de creation des archives .sav des fichiers samples d'un simulation tugo

IF NOT KEYWORD_SET(section_path) THEN section_path='/media/usb_data_idl/data/model/mto/tugo/mertz/b9b1/section/'
IF NOT KEYWORD_SET(origine) THEN origine='mertz_b9b1_mto'

 ;recherche des fichiers section dans le repertoire
section_files   = FILE_SEARCH(section_path,'*section*',count=nfiles)

sec = read_all_section(section_files,ORIGINE=origine)

; creation et ecrire du fichier d'archive .sav
sav_descr = "sec => sec@simu_mertz from b9b1 t-ugom [mto] dt=6mn"
sav_rep   = !idl_sample_arx+'mertz/tugo_section_mto_b9b1.sav'
SAVE, sec, DESCRIPTION=sav_descr,file=sav_rep
PRINT,sav_descr
PRINT,sav_rep
END