FUNCTION update_symbol_layer, layer, name=name 
; function to configure the symbol plot and update
CASE (name) OF
  'name' : BEGIN
  layerval = HASH('sym_size',2.0        ,'sym_thick',2.         ,'sym_filled',0         ,'sym_transparency',0      ,'sym_color','red'         ,'sym_fill_color','orange'  ,$
                  'linestyle',6         ,'line_color','black'   ,'line_thick',1.        ,$
                  'label_font_size',8  ,'label_color','black'  ,'label_orientation',0. ,'label_position','right'  ,'label_shift',[0.0,0.0]    ,$
                  'clip',1)
  END
  'mgr_label' : BEGIN
  layerval = HASH('sym_size',2.0        ,'sym_thick',2.         ,'sym_filled',0         ,'sym_transparency',0      ,'sym_color','red'         ,'sym_fill_color','orange'  ,$
                  'linestyle',6         ,'line_color','black'   ,'line_thick',1.        ,$
                  'label_font_size',8  ,'label_color','black'  ,'label_orientation',0. ,'label_position','right'  ,'label_shift',[0.0,0.0]    ,$
                  'clip',1)
  END
  'track': BEGIN
   layerval = HASH('sym_size',0.5        ,'sym_thick',1.         ,'sym_filled',1          ,'sym_transparency',50     ,'sym_color','red'         ,'sym_fill_color','orange'  ,$
                   'linestyle',6         ,'line_color','black'   ,'line_thick',1.         ,$
                   'label_font_size',10  ,'label_color','black'  ,'label_orientation',0. ,'label_position','left'  ,'label_shift',[0.0,0.0]    ,$
                   'clip',1)
  END
  'section': BEGIN
   layerval = HASH('sym_size',0.5        ,'sym_thick',0.2         ,'sym_filled',0          ,'sym_transparency',0      ,'sym_color','green'         ,'sym_fill_color','orange'  ,$
                   'linestyle',6         ,'line_color','black'   ,'line_thick',1.         ,$
                   'label_font_size',10  ,'label_color','black'  ,'label_orientation',0. ,'label_position','right'  ,'label_shift',[0.0,0.0]    ,$
                   'clip',1)
  END
  'dot' : BEGIN
  layerval = HASH('sym_size',0.8        ,'sym_thick',0.5         ,'sym_filled',1         ,'sym_transparency',0      ,'sym_color','black'         ,'sym_fill_color','red'  ,$
                  'linestyle',6         ,'line_color','black'   ,'line_thick',1.        ,$
                  'label_font_size',12  ,'label_color','black'  ,'label_orientation',0. ,'label_position','right'  ,'label_shift',[0.0,0.0]    ,$
                  'clip',1)
  END
  'number' : BEGIN
  layerval = HASH('sym_size',1.8        ,'sym_thick',0.5         ,'sym_filled',1         ,'sym_transparency',0      ,'sym_color','black'         ,'sym_fill_color','red'  ,$
                  'linestyle',6         ,'line_color','black'   ,'line_thick',1.        ,$
                  'label_font_size',10  ,'label_color','black'  ,'label_orientation',0. ,'label_position','right'  ,'label_shift',[0.0,0.0]    ,$
                  'clip',1)
  END

ENDCASE
layer.LINESTYLE           = layerval['linestyle']
layer.LINE_COLOR          = layerval['line_color']
layer.LINE_THICK          = layerval['line_thick']
layer.SYM_SIZE            = layerval['sym_size']
layer.SYM_THICK           = layerval['sym_thick']
layer.SYM_FILLED          = layerval['sym_filled']
layer.SYM_TRANSPARENCY    = layerval['sym_transparency']
layer.SYM_COLOR           = layerval['sym_color']
layer.SYM_FILL_COLOR      = layerval['sym_fill_color']
layer.LABEL_SHIFT         = layerval['label_shift']
layer.LABEL_FONT_SIZE     = layerval['label_font_size']
layer.LABEL_COLOR         = layerval['label_color']
layer.LABEL_ORIENTATION   = layerval['label_orientation']
layer.LABEL_POSITION      = layerval['label_position']
layer.CLIP                = layerval['clip']
RETURN,layer
END