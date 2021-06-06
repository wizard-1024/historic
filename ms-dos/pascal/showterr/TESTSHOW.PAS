{ Sample by Dmitry Stefankov, 07/20/94 }
program DemoForShowTErr;
uses  
   ShowTErr;
var
  pTemp  : pointer;
  iA, iB, iC : integer;

procedure _NewExitProc; far;
begin
  ExitProc := pTemp;
  asm
        jmp     @1
   @Msg:
        db      'First in chain of EXITs. Recover previous ExitProc.',13,10,'$'
   @1:
          push  ds
          mov   ax, cs
          mov   ds, ax
          mov   dx, OFFSET @Msg
          mov   ah,9
          int   21h
          pop   ds
  end;
end;

begin
  iA := 5;
  iB := 0;
  Writeln('test for ',iA,'/',iB);
  Write('Select 0=old Turbo handler, 1=new ShowTErr handler: ');
  Readln(iC);
   if (iC <> 1)
    then  ShowTErr._UnInstallErrorHandler;
  Write('Select 0=no for chain of EXITs, 1=yes for chain EXITs: ');
  Readln(iC);
  If (iC = 1)
    then begin
       pTemp := ExitProc;
       ExitProc := @_NewExitProc;
         end;
  Writeln(iA/iB);
end.
