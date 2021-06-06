{$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   CRT  Unit             *
        *        Full-Screen Control and Keyboard          *
        *             Routines and Utilites                *
        *          Version  2.20      01/09/90             *
        *         written   by  Dmitry V. Stefankov        *
        *                                                  *
        ****************************************************
  }

   unit   TpCrt;

   interface                             { public part }

     uses
         TpSystem,TpString,TpDos;         { other units }

     const
        BW40          =       0;         {  text modes  }
        CO40          =       1;
        BW80          =       2;
        CO80          =       3;
        Mono          =       7;
        Font8x8       =       256;       { 43/50-line mode EGA/VGA }

        NumberOfRows  =       79;        { used for video table }

        Black         :   byte  =  0;    {  screen colors  }
        Blue          :   byte  =  1;    { init'd for color TV }
        Green         :   byte  =  2;
        Cyan          :   byte  =  3;
        Red           :   byte  =  4;
        Magenta       :   byte  =  5;
        Brown         :   byte  =  6;
        LightGray     :   byte  =  7;
        DarkGray      :   byte  =  8;
        LightBlue     :   byte  =  9;
        LightGreen    :   byte  =  10;
        LightCyan     :   byte  =  11;
        LightRed      :   byte  =  12;
        LightMagenta  :   byte  =  13;
        Yellow        :   byte  =  14;
        White         :   byte  =  15;

	Blink         =       128;         {  blink attribute  }

        Null          =        #0;
        CtrlA         =        #1;
        CtrlD         =        #4;
        CtrlF         =        #6;
        Bell          =        #7;
        BS            =        #8;
        HT            =        #9;
        LF            =        #10;
        CR            =        #13;
        CtrlR         =        #18;
        CtrlS         =        #19;
        CtrlX         =        #24;
        ESC           =        #27;
        Blank         =        #32;

        MaxChar       =        #255;

        UpArrow       =        #$48;
        DownArrow     =        #$50;
        HomeKey       =        #$47;
        EndKey        =        #$4F;
        PageUp        =        #$49;
        PageDown      =        #$51;
        LeftArrow     =        #$4B;
        RightArrow    =        #$4D;

        F1key         =        #$3B;            { function keys }
        F2key         =        #$3C;
        F3key         =        #$3D;
        F4key         =        #$3E;
        F5key         =        #$3F;
        F6key         =        #$40;
        F7key         =        #$41;
        F8key         =        #$42;
        F9key         =        #$43;
        F10key        =        #$44;
        F11key        =        #$57;
        F12key        =        #$58;

        InsState           =      $80;          { lock and shift states }
        CapsState          =      $40;
        NumState           =      $20;
        ScrollState        =      $10;
        AltShift           =      $8;
        CtlShift           =      $4;
        LeftShift          =      $2;
        RightShift         =      $1;

        SysReq             =      $80;          { pressed keys }
        CapsLock           =      $40;
        NumLock            =      $20;
        ScrollLock         =      $10;
        RightAlt           =      $8;
        RightCtl           =      $4;
        LeftAlt            =      $2;
        LeftCtl            =      $1;

        Delay250           =      0;            { delay values }
        Delay500           =      1;
        Delay750           =      2;
        Delay1000          =      3;

        BreakCstr       :    array[0..4]   of  char  =  (#4,'^','C',#13,#10);
	CheckBreak      :    boolean  =  false;  {  check ^Break    }

     type
        ColorMap    =   array[0..15] of byte;

     const
       MonoTable   :  ColorMap   =  (0,1,2,2,4,4,4,7,8,9,10,11,12,12,15,15);
       ColorTable  :  ColorMap   =  (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
       ColorTableLen  =  16;
       SaveVideoBuffer  :  boolean  =  false;     { preserve the video buffer for EGA,VGA, PCjr, PC-Conv }
       DirectVideo      :  boolean  =  true;      { direct i/o to/from video memory }
       CheckSnow        :  boolean  =  false;     { access memory only for retrace periods }
       LogicalCursor    :  boolean  =  false;     { logical emulation of cursor }

     var
        ActivePage     :      byte;        {  current active page       }
        DisplayPage    :      byte;        {  current display page      }
        TextAttr       :      byte;        {  current attribute         }
        NormAttr       :      byte;        {  attribute used at start   }
        CurrentWidth   :      byte;        {  current screen width      }
        CurrentHeight  :      byte;        {  current screen height     }
        LastMode       :      word;        {  last mode for text        }
	CurrentMode    :      byte   absolute   LastMode;
        WindMin        :      word;        {  window upper coordinates  }
        WindMax        :      word;        {  window lower coordinates  }
        BaseCrtAddr    :      word;        {  CRTC base address         }
        VideoSegment   :      word;        {  current video segment     }
        VideoBufSize   :      word;        {  current offset of page    }
        CursorX        :      byte;        {  cursor X-position         }
        CursorY        :      byte;        {  cursor X-position         }
        RowsTable      :      array[0..NumberOfRows]  of word;
        PageTable      :      array[0..7] of word;

        EnhancedKbd     :   boolean;       { present enhanced keyboard }

        function  ReadKey : word;
        { returns the next char in the keyboard buffer. }

        function  GetAsciiCode  :  char;
        { returns the ASCII code for keystroke. }

        function  GetScanCode  :  byte;
        { returns the scan code for keystroke. }

        function  KeyPressed : boolean;
        { checks to see if a char is available in the buffer. }

        function  ShiftStatus : byte;
        { returns the current keyboard shift status. }

        procedure SetKeyboardRate(Rate, DelayValue : byte);
        { sets the typematic rate and delay of the keyboard. }

        procedure WriteKey(ScanCode, AsciiCode : byte; var Result : boolean);
        { puts a char into the keyboard buffer. }

        function  ReadKeyTimeSlice : word;
        { read a char from the keyboard buffer using the Int $28 for waiting. }

        function  EnhancedKbdPresent :  boolean;
        { -returns a true if enhanced keyboard present. }

        procedure FlushKbdBuf;
        { fluish the ROM-BIOS keybord buffer. }

        function  NonDestructiveInput : word;
        { read a key from the keyboard, no moving keyboard pointer. }

        function ReturnScanCode(W : word) : char;
        { converts to char type. }
        inline($58          {  pop  ax     ; AL = W  }
              /$88/$E0);    {  mov  ah,al  ; AH = result }

        function ReturnChar(W : word) : char;
        { converts to char type. }
        inline($58);       {  pop  ax    ; AL = result }

        procedure  TextMode(Mode : integer);
        { selects a specific text mode. }

        procedure  GotoXY(X,Y : byte);
        { positions cursor on active page, relative to the current window. }

        procedure  GotoXYW(YX : word);
        { positions cursor on active page, relative to the current window. }

        procedure  Window(X1,Y1,X2,Y2 : byte);
        { defines window on screen. }

        function   WhereX : byte;
        { returns the X-coordinate of the current cursor position,relative to the current window. }

        function   WhereY : byte;
        { returns the X-coordinate of the current cursor position,relative to the current window. }

        function   WhereXY : word;
        { returns both cursor coordinates, relative to current window. }

        procedure  ClrScr;
        { clears the active window and places the cursor in the upper left-hand corner. }

        procedure  ClrEol;
        { clears all characters from the cursor position to the end of line, no cursor moving. }

        procedure  InsLine;
        { inserts a empty line at the cursor position. }

        procedure  DelLine;
        { deletes a line containing the cursor. }

        procedure  Sound(Hz : word);
        { starts the internal speaker. }

        procedure  Delay(MS : word);
        { delays for MS milliseconds. }

        function   CurrentTextColor : byte;
        { returns the current foreground color. }
        inline($A0/>TextAttr    {  mov  al,TextAtrr   }
              /$24/$0F);        {  and  al,00001111b  }

        function   CurrentTextBackground : byte;
        { returns the current foreground color. }
        inline($A0/>TextAttr    {  mov   al,TextAttr  }
              /$B1/$04          {  mov   cl,4         }
              /$D2/$E8);        {  shr   al,4         }

        procedure  NoSound;
        { turns off the internal speaker. }

        procedure  TextColor(Color : byte);
        { selects the foreground character color. }
        inline($58                    {  pop    ax                 }
              /$24/$1F                {  and    al,00011111b       }
              /$A8/$10                {  test   al,TurboBlink      }
              /$74/$04                {  jz     L1                 }
              /$0C/$80                {  or     al,Blink           }
              /$24/$8F                {  and    al,10001111b       }
              /$80/$26/>TextAttr/$70  {  and    TextAttr,0111000b  }
              /$08/$06/>TextAttr);    {  or     TextAttr,al        }

        procedure  TextBackGround(Color : byte);
        { selects the background color. }
        inline($58                    {  pop     ax                  }
              /$24/$07		      {  and     al,00000111b        }
              /$B1/$04		      {  mov     cl,4                }
              /$D2/$E0		      {  shl     al,cl               }
              /$80/$26/>TextAttr/$8F  {  and     TextAttr,10001111b  }
              /$08/$06/>TextAttr);    {  or      TextAttr,al         }

        procedure  HighVideo;
        { selects high intensity characters. }
        inline($80/$0E/>TextAttr/$08);   {  or  TextAttr,00001000b  }

        procedure  NormVideo;
        { selects the original attribute for characters. }
        inline($A0/>NormAttr         {  mov    al,NormAttr  }
              /$A2/>TextAttr);       {  mov    TextAttr,al  }

        procedure  LowVideo;
        { selects high intensity characters. }
        inline($80/$26/>TextAttr/$77);   {  and  TextAttr,01110111b  }

        procedure  SetCursorType(StartLine,EndLine : byte);
        { sets the cursor starting and ending scan line. }
        inline($59        {  pop  cx      ; CL = EndLine    }
              /$58        {  pop  ax      ; AL = StartLine  }
              /$88/$C5    {  mov  ch,al   ; CH = StarLine   }
              /$B4/$01    {  mov  ah,01h  ; set cursor type }
              /$CD/$10);  {  int  10h     ; call video BIOS }

        procedure  SetCursorTypeW(CurType : word);
        { sets the cursor starting(hi-byte) and ending scan line(lo-byte). }
        inline($59        {  pop  cx      ; CH = Start, CL = End Scan Line }
              /$B4/$01    {  mov  ah,01h  ; set cursor type }
              /$CD/$10);  {  int  10h     ; call video BIOS }

        procedure  DelayTimer2(MS : word);
        { delays for MS milliseconds, machine-independent routine. }

        procedure  GetCrtMode(var Mode,Columns,Page : byte);
        { get the current video mode info. }

        procedure  GotoXYabs(X,Y : byte);
        { moves the cursor to column X, row Y. }

        procedure  GotoXYWabs(XY : word);
        { moves the cursor to column X(low-byte), row Y(high-byte). }

        function   WhereXYabs : word;
        { returns the absolute coordinates of the cursor. }

        procedure  SetDisplayPage(VideoPageNum : byte);
        { set the new video page for display. }

        function   CursorType : word;
        { returns the cursor starting and ending scan lines. }

        procedure  WriteChar(Ch : char);
        { writes a char at current cursor position. }

        procedure  WriteCharAttr(Ch : char; Attr : byte);
        { writes a char with attribute at current cursor position. }

        procedure  WriteAttr(Attr : byte);
        { writes a attribute without destroy of a char at current cursor position. }

        procedure  WriteTTY(Ch : char);
        { writes char like TTY mode. }

        function   ReadCharAttr : word;
        { reads a char and it's attribute at current cursor position. }

        function   ReadCharAtCursor : char;
        { reads a char current cursor position. }

        function   WhereXabs : byte;
        { return absolute column coordinate of cursor }

        function   WhereYabs : byte;
        { return absolute row coordinate of cursor }

        function   WindowSizeX : byte;
        { returns the X-size of current window. }

        function   WindowSizeY : byte;
        { returns the Y-size of current window. }

        function   WindowSize : word;
        { returns the full size (char,attr) for the current window. }

        procedure  WindowScrollUp(Lines : byte);
        { scrolls the current window up designated lines }

        procedure  WindowScrollDown(Lines : byte);
        { scrolls the current window down designated lines }

        procedure  WriteCharInWindow(Ch : char);
        { writes a char,relative current window. }

        procedure  FastWrite(P : Pointer; Count : byte);
        { fast writes to screen with the current TextAttr. }

        procedure  FastWriteStr(S : AnyString);
        { fast writes the string to screen with the current TextAttr. }

        procedure  FastWriteStrNoAttr(S : AnyString);
        { fast writes the string to screen without updating screen attribute. }

        procedure  WriteBiosStr(S : AnyString);
        { writes a string,relative current window. }

	procedure  WriteStr(S : AnyString);
        { writes a string,relative current window. }

        procedure  WriteLn;
        { writes a carriage return/line feed on screen. }

        procedure  WriteLnStr(S : AnyString);
        { writes a string on screen and moves the cursor to beginning of next line. }

	procedure  WriteBoolean(Value : boolean);
        { writes the boolean value. }

        procedure  WriteByte(Value : byte);
        { writes a byte-sized value. }

	procedure  WriteInteger(Value : integer; Width : byte);
        { writes a integer number. }

        procedure  WriteWord(Value : word; Width : byte);
        { writes a word. }

        procedure  WriteLongInteger(Value : longint; Width : byte);
        { writes a long integer number. }

	procedure  WriteReal(Value : real; Width, Decimal : byte);
        { writes a real number. }

        procedure  WriteLnBoolean(Value : boolean);
        { writes a boolean value. }

        procedure  WriteLnByte(Value : byte);
        { writes a byte-sized value. }

        procedure  WriteLnWord(Value : word; Width : byte);
        { writes a word value. }

	procedure  WriteLnInteger(Value : integer; Width : byte);
        { writes a integer value. }

        procedure  WriteLnLongInteger(Value : longint; Width : byte);
        { writes a long integer value. }

	procedure  WriteLnReal(Value : real; Width, Decimal : byte);
        { writes a real value. }

        procedure  ReadStr(var A);
        { reads the text input into the string. }

        procedure  ReadLnStr(var A);
        { reads the text input into the string and moves a cursor to next line. }

        procedure  ReadLn;
        { reads a text stream until carriage return not found. }

        procedure  ReadByte(var Value : byte);
        { reads a byte-sized value. }

        procedure  ReadWord(var Value : word);
        { reads a word value. }

	procedure  ReadInteger(var Value : integer);
        { reads a integer value. }

	procedure  ReadReal(var Value : real);
        { reads a real value. }

        procedure  ReadLongInteger(var Value : longint);
        { reads a long integer value. }

        procedure  ReadLnByte(var Value : byte);
        { reads a byte-sized value. }

        procedure  ReadLnWord(var Value : word);
        { reads a word and move cursor to beginning of next line. }

	procedure  ReadLnInteger(var Value : integer);
        { reads a integer value and move cursor to beginning of next line. }

        procedure  ReadLnLongInteger(var Value : longint);
        { reads a longinteger value and move cursor to beginning of next line. }

	procedure  ReadLnReal(var Value : real);
        { reads a real value. }

        procedure  MonoColors;
        { switches the color map to mono/black and white. }

        procedure  ColorColors;
        { switches the color map to color. }

        procedure  FillWindow(Ch : char);
        { clears and fills a current window with a specified char. }

        procedure  SaveWindow(Buffer : pointer);
        { saves the contents of current window to buffer. }

        procedure  RestoreWindow(Buffer : pointer);
        { restores the contents of current window from buffer. }

        procedure  ReadHexByte(var S : Str2);
        { returns a byte in hexadecimal representation. }

        procedure  ReadHexWord(var S : Str4);
        { returns a word in hexadecimal representation. }

        procedure  ReadLnHexByte(var S : Str2);
        { returns a byte in hexadecimal representation and execute CR/LF. }

        procedure  ReadLnHexWord(var S : Str4);
        { returns a word in hexadecimal representation and execute CR/LF. }

        procedure  CenterWrite(S : AnyString);
        { writes a string, centering it. }

        procedure  ScrollLeft(Cols : byte);
        { scrolls the current window to left at specied columns. }

        procedure  ScrollRight(Cols : byte);
        { scrolls the current window to right at specied columns. }

        procedure  FillAttr(Attr, Count : byte);
        { fills with a specified attribute the screen region. }

        function   HexToDec(S : AnyString) : word;
        { converts a hex. string to it's decimal value. }

        function   GetAttrAtCursor : byte;
        { returns the attribute of a char. }

        procedure  ReadFromScreen(var A; Count,X,Y : byte);
        { moves a string from screen relative current window. }

        procedure  Abort(Message : AnyString; ReturnCode : byte);
        { prints a message and stops program. }

        procedure  CursorOff;
        { hides the cursor at last position+1 on screen. }

        procedure  WriteStrNoScroll(S : AnyString);
        { writes a string relative current window without scrolling. }

        function   WindowBrowse(var CurLine : integer; LastLine : integer; Key : char) : byte;
        { browses the current text window. }

        procedure  FillCharInWindow(Ch : char; Count : byte);
        { fills with a specified char the screen region. }

        procedure  CursorOn;
        { unhides the cursor on the screen. }

        procedure  WriteStrNoAttr(S : AnyString);
        { writes a string without updating the screen attribute. }

        procedure  GetVideoCardType(var VideoSeg : word; var CardType : byte);
        { detect the video card type and its characteristics. }

        function   VideoCardName(CardType : byte) : AnyString;
        { returns the video adapter name. }

        function   EGAinstalled : boolean;
        { detect the presence of the EGA or higher card. }

        procedure  ForceEGAcard;
        { clear the bit in the EGA data area. }


   implementation                { private part }

        const
          SaveKbdCode   :  word  =  $0;   { last read keyboard code }

   {    *******************************************************
        *                 WARNING !!!                         *
        *  Only a active display page can be scrolled or have *
        *  the cursor physically move.                        *
        *******************************************************   }

        procedure  ScanVideoParms;
        { check the user settings. }
        var
          S  :  CommandStr;
          i  :  byte;
        begin
          GetCmdLine(S);
          if  (Length(S) <> 0) then  begin
                UpCaseString(S);
                i := Pos('SNOW=',S);
                if  (i <> 0) then  begin
                  case  S[i+5]  of
                         'F'  :  CheckSnow := false;
                         'T'  :  CheckSnow := true;
                     else ;
                  end; { case }
                end;  { if }
                i := Pos('BIOS=',S);
                if  (i <> 0) then  begin
                  case  S[i+5]  of
                         'F'  :  DirectVideo := true;
                         'T'  :  DirectVideo := false;
                     else ;
                  end; { case }
                end;  { if }
          end;  { if }
        end;  { ScanVideoParms }

        {$L READKEY.OBJ }
        function  ReadKey : word; external;
        { returns the next char in the keyboard buffer. }

        function  GetAsciiCode  :  char; external;
        { returns the ASCII code for keystroke. }

        function  GetScanCode  :  byte; external;
        { returns the scan code for keystroke. }

        {$L KBDSTAT.OBJ }
        function  ShiftStatus : byte; external;
        { returns the current keyboard shift status. }

        {$L KEYPRESS.OBJ }
        function  KeyPressed : boolean; external;
        { checks to see if a char is available in the buffer. }

        {$L KBDRATE.OBJ }
        procedure SetKeyboardRate(Rate, DelayValue : byte); external;
        { sets the typematic rate and delay of the keyboard. }

        {$L WRITEKEY.OBJ }
        procedure WriteKey(ScanCode, AsciiCode : byte; var Result : boolean); external;
        { puts a char into the keyboard buffer. }

        {$L KBDSLICE.OBJ }
        function  ReadKeyTimeSlice : word; external;
        { read a char from the keyboard buffer using the Int $28 for waiting. }

        function  EnhancedKbdPresent : boolean;
        { -returns a true if enhanced keyboard present. }
        begin
          EnhancedKbdPresent := EnhancedKbd;
        end; { EnhancedKbdPresent }

        procedure FlushKbdBuf;
        { fluish the ROM-BIOS keybord buffer. }
        var
          TempKey : word;
        begin
          while (KeyPressed) do TempKey := ReadKey;
        end;  { FlushKbdBuf }

        {$L NODESTIN.OBJ }
        function  NonDestructiveInput : word; external;
        { read a key from the keyboard, no moving keyboard pointer. }

        {$L CALCOFS.OBJ }
        procedure  CalcOffset; external;
        { calculates all needing variables for video output. }

        {$L BTABLES.OBJ }
        procedure  BuildTables; external;
        { initialize internal video tables. }

        {$L INSLNSET.OBJ }
        procedure  InsLineSetup; external;
        { set insert video parameters. }

        {$L RDCURPRM.OBJ }
        procedure  ReadCursorPrim; external;
        { get cursor info primitive. }

        {$L SETCRPRM.OBJ }
        procedure  SetCursorPrim; external;
        { set cursor primitive. }

        {$L SETWPRM.OBJ }
        procedure  SetWindowPrim; external;
        { set window primitive. }

        {$L TEXTMODE.OBJ }
        procedure  TextMode(Mode : integer); external;
        { selects a specific text mode. }

        {$L GOTOXY.OBJ }
        procedure  GotoXY(X,Y : byte); external;
        { positions cursor on active page, relative to the current window. }

        {$L GOTOXYW.OBJ }
        procedure  GotoXYW(YX : word); external;
        { positions cursor on active page, relative to the current window. }

        {$L WINDOW.OBJ }
        procedure  Window(X1,Y1,X2,Y2 : byte); external;
        { defines window on screen. }

        {$L WHEREX.OBJ }
        function   WhereX : byte; external;
        { returns the X-coordinate of the current cursor position,relative to the current window. }

        {$L WHEREY.OBJ }
        function   WhereY : byte; external;
        { returns the X-coordinate of the current cursor position,relative to the current window. }

        {$L WHEREXY.OBJ }
        function   WhereXY : word; external;
        { returns both cursor coordinates, relative to current window. }

        {$L CLRSCR.OBJ }
        procedure  ClrScr; external;
        { clears the active window and places the cursor in the upper left-hand corner. }

        {$L CLREOL.OBJ }
        procedure  ClrEol; external;
        { clears all characters from the cursor position to the end of line, no cursor moving. }

        {$L INSLINE.OBJ }
        procedure  InsLine; external;
        { inserts a empty line at the cursor position. }

        {$L DELLINE.OBJ }
        procedure  DelLine; external;
        { deletes a line containing the cursor. }

        {$L MSDELAY.OBJ }
        procedure  DelayMs; external;
        { internal Turbo DELAY primitive. }

        {$L SOUND.OBJ }
        procedure  Sound(Hz : word); external;
        { starts the internal speaker. }

        {$L NOSOUND.OBJ }
        procedure  NoSound; external;
        { turns off the internal speaker. }

        {$L DELAY.OBJ }
        procedure  Delay(MS : word); external;
        { delays for MS milliseconds. }

        {$L DELAY2.OBJ }
        procedure  DelayTimer2(MS : word); external;
        { delays for MS milliseconds, machine-independent routine. }

        {$L GETCRTMD.OBJ }
        procedure  GetCrtMode(var Mode,Columns,Page : byte); external;
        { get the current video mode info. }

        {$L GOTOXYA.OBJ }
        procedure  GotoXYabs(X,Y : byte); external;
        { moves the cursor to column X, row Y. }

        {$L GOTOXYWA.OBJ }
        procedure  GotoXYWabs(XY : word); external;
        { moves the cursor to column X(low-byte), row Y(high-byte). }

        {$L WHEREXYA.OBJ }
        function   WhereXYabs : word; external;
        { returns the absolute coordinates of the cursor. }

        {$L SETPAGE.OBJ }
        procedure  SetDisplayPage(VideoPageNum : byte); external;
        { set the new video page for display. }

        {$L CURSTYPE.OBJ }
        function   CursorType : word; external;
        { returns the cursor starting and ending scan lines. }

        {$L WRITCHR.OBJ }
        procedure  WriteChar(Ch : char); external;
        { writes a char at current cursor position. }

        {$L WRCHRATR.OBJ }
        procedure  WriteCharAttr(Ch : char; Attr : byte); external;
        { writes a char with attribute at current cursor position. }

        {$L WRITATTR.OBJ }
        procedure  WriteAttr(Attr : byte); external;
        { writes a attribute without destroy of a char at current cursor position. }

        {$L WRITETTY.OBJ }
        procedure  WriteTTY(Ch : char); external;
        { writes char like TTY mode. }

        {$L RDCHRATR.OBJ }
        function   ReadCharAttr : word; external;
        { reads a char and it's attribute at current cursor position. }

        {$L RDCHRCUR.OBJ }
        function   ReadCharAtCursor : char; external;
        { reads a char current cursor position. }

        {$L WHEREXA.OBJ }
        function   WhereXabs : byte; external;
        { return absolute column coordinate of cursor }

        {$L WHEREYA.OBJ }
        function   WhereYabs : byte; external;
        { return absolute row coordinate of cursor }

        {$L WINSIZX.OBJ }
        function   WindowSizeX : byte; external;
        { returns the X-size of current window. }

        {$L WINSIZY.OBJ }
        function   WindowSizeY : byte; external;
        { returns the Y-size of current window. }

        {$L WINSIZE.OBJ }
        function   WindowSize : word; external;
        { returns the full size (char,attr) for the current window. }

        {$L SCROLLUP.OBJ }
        procedure  WindowScrollUp(Lines : byte); external;
        { scrolls the current window up designated lines }

        {$L SCROLLDN.OBJ }
        procedure  WindowScrollDown(Lines : byte); external;
        { scrolls the current window down designated lines }

        {$L CHRINWIN.OBJ }
        procedure  WriteCharInWindow(Ch : char); external;
        { writes a char,relative current window. }

        {$L FASTWRIT.OBJ }
        procedure  FastWrite(P : Pointer; Count : byte); external;
        { fast writes to screen with the current TextAttr. }

        {$L FWRITSTR.OBJ }
        procedure  FastWriteStr(S : AnyString); external;
        { fast writes the string to screen with the current TextAttr. }

        {$L FWRSTRNA.OBJ }
        procedure  FastWriteStrNoAttr(S : AnyString); external;
        { fast writes the string to screen without updating screen attribute. }

        {$L WBIOSSTR.OBJ }
        procedure  WriteBiosStr(S : AnyString); external;
        { writes a string,relative current window. }

        procedure  WriteStr(S : AnyString);
        { writes a string,relative current window. }
        var
          P     :  pointer;
          Count, i, SaveX : byte;
          SLen : byte absolute S;
        begin
          if  (DirectVideo)  then 
          begin
            P := Ptr(Seg(S[1]),Ofs(S[1]));
            i := 1;
            repeat
              SaveX := WhereX;
              Count :=  WindowSizeX - SaveX;
              if  (Count > SLen)  then  Count := SLen;
              FastWrite(P,Count);
              Dec(SLen,Count);
              Inc(i,Count);
              P := AddPtr(P,Count);
              GotoXY(SaveX+Count,WhereY);
              if (SLen <> 0)  then  begin
                 WriteCharInWindow(S[i]);
                 Dec(SLen);
                 P := AddPtr(P,1);
              end; { if }
            until  (SLen = 0);
          end
          else
              WriteBiosStr(S);
        end;  { WriteStr }

        procedure  WriteStrNoScroll(S : AnyString);
        { writes a string relative current window without scrolling. }
        var
         SLen : byte absolute S;
         TempLen : byte;
        begin
          TempLen := WindowSizeX - WhereX + 1;
          if  (Length(S) > TempLen) then  SLen := TempLen;
          FastWriteStr(S);
        end;  { WriteStrNoScroll }

        procedure  WriteStrNoAttr(S : AnyString);
        { writes a string without updating the screen attribute. }
        var
          SLen  :  byte  absolute S;
          X,Y,i,TempLen : byte;
        begin
          TempLen := WindowSizeX - WhereX + 1;
          if  (Length(S) > TempLen) then  SLen := TempLen;
          if  (DirectVideo = false)  then  begin
            X := WhereX; Y := WhereY;
            for i := 1 to SLen do  begin
              GotoXY(X+i-1,Y);
              WriteChar(S[i]);
            end; { for }
          end
          else  FastWriteStrNoAttr(S);
        end;  { WriteStrNoAttr }

        procedure  WriteLn;
        { writes a carriage return/line feed on screen. }
        begin
          WriteBiosStr(#13#10);
        end;  { WriteLn }

        procedure  WriteLnStr(S : AnyString);
        { writes a string on screen and moves the cursor to beginning of next line. }
        begin
          WriteStr(S);
          WriteLn;
        end;  { WriteLnStr }

	procedure  WriteBoolean(Value : boolean);
	{ writes the boolean value. }
	begin
	  if  Value  then  WriteStr('TRUE')
	  else  WriteStr('FALSE');
	end;  { WriteBoolean }

        procedure  WriteByte(Value : byte);
        { writes a byte-sized value. }
        var
          S : Str3;
        begin
          Str(Value,S);
	  WriteStr(S);
        end;  { WriteByte }

        procedure  WriteWord(Value : word; Width : byte);
        { writes a word. }
	var
	  S : Str5;
	begin
	  Str(Value : Width,S);
	  WriteStr(S);
	end;  { WriteWord }

	procedure  WriteInteger(Value : integer; Width : byte);
	{ writes a integer number. }
	var
	  S : Str5;
	begin
	  Str(Value : Width,S);
	  WriteStr(S);
	end;  { WriteInteger }

        procedure  WriteLongInteger(Value : longint; Width : byte);
        { writes a long integer number. }
	var
	  S : Str10;
	begin
	  Str(Value : Width,S);
	  WriteStr(S);
	end;  { WriteLongInteger }

	procedure  WriteReal(Value : real; Width, Decimal : byte);
	{ writes a real number. }
	var
	  S : AnyString;
	begin
	  Str(Value : Width : Decimal,S);
	  WriteStr(S);
	end;  { WriteReal }

        procedure  WriteLnBoolean(Value : boolean);
        { writes a boolean value. }
        begin
          WriteBoolean(Value);
          WriteLn;
        end;  { WriteLnBoolean }

        procedure  WriteLnByte(Value : byte);
        { writes a byte-sized value. }
        begin
          WriteByte(Value);
          WriteLn;
        end;  { WriteLnByte }

        procedure  WriteLnWord(Value : word; Width : byte);
        { writes a word value. }
        begin
          WriteWord(Value,Width);
          WriteLn;
        end; { WriteLnWord }

	procedure  WriteLnInteger(Value : integer; Width : byte);
        { writes a integer value. }
        begin
          WriteInteger(Value,Width);
          WriteLn;
        end; { WriteLnInteger }

        procedure  WriteLnLongInteger(Value : longint; Width : byte);
        { writes a long integer value. }
        begin
          WriteLongInteger(Value,Width);
          WriteLn;
        end; { WriteLnLongInteger }

	procedure  WriteLnReal(Value : real; Width, Decimal : byte);
        { writes a real value. }
        begin
          WriteReal(Value,Width,Decimal);
          Writeln;
        end;  { WriteLnReal }

        procedure  ReadStr(var A);
        { reads the text input into the string. }
        var
           S     :  AnyString;
           Ch    :  char;
	   i     :  byte  absolute  S;
           MaxLen     :  byte;
           OldX,OldY  :  byte;
           SaveVideo  :  boolean;
	begin
          SaveVideo := DirectVideo; DirectVideo := false;
          i := 0;  MaxLen := 0;
          OldX := WhereX;
          OldY := WhereY;
          repeat
	  Ch := ReturnChar(ReadKey);
             case  Ch  of
                 CR         : S[0] := char(i);
                 CtrlA,Esc  : if  (i > 0)  then
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
          Move(S[0],A,Length(S)+1);
          DirectVideo := SaveVideo;
        end;  { ReadStr }

        procedure  ReadLnStr(var A);
        { reads the text input into the string and moves a cursor to next line. }
        begin
          ReadStr(A);
          WriteLn;
        end;  { ReadLnStr }

        procedure  ReadLn;
        { reads a text stream until carriage return not found. }
        var
          S : AnyString;
        begin
          ReadLnStr(S);
        end;  { ReadLn }

        procedure  ReadByte(var Value : byte);
        { reads a byte-sized value. }
        var
          S : AnyString;
          ErrorCode : integer;
        begin
          ReadStr(S);
          {$R-}  Val(S,Value,ErrorCode);  {$R+}
        end;  { ReadByte }

        procedure  ReadLnByte(var Value : byte);
        { reads a byte-sized value. }
        begin
          ReadByte(Value);
          WriteLn;
        end;  { ReadLnByte }

        procedure  ReadWord(var Value : word);
        { reads a word value. }
        var
          S : AnyString;
          ErrorCode : integer;
        begin
          ReadStr(S);
          {$R-}  Val(S,Value,ErrorCode);  {$R+}
        end;  { ReadWord }

	procedure  ReadInteger(var Value : integer);
        { reads a integer value. }
        var
          S : AnyString;
          ErrorCode : integer;
        begin
          ReadStr(S);
          {$R-}  Val(S,Value,ErrorCode);  {$R+}
          if  (Value < 0) or (Value > MaxInt)  then  Value := 0;
        end;  { ReadInteger }

        procedure  ReadLongInteger(var Value : longint);
        { reads a long integer value. }
        var
          S : AnyString;
          ErrorCode : integer;
        begin
          ReadStr(S);
          {$R-}  Val(S,Value,ErrorCode);  {$R+}
          if  (Value < 0) or (Value > MaxLongInt)  then  Value := 0;
        end;  { ReadInteger }

	procedure  ReadReal(var Value : real);
        { reads a real value. }
        var
          S : AnyString;
          ErrorCode : integer;
        begin
          ReadStr(S);
          {$R-}  Val(S,Value,ErrorCode);  {$R+}
        end;  { ReadReadl }

        procedure  ReadLnWord(var Value : word);
        { reads a word and move cursor to beginning of next line. }
        begin
          ReadWord(Value);
          WriteLn;
        end;  { ReadLnWord }

	procedure  ReadLnInteger(var Value : integer);
        { reads a integer value and move cursor to beginning of next line. }
        begin
          ReadInteger(Value);
          WriteLn;
        end;  { ReadLnInteger }

        procedure  ReadLnLongInteger(var Value : longint);
        { reads a longinteger value and move cursor to beginning of next line. }
        begin
          ReadLongInteger(Value);
          WriteLn;
        end;  { ReadLnLongInteger }

	procedure  ReadLnReal(var Value : real);
        { reads a real value. }
        begin
          ReadReal(Value);
          WriteLn;
        end;  { ReadLnReadl }

        procedure  MonoColors;
        { switches the color map to mono/black and white. }
        begin
          Move(MonoTable[0],Black,ColorTableLen);
        end;  { MonoColors }

        procedure  ColorColors;
        { switches the color map to color. }
        begin
          Move(ColorTable[0],Black,ColorTableLen);
        end;  { ColorColors }

        procedure  FillWindow(Ch : char);
        { clears and fills a current window with a specified char. }
        var
          Loop,Size  :  word;
        begin
          Size := WindowSizeX * WindowSizeY - 1;
          for  Loop := 1  to  Size  do  WriteCharInWindow(Ch);
          WriteCharAttr(Ch,TextAttr);
          GotoXY(1,1);
        end;  { FillWindow }

        {$L SAVEWIN.OBJ }
        procedure  SaveWindow(Buffer : pointer); external;
        { saves the contents of current window to buffer. }

        {$L RESTWIN.OBJ }
        procedure  RestoreWindow(Buffer : pointer); external;
        { restores the contents of current window from buffer. }

        procedure  ReadHexByte(var S : Str2);
        { returns a byte in hexadecimal representation. }
        var
          A : AnyString;
        begin
          ReadStr(A);
          if (Length(A) > 2) then A[0] := #2;
          S := GetHexStr(A);
        end;  { ReadHexByte }

        procedure  ReadHexWord(var S : Str4);
        { returns a word in hexadecimal representation. }
        var
          A : AnyString;
        begin
          ReadStr(A);
          if (Length(A) > 4) then A[0] := #4;
          S := GetHexStr(A);
        end;  { ReadHexWord }

        procedure  ReadLnHexByte(var S : Str2);
        { returns a byte in hexadecimal representation and execute CR/LF. }
        begin
          ReadHexByte(S);
          WriteLn;
        end;  { ReadLnHexByte }

        procedure  ReadLnHexWord(var S : Str4);
        { returns a word in hexadecimal representation and execute CR/LF. }
        begin
          ReadHexWord(S);
          WriteLn;
        end;  { ReadLnHexWord }

        procedure  CenterWrite(S : AnyString);
        { writes a string, centering it. }
        var
          SLen  :  byte  absolute  S;
          Diff  :  byte;
        begin
          Diff := WindowSizeX - SLen;
          if  (SLen > 0) and (Diff > 1)  then
            begin
              GotoXY((Diff div 2) + (Diff mod 2) + 1, WhereY);
              WriteStr(S);
            end;
        end;  { CenterWrite }

        procedure  ScrollLeft(Cols : byte);
        { scrolls the current window to left at specied columns. }
        var
          OldXY : word;
          i, j,Ypos, NewChar, WinY  :  byte;
          S  :  AnyString;
        begin
          if  Cols >= (WindowSizeX)  then   Exit;
          OldXY := WhereXY;
          S[0] := char(WindowSizeX-1);
          WinY := WindowSizeY;
          for  j  :=  1  to  WinY  do
          begin
            FillChar(S[1],WindowSizeX,Blank);
            for  i  :=  Cols+1  to  WindowSizeX  do
            begin
                GotoXY(i,j);
                S[i-Cols] := ReadCharAtCursor;
            end;
            GotoXY(1,j);
            WriteStr(S);
            WriteChar(S[WindowSizeX]);
          end;
          GotoXYW(OldXY);
        end;  { ScrollLeft }

        procedure  ScrollRight(Cols : byte);
        { scrolls the current window to right at specied columns. }
        var
          OldXY : word;
          i, j,Ypos, NewChar, WinY  :  byte;
          S  :  AnyString;
        begin
          if  Cols >= (WindowSizeX)  then   Exit;
          OldXY := WhereXY;
          S[0] := char(WindowSizeX-1);
          WinY := WindowSizeY;
          for  j  :=  1  to  WinY  do
          begin
            FillChar(S[1],WindowSizeX,Blank);
            for  i  :=  1  to  WindowSizeX-Cols  do
            begin
                GotoXY(i,j);
                S[Cols+i] := ReadCharAtCursor;
            end;
            GotoXY(1,j);
            WriteStr(S);
            WriteChar(S[WindowSizeX]);
          end;
          GotoXYW(OldXY);
        end;  { ScrollRight }

        {$L FFILLATR.OBJ }
        procedure  FastFillAttr(Attr, Count : byte); external;
        { fills with a specified attribute the screen region. }

        procedure  FillAttr(Attr, Count : byte);
        { fills with a specified attribute the screen region. }
        var
          XY  :  word;
          i   :  byte;
        begin
          if  (Count <= (WindowSizeX - WhereX + 1)) then  begin
          if  (DirectVideo)  then  FastFillAttr(Attr,Count)
          else  begin
            XY := WhereXY;
            for i := 1  to  Count  do  begin
              GotoXYW(XY);
              WriteAttr(Attr);
              Inc(XY);
            end;  { for }
          end;  { if }
          end; { if }
        end;  { FillAttr }

        function  HexToDec(S : AnyString) :word;
        { converts a hex. string to it's decimal value. }
	const
           Power  :  array[1..4]  of  word   =  (4096,256,16,1);
        var
          StrLen  :  byte  absolute  S;
          Ch,i  :  byte;
          Value : word;
        begin
          S := GetHexStr(S);
          Value := 0;
          if  (StrLen > 4)  then  StrLen := 4;
          for  i := StrLen downto 1  do
          begin
             if  (Ch in [$41..$46])  then  Dec(Ch,byte('A')-10)  else  Dec(Ch,byte('0'));
             Value := Value + Power[i] * Ch;
          end;  { for }
          HexToDec := Value;
        end;  { HexToDec }

        {$L GETATR.OBJ }
        function   GetAttrAtCursor : byte; external;
        { returns the attribute of a char. }

        procedure  ReadFromScreen(var A; Count,X,Y : byte);
        { moves a string from screen relative current window. }
        var
          S  :  AnyString;
          i  :  byte;
          NewX  : byte  absolute  X;
          NewY  : byte  absolute  Y;
          OldXY :  word;
        begin
          OldXY := WhereXY;
          S[0] := char(Count);
          for i := 1  to  Count  do
          begin
            GotoXY(NewX,NewY);
            S[i] := ReadCharAtCursor;
            Inc(NewX);
          end;
          GotoXYW(OldXY);
          Move(S[0],A,Length(S)+1);
        end;  { ReadFromScreen }

        procedure  Abort(Message : AnyString; ReturnCode : byte);
        { prints a message and stops program. }
        begin
           WriteLnStr(Message);
           Halt(ReturnCode);
        end;  { Abort }

        procedure  CursorOff;
        { hides the cursor at last position+1 on screen. }
        var
          SaveXY : word;
        begin
          if  (DirectVideo)  then  begin
             SaveXY := WhereXY;
             GotoXYabs(1,CurrentHeight+2);
             LogicalCursor := true;
             GotoXYW(SaveXY);
            end
          else  SetCursorTypeW($2000);
        end;  { CursorOff }

        function  WindowBrowse(var CurLine : integer; LastLine : integer; Key : char) : byte;
        { browses the current text window. }
        var
          Lines,Y : byte;
        begin
        Lines := 0;
        Y := WindowSizeY;
          case  Key  of
               UpArrow  :  { up arrow }
                          begin
                          Y := WhereY;
                          if (CurLine > 1) then  begin
                              Dec(CurLine);
                              if (Y = 1)  then  begin
                                WindowScrollDown(1);
                                GotoXY(1,1);
                                Inc(Lines);
                              end
                              else  GotoXY(WhereX,Y-1);
                          end; { if }
                          end;
              DownArrow  :  { down arrow }
                          if  (CurLine < LastLine)  then  begin
                            Inc(CurLine);
                            if  (WhereY = Y)  then begin
                              WindowScrollUp(1);
                              GotoXY(1,Y);
                              Inc(Lines);
                            end
                          else  GotoXY(WhereX,WhereY+1);
                          end;  { if }
              HomeKey  :  { home key }
                           if  (CurLine > 1)  then  begin
                              CurLine := 1;
                              Dec(Lines);
                           end;  { if }
              EndKey    :  { end key }
                           if  (CurLine < LastLine)  then  begin
                              CurLine := LastLine;
                              Dec(Lines);
                           end;  { if }
              PageUp     :   { page up key }
                           if  (CurLine > 1)  then  begin
                              Dec(CurLine,Y-1);
                              if  (CurLine < 1)  then CurLine := 1;
                              Lines := 2;
                            end;  { if }
              PageDown     :   { page down key }
                            if  (CurLine <> LastLine) then
                            begin
                              Lines := 2;
                              Inc(CurLine,Y-1);
                              if  (CurLine >= LastLine)  then begin
                                CurLine := LastLine;
                                Lines := $FF;
                              end
                              else
                               if  ((LastLine - CurLine + 1) <= Y)  then begin
                                 CurLine := LastLine - Y + 1;
                               end;
                           end;
          end; { case }
          WindowBrowse := Lines;
        end;  { WindowBrowse }

        procedure  FillCharInWindow(Ch : char; Count : byte);
        { fills with a specified char the screen region. }
        var
          X, Y, i : byte;
        begin
          if  (Count <= WindowSizeX)  then
          begin
            X := WhereX; Y := WhereY;
            for  i := 1  to  Count  do
            begin
              GotoXY(X,Y);
              WriteChar(Ch);
              Inc(X);
            end;  { for }
          end;  { if }
        end;  { FillCharInWindow }

        procedure  CursorOn;
        { unhides the cursor on the screen. }
        var
          SaveXY : word;
        begin
          if  (DirectVideo)  then  begin
             SaveXY := WhereXY;
             LogicalCursor := false;
             GotoXYW(SaveXY);
            end
          else  begin
            SaveXY := $0607;      { assume that CGA mode }
            if  (CurrentMode = 7) or (LastMode >= $102) then  SaveXY := $0B0C;
            SetCursorTypeW(SaveXY);
          end;
        end;  { CursorOn }

        {$L INITCRT.OBJ }
	procedure  InitCrt; external;
	{ initialize all internal variables. }

        function   EGAinstalled : boolean;
        { detect the presence of the EGA or higher card. }
        begin
          asm
             mov   ax,1200h       { get EGA info }
             mov   bx,10h
             sub   cx,cx
             int   10h
             mov     al,0          { assume that not present }
             or      cx,cx         { CX == 0 ?  }
             jz      @Done
             mov     al,1          { AL = true }
          @Done:
             mov     [bp-1],al     { EGAinstalled = AL }
          end; { asm }
        end; { EGAinstalled }

        procedure  GetVideoCardType(var VideoSeg : word; var CardType : byte);
        { detect the video card type and its characteristics. }
        var
          AdapterFound : boolean;
        begin
          asm
             mov    AdapterFound,0           { set to false }
             mov    byte ptr CardType,255    { set to unknown }
             mov    ax,VideoSegment;   { VideoSeg <- VideoSegment }
             mov    word ptr VideoSeg,ax
             mov    ax,1A00h           { get VGA info }
             int    10h
             cmp    al,1Ah             { if AL == 1Ah then VGA present }
             jne    @notVGA
             mov    byte ptr CardType,bl
             mov    AdapterFound,1     { set to true }
           @notVGA:
             mov    ah,12h             { get EGA info }
             mov    bl,10h
             int    10h
             cmp    bl,1                { BL = memory size on card }
             jb     @NotEGA
             cmp    bl,3
             ja     @NotEGA
             mov    word ptr VideoSeg,0A000h
           @notEGA:
          end; { asm }
        end;  { GetVideoCardType }

        function   VideoCardName(CardType : byte) : AnyString;
        { returns the video adapter name. }
        var
           S : AnyString;
        begin
          case  CardType of
                 $FF   :  S := 'Unkown adapter';
                 $00   :  S := 'No display adapter';
                 $01   :  S := 'Monocrome Adapter';
                 $02   :  S := 'CGA/Color Display';
                 $03   :  S := 'reserved type';
                 $04   :  S := 'EGA/Color Display';
                 $05   :  S := 'EGA/Monocrome Display';
                 $06   :  S := 'PGA/Color Display';
                 $07   :  S := 'VGA/Analog/Monochrome';
                 $08   :  S := 'VGA/Analog/Color';
                 $09   :  S := 'reserved type';
                 $0A   :  S := 'MCGA/Digital/Color';
                 $0B   :  S := 'MCGA/Monochrome/Color';
                 $0C   :  S := 'MCGA/Analog/Color';
            else
              S :=  'Not implemented';
          end;  { case }
          VideoCardName := S;
        end;  { VideoCardName }

        procedure  ForceEGAcard;
        { clear the bit in the EGA data area. }
        begin
          asm
              mov    ax,40h        { ES = BIOS data segment }
              mov    es,ax
              and    byte ptr es:[87h],7Fh  { clear high bit }
          end;
        end; { ForceEGAcard }

   begin    { initialization part }
     InitCrt;
     if  (CurrentMode = Mono)  then  MonoColors;
     { test for enhanced keyboard }
     asm
        mov     ax,40h        { ES = BIOS data segment }
        mov     es,ax
        mov     al,0          { assume that not present }
        test    byte ptr es:[096h],10h  { test need bit }
        jz      @Done
        mov     al,1          { AL = true }
     @Done:
        mov    EnhancedKbd,al { set the variable }
     end;
   end.
