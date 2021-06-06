{  This is the sound effects. Thank to the Microsoft Quick Basic V4.0
        V1.00  Video Trends Software, 1989                            }

   procedure  Klaxon;
   { emulates the klaxon. }
   begin
     Tone(987,5);
     Tone(329,5);
   end;  { Klaxon }

   procedure  Fall;
   { emulates the falling. }
   var
     count  :  integer;
   begin
     count := 2000;
     repeat
       Tone(count,(500 mod count));
       Dec(count,10);
     until (count = 540);
   end;  { Fall }

   procedure  Bounce;
   { emulates the bouncing. }
   var
     count : integer;
   begin
     count := 780;
     repeat
       Tone(780-abs(count),6);
       Dec(count,4);
     until  (count = -770);
   end;  { Bounce }
