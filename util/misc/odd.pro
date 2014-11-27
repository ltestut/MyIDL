FUNCTION odd, num
; determine if number if odd or even 
   fnum=round(num)
   if (2*(fnum/2) eq fnum) then begin
      return,0
   end else begin
      return,1
   end
END