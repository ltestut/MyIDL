PRO output_ps
  original_device= !D.NAME
  set_plot, 'PS'
  !P.FONT= 0
  CD, current=here
  output = here+'/output_IDL.ps'
  device, /portrait, /color, filename=output, $
     /narrow, font_size=8,$
      xsize=18, ysize=22,xoffset=2.,yoffset=4.
  print,"Ecriture du fichier PostScript dans ",output
END