;+
; :Description:
;    creation des archives .sav des fichiers samples d'une simulation tugo
;
; :Params:
;    filename : nom du fichier d'input de tugo tugo.sample ou plot.input
;
; :Keywords:
;    sample_path : repertoire de stockage des fichiers sample.*
;    origine     : origine de la simulation (ex: origine='mertz_b9b1')
;
; :Author: TESTUT
;-
PRO make_tugo_sample_arx, filename, sample_path=sample_path, origine=origine
; procedure de creation des archives .sav des fichiers samples d'un simulation tugo

IF NOT KEYWORD_SET(sample_path) THEN sample_path='F:\data\model\tides\tugo\mertz\b9b1\sample\tide\'
IF NOT KEYWORD_SET(origine) THEN origine='mertz_b9b1'

 ;lecture du fichier de configuration de la simulation
init_sample = read_sample_init(filename)

 ;recherche des fichiers sample dans le repertoire
sample_files   = FILE_SEARCH(sample_path,'*sample*',count=nfiles)

spl = read_all_sample(sample_files,INIT=filename,ORIGINE=origine)

; creation et ecrire du fichier d'archive .sav
sav_descr = "spl => spl@simu_phyan from t-ugom [meteo] dt=1mn"
sav_rep   = !idl_sample_arx+'nindian/tugo_sample_mto_phyan.sav'
SAVE, spl, DESCRIPTION=sav_descr,file=sav_rep
PRINT,sav_descr
PRINT,sav_rep
END