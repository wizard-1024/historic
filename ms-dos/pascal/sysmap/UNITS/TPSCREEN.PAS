  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *        Turbo Pascal 6.0    SCREEN   Unit         *
        *        Heap    Routines  and  Utilites           *
	*          Version  2.10      01/09/91             *
        *         written  by  Dima  Stefankov             *
        *                                                  *
        ****************************************************
  }

   unit   TpScreen;

   interface                             { public part }

   uses
     TpString, TpCrt;    { link with other units }

   const
      TpWord  :  set of char = ['A'..'Z','a'..'z','0'..'9','_','.'];


      function    HyperText(var X,Y : integer) : AnyString;
      function    EditString(S : AnyString) : AnyString;

   implementation                { private part }

      function    HyperText(var X,Y : integer) : AnyString;
      { try to return the TP word from the screen at the current cursor position. }
      var
        NewX  : integer  absolute  X;
        NewY  : integer  absolute  Y;
        SaveX,SaveY : byte;
        S  : AnyString;
        S1  : Str80;
        Ch  : char;
      begin
        S := '';              { initialize at start }
        SaveX := WhereX;
        SaveY := WhereY;
        NewX := SaveX;
        NewY := SaveY;
        Ch := ReadCharAtCursor;     { first symbol }
        while  (Ch in TpWord)  do  begin
          S := S + Ch;
          Inc(NewX);
          if  (NewX > (CurrentWidth+1))  then  Ch := #0
          else  begin
            GotoXY(NewX,NewY);
            Ch := ReadCharAtCursor;
          end;  { if }
        end;  { while }
        NewX := SaveX - 1;
        NewY := SaveY;
        GotoXY(NewX,NewY);
        Ch := ReadCharAtCursor;
        while  (Ch in TpWord)  do  begin
          Insert(Ch,S,1);
          Dec(NewX);
          if  (NewX < 1)  then  Ch := #0
          else  begin
            GotoXY(NewX,NewY);
            Ch := ReadCharAtCursor;
          end;  { if }
        end;  { while }
        Inc(NewX);
        HyperText := S;
        GotoXY(SaveX,SaveY);
      end;  { HyperText }

      function    EditString(S : AnyString) : AnyString;
      { edit the specified string. }
        var
           Ch    :  char;
	   i     :  byte  absolute  S;
           MaxLen   :   byte;
           OldX,OldY  :  byte;
           SaveCheckBreak : boolean;
	begin
          SaveCheckBreak := CheckBreak;
          CheckBreak := false;
          MaxLen := i;
          OldX := WhereX;
          OldY := WhereY;
          WriteStr(S);
          repeat
	  Ch := GetAsciiCode;
             case  Ch  of
                 Esc        : begin
                                S[0] := #0;
                                Ch := CR;
                               end;
                 CR         : S[0] := char(i);
                 CtrlA      : if  (i > 0)  then
                                 begin
				    i := 0;
                                    if  (OldY <> WhereY)  then  OldX := 1;
                                    GotoXY(OldX,WhereY);
                                    ClrEol;
                                 end;
		 CtrlF  :   while  (i < MaxLen)  do
                               begin
                                 Inc(i);
                                 WriteCharInWindow(S[i]);
                               end;
                 CtrlD  :   if (i < MaxLen)  then
                              begin
                                Inc(i);
                                WriteCharInWindow(S[i]);
                              end;
		 HT           :   begin
				     Inc(i);
				     S[i] := Ch;
				     WriteCharInWindow(HT);
				     if (i > MaxLen)  then  MaxLen := i;
                                  end;
                 BS,CtrlS     :   if (i <> 0)  then
                                    if  (S[i] <> HT)  then
				      begin
                                        Dec(i);
					WriteStr(BS + Blank + BS);
                                      end
				    else
				      begin
					Dec(i);
					repeat
					  WriteCharInWindow(BS);
					  Ch := ReadCharAtCursor;
					until (Ch <> Blank) or (WhereX = 1);
					if  (Ch <> Blank)  then  GotoXY(WhereX+1,WhereY);
				      end;
                 ' '..'~','€'..MaxChar:
                        begin
                          Inc(i);
                          S[i] := Ch;
                          if (i > MaxLen)  then  MaxLen := i;
                          WriteCharInWindow(Ch);
                        end;
             else
                 Ch := Null;
             end;  { case }
          until  (Ch = CR);
          EditString := S;
          CheckBreak := SaveCheckBreak;
      end;  { EditString }


   {begin}  { initialization part }
   end.
