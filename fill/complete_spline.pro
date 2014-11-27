PRO complete_spline,tab, NAP, TTAIL
ON_ERROR,2

IF (N_PARAMS() EQ 0) THEN BEGIN
	print,'UTILISATION: complete_spline, tab, NAV-AP, TTAIL'
	print,'Interpole par spline les petis trous (< TTAIL heures)'
	print,'en regardant Nav avant et apres'
RETURN
ENDIF

idt  = WHERE(FINITE(tab,/NAN),nt);;Position des trous de la série, nt=nombre de trou
;;NAP  = 10                        ;Nombre de valeurs prise avant et apres les espaces trouees
;;TTAIL= 5                         ;Taille MAX des trous a combler
I    = 0L
esp  = 0

tabfix=tab        ;;On initialise un tableau de valeur qui ne seront pas remplacer


IF nt EQ 1L THEN BEGIN        ;;si on n'a qu'un trou dans la série
     x_av  = idt(0)-1 - indgen(Nap)
     x_ap  = idt(0)+1 + indgen(Nap)
     x     = [x_av(sort(x_av)),x_ap(sort(x_ap))]          ;;Abscisse avec trous
     x_cplt= [x_av(sort(x_av)),idt[0],x_ap(sort(x_ap))]   ;;Abscisse completee
     ipol  = interpol(tab(x),x,x_cplt)                       ;;interpolation lineaire
     tab(x_cplt)=ipol	
RETURN    
END


icomb=0

WHILE I LT nt-1L DO BEGIN ;; si on a plusieurs trous
     ktc = 0              ;; k trous consecutifs

	     WHILE ((idt(I+1)-idt(I)) EQ 1) DO BEGIN
	     ktc = ktc+1
	     IF (I+1 EQ nt-1) THEN GOTO, jump1
	     I=I+1
	     ENDWHILE

     jump1:
     IF (I+1 EQ nt-1) THEN I=I+1

     esp=esp+1             ;nombre d'espace sans donnees; ktc=taille des espaces     
     print,'ESPACE N°: ',esp,'   nbr de trous consecutifs',ktc+1,idt(I-ktc),'  --->',idt(I)

     x_av  = idt(I-ktc)-1 - indgen(Nap)
     x_ap  = idt(I)+1 + indgen(Nap)
     x     = [x_av(sort(x_av)),x_ap(sort(x_ap))]             ;Abscisse des non-trous
;;     print,'x_init    =',x
     x     = x[where(tabfix(x) ne 999999.000)]
;;     print,'x_nontrous=',x
     x_cplt= [x_av(sort(x_av)),idt[I-ktc:I],x_ap(sort(x_ap))];Abscisse completee
;;     print,'x_complet =',x_cplt

	     IF (idt(I-ktc)-Nap GT 0) THEN BEGIN

		 	
	         IF (ktc+1 LE TTAIL) THEN BEGIN ; pour les petits trous on interpole
	         ipol=interpol(tab(x),x,x_cplt,/spline)
	         tab(x_cplt)=ipol
;;		 print,'tab(x)',tab(x_cplt)	    
		 icomb=icomb+1
		 ENDIF
	    ENDIF
;;	     ENDIF ELSE BEGIN
;;	     tab(x_cplt)=9999.
;;	     ENDELSE		 
             
		 
;;	         ENDIF ELSE BEGIN  ;pour les grands tour on curvefit
;;		 x_trou     = [idt[I-ktc:I]]
;;		 tab(x_trou)= 0.
;;		 print,x_trou
;;		 print,tab(x_trou)
;;		 
;;		   FOR I=0,M-1 DO BEGIN 
;;                   tab(x_trou) = tab(x_trou) + A[2*I]*cos(dpi*fmar[I]*x_trou)+A[2*I+1]*sin(dpi*fmar[I]*x_trou)
;;                   END;;

;;		 ENDELSE
;;	     
;;	     ENDIF ELSE BEGIN
;;	     tab(x_cplt)=0.
;;	     ENDELSE
     I=I+1
 ENDWHILE

print,'Nombre de trous de la serie de depart =',nt
print,'Nombre de trous comble            =',icomb
END
     
