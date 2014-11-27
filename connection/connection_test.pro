PRO connection_test
   ; test ftp connection with given file
   oUrl = OBJ_NEW('IDLnetUrl', URL_SCHEME='https', $
      URL_HOST='github.com',URL_Port=443, $
      URL_USERNAME='ltestut', URL_PASSWORD='q7WTlUpp',$
      URL_PATH='dickjackson/legos/blob/master/.gitignore')
      
   PRINT, oURL->Get(FILENAME=!desk+'toto.txt')
END