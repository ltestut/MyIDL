

; pour un satellite (topex, jason, envisat, etc..)
; pour un site      (capraia, senetosa, harvest, ....)
; ==> creer un fichier avec les dates de passage
; exemple : 23/03/1993  22 h 36 min  TU 1993/082  cycle  19

; ==> eventuellement, pour un jour donne, sortir le numero du cycle et
; la date de passage


;MODIF OL le 10/10/2008 : rajout de mot clef pour un appel via calc_tropo (non interactif)
;                         sat et pass en entree / cyc et jj en sortie

@setarray_utils.pro

PRO passages,site,date,fin=fin,sat=sat,pass=pass,cyc=cyc_pass,jj=jj_pass

; site : senetosa ou capraia
; date : 0 ou jj date voulue
; exemple : passage 1 de js1 a Senetosa le 18/01/2002 a 12:35:28.99 (19010.5246366)
;          passages,'senetosa',19010
;          passages,'senetosa',19704
; ==> 19704.6196666 (13/12/2003 a 14:52:19)
;
;          passages,'senetosa',19010,fin=21915
;          passages,'lac',22153,fin=22167
;

; Pour ajaccio new orbite faire les deux pass dans le meme fichier,
; puis: sort -k9n -k7 dates_pass_env-orb2_ajaccio.dat


; rep de eric en seconde : 856711.4470d0 pour TP

;modif car lorsque appele par cal_tropo, le site peut-etre figari
if site EQ "figari" then site="SENETOSA"

; pour un site et une date ==> choix satellite et passage
sene = {sat      :['js1','t_p','js2','hy2'],$
        pass     :[85,85,85,364],$
        rep      :[9.91564226d,9.91564226d,9.91564226d,14d],$
        date_orig:[18266.85208d,18266.85208d,18266.85208d,22580.25251157d],$
        cyc_orig :[-74,-74+343,-313,2]}

; Ers passe 30 min apres envisat
ajac = {sat      :['env','ers','env-orb2','env-orb2'],$
        pass     :[130,130,504,150],$
        rep      :[35d,35d,30d,30d],$
        date_orig:[19270.4141079d,19270.4338417d,22352.41666667d,22516.87708333d],$
        cyc_orig :[10,78,100,106]}

; capr = {sat      :['js1','js1','env','env'],$
;         pass     :[44,85,257,588],$
;         rep      :[9.91564226d,9.91564226d,35d,35d],$
;         date_orig:[18266.85208d,18266.85208d,19270.4141079d,19270.4141079d],$
;         cyc_orig :[-74,-74,10,10]}

capr = {sat      :['js1','js1','env','env'],$
        pass     :[44,85,257,588],$
        rep      :[9.91564226d,9.91564226d,35d,35d],$
        date_orig:[19504.6857584,19506.3071871,19270.4141079d,19270.4141079d],$
        cyc_orig :[51,51,10,10]}

bur1 = {sat      :['js1'],$
        pass     :[88],$
        rep      :[9.91564226d],$
        date_orig:[20964.023637d],$
        cyc_orig :[198]}

lak1 = {sat      :['js1','js1-new','js2','env','env','env','env'],$
        pass     :[131,90,131,10,223,554,767],$
        rep      :[9.91564226d,9.91564226d,9.91564226d,35d,35d,35d,35d],$
        date_orig:[20747.55845106d,21623.47529382859954d,20747.55845106d,$
                   21611.2223417905d,21618.67907862871528d,21630.22433153,21637.68105880],$
        cyc_orig :[176,265,-63,77,77,77,77]}

vanu = {sat      :['env','env'],$
        pass     :[303,374],$
        rep      :[35d,35d],$
        date_orig:[20116.4621990740741d,20118.9483449074073d],$
        cyc_orig :[34,34]}

india = {sat      :['env','env'],$
         pass     :[539,840],$
         rep      :[35d,35d],$
         date_orig:[21734.71041667d,21745.22013889d],$
         cyc_orig :[80,80]}


str_sites = {senetosa:sene, ajaccio:ajac, capraia:capr, burnie:bur1, lac:lak1,vanuatu:vanu,indian_ocean:india}

names  = tag_names(str_sites)
n_site = where(names eq strupcase(site))

if (keyword_set(sat) AND keyword_set(pass)) then begin
   n = SETINTERSECTION(where(str_sites.(n_site).sat EQ sat),where(str_sites.(n_site).pass EQ pass))
   n = n[0]
   if (n EQ -1) then return
endif else begin
   print,'choisir entre :'
   for i=0, n_elements(str_sites.(n_site).sat)-1 do begin
      print,i,str_sites.(n_site).sat(i),str_sites.(n_site).pass(i),$
        format="(i2,' : ',a,' passage ',i3.3)"
   end
   read,n
endelse

rep   = str_sites.(n_site).rep(n)
date1 = str_sites.(n_site).date_orig(n) + julday(01,01,1950,0,0,0)
cyc1  = str_sites.(n_site).cyc_orig(n)

jjref = julday(01,01,1950,0,0,0)

if date eq 0 then $
  tab_date     = [systime(/julian)] $
else $
  tab_date     = [double(date) + jjref]

if keyword_set(fin) then $
  tab_date = timegen(start=double(date)+jjref,final=double(fin)+jjref,step_size=rep)


for i=0l, n_elements(tab_date)-1 do begin

   date     = tab_date[i]

   interv   = fix((date - date1)/rep+0.5d)
   jj_pass  = date1 + interv*rep
   cyc_pass = cyc1 + interv

   ;print,cyc_pass,date1,interv,rep,jj_pass,jj_pass-jjref

   caldat,jj_pass , month , day , year, hour, minute, sec
   dyear = jj_pass - julday(01,01,year,0,0,0) + 1

   print,day,month,year,hour,minute,year,dyear,cyc_pass,$
     format ="(i2.2,'/',i2.2,'/',i4,2x,i2.2,' h ',i2.2,' min  TU ',i4,'/',i3.3,'  cycle ',i4)"
endfor

end

