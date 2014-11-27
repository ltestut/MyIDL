PRO make_chrono, st, gap_size=gap_size, file_out=file_out, irow=irow, name=name, $
                 color=color, orientation=orientation, verb=verb, concat=concat
; construit un fichier chrono (file_out.txt) a partir d'une structure de type {jul,val}
; on peut tracer ce fichier avec plot_chrono
; il decoupe le chrono des qu'il detecte un tour > a gap_size en heure 
; make_chrono, st, gap_size=1h, file_out='toto.txt'

IF (N_ELEMENTS(irow) EQ 0)       THEN irow=1
IF NOT KEYWORD_SET(color)        THEN color='grey'
IF NOT KEYWORD_SET(name)         THEN name=''
IF NOT KEYWORD_SET(orientation)  THEN orientation='0.'
IF NOT KEYWORD_SET(file_out)     THEN file_out=!txt
IF NOT KEYWORD_SET(gap_size) THEN delta = (1./24.) ELSE delta = (gap_size/24.)

void     = ''
st1      = finite_st(st)
tab_diff = -TS_DIFF(st1.jul,1,/DOUBLE)
Nd       = N_ELEMENTS(tab_diff)
ech_tab  = tab_diff[0:Nd-2]
id_delta = WHERE(ech_tab GT delta,count)
; mode verbeux
IF (count GE 1 AND KEYWORD_SET(verb)) THEN BEGIN
   print,"Nbre de trou = ",count
   print,print_date(st1[id_delta].jul),"taille du trou  ",ech_tab[id_delta]*24.,'  H' 
ENDIF

 ;check file exist
check_file=FILE_INFO(file_out)
fname     = getfilename(file_out)
IF check_file.exists THEN PRINT,"Le fichier : ",fname.name, "  existe" ELSE PRINT,"Creation du fichier ",fname.name

; ouverture et ecriture du fichier de sortie
; ------------------------------------------
   IF (check_file.exists AND KEYWORD_SET(concat)) THEN BEGIN; pour la concatenation
   OPENU,  UNIT, file_out  , /GET_LUN
      print,'concatenation lecture du fichier = ',fname.name
      nlines=FILE_LINES(file_out)
      OPENR, in, file_out, /GET_LUN                            ; on relit et ecrit a nouveau l'existant
      ;print, 'UNTI number / EOF(in) / nline =',in,EOF(in),nlines
      line=''
         WHILE (NOT EOF(in)) DO BEGIN
            READF, in, line
            PRINTF, UNIT, line
         ENDWHILE
      FREE_LUN, in
   ENDIF ELSE BEGIN
   ; ecriture de l'entete du fichier  
   OPENW,  UNIT, file_out  , /GET_LUN
   PRINTF,UNIT,';raw begin               end                 name                color      orientation'
   ENDELSE

      
   IF (count GT 0) THEN BEGIN ; -----------------  si + de 0 trou   
   PRINTF,UNIT,FORMAT='(I2,3X,A19,X,A19,X,A-19,X,A-10,X,A-19)',irow,print_date(st1[0].jul,/SINGLE),$
                                                                    print_date(st1[id_delta[0]].jul,/SINGLE),$
                                                                    void,color,void
      IF (count GT 2) THEN BEGIN 
        FOR I=0,count-2 DO BEGIN
        PRINTF,UNIT,FORMAT='(I2,3X,A19,X,A19,X,A-19,X,A-10,X,A-19)',irow,print_date(st1[id_delta[I]+1].jul,/SINGLE),$
                                                                    print_date(st1[id_delta[I+1]].jul,/SINGLE),$
                                                                    void,color,void
         ENDFOR
      ENDIF

   PRINTF,UNIT,FORMAT='(I2,3X,A19,X,A19,X,A-19,X,A-10,X,A-19)',irow,print_date(st1[id_delta[count-1]+1].jul,/SINGLE),$
                                                                    print_date(st1[Nd-1].jul,/SINGLE),$
                                                                    name,color,orientation
   ENDIF ELSE BEGIN          ; -----------------  si pas de trou
   PRINTF,UNIT,FORMAT='(I2,3X,A19,X,A19,X,A-19,X,A-10,X,A-19)',irow,print_date(st1[0].jul,/SINGLE),$
                                                                    print_date(st1[Nd-1].jul,/SINGLE),$
                                                                    name,color,orientation
   ENDELSE     
     
FREE_LUN, UNIT
CLOSE, UNIT
IF KEYWORD_SET(verb) THEN print,"Ecriture du fichier chrono dans  ==>",file_out
END
