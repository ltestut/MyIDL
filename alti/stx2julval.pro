FUNCTION stx2julval, stx, pt=pt, sla=sla, detided=detided, tide=tide, scale=scale, pvalid=pvalid
; extraction d'un point de la trace et renvoie dans une structure de type julval
; pvalid=80. ;pourcentage minimum pour l'extraction de la serie
IF NOT KEYWORD_SET(pvalid) THEN pvalid=10.

IF NOT KEYWORD_SET(scale) THEN scale=100.

IF (stx.pt[pt].valid GT pvalid) THEN BEGIN
  date =  stx.pt[pt].jul
  val  = (stx.pt[pt].sla+stx.pt[pt].tide+stx.pt[pt].dac)*scale    ; serie brute en cm (signal total)
  IF KEYWORD_SET(sla) THEN BEGIN
    val  =  stx.pt[pt].sla*scale                ; sla (corrige du BI et de la maree) (en cm)
    PRINT,'STX2JULVAL     : Niveau de la mer corrige de la maree et de la DAC'
  ENDIF
  IF KEYWORD_SET(detided) THEN BEGIN
    val  =  (stx.pt[pt].sla+stx.pt[pt].dac)*scale ; serie corrige de la maree seulement (en cm)
    PRINT,'STX2JULVAL     : Niveau de la mer corrige de la maree seulement'
  ENDIF
  IF KEYWORD_SET(tide) THEN BEGIN
    val  =  (stx.pt[pt].sla+stx.pt[pt].tide)*scale ; serie corrige de la maree seulement (en cm)
    PRINT,'STX2JULVAL     : Niveau de la mer corrige de la DAC seulement'
  ENDIF
  inan = WHERE(FINITE(val),cpt)
  IF (cpt GT 0) THEN BEGIN
   st=create_julval(cpt)
   st.jul=date[inan]
   st.val=val[inan] 
  ENDIF ELSE BEGIN
   STOP,"No data for this point : ",pt
  ENDELSE
ENDIF ELSE BEGIN
   STOP,"Not enough data for this point : ",pvalid
ENDELSE 
RETURN,st
END
