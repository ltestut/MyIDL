FUNCTION sort_mgr, mgr_in, name_list=name_list, ulcase=ulcase, clean=clean, verbose=verbose
;sort the mgr either in alphabetical order or according to a name_list
;if name_list is empty then return the same mgr
IF (N_PARAMS() EQ 0) THEN BEGIN
 PRINT," mgr = sort_mgr(mgr,NAME_LIST=['port_louis','new_york','Bombay'])  =>  sort according to given list"
 PRINT," mgr = sort_mgr(mgr,NAME_LIST='none')                              =>  no sort"
 STOP ," mgr = sort_mgr(mgr)                                               =>  alpabetical sort"
ENDIF


nsta   = N_ELEMENTS(mgr_in)
nwave  = N_ELEMENTS(mgr_in[0].code)
IF KEYWORD_SET(name_list) THEN BEGIN
  IF (name_list[0] EQ 'none') THEN BEGIN ;if name_list is empty return the same mgr
     mgr     = create_mgr(nsta,nwave) 
     j_sort  = INDGEN(nsta)
  ENDIF ELSE BEGIN                       ;if name_list is not empty return the mgr of the given list
     nsta   = N_ELEMENTS(name_list)  
     i_sta  = INTARR(nsta)               ;index of name in the
     FOR i=0,nsta-1 DO BEGIN
        i_sta[i]  = WHERE(mgr_in.name EQ name_list[i])
        IF KEYWORD_SET(verbose) THEN BEGIN
           PRINT,FORMAT='(%"Sation Number %2.0d : search for %-25s ---- find %d")',i,name_list[i],i_sta[i]
        ENDIF
     ENDFOR
     i_valid = WHERE(i_sta NE -1,nvalid,COMPLEMENT=i_unvalid,NCOMPLEMENT=unvalid)
     IF (unvalid GE 1) THEN PRINT,'NOT FOUND IN THE MGR FILE : ',mgr_in[i_valid[i_unvalid]].name 
     mgr     = create_mgr(nvalid,nwave) 
     j_sort  = i_sta[i_valid]
  ENDELSE
ENDIF ELSE BEGIN                          ;if no name_list return the mgr sorted in alphabetical order
  mgr    = create_mgr(nsta,nwave) 
  nwave  = N_ELEMENTS(mgr_in[0].code)
  j_sort = SORT(mgr_in.name)
ENDELSE
name         = mgr_in[j_sort].name
IF KEYWORD_SET(clean) THEN BEGIN
 FOR i=0,N_ELEMENTS(name)-1 DO name[i]=str_replace(name[i],'_','-')
 FOR i=0,N_ELEMENTS(name)-1 DO name[i]=str_replace(name[i],'_','-')
 FOR i=0,N_ELEMENTS(name)-1 DO name[i]=str_replace(name[i],'_','-')
 FOR i=0,N_ELEMENTS(name)-1 DO name[i]=str_replace(name[i],'_','-')
ENDIF
IF NOT KEYWORD_SET(ulcase) THEN mgr.name     = name ELSE mgr.name     = STRLOWCASE(name) 
mgr.origine  = mgr_in[j_sort].origine
mgr.lat      = mgr_in[j_sort].lat
mgr.lon      = mgr_in[j_sort].lon
mgr.val      = mgr_in[j_sort].val
mgr.enr      = mgr_in[j_sort].enr
mgr.nwav     = mgr_in[j_sort].nwav
mgr.filename = mgr_in[j_sort].filename 
mgr.code     = mgr_in[j_sort].code
mgr.wave     = mgr_in[j_sort].wave
mgr.amp      = mgr_in[j_sort].amp
mgr.pha      = mgr_in[j_sort].pha
RETURN, mgr
END