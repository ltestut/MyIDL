PRO synchro3_julval, sta, stb, stc, stsync1, stsync2, stsync3
;permet de synchroniser 3 structures de type jul,val
synchro_julval, sta,  stb, stas, stbs
synchro_julval, stas, stc, stsync1, stsync3
synchro_julval, stsync1, stb, stsync1, stsync2
synchro_julval, stsync1, stc, stsync1, stsync3
END
