PRO close_output_format, verbose=verbose, png=png, ps=ps, _EXTRA=_EXTRA

IF KEYWORD_SET(ps) THEN device, /close_file               ; on ferme le fichier PostScript
IF (KEYWORD_SET(png) AND KEYWORD_SET(output)) THEN BEGIN  ; on ecrit un .png sans boite de dialog dans le fichier de sortie output 
   image=TVRead(filename=output,/NODIALOG,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF ELSE IF KEYWORD_SET(png) THEN BEGIN                 ; on ecrit le .png avec ouverture d'une boite de dialog
   image=TVRead(filename=output,/CANCEL,/PNG)
   print,"Ecriture du fichier : ",output
ENDIF

END