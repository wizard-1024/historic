{ Sample by Dmitry Stefankov, 07/20/94 }
program DemoForShowTErr;
uses  
   ShowTErr;
var
  iCode : integer;
begin
   Writeln('Test program for ShowTErr unit.');
   Write('Enter error code (range 0-255): ');
   Readln(iCode);
   RunError(iCode);
end.
