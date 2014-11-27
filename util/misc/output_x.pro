PRO output_x
original_device= !D.NAME
IF (!VERSION.OS EQ 'Win32') THEN set_plot, 'WIN' ELSE set_plot,'X'
device, retain=2, decomposed=0
output='Xwindow'
print,"Ecriture du fichier dans ",output
END