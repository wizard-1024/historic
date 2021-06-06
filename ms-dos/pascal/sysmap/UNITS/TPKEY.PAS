  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   KEY  Unit             *
        *     Provides access to the protection functions  *
	*          Version  2.10      01/09/91             *
        *         written  by  Dima  Stefankov             *
        *                                                  *
        ****************************************************
  }

   unit   TpKey;

   interface                 { public part }

     uses
        TpCrt,TpDos;           { other units }


     implementation

   begin    { initialization }
     SetTrueDos(true);
     if  (NOT(UseTrueDos) AND  NOT(bDos5InUseOk)) then  begin
       WriteStr('Unable to find the true Dos entry! Continue? (N/Y): ');
       if  (UpCase(ReturnChar(ReadKey)) <> 'Y')  then Abort('Program halts...',1);
     end;  { if }
     WriteLn;
   end.
