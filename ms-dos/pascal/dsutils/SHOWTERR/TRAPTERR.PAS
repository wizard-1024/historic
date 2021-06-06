{ Sample by Dmitry Stefankov, 05/08/97 }
PROGRAM DemoForTrapTechnique;
USES
   ShowTErr;
VAR
  iCode,
  iValue : integer;
  OldTrapProc : pointer;

PROCEDURE  TrapHandler; FAR;
BEGIN
   WriteLn('Trap handler in progress watching exit code = ',ExitCode);
   ShowTErr.TrapProc := OldTrapProc;
END;

begin
   Writeln('Test program for ShowTErr unit (trap technique).');
   Write('Enter error code (range 0-255): ');
   ShowTErr._TrapBegin;
   OldTrapProc := ShowTErr.TrapProc;
   {OldTrapProc := NIL;}
   ShowTErr.TrapProc := @TrapHandler;
   Readln(iCode);
   RunError(iCode);
   {iValue := 0; iCode := iCode DIV iValue;}
   {ShowTErr._TrapEnd;}
   Writeln('Ok! Continue here!');
end.
