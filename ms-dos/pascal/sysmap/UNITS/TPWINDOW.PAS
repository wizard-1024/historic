  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   WINDOW   Unit         *
        *       Window    Routines  and  Utilites          *
	*          Version  2.10      01/09/91             *
        *         written  by  Dima  Stefankov             *
        *                                                  *
        ****************************************************
  }

   unit   TpWindow;

   interface                             { public part }

     uses
         TpSystem,TpString,TpHeap,TpCrt;                   { other units }

     const
        MinWindows     =    1;        { max # of windows = 50 }
        MaxWindows     =    50;
        FreeHandle     =    0;        { free window handle     }
        EndOfChain     =    $FF;      { no more active windows }

     type
        WindowRecPtr   =    ^WindowRec;
        WindowRec      =    record
                  Active        :   boolean;   { active window record    }
                  VideoPage     :   byte;      { window page for i/o     }
                  XL,YL,XH,YH   :   byte;      { window coordinates      }
                  SizeInWords   :   word;      { window size in words    }
                  WinBufPtr     :   pointer;   { original window to save }
                  SCols         :   byte;      { number of columns       }
                  SRows         :   byte;      { number of rows          }
                  WindowMin     :   word;      { window coordinates      }
                  WindowMax     :   word;
                  Shadow        :   boolean;   { shadow window           }
                  ShadowAttr    :   byte;      { shadow fill attribute   }
                  ForeColor     :   byte;      { foreground text color   }
                  BackColor     :   byte;      { background text color   }
                  CurCol        :   byte;      { cursor X-coordinate     }
                  CurRow        :   byte;      { cursor Y-coordinate     }
                  CurStartLine  :   byte;      { cursor start scan line  }
                  CurEndLine    :   byte;      { cursor end scan line    }
                  OldCursorPos  :   word;      { old cursor position     }
                  OldCursorSize :   word;      { old cursor type         }
                  OldForeColor  :   byte;      { old text color          }
                  OldBackColor  :   byte;      { old background color    }
                  OldWindMin    :   word;      { old window coordinates  }
                  OldWindMax    :   word;
                            end;  { WindowRec }

     const
        WindowRecSize  =    36;       { size of window description record }
                                      { in bytes }

        { line drawing chars }

        LeftUpperFrames      :    array[1..4]  of  char   =  'ÚÉÕÖ';

        LeftLowerFrames      :    array[1..4]  of  char   =  'ÀÈÔÓ';

        RightUpperFrames     :    array[1..4]  of  char   =  '¿»¸·';

        RightLowerFrames     :    array[1..4]  of  char   =  'Ù¼¾½';

        HorizFrames          :    array[1..2]  of  char   =  'ÄÍ';

        VertFrames           :    array[1..2]  of  char   =  '³º';

        LeftMedianFrames     :    array[1..4]  of  char   =  'ÃÌÆÇ';

        RightMedianFrames    :    array[1..4]  of  char   =  '´¹µ¶';

        UpperMedianFrames    :    array[1..4]  of  char   =  'ÂËÑÒ';

        LowerMedianFrames    :    array[1..4]  of  char   =  'ÁÊÏÐ';


     var
       HandlesList    :  array[0..MaxWindows]  of  byte;
       WindowHandles  :  array[MinWindows..MaxWindows]  of  WindowRecPtr;

       function   WindowRecord(Handle : byte) : WindowRecPtr;
       procedure  DefineWindow( Page, X1, Y1, X2, Y2, Fore, Back : byte;
                                      Buffer : pointer; SaveScreen : boolean; ShadowVal : boolean;
                                      ShadowAttribute : byte; var Handle : byte);
       procedure  OpenWindow(Handle : byte);
       procedure  WindowFrames(Handle : byte; LeftUp,LeftLow,RightUp,RightLow,HorizLine,VerLine : char;
                               Header,Footer : AnyString; HeaderAttr, FooterAttr : byte);
       procedure  SelectWindow(Handle : byte);
       procedure  ExitWindow(Handle : byte);
       procedure  CloseWindow(Handle : byte);

   implementation                { private part }

     const
       CurWinHandle  :  byte    =   0;    { init'd to Root }

     var
       i  :  integer;


     function  WindowRecord(Handle : byte) : WindowRecPtr;
     { return the current window state for specified handle. }
     begin
       if  (Handle > MaxWindows) or (Handle < MinWindows)  then   WindowRecord := nil
       else  WindowRecord := WindowHandles[Handle];
     end;  { WindowRecord }

     function   FindFree : byte;
     { searches the handles list for first free window handle. }
     var
        J  :  byte;
     begin
       J := 0;
       repeat
         Inc(J);
       until  (HandlesList[J] = FreeHandle)  or  (J = MaxWindows);
       if (HandlesList[J] = 0)  then  FindFree := J
       else   FindFree := 0;
     end;  { FindFree }

     procedure  AddToList(Handle : byte);
     { add a handle to list. }
     var
       J  :  byte;
     begin
       J := 0;
       while (HandlesList[J] <> EndOfChain)  do  Inc(J);
       HandlesList[J] := Handle;
       HandlesList[Handle] := EndOfChain;
     end;  { AddToList }

     procedure  DeleteFromList(Handle : byte);
     { deletes a handle from list. }
     var
        Link : byte;
     begin
       Link := 0;
       while (HandlesList[Link] <> Handle) and (Link <> MaxWindows)  do
             Inc(Link);
       if  (HandlesList[Link] = Handle)  then
         begin
            HandlesList[Link] := HandlesList[Handle];
            HandlesList[Handle] := FreeHandle;
         end;
     end;  { DeleteFromList }

     function   FindLastHandle : byte;
     { finds the end of chain of handles. }
     var
       J  :  byte;
     begin
       J := 0;
       while (HandlesList[J] <> EndOfChain)  do  Inc(J);
       FindLastHandle := J;
     end;  { FindLastHandle }

     procedure  RemoveWindowRecord(Handle : byte);
     { removes the current window record. }
     var
       P  :  WindowRecPtr;
     begin
        P := WindowRecord(Handle);
        if  (P <> nil)  then
         begin
            FreeMemCheck(P^.WinBufPtr,P^.SizeInWords);
            Dispose(P);
            WindowHandles[Handle] := nil;
         end;
     end;  { RemoveWindowRecord }

     procedure  SaveVideoInfo(Handle : byte);
     { saves a video attributes for current handle. }
     var
       P  :  WindowRecPtr;
     begin
       P := WindowRecord(Handle);
       if  (P <> nil)  and  (P^.Active)  then
         with  P^  do
           begin
             CurCol := WhereX;
             CurRow := WhereY;
             CurStartLine := HiByte(CursorType);
             CurEndLine := LoByte(CursorType);
             WindowMin := WindMin;
             WindowMax := WindMax;
             ForeColor := CurrentTextColor;
             BackColor := CurrentTextBackground;
           end;
     end;  { SaveVideoInfo }

     procedure  SetVideoAttr(P : WindowRecPtr);
     { sets the video attributes. }
     begin
       with  P^  do
         begin
           TextBackground(BackColor);
           TextColor(ForeColor);
           SetCursorType(CurStartLine,CurEndLine);
           GotoXY(CurCol,CurRow);
         end;  { with }
     end;  { SetVideoAttr }

     procedure  UpdateCurWinHandle(Handle : byte; P : WindowRecPtr);
     begin
       SetVideoAttr(P);
       DeleteFromList(Handle);
       AddToList(Handle);
       CurWinHandle := Handle;
     end;  { UpdateCurWinHandle }

     procedure  DefineWindow(Page, X1, Y1, X2, Y2, Fore, Back : byte;
                                      Buffer : pointer; SaveScreen : boolean; ShadowVal : boolean;
                                      ShadowAttribute : byte; var Handle : byte);
     { make the window descrition record. }
     var
       P  :  WindowRecPtr;
       WinSize  :  word;
       WinCols,WinRows  :  byte;
       ErrorFlag  :  boolean;
     begin
       ErrorFlag := true;    { assume error result }
       Handle := FindFree;
       if  (Handle = 0)  then   Exit;   { no available handles }
       WinCols := (X2 - X1 + 1);  WinRows := (Y2 - Y1 + 1);
       WinSize := WinCols * WinRows * 2;
           if  (MaxAvail > WindowRecSize)  then
            begin
             New(P);   { construct new window desciption record }
             AddToList(Handle);
             WindowHandles[Handle] := P;
             with  P^  do
              begin
                 ErrorFlag := false;     { no error state }
                 Active := false;        { not active now }
                 VideoPage := Page;      { window page    }
                 XL := X1;               { window coordinates }
                 XH := X2;
                 YL := Y1;
                 YH := Y2;
                 Buffer := nil;
                 if  (SaveScreen)  then  if GetMemCheck(Buffer,WinSize) then ;
                 WinBufPtr := Buffer;    { pointer to buffer to save contents }
                 SCols := WinCols;
                 SRows := WinRows;
                 Shadow := ShadowVal;
                 ShadowAttr := ShadowAttribute;
                 SizeInWords :=  WinSize;
                 ForeColor := Fore;
                 BackColor := Back;
               end;  { with }
            end;
        if  (ErrorFlag)  then  Handle := 0;
     end;  { DefineWindow }

     procedure  SelectWindow(Handle : byte);
     { switch the active window to new. }
     var
       P  :  WindowRecPtr;
     begin
       if  (Handle = CurWinHandle)  then   Exit;
       P := WindowRecord(Handle);
       if  (P <> nil)  and  (P^.Active) then
         begin
           if  (CurWinHandle <> 0)  then  SaveVideoInfo(CurWinHandle);
           with  P^  do
             begin
               WindMin := WindowMin;
               WindMax := WindowMax;
             end;  { with }
           UpdateCurWinHandle(Handle,P);
         end;
     end;  { SelectWindow }

     procedure  OpenWindow(Handle : byte);
     { makes a window and redefines a video attributes. }
     var
       P  :  WindowRecPtr;
       i, LenX, LenY  :  byte;
     begin
       P := WindowRecord(Handle);
       if  (P <> nil)  and  not(P^.Active)  then
       begin
        with  P^  do
         begin
          Active     := true;          { active window now }
          ActivePage := VideoPage;
          OldCursorSize := CursorType;
          OldCursorPos  := WhereXYabs;
          OldForeColor  := CurrentTextColor;
          OldBackColor  := CurrentTextBackground;
          OldWindMin    := WindMin;
          OldWindMax    := WindMax;
          CurStartLine := HiByte(CursorType);
          CurEndLine := LoByte(CursorType);
          if  (CurWinHandle <> 0)  then  SaveVideoInfo(CurWinHandle);
          Window(XL,YL,XH,YH);
          if  (WinBufPtr <> nil)  then  SaveWindow(WinBufPtr);
          if  (Shadow)  then
          begin
             LenX := WindowSizeX;  LenY := WindowSizeY;
             for  i := 2  to  LenX  do
             begin
                GotoXY(i,LenY);
                FillAttr((ShadowAttr shl 4) + (GetAttrAtCursor and 15),1);
             end;  { for }
             for  i := 2  to  (LenY-1)  do
              begin
                 GotoXY(LenX,i);
                 FillAttr((ShadowAttr shl 4) + (GetAttrAtCursor and 15),1);
              end;  { for }
             Window(XL,YL,XH-1,YH-1);
          end;  { if }
         end;  { with }
         UpdateCurWinHandle(Handle,P);
       end; { if }
     end;  { OpenWindow }


     procedure  WindowFrames(Handle : byte; LeftUp,LeftLow,RightUp,RightLow,HorizLine,VerLine : char;
                             Header,Footer : AnyString; HeaderAttr, FooterAttr : byte);
     { draw the frames for current window and homes cursor. }
     var
        CurPosX, CurPosY, Ypos, LenX, LenY  :   byte;
        P    :   WindowRecPtr;

     procedure  DrawLine(LeftCh : char);
     { draws a line. }
     var
       S           :  AnyString;
       StrPos      :  byte;
     begin
       S[0] := char(LenX-1);
       S[1] := LeftCh;
       FillChar(S[2],LenX-2,HorizLine);
       WriteStr(S);
     end;  { DrawLine }

     procedure  DrawString(S : AnyString; NewColor, Ypos : byte);
     { draws a string with a specified attribute. }
     var
       StrLen   :   byte  absolute  S;
       OldColor : byte;
     begin
       if  (StrLen <> 0) and (StrLen < (LenX-2))  then
       begin
         GotoXY(1,YPos);
         OldColor := TextAttr;
         TextAttr := NewColor;
         CenterWrite(S);
         TextAttr := OldColor;
       end;
     end;  { DrawString }

     begin
        P := WindowRecord(Handle);
        if  (P <> nil)  and  (P^.Active)  then
          begin
             LenX := WindowSizeX;
             LenY := WindowSizeY;
             GotoXY(1,1);                                { homes cursor    }
             DrawLine(LeftUp);
             DrawString(Header,HeaderAttr,1);
             GotoXY(WindowSizeX,1);
             WriteCharInWindow(RightUp);
             for  Ypos := WhereY  to  (LenY - 1)   do
               begin
                  WriteCharAttr(VerLine,TextAttr);
                  GotoXY(LenX,Ypos);
                  WriteCharInWindow(VerLine);
               end;  { for }
             DrawLine(LeftLow);
             WriteCharAttr(RightLow,TextAttr);
             DrawString(Footer,FooterAttr,WhereY);
             Window(LoByte(WindMin)+2,HiByte(WindMin)+2,LoByte(WindMax),HiByte(WindMax));
           end;
     end;  { WindowFrames }



     procedure  ExitWindow(Handle : byte);
     { exits from current window and restores old video info saved before. }
     var
       P  :  WindowRecPtr;
       var  i  :  byte;
     begin
       P := WindowRecord(Handle);
       if  (P <> nil)  and  (P^.Active)  then
         begin
           with  P^  do
             begin
                TextColor(OldForeColor);
                TextBackground(OldBackColor);
                SetCursorTypeW(OldCursorSize);
                GotoXYWabs(OldCursorPos);
                WindMin    := OldWindMin;
                WindMax    := OldWindMax;
             end;  { with }
           DeleteFromList(Handle);
           RemoveWindowRecord(Handle);
           CurWinHandle := FindLastHandle;
        end;
     end;  { ExitWindow }

     procedure  CloseWindow(Handle : byte);
     { removes the specifies window from screen. }
     var
       P  : WindowRecPtr;
       CurPosXY, Wmin, Wmax :  word;
     begin
       P := WindowRecord(Handle);
       if  (P <> nil)  and  (P^.Active) then
         begin
            Window(P^.XL,P^.YL,P^.XH,P^.YH);
	    if  (P^.WinBufPtr <> nil)  then  RestoreWindow(P^.WinBufPtr);
            ExitWindow(Handle);
         end;
     end;  { CloseWindow }


   begin      { initializtion part }
      HandlesList[0] := EndOfChain;
      for  i :=  MinWindows  to  MaxWindows  do  HandlesList[i] := 0;
      for  i :=  MinWindows  to  MaxWindows  do  WindowHandles[i] := nil;
   end.
