;--------------------------------------------------------------------
;+
; :Description:
;    Generate Multiple Aspects of Model Performance in a Single Diagram
;    Taylor, K. E., J. Geophys. Res., 106, D7, 7183-7192, 2001
;
; :Params:
;   This expects one or more datasets. The left dimension 
;   is the number of datasets. The rightmost is the number of pts.
;
;   By default, the function can handle up to 9 variable comparisons..
;   To expand ...  modify the 'markers' and 'markers_colors' attributes.
;   The user can change / add some default settings.
;
;    RATIO - (M, N) array of Standard Deviations (M datasets, N measurements)
;    
;    CC - (M, N) array of Correlations  (M datasets, N measurements)
;    
;    in_rOpts - structure of additional options
;
;  :Requires:
;     cgColor.pro by David Fanning
;
; :Returns:
;   IDLgrView object 
;    
; :Examples:
;;**********************************
;; based on taylor_1.ncl (http://www.ncl.ucar.edu/Applications/Scripts/taylor_1.ncl)
;;**********************************
;
;pro taylorDiagTest
;
;;**********************************
;; All cross correlation values are 0.0 to 1.0 [inclusive]
;;**********************************
;
;; "p" dataset
;                   
;  p_rat    = [1.230, 0.988, 1.092, 1.172, 1.064, 0.966, 1.079, 0.781]
;
;  p_cc     = [0.958, 0.973, 0.740, 0.743, 0.922, 0.982, 0.952, 0.433]
;  
;; "t" dataset
;
;  t_rat    = [1.129, 0.996, 1.016, 1.134, 1.023, 0.962, 1.048, 0.852]
;  
;  t_cc     = [0.963, 0.975, 0.801, 0.814, 0.946, 0.984, 0.968, 0.647]
;
;  nDataSets  = 2                               ; number of datasets
;  
;  npts       = size(p_rat, /dim)
;  
;  ratio      = fltarr(nDataSets, npts)
;  
;  cc         = fltarr(nDataSets, npts)
;
;  ratio[0,*] = p_rat
;  
;  cc[0,*]    = p_cc 
;
;  ratio[1,*] = t_rat
;  
;  cc[1,*]    = t_cc
;   
;;**********************************
;; create plot
;;**********************************
;
;  var = ["SLP","Tsfc","Prc","Prc 30S-30N","LW","SW","U300","Guess"]
;   
;  oWindow = obj_new('IDLgrWindow', dimensions=[900, 900], title='Taylor')
;
;  opts   = {fontSize:18, normalizedSD:0, refRad:1.0, stnRad:[0.25, 0.5, 0.75, 1.25], centerDiffRMS:1, ccRays:[0.6, 0.9], $
;            caseLabels:['Case A', 'Case B'], mainTitle:'Example Taylor diagram', varLabels:var}
;
;  plot  = taylor_diagram(ratio, cc, opts)
;
;  oWindow->Erase
;  
;  oWindow->Draw, plot
;    
;end
;    
; :Author: Igor Okladnikov
;-
;--------------------------------------------------------------------
; Auxiliary functions
;--------------------------------------------------------------------
function isatt, inStruct, inTag
  if (n_elements(inStruct) eq 0) then return, 0
  if (size(inStruct, /type) ne size({a:0}, /type)) then return, 0
  pos = where(tag_names(inStruct) eq strupcase(inTag))
  return, pos ne -1
end
;--------------------------------------------------------------------
function fspan, min, max, n
  return, findgen(n)/(n-1)*(max-min)+min
end
;--------------------------------------------------------------------
;; This function is an extraction from FSC_COLOR.PRO function by David Fanning.
;; Not used anymore.
;--------------------------------------------------------------------
;FUNCTION getColor, theColor, colorIndex, Triple=triple, Decomposed=decomposedState
;
;   ; Make sure you have a color name and color index.
;
;CASE N_Elements(theColor) OF
;   0: BEGIN
;      theColor = 'White'
;      IF N_Elements(colorIndex) EQ 0 THEN colorIndex = !P.Color < (!D.Table_Size - 1) $
;         ELSE colorIndex = 0 > colorIndex < (!D.Table_Size - 1)
;      ENDCASE
;
;   1: BEGIN
;         type = Size(theColor, /TNAME)
;         IF type NE 'STRING' THEN Message, 'The color must be expressed as a color name.'
;         IF N_Elements(colorIndex) EQ 0 THEN colorIndex = !P.Color < (!D.Table_Size - 1) $
;            ELSE colorIndex = 0 > colorIndex < (!D.Table_Size - 1)
;         ENDCASE
;
;   ELSE: BEGIN
;         type = Size(theColor, /TNAME)
;         IF type NE 'STRING' THEN Message, 'The colors must be expressed as color names.'
;         ncolors = N_Elements(theColor)
;         CASE N_Elements(colorIndex) OF
;            0: colorIndex = Indgen(ncolors) + (!D.Table_Size - (ncolors + 1))
;            1: colorIndex = Indgen(ncolors) + colorIndex
;            ELSE: IF N_Elements(colorIndex) NE ncolors THEN $
;               Message, 'Index vector must be the same length as color name vector.'
;         ENDCASE
;
;            ; Did the user want color triples?
;
;         IF Keyword_Set(triple) THEN BEGIN
;            colors = LonArr(3, ncolors)
;            FOR j=0,ncolors-1 DO colors[*, j] = getColor(theColor[j], colorIndex[j], $
;               Decomposed=decomposedState, /Triple)
;            RETURN, colors
;         ENDIF ELSE BEGIN
;            colors = LonArr(ncolors)
;            FOR j=0,ncolors-1 DO colors[j] = getColor(theColor[j], colorIndex[j], $
;               Decomposed=decomposedState)
;            RETURN, colors
;        ENDELSE
;      END
;ENDCASE
;
;   ; Make sure the color parameter is an uppercase string.
;
;varInfo = Size(theColor)
;IF varInfo[varInfo[0] + 1] NE 7 THEN $
;   Message, 'The color name parameter must be a string.', /NoName
;theColor = StrUpCase(StrCompress(StrTrim(theColor,2), /Remove_All))
;
;   ; Check synonyms of color names.
;
;IF StrUpCase(theColor) EQ 'GREY' THEN theColor = 'GRAY'
;IF StrUpCase(theColor) EQ 'LIGHTGREY' THEN theColor = 'LIGHTGRAY'
;IF StrUpCase(theColor) EQ 'MEDIUMGREY' THEN theColor = 'MEDIUMGRAY'
;IF StrUpCase(theColor) EQ 'SLATEGREY' THEN theColor = 'SLATEGRAY'
;IF StrUpCase(theColor) EQ 'DARKGREY' THEN theColor = 'DARKGRAY'
;IF StrUpCase(theColor) EQ 'AQUA' THEN theColor = 'AQUAMARINE'
;IF StrUpCase(theColor) EQ 'SKY' THEN theColor = 'SKYBLUE'
;IF StrUpCase(theColor) EQ 'NAVY BLUE' THEN theColor = 'NAVY'
;IF StrUpCase(theColor) EQ 'NAVYBLUE' THEN theColor = 'NAVY'
;
; ; Set up the color vectors.
;
;colors = ['White']
;rvalue = [ 255]
;gvalue = [ 255]
;bvalue = [ 255]
;colors = [ colors,       'Snow',     'Ivory','Light Yellow',   'Cornsilk',      'Beige',   'Seashell' ]
;rvalue = [ rvalue,          255,          255,          255,          255,          245,          255 ]
;gvalue = [ gvalue,          250,          255,          255,          248,          245,          245 ]
;bvalue = [ bvalue,          250,          240,          224,          220,          220,          238 ]
;colors = [ colors,      'Linen','Antique White',    'Papaya',     'Almond',     'Bisque',  'Moccasin' ]
;rvalue = [ rvalue,          250,          250,          255,          255,          255,          255 ]
;gvalue = [ gvalue,          240,          235,          239,          235,          228,          228 ]
;bvalue = [ bvalue,          230,          215,          213,          205,          196,          181 ]
;colors = [ colors,      'Wheat',  'Burlywood',        'Tan', 'Light Gray',   'Lavender','Medium Gray' ]
;rvalue = [ rvalue,          245,          222,          210,          230,          230,          210 ]
;gvalue = [ gvalue,          222,          184,          180,          230,          230,          210 ]
;bvalue = [ bvalue,          179,          135,          140,          230,          250,          210 ]
;colors = [ colors,       'Gray', 'Slate Gray',  'Dark Gray',   'Charcoal',      'Black', 'Light Cyan' ]
;rvalue = [ rvalue,          190,          112,          110,           70,            0,          224 ]
;gvalue = [ gvalue,          190,          128,          110,           70,            0,          255 ]
;bvalue = [ bvalue,          190,          144,          110,           70,            0,          255 ]
;colors = [ colors,'Powder Blue',   'Sky Blue', 'Steel Blue','Dodger Blue', 'Royal Blue',       'Blue' ]
;rvalue = [ rvalue,          176,          135,           70,           30,           65,            0 ]
;gvalue = [ gvalue,          224,          206,          130,          144,          105,            0 ]
;bvalue = [ bvalue,          230,          235,          180,          255,          225,          255 ]
;colors = [ colors,       'Navy',   'Honeydew', 'Pale Green','Aquamarine','Spring Green',       'Cyan' ]
;rvalue = [ rvalue,            0,          240,          152,          127,            0,            0 ]
;gvalue = [ gvalue,            0,          255,          251,          255,          250,          255 ]
;bvalue = [ bvalue,          128,          240,          152,          212,          154,          255 ]
;colors = [ colors,  'Turquoise', 'Sea Green','Forest Green','Green Yellow','Chartreuse', 'Lawn Green' ]
;rvalue = [ rvalue,           64,           46,           34,          173,          127,          124 ]
;gvalue = [ gvalue,          224,          139,          139,          255,          255,          252 ]
;bvalue = [ bvalue,          208,           87,           34,           47,            0,            0 ]
;colors = [ colors,      'Green', 'Lime Green', 'Olive Drab',     'Olive','Dark Green','Pale Goldenrod']
;rvalue = [ rvalue,            0,           50,          107,           85,            0,          238 ]
;gvalue = [ gvalue,          255,          205,          142,          107,          100,          232 ]
;bvalue = [ bvalue,            0,           50,           35,           47,            0,          170 ]
;colors = [ colors,      'Khaki', 'Dark Khaki',     'Yellow',       'Gold','Goldenrod','Dark Goldenrod']
;rvalue = [ rvalue,          240,          189,          255,          255,          218,          184 ]
;gvalue = [ gvalue,          230,          183,          255,          215,          165,          134 ]
;bvalue = [ bvalue,          140,          107,            0,            0,           32,           11 ]
;colors = [ colors,'Saddle Brown',       'Rose',       'Pink', 'Rosy Brown','Sandy Brown',       'Peru' ]
;rvalue = [ rvalue,          139,          255,          255,          188,          244,          205 ]
;gvalue = [ gvalue,           69,          228,          192,          143,          164,          133 ]
;bvalue = [ bvalue,           19,          225,          203,          143,           96,           63 ]
;colors = [ colors,  'Indian Red',  'Chocolate',     'Sienna','Dark Salmon',    'Salmon','Light Salmon' ]
;rvalue = [ rvalue,          205,          210,          160,          233,          250,          255 ]
;gvalue = [ gvalue,           92,          105,           82,          150,          128,          160 ]
;bvalue = [ bvalue,           92,           30,           45,          122,          114,          122 ]
;colors = [ colors,     'Orange',      'Coral', 'Light Coral',  'Firebrick',      'Brown',  'Hot Pink' ]
;rvalue = [ rvalue,          255,          255,          240,          178,          165,          255 ]
;gvalue = [ gvalue,          165,          127,          128,           34,           42,          105 ]
;bvalue = [ bvalue,            0,           80,          128,           34,           42,          180 ]
;colors = [ colors,  'Deep Pink',    'Magenta',     'Tomato', 'Orange Red',        'Red', 'Violet Red' ]
;rvalue = [ rvalue,          255,          255,          255,          255,          255,          208 ]
;gvalue = [ gvalue,           20,            0,           99,           69,            0,           32 ]
;bvalue = [ bvalue,          147,          255,           71,            0,            0,          144 ]
;colors = [ colors,     'Maroon',    'Thistle',       'Plum',     'Violet',    'Orchid','Medium Orchid']
;rvalue = [ rvalue,          176,          216,          221,          238,          218,          186 ]
;gvalue = [ gvalue,           48,          191,          160,          130,          112,           85 ]
;bvalue = [ bvalue,           96,          216,          221,          238,          214,          211 ]
;colors = [ colors,'Dark Orchid','Blue Violet',     'Purple' ]
;rvalue = [ rvalue,          153,          138,          160 ]
;gvalue = [ gvalue,           50,           43,           32 ]
;bvalue = [ bvalue,          204,          226,          240 ]
;
;   ; How many colors do we have?
;
;ncolors = N_Elements(colors)
;
;   ; Process the color names.
;
;theNames = StrUpCase( StrCompress( StrTrim( colors, 2 ), /Remove_All ) )
;
;   ; Find the asked-for color in the color names array.
;
;theIndex = Where(theNames EQ theColor, foundIt)
;theIndex = theIndex[0]
;
;   ; If the color can't be found, report it and continue with
;   ; the first color in the color names array.
;
;IF foundIt EQ 0 THEN BEGIN
;   Message, "Can't find color " + theColor + ". Substituting " + StrUpCase(colors[0]) + ".", /Informational
;   theColor = theNames[0]
;   theIndex = 0
;ENDIF
;
;   ; Get the color triple for this color.
;
;r = rvalue[theIndex]
;g = gvalue[theIndex]
;b = bvalue[theIndex]
;
;   ; Did the user want a color triple? If so, return it now.
;
;IF Keyword_Set(triple) THEN BEGIN
;   RETURN, [r, g, b]
;ENDIF
;
;   ; Otherwise, we are going to return either an index
;   ; number where the color has been loaded, or a 24-bit
;   ; value that can be decomposed into the proper color.
;
;IF N_Elements(decomposedState) EQ 0 THEN BEGIN
;   IF Float(!Version.Release) GE 5.2 THEN BEGIN
;      IF (!D.Name EQ 'X' OR !D.Name EQ 'WIN' OR !D.Name EQ 'MAC') THEN BEGIN
;         Device, Get_Decomposed=decomposedState
;      ENDIF ELSE decomposedState = 0
;   ENDIF ELSE decomposedState = 0
;ENDIF ELSE decomposedState = Keyword_Set(decomposedState)
;
;   ; Return the color value or values.
;
;IF decomposedState THEN BEGIN
;
;      ; Need a color structure?
;  
;  RETURN, r + (g * 2L^8) + (b * 2L^16)
;
;ENDIF ELSE BEGIN
;
;      IF N_Elements(colorIndex) EQ 0 THEN colorIndex = !D.Table_Size - ncolors - 1
;      IF colorIndex LT 0 THEN $
;         Message, 'Number of colors exceeds available color table values. Returning.', /NoName
;      IF (colorIndex + ncolors) GT 255 THEN $
;         Message, 'Number of colors exceeds available color table indices. Returning.', /NoName
;      IF !D.Name NE 'PRINTER' THEN TVLCT, rvalue, gvalue, bvalue, colorIndex
;      RETURN, IndGen(ncolors) + colorIndex
;
;ENDELSE
;
;END 
;--------------------------------------------------------------------
function taylor_diagram, RATIO, CC, in_rOpts
;--------------------------------------------------------------------
; The defaults that the user can modify through input structure "in_rOpts":
;;
; rOpts.fontSize            = 12
; rOpts.yAxisTitle          = "Standard Deviations (Normalized)"
; rOpts.MainTitle           = ''
; rOpts.MainTitleSize       = rOpts.FontSize + 4
; rOpts.refRad              = 1.0
; rOpts.stnRad              = []
; rOpts.drawCorLabel        = 1
; rOpts.ccRays              = []
; rOpts.ccRays_color        = "Black"
; rOpts.centerDiffRMS       = 0
; rOpts.centerDiffRMS_color = "Black"
; rOpts.markers             = [ 4, 6, 5, 2, 1, 7, 8, 9, 3, 10, 11, 12, 13, 14 ]
; rOpts.markers_colors      = [ "red", "blue", "green", "cyan", "orange", "brown", "yellow", "purple", "black" ]
; rOpts.markerThickness     = 2.0
; rOpts.markerSize          = 0.013
; rOpts.markerFontSize      = rOpts.FontSize - 5
; rOpts.markerTxYOffset     = xyMax*0.035
; rOpts.markerText          = 1
; rOpts.caseLabels          = []         
; rOpts.caseLabelsFontSize  = rOpts.fontSize - 3
; rOpts.varLabels           = []
; rOpts.varLabelsFontSize   = rOpts.fontSize - 3
; rOpts.varLabelsDy         = 0.05
; rOpts.varLabelsYloc       = max( [nVarLabels*rOpts.varLabelsDy, xyMax*0.91] ) - tries to put in the top left corner
; ropts.arrows              = 0
; ropts.skillType           = 0 (types available: 0, 1)
; rOpts.skillR0             = 0.99
; rOpts.skill_color         = "Black"
; rOpts.skillThickness      = 1.0
;;
; It returns to the user a IDLgrView object containing the 
; Taylor diagram's axes, background and plotted x/y points.
; This graphic object contains a simple Taylor diagram appropriate 
; for standardized data and the markers for the datasets.
; ==================================================================
;; Disclamer
;
; This IDL function is based on NCL function which can be found here: 
; http://www.ncl.ucar.edu/Applications/Scripts/taylor_diagram.ncl.
; It uses cgColor.pro by David Fanning to convert color names into indices.
; 
; The function taylor_diagram and all auxiliary functions are provided AS IS. 
; Which means I'm NOT responsible for any health, software or hardware 
; damage/injure caused due to the using of this function, as well 
; as for any wrong scientific results obtained.
; 
; This function is distributed absolutely free of charge and can be
; modified by anyone to satisfy additional requirements.
; (c) Igor Okladnikov, 2011. E-mail: oig(at)scert.ru.
; ==================================================================
;begin
  if (n_elements(in_rOpts) ne 0) then rOpts = in_rOpts else rOpts = 0
  
  False                 = 0
  True                  = 1
  dimR                  = size( RATIO, /dim )
  nCase                 = dimR(0)    ; # of cases [models] 
  nVar                  = dimR(1)    ; # of variables

                                     ; x/y coordinates for plotting
  X    = make_array( nCase, nVar, type = size( RATIO, /type ) )
  Y    = make_array( nCase, nVar, type = size( RATIO, /type ) )

  for nc = 0, nCase-1 do begin
     angle      = acos( CC(nc, *) )   ; array operation                                    
     X[nc, *]    = RATIO[nc, *] * cos( angle )     
     Y[nc, *]    = RATIO[nc, *] * sin( angle )    
  endfor

  defaultYTitle      = "Standard Deviation"

  if (isatt(rOpts,"refPoint")) then begin 
      refPoint       = rOpts.refPoint    ; user wants to specify size
  endif else begin
      refPoint       = 1.0
  endelse

  xyMin                 = 0 ; min(RATIO)
  xyMax                 = round(max(RATIO)*1.1/0.5)*0.5
  
  xyOne                 = 1.00
  trXoffset             = xyMax*0.16
  trYoffset             = xyMax*0.12             ; xyMax*0.07
  xyMax_Panel           = xyMax*1.25             ; paneling purposes
 
  if (isatt(rOpts,"fontSize")) then begin 
      FontHeightF       = rOpts.FontSize    ; user wants to specify size
  endif else begin
      FontHeightF       = 12
  endelse
 
; ----------------------------------------------------------------
; Part 1:
; base plot: Based upon request of Mark Stevens
; basic x-y and draw the 1.0 observed and the outer curve at 1.65
; ----------------------------------------------------------------
    
  if (isatt(rOpts,"YAxisTitle")) then begin 
    tiYAxisString       = rOpts.YAxisTitle    ; user wants to specify size
  endif else begin
    tiYAxisString     = defaultYTitle
  endelse
  tiYAxisFontHeightF = FontHeightF                        ; default=0.025 
  
;  tmXBValues        = [0.0, 0.25, 0.50, 0.75, 1.00, 1.25, 1.5]    ; major tm
  if (xyMax lt 1.5) then begin
    roundFactor = 0.125
    labelFormat = '(f6.3)'
  endif
  if ((xyMax ge 1.5) and (xyMax le 10)) then begin
    roundFactor = 0.25
    labelFormat = '(f5.2)'
  endif
  if (xyMax gt 10) then begin
    roundFactor = 0.5
    labelFormat = '(f4.1)'
  endif
    
  tmXBValues        = floor(findgen(7)*xyMax/6.0/roundFactor)*roundFactor
  tmXBLabels         = string(tmXBValues, format=labelFormat)
  
  tmXBMajorLengthF  = 0.02      ; default=0.02 for a vpHeightF=0.6
  tmXBLabelFontHeightF = FontHeightF
  tmXBMinorOn       = False
  trXMaxF           = xyMax_Panel

  tmYLMinorOn       = False
  tmYLMajorLengthF  = tmXBMajorLengthF
  tmYLLabelFontHeightF = FontHeightF
  tmYLValues        = tmXBValues ; [0.0, .25,0.50, 0.75, 1.00, 1.25, 1.5] ; major tm
  tmYLLabels        = tmXBLabels ; ['0.00','0.25','0.50','0.75','1.00','1.25','1.50']
  tmXBLabels[0] = '    '
  tmXBLabels[6] = '    '
  
  trYMaxF           = xyMax_Panel

  xyDashPattern         =  0     ; line characteristics (dash,solid)
  xyLineThickness       =  2.    ; choose line thickness

  ; create outer 'correlation axis'
  npts    = 200                        ; arbitrary
  xx      = fspan(xyMin,xyMax,npts) 
  yy      = sqrt(xyMax^2 - xx^2)   ; outer correlation line (xyMax)

  sLabels = ['0.0','0.1','0.2','0.3','0.4','0.5','0.6', $ ; correlation labels
             '0.7','0.8','0.9','0.95','0.99','1.0']; also, major tm
  
  cLabels = float(sLabels)
  rad     = 4.*atan(1.0)/180.
  angC    = acos(cLabels)/rad                     ; angles: correlation labels
  tiMainString = ''                                                                 
  if (isatt(rOpts,"MainTitle")) then begin
      tiMainString      = rOpts.MainTitle
      if (isatt(rOpts,"MainTitleSize")) then begin
           tiMainFontHeightF = rOpts.MainTitleSize
      endif else begin
           tiMainFontHeightF = FontHeightF+4        ; default  0.025              
      endelse
  endif

  oView = obj_new('IDLgrView', viewplane_rect=[0, 0, trXMaxF, trYMaxF])

  oModel = obj_new('IDLgrModel')

  oView->Add, oModel
  oModel->Translate, trXoffset, trYoffset, 0

; outer line  
  oLine = obj_new('IDLgrPlot', xx, yy, linestyle=xyDashPattern, thick=xyLineThickness)
  oModel->Add, oLine
  
; bottom X-axis
  oXBAxis = obj_new('IDLgrAxis', direction=0, minor=tmXBMinorOn, ticklen=tmXBMajorLengthF, tickvalues=tmXBValues, $
    ticktext=obj_new('IDLgrText', tmXBLabels, font=obj_new('IDLgrFont', size=tmXBLabelFontHeightF)), $
    range = [xyMin, xyMax], exact=1, thick=xyLineThickness)
  oModel->Add, oXBAxis

; left Y-axis
  oYLAxis = obj_new('IDLgrAxis', direction=1, minor=tmYLMinorOn, ticklen=tmYLMajorLengthF, tickvalues=tmYLValues, $
    ticktext=obj_new('IDLgrText', tmYLLabels, font=obj_new('IDLgrFont', size=tmYLLabelFontHeightF)), $
    range = [xyMin, xyMax], exact=1, thick=xyLineThickness, $
    title=obj_new('IDLgrText', tiYAxisString, font=obj_new('IDLgrFont', size=tiYAxisFontHeightF)))
  oModel->Add, oYLAxis

; main title
  tiXMainPos = (xyMax-xyMin)/2.0
  tiYMainPos = xyMax*1.09
  oMainTitle = obj_new('IDLgrText', tiMainString, alignment=0.5, vertical_alignment=0.5, $
    locations=[tiXMainPos, tiYMainPos], font=obj_new('IDLgrFont', size=tiMainFontHeightF))
  oModel->Add, oMainTitle

; draw Ref standard radius
  if (isatt(rOpts,"refRad") ) then begin
    xyRef = rOpts.refRad
  endif else begin
    xyRef = 1.0
  endelse

  xx   = fspan(xyMin, xyRef ,npts)                
  yy   = sqrt(xyRef^2 - xx^2)   
  gsLineDashPattern = 1                    ; dashed line pattern
  gsLineThicknessF  = 3  ; line thickness
  dum2 = obj_new('IDLgrPolyline', xx, yy, linestyle=gsLineDashPattern, thick=gsLineThicknessF)
  oModel->Add, dum2 
  
  txRefSymSize = xyMax*0.09
  oCircle = obj_new('IDLgrPlot', [xyRef], [0], symbol=obj_new('IDLgrSymbol', 3, thick=2, size=txRefSymSize))
  oModel->Add, oCircle
                                                  
  if (isatt(rOpts,"stnRad") ) then begin
      gsLineThicknessF  = 1  
      nStnRad = n_elements(rOpts.stnRad)

      dum3 = objarr(nStnRad)
      for n=0, nStnRad-1 do begin
         rr = rOpts.stnRad(n)
         xx = fspan(xyMin, rr ,npts) 
         yy = sqrt(rr^2   - xx^2)   
         dum3[n] = obj_new('IDLgrPolyline', xx, yy, linestyle=gsLineDashPattern, thick=gsLineThicknessF)
         oModel->Add, dum3[n]
      endfor
  endif

  oYLAxis->GetProperty, ticktext=oTickText
  oTickText->GetProperty, font=oTickFont
  oTickFont->GetProperty, name=tmYLLabelFont
  oTickFont->GetProperty, size=tmYLLabelFontHeightF
;; ----------------------------------------------------------------
;; Part 2:
;; Correlation labels
;; ----------------------------------------------------------------
  radC    = xyMax                                  ; for correlation labels
  xC      = radC*cos(angC*rad)
  yC      = radC*sin(angC*rad)
;; added to get some separation
  xC      = xC + 0.012*xyMax*cos(rad*angC)
  yC      = yC + 0.012*xyMax*sin(rad*angC)
;
  txFontHeightF = tmYLLabelFontHeightF               ; match YL 
  tmYLLabelFont = tmYLLabelFont             ; match YL
  txAngleF      = -45.
  xPos          = xyMax*0.78
  yPos          = xyMax*0.78
  if (isatt(rOpts, "drawCorLabel")) then drawCorLabel = rOpts.drawCorLabel else drawCorLabel = 0
  if (~isatt(rOpts,"drawCorLabel") or drawCorLabel) then begin
      oModelCorrTitle = obj_new('IDLgrModel')
      dum4 = obj_new('IDLgrText', "Correlation", align=0.5, vertical_align=0.5, $
        font=obj_new('IDLgrFont', name=tmYLLabelFont, size=FontHeightF))
      oModelCorrTitle->Add, dum4
      oView->Add, oModelCorrTitle
      oModelCorrTitle->Rotate, [0, 0, 1], txAngleF
      oModelCorrTitle->Translate, trXoffset+xPos, trYoffset+yPos, 0
  endif

  gsLineThicknessF = 2.
  
  txHAlign        = 0             ; Default="CenterCenter".
  txVAlign        = 0.5
  txFontHeightF = FontHeightF               ; match YL 

  tmEnd = 0.975
  radTM = xyMax*tmEnd                             ; radius end: major TM 
  xTM   = fltarr( 2 )
  yTM   = fltarr( 2 )

  dum5 = objarr(n_elements(sLabels))
  oModelCorrText = dum5
  dum6 = dum5

  for i=0, n_elements(sLabels)-1 do begin                      ; Loop to draw strings
    txAngleF = angC[i]
    oModelCorrText[i] = obj_new('IDLgrModel')
    dum5[i] = obj_new('IDLgrText', sLabels[i], align=txHAlign, vertical_align=txVAlign, $
     font=obj_new('IDLgrFont', name=tmYLLabelFont, size=FontHeightF))
    oModelCorrText[i]->Add, dum5[i]
    oView->Add, oModelCorrText[i]
    oModelCorrText[i]->Rotate, [0, 0, 1], txAngleF
    oModelCorrText[i]->Translate, trXoffset+xC(i), trYoffset+yC(i), 0
    xTM[0]   = xyMax*cos(angC(i)*rad)             ; major tickmarks at
    yTM[0]   = xyMax*sin(angC(i)*rad)             ; correlation labels
    xTM[1]   = radTM*cos(angC(i)*rad)             
    yTM[1]   = radTM*sin(angC(i)*rad)
    dum6[i] = obj_new('IDLgrPolyline', xTM, yTM, thick=gsLineThicknessF)
    oModel->Add, dum6[i]
  endfor
                                                  ; minor tm locations
  mTM     = [0.05,0.15,0.25,0.35,0.45,0.55,0.65, $ 
             0.75,0.85,0.91,0.92,0.93,0.94,0.96,0.97,0.98]
  angmTM  = acos(mTM)/rad                         ; angles: correlation labels
  radmTM  = xyMax*(1.-(1.-tmEnd)*0.5)             ; radius end: minor TM 

  dum7 = objarr(n_elements(mTM))

  for i=0, n_elements(mTM)-1 do begin             ; manually add tm
    xTM[0]   = xyMax*cos(angmTM(i)*rad)           ; minor tickmarks
    yTM[0]   = xyMax*sin(angmTM(i)*rad)
    xTM[1]   = radmTM*cos(angmTM(i)*rad)          
    yTM[1]   = radmTM*sin(angmTM(i)*rad)
    dum7[i]  = obj_new('IDLgrPolyline', xTM, yTM, thick=gsLineThicknessF)
    oModel->Add, dum7[i]
  endfor
                                                  ; added for Wanli
                                                  
  if ( isatt(rOpts,"ccRays") ) then begin
      angRL = acos(rOpts.ccRays)/rad             ; angles: radial lines

;      rlRes = True
      gsLineDashPattern= 1  ; line pattern
      gsLineThicknessF = 1  ; choose line thickness
      gsLineColor      = 'Black'
      if (isatt(rOpts,"ccRays_color")) then begin
          gsLineColor    =  rOpts.ccRays_color
      endif

      dum8 = objarr(n_elements(angRL))
      for i=0, n_elements(angRL)-1 do begin
         xRL     = xyMax*cos(angRL(i)*rad)
         yRL     = xyMax*sin(angRL(i)*rad)
         dum8[i] = obj_new('IDLgrPolyline', [0, xRL], [0, yRL], linestyle=gsLineDashPattern, thick=gsLineThicknessF, $
;          color = getColor(gsLineColor, /triple))
          color = cgColor(gsLineColor, /triple, /row))
         oModel->Add, dum8[i]
      endfor
  endif

;  
;; ----------------------------------------------------------------
;; Part 3:
;; Concentric about 1.0 on XB axis
;; I think this is correct. Still test mode.
;; ----------------------------------------------------------------
  if (isatt(rOpts, "centerDiffRMS")) then centerDiffRMS = rOpts.centerDiffRMS else centerDiffRMS = 0
  if (isatt(rOpts,"centerDiffRMS") and centerDiffRMS) then begin
;      respl                    = True                ; polyline mods desired
      respl_xyLineThicknessF   = 1.0                 ; line thickness
      respl_xyLineDashPattern  = 2                   ; short dash lines
      respl_gsLineColor        = 'Black'             ; line color     
      if (isatt(rOpts,"centerDiffRMS_color")) then begin
          respl_gsLineColor    =  rOpts.centerDiffRMS_color
      endif
      
      dx   = tmXBValues[2]-tmXBValues[1]
      ncon = 5                                       ; 
      npts = 100                                     ; arbitrary
      ang  = fspan(180,360,npts)*rad

      dum9 = objarr(ncon)
        outxx      = fspan(xyMin,xyMax,npts) 
        outyy      = sqrt(xyMax^2 - outxx^2)   ; outer correlation line (xyMax)
      

      for n=1, ncon do begin 
         rr  = n*dx            ; radius from REF [OBS] abscissa
         xx  = xyRef + rr*cos(ang)
         yy  = abs( rr*sin(ang) )
         maxx = (xyMax^2-rr^2+xyRef^2)/(2*xyRef)
         idx = where((xx ge xyMin) and (xx le maxx))
         if (idx[0] ne -1) then begin
           xx = xx[idx]
           yy = yy[idx]
         endif
         dum9[n-1] = obj_new('IDLgrPolyline', xx, yy, linestyle=respl_xyLineDashPattern, $
;          thick=respl_xyLineThicknessF, color = getColor(respl_gsLineColor, /triple))
          thick=respl_xyLineThicknessF, color = cgColor(respl_gsLineColor, /triple, /row))
         oModel->Add, dum9[n-1]
      endfor
  endif
;; ---------------------------------------------------------------
;; Part 4:
;; generic resources that will be applied to all users data points
;; of course, these can be changed 
;; http://www.ncl.ucar.edu/Document/Graphics/Resources/gs.shtml
;; ---------------------------------------------------------------
  if (isatt(rOpts,"markers")) then begin
      markers = rOpts.markers
  endif else begin
      markers = [ 4, 6, 5, 2, 1, 7, 8, 9, 3, 10, 11, 12, 13, 14 ] ; Marker Indices
  endelse
  
  npts = 20
  rr = 1
  ang  = fspan(0,360,npts)*rad
  circleOne = fltarr(2, npts)
  for i = 0, npts-1 do begin
    circleOne[0, i] = rr*cos(ang[i])
    circleOne[1, i] = rr*sin(ang[i])
  endfor
    
  solidMarkerPattern = { square : [[-1, -1], [-1, 1], [1, 1], [1, -1]], $
                         diamond : [[0, -1], [-1, 0], [0, 1], [1, 0]], $
                         circle : circleOne, $
                         triangleup: [[-1, -1], [0, 1], [1, -1]], $
                         triangledown: [[-1, 1], [1, 1], [0, -1]] $
                       }

  if (isatt(rOpts,"markers_colors")) then begin
      Colors  = rOpts.markers_colors
  endif else begin
      Colors  = [ "red", "blue", "green", "cyan", "orange", "brown", "yellow", "purple", "black" ]
  endelse

  if (isatt(rOpts,"markerThickness")) then begin
      gsMarkerThicknessF = rOpts.markerThickness
  endif else begin
      gsMarkerThicknessF = 2.0
  endelse

  if (isatt(rOpts,"markerSize")) then begin
      gsMarkerSizeF      = rOpts.markerSize
  endif else begin
      gsMarkerSizeF      = xyMax*0.008                  ; 
  endelse

  if (isatt(rOpts,"arrows")) then begin
      arrows = rOpts.arrows
  endif else begin
      arrows = 0
  endelse

;  gsRes = True
  gsRes_gsMarkerThicknessF = gsMarkerThicknessF      ; 
  gsRes_gsMarkerSizeF      = gsMarkerSizeF           ;  

;  ptRes = True                        ; text options for points
;  ptRes_txJust             = "BottomCenter";
  ptRes_txHAlign           = 0.5
  ptRes_txVAlign           = 1.0
  ptRes_txFontThicknessF   = 1.2      ;
  ptRes_txFontHeightF      = FontHeightF-5   ;
  if (isatt(rOpts,"markerFontSize")) then begin
      ptRes_txFontHeightF  = rOpts.markerFontSize
  endif

  markerTxYOffset          = xyMax*0.035   ; default
  if (isatt(rOpts,"markerTxYOffset")) then begin
      markerTxYOffset = rOpts.markerTxYOffset             ; user defined offset
  endif

  if (isatt(rOpts,"markerText")) then begin
      gsMarkerText = rOpts.markerText
  endif else begin
      gsMarkerText = 1
  endelse

  dum10 = objarr((nCase*nVar))
  dum11 = dum10
  
; plot arrows
  if (arrows ne 0) then begin
    oArrows = objarr((nVar))
    oHeads = oArrows
    oModelArrowHead = oArrows
    gsArrowIndex = 8
    gsArrowThickness = 2
    gsArrowSize = xyMax*0.015
    for i=0, nVar-1 do begin
       headAngle = asin((Y[1, i]-Y[0, i])/sqrt((X[1, i]-X[0, i])^2+(Y[1, i]-Y[0, i])^2))/rad
       if (X[1, i] lt X[0, i]) then headAngle = 180-headAngle
       oArrows[i] = obj_new('IDLgrPolyline', [X[0, i], X[1, i]], [Y[0, i], Y[1, i]], linestyle=0, thick=gsArrowThickness)
       oHeads[i] = obj_new('IDLgrPlot', [0], [0], symbol=obj_new('IDLgrSymbol', gsArrowIndex, $
        size=gsArrowSize, thick=gsArrowThickness))
       oModelArrowHead[i] = obj_new('IDLgrModel')
       oView->Add, oModelArrowHead[i]
       oModel->Add, oArrows[i]
       oModelArrowHead[i]->Add, oHeads[i]
       oModelArrowHead[i]->Rotate, [0, 0, 1], headAngle
       oModelArrowHead[i]->Translate, trXoffset+X[1, i], trYoffset+Y[1, i], 0
    endfor
  endif

  for n=0, nCase-1 do begin
    gsRes_gsMarkerColor   = Colors[n]              ; marker color
    ptRes_txFontColor     = gsRes_gsMarkerColor
    if (Markers[n] lt 10) then begin 
      gsRes_gsMarker   = Markers[n]             ; marker style (+)
    endif else begin
;      gsRes_gsMarker = obj_new('IDLgrPolygon', solidMarkerPattern.(Markers[n]-10), color=getColor(gsRes_gsMarkerColor, /triple))
      gsRes_gsMarker = obj_new('IDLgrPolygon', solidMarkerPattern.(Markers[n]-10), color=cgColor(gsRes_gsMarkerColor, /triple, /row))
    endelse
    for i=0, nVar-1 do begin
;       oSymbol=obj_new('IDLgrSymbol', gsRes_gsMarker, color=getColor(gsRes_gsMarkerColor, /triple), $
       oSymbol=obj_new('IDLgrSymbol', gsRes_gsMarker, color=cgColor(gsRes_gsMarkerColor, /triple, /row), $
        thick=gsRes_gsMarkerThicknessF, size=gsRes_gsMarkerSizeF)
       dum10[n*nVar+i] = obj_new('IDLgrPlot', [X[n, i]], [Y[n, i]], linestyle=6, symbol=oSymbol)
       oModel->Add, dum10[n*nVar+i]
;       print, 'X(n,i) = ' + strtrim(string(X(n,i)),2) + ' ' + 'Y(n,i) = ' + strtrim(string(Y(n,i)),2)
       if ((n eq 1) and (arrows ne 0)) then continue 
       if (gsMarkerText eq 1) then begin
         dum11[n*nVar+i] = obj_new('IDLgrText', strtrim(string(i+1), 2), locations=[X[n,i], Y[n,i]+markerTxYOffset], $
          align=ptRes_txHAlign, vertical_align=ptRes_txVAlign, font=obj_new('IDLgrFont', thick=ptRes_txFontThicknessF, $
;          size=ptRes_txFontHeightF), color=getColor(ptRes_txFontColor, /triple))
          size=ptRes_txFontHeightF), color=cgColor(ptRes_txFontColor, /triple, /row))
         oModel->Add, dum11[n*nVar+i]
       endif
    endfor
  endfor

;; ---------------------------------------------------------------
;; Part 5: ; add model skill contours
;; ---------------------------------------------------------------
  if ( isatt(rOpts,"skillType") ) then begin
    skillType = rOpts.skillType

; prepare grid
    n_R = 250L
    n_sigma = 250L
    R = replicate(1.0, n_sigma) # fspan(0.0, 1.0, n_R)
    ang = acos(R)/rad             ; correlations
    sigma = fspan(0.0, xyMax, n_sigma) # replicate(1.0, n_R)    ; standard deviations
    xx = sigma * cos(ang*rad)
    yy = sigma * sin(ang*rad)

; default R0
    R0 = 0.99
    if ( isatt(rOpts,"skillR0") ) then R0 = rOpts.skillR0
    
; only 2 model skills are calculated now. can be extended in the future.
    if (skillType eq 0) then begin
      S =                ( 4*(1+R) ) / $
          ( ( (sigma/rOpts.refRad) + 1.0/( sigma/rOpts.refRad ) )^2 * ( 1 + R0 ) )
    endif else begin
      S =                ( 4*(1+R)^4 ) / $
          ( ( (sigma/rOpts.refRad) + 1.0/( sigma/rOpts.refRad ) )^2 * ( 1 + R0 )^4 )
    endelse

    gsLineDashPattern= 1  ; line pattern
    gsLineThicknessF = 1  ; choose line thickness
    if (isatt(rOpts,"skillThickness")) then begin
        gsLineThicknessF    =  rOpts.skillThickness
    endif
    gsLineColor      = 'Black'
    if (isatt(rOpts,"skill_color")) then begin
        gsLineColor    =  rOpts.skill_color
    endif

    n_lev = 10
;      oGrid = obj_new('IDLgrPlot', reform(xx, n_sigma*n_R), reform(yy, n_sigma*n_R), linestyle=6, $
;       symbol=obj_new('IDLgrSymbol', 3, size=0.01), color = cgColor(gsLineColor, /triple, /row))
    oSkill = obj_new('IDLgrContour', S, geomx=xx, geomy=yy, n_levels=n_lev, $
     color = cgColor(gsLineColor, /triple, /row), c_label_show=1, c_use_label_orientation=1)
;      oModel->Add, oGrid
    oModel->Add, oSkill
  endif
  
;; ---------------------------------------------------------------
;; Part 6: ; add case legend and variable labels
;; ---------------------------------------------------------------

  if (isatt(rOpts,"caseLabels")) then begin 
      if (isatt(rOpts,"caseLabelsFontSize")) then begin
          caseLabelsFontHeightF = rOpts.caseLabelsFontSize
      endif else begin
          caseLabelsFontHeightF = FontHeightF-3 
      endelse

;      lgres                    = True
      lgres_lgMarkerColors     = Colors        ; colors of markers
      lgres_lgMarkerIndexes    = Markers       ; Markers 
      lgres_lgMarkerSizeF      = gsMarkerSizeF ; Marker size
      lgres_gsMarkerThicknessF = gsMarkerThicknessF ; Marker thickness
      lgres_lgItemType         = replicate(0, n_elements(Colors))  ; draw markers only
      lgres_lgLineStyle        = replicate(6, n_elements(Colors))  ; draw markers only      
      lgres_lgLabelFontHeightF = caseLabelsFontHeightF  ; font height of legend case labels

      lgres_lgPerimOn          = True         ; turn off perimeter
      nModel                   = n_elements( rOpts.caseLabels )
      oMarkers                 = objarr(nModel)

      for i=0, nModel-1 do begin
        if (lgres_lgMarkerIndexes[i] lt 10) then begin 
          lgres_lgMarker   = lgres_lgMarkerIndexes[i]
        endif else begin
          lgres_lgMarker = obj_new('IDLgrPolygon', solidMarkerPattern.(lgres_lgMarkerIndexes[i]-10), $
;           color=getColor(lgres_lgMarkerColors[i], /triple))
           color=cgColor(lgres_lgMarkerColors[i], /triple, /row))
        endelse
        oMarkers[i] = obj_new('IDLgrSymbol', lgres_lgMarker, size=lgres_lgMarkerSizeF, $
         thick=lgres_gsMarkerThicknessF)
      endfor
;      oLegend = obj_new('IDLgrLegend', rOpts.caseLabels, item_color=getColor(lgres_lgMarkerColors, /triple), $
      oLegend = obj_new('IDLgrLegend', rOpts.caseLabels, item_color=transpose(cgColor(lgres_lgMarkerColors, /triple)), $
       item_object=oMarkers, item_type=lgres_lgItemType, item_linestyle=lgres_lgLineStyle, $
       font=obj_new('IDLgrFont', size=lgres_lgLabelFontHeightF), show_outline=lgres_lgPerimOn, gap=0.7, border_gap=0.5)
   
      legXPosF     =  xyMax*0.85      
      legYPosF     =  xyMax-xyMax*0.025*nModel    
      oModelLegend = obj_new('IDLgrModel')
      oModelLegend->Add, oLegend
      oModelLegend->Translate, trXoffset+legXPosF, trYoffset+legYPosF, 0
      oView->Add, oModelLegend
  endif

  if (isatt(rOpts,"varLabels")) then begin 
      nVar    = n_elements(rOpts.varLabels)

      if (isatt(rOpts,"varLabelsFontSize")) then begin
          varLabelsFontHeightF = rOpts.varLabelsFontSize
      endif else begin
          varLabelsFontHeightF = FontHeightF-3
      endelse

;      txres = True
      txres_txFontHeightF = varLabelsFontHeightF
;      txres_txJust = "CenterLeft"              ; justify to the center left
      txres_txHAlign = 0.0
      txres_txVAlign = 0.5

      if (isatt(rOpts,"varLabelsDy")) then begin
          delta_y  = rOpts.varLabelsDy            ; user specified
      endif else begin
          delta_y  = xyMax*0.03
      endelse
      if (isatt(rOpts,"varLabelsYloc")) then begin
          ys  = rOpts.varLabelsYloc            ; user specified
      endif else begin
          ys  = max( [nVar*delta_y , xyMax*0.91] )
      endelse

      ys0 = ys+delta_y

      for i = 1, nVar do begin     
         if (i eq 1) then begin
             dum12 = objarr(nVar)
         endif
         dum12[i-1] = obj_new('IDLgrText', strtrim(string(i), 2) + " - " + strtrim(string(rOpts.varLabels[i-1]), 2), $
          locations=[xyMax*0.07, ys], align=txres_txHAlign, vertical_align=txres_txVAlign, $
          fill_background=1, fill_color=cgColor('white', /triple, /row), font=obj_new('IDLgrFont', size=txres_txFontHeightF))
         oModel->Add, dum12[i-1]
         ys = ys - delta_y
      endfor
      
  endif

  return, oView
end
