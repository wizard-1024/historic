{ Sample by Dmitry Stefankov, 10/18/1998 }
PROGRAM DemoForTrapTechnique;
USES
   ShowTErr;
VAR
  iCode,
  iValue : integer;

begin
   Writeln('Test program 2 for ShowTErr unit (error trap mechanism).');
   ShowTErr._TrapBegin;
   WriteLn('Now division by zero. Error trap handler installed.');
   iValue := 0; 
   iCode := iCode DIV iValue;
   ShowTErr._TrapEnd;
   ShowTErr._InstallErrorHandler;           {Don't forget this!}   
   Writeln('Ok! Continue here!');
   WriteLn('Good division.');
   iValue := 5;
   iCode := iCode DIV iValue;
   {ShowTErr.TrapProc := NIL;}
   WriteLn('Now division by zero. Error trap handler removed.');   
   ShowTErr._TrapBegin;
   iValue := iValue - 5; 
   iCode := iCode DIV iValue;   
   ShowTErr._TrapEnd;   
   ShowTErr._InstallErrorHandler;           {Don't forget this!}      
   WriteLn('Good division.');
   iValue := 7;
   iCode := iCode DIV iValue;
   WriteLn('Divided = ',iCode,'; divisor = ', iValue);   
   Writeln('Ok! Terminate here!');   
end.
