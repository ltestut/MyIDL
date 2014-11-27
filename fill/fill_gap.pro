FUNCTION fill_gap_julval,st,st_ref
ON_ERROR,2

;Interpolation lineaire de la structure st sur la base de temps st_ref


IF (N_PARAMS() EQ 0) THEN STOP, 'UTILISATION:  st=interpol_julval(st,st_ref)'

sti=create_julval(N_ELEMENTS(st_ref.jul))

sti.jul = st_ref.jul
sti.val = INTERPOL(st.val,st.jul,st_ref.jul)


RETURN,sti
;; Derniere modif: le 05/12/2006
END

