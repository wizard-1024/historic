{ Sample by Dmitry Stefankov, 05/08/94 }
PROGRAM SampleForShowTErr1;
USES
   ShowTErr, Dos, TestUnit;
CONST
   dbDriveID  =  27;  {drive [}
VAR
  iCode : integer;
  sCurDirForDriveID : STRING;
  A, B : word;
BEGIN
   Writeln('Test program for ShowTErr unit.');
   GetDir(dbDriveID,sCurDirForDriveID);
   System.WriteLn('Current directory for drive ',dbDriveID,
                  ' is ',sCurDirForDriveID);
   A := TestUnit._fndwTestFunc;
   A := 5; B:= 0;
  writeln(A/B);
END.
