program  BIORYTHM;

{
             The demonstration graphic program
               by V.Bortko and D.Stefankoff
              Copyright  (c)  VideoSoft Inc.
                Release 1.1,  5 Dec 1988
}

uses
  Crt, Dos, Graph, Printer, Drivers, Fonts;
const
  Days     =    6;
  Months   =    12;
  BS       =    #8;                   { ASCII chars }
  LF       =    #10;
  CR       =    #13;
  ESC      =    #27;
  SPC      =    #32;
  WindX    =    639;                  { CGA hi-res screen }
  WindY    =    199;
type
  Str3     =  string[3];
  Str25    =  string[25];
  Str30    =  string[30];
const
  CopyrightMessage  :  array[1..39]  of  char  =
    'Copyright  (c)  by  VideoSoft Inc. 1988';

  DayNames     :   array[0..Days]  of  Str3  =
                      ('SUN','MON','TUE','WED','THU','FRI','SAT');

  MonthNames   :   array[1..Months]  of  Str3  =
                      ('JAN','FEB','MAR','APR','MAY','JUN',
                       'JUL','AUG','SEP','OCT','NOV','DEC');

  DaysInMonth  :   array[1..Months]  of  byte  =
                      (31,28,31,30,31,30,31,31,30,31,30,31);
var
  CurrentYear,CurrentMonth,CurrentDay,CurrentDayOfWeek : word;
  Year, Month, Day, DayOfWeek  :  integer;
  Name  :  Str25;

procedure  Copyright;
{ display our rights. }
var
  X, i  :  byte;
begin
  X := (Lo(WindMax)-Length(CopyrightMessage)) div 2;
  GotoXY(X,1);
  writeln(CopyrightMessage);
  GotoXY(X-1,2);
  for  i := 1  to  Length(CopyrightMessage)+2  do  write('-');
end; { Copyright }


function  ReadChar  : char;
{ get a char from keyboard. }
begin
 ReadChar := ReadKey;
end;  { ReadChar }


procedure  Bell;
{ sounds  the  speaker. }
begin
  Sound(220);
  Delay(440);
  NoSound;
end;  { Bell }


procedure  Init;
{ initialize variables }
begin
  DirectVideo := false;         { always do it!}
  ClrScr;
  Copyright;
end;  { Init }


function  GetNumber  :  integer;
{ read the number from keyboard. }
var
  Digits  :  array[1..4]  of  byte;
  Count, i, X, Y, Xmin  :  byte;
  Number, Power  :  word;
  Ch  :  char;
begin
  Xmin := WhereX;            { remember where cursor }
  X := Xmin;
  Y := WhereY;
  for  i := 1  to  4  do  Digits[i] := 0;      { number = zero }
  i := 1;
  Count := 0;
  repeat                                    { read by one }
    Ch := ReadChar;
    if  (Ch in ['0'..'9'])  then
      begin
        if  (Count < 4)  then
          begin
             Digits[i] := byte(Ch)-byte('0');
             Inc(i);
             Inc(Count);
             Write(Ch);
             Inc(X);
          end;
      end
    else  if  (Ch = BS)  then
              begin
                Dec(X);
                if  (X < Xmin)  then  X := Xmin;
                GotoXY(X,Y);
                Write(SPC);
                GotoXY(X,Y);
                if  (i <> 0)  then  Dec(i);
                if  (Count <> 0)  then  Dec(Count);
              end
          else
            if  (Ch <> CR)  then  Bell;
  until  (Ch = CR) or (Count > 4);
  Number := 0;                  { convert to integer representation }
  Power := 1;
  for  i := Count  downto  1  do
    begin
      Number := Number + Power*byte(Digits[i]);
      Power := Power * 10;
    end;
  GetNumber := Number;
end;  { GetNumber }


procedure  WriteString(Y : byte; S : Str30);
{ write string to screen. }
var
  X  :  byte;
begin
  X := (Lo(WindMax)-Length(S)) div 2;   { center the string }
  GotoXY(X,Y);
  Write(S);
end;  { WriteString }


procedure  GetBirthDay;
{ get user birthday. }
var
  Y  :  byte;
  S  :  Str30;
begin
  Y := 5;
  WriteString(Y,'Enter your birthday!');
  Inc(Y,2);
  WriteString(Y,'Year: ');
  Year := GetNumber;
  if  (Year < 100)  then Year := 1900 + Year;
  Inc(Y);
  WriteString(Y,'Month: ');
  Month := GetNumber;
  if (Month = 0) or (Month > 12)  then  Month := 1;
  Inc(Y);
  WriteString(Y,'Day: ');
  Day := GetNumber;
  if (Day = 0) or  (Day > 31)  then  Day := 1
  else
    case  Month  of
           2  :  if  ((Year mod 4) = 0)  then
                    begin
                      if  (Day > 29)  then  Day := 1;
                      DaysInMonth[2] := 29;
                    end
                  else  if (Day > 28)  then  Day := 1;
        4,6,9,11 :  if  (Day > 30)  then  Day := 1;
    end;  { case }
 Inc(Y);
 WriteString(Y,'Your Name:');
 ReadLn(Name);
 if (Length(Name) > 15)  then Delete(Name,16,Length(Name)-15);
 Inc(Y,2);
 WriteString(Y,'Enter the current date? (N/Y)');
 Readln(S);
 if  (S <> '')  and  (Upcase(S[1]) = 'Y')  then
 begin
  Inc(Y,2);
  WriteString(Y,'Current Year: ');
  CurrentYear := GetNumber;
  if  (CurrentYear < Year)  then CurrentYear := Year;
  Inc(Y);
  WriteString(Y,'Current Month: ');
  CurrentMonth := GetNumber;
  if (CurrentMonth = 0) or (CurrentMonth > 12)  then  CurrentMonth := 1;
  Inc(Y);
  WriteString(Y,'Current Day: ');
  CurrentDay := GetNumber;
 end
 else  GetDate(CurrentYear,CurrentMonth,CurrentDay,CurrentDayOfWeek);
end;  { GetBirthDay }


procedure  DisplayGraphic;
{ graphic representation. }
const
  ScaleX   =   1.64;
type
  Str4  =   string[4];
const
  CycleText  :  array[1..3]  of  string[13]  =
                  ('Physical','Psychological','Cognitive');
var
  GraphDriver, Graphmode, MaxX, MaxY, MinX, MinY, MedY,
  X, Y, i, BirthDay_DayOfWeek, d, dd, a, a2, step  :  integer;
  Cycle  :  array[1..3] of integer;
  ViewPort  :  ViewPortType;
  OldExitProc  :  pointer;
  Int2Str  :  string[4];
  IntS  :  string[2];
  S   :  string[70];
  Ch  :  char;

{$F+}
procedure  MyExitProc;
{ exit from procedure on error condition. }
begin
  CloseGraph;
  ExitProc := OldExitProc;
end;
{$F-}

procedure  CalculateDays;
var
  n, n1, n2  :  longint;

function  AllDay(Day1,Month1,Year1 : integer) : integer;
var
  L  :  longint;
begin
  L := trunc((22-month1)/10);
  AllDay := trunc((Year1-1899-L)*365.25)+trunc((12*L+Month1-14)*30.59)+
            29+Day1;
end;  { AllDay }

function  CycleDay(c : integer) : integer;
begin
  CycleDay := n - trunc(n/c)*c;
end;  { CycleDay }

begin
  n1 := AllDay(Day,Month,Year);
  n2 := AllDay(1,CurrentMonth,CurrentYear);
  n := n2 - n1;
  BirthDay_DayOfWeek := trunc((n1/7-trunc(n1/7))*7+0.5);
  Cycle[1] := CycleDay(23);
  Cycle[2] := CycleDay(28);
  Cycle[3] := CycleDay(33);
end;  { CalculateDays }

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

procedure  PrintPicture(Mode : char);
{ output to printer. }
const
  Bits : array[0..7] of byte = (128,64,32,16,8,4,2,1);
var
  i, j, k  : integer;
  Ch1  :  byte;

procedure  PrintByte(Ch : char);
{ prints a byte. }
begin
  Write(Lst,Ch);
end;  { PrintByte }

procedure  WriteOut(S : Str4);
{ prints a string. }
begin
  Write(Lst,S);
end;  { WriteOut }

procedure  AdjustSpace(Ch : char);
{ set the line spacing to n/216". }
begin
  WriteOut(ESC+'3'+Ch);
end;  { AdjustSpace }

procedure  LineFeed;
{ execute a line feed. }
begin
  PrintByte(LF);
  PrintByte(CR);
end; { LineFeed }

begin
  AdjustSpace(#24);
  if  (Mode = 'H')  then
  for  i := 1  to  (MaxY-MinY+1) shr 3  do
  { we use the 960-dot graphic print. }
  begin
    WriteOut(ESC + 'L' + char(Lo(MaxX-MinX+1)) + char(Hi(MaxX-MinX+1)));
    Y := MinY + (i-1)*8;
    for  j := 0  to  (MaxX-MinX) do
    begin
      Ch1 := 0;
      for k := 0  to  7  do  if  (Lo(GetPixel(j,Y+k)) <> 0)  then
        Ch1 := Ch1 or Bits[k];
    PrintByte(char(Ch1));
    end;
    LineFeed;
  end
  else   { we use the 480-dot graphic print. }
  for  i := 1  to  (MaxX-MinX+1) shr 3  do
  begin
    WriteOut(ESC+'K'+char(Lo(MaxY-MinY+1+100))+char(Hi(MaxY-MinY+1+100)));
    X := MinX + (i-1) * 8;
    for  j := 1  to  100  do  PrintByte(#0);
    for  j := MaxY  downto  MinY  do
    begin
      Ch1 := 0;
      for  k := 0  to  7  do  if  (Lo(GetPixel(X+k,j)) <> 0)  then
        Ch1 := Ch1 or Bits[k];
      PrintByte(char(Ch1));
    end;
    LineFeed;
  end;
  WriteOut(ESC+'@');      { reset the printer to defaults. }
  LineFeed;
  LineFeed;
  LineFeed;
end;  { PrintPicture }

begin
  CalculateDays;                 { biorithm's algorithm }
  OldExitProc := ExitProc;
  ExitProc := @MyExitProc;
  { Register all the drivers }
  if RegisterBGIdriver(@CGADriverProc) < 0 then
    Abort('CGA');
  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then
    Abort('EGA/VGA');
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    Abort('Herc');
  if RegisterBGIdriver(@ATTDriverProc) < 0 then
    Abort('AT&T');
  if RegisterBGIdriver(@PC3270DriverProc) < 0 then
    Abort('PC 3270');
  { Register only a font }
  if RegisterBGIfont(@SmallFontProc) < 0 then
    Abort('Small');
  GraphDriver := Detect;         { autodetect the hardware }
  InitGraph(GraphDriver,GraphMode,'');
  case  GraphDriver  of
          CGA       :  GraphMode := CGAhi;
          MCGA      :  GraphMode := MCGAMed;
          EGA       :  GraphMode := EGALo;
          EGA64     :  GraphMode := EGA64Lo;
          EGAMono   :  GraphMode := EGAMonoHi;
          HercMono  :  GraphMode := HercMonoHi;
          ATT400    :  GraphMode := ATT400Med;
          VGA       :  GraphMode := VGALo;
          PC3270    :  GraphMode := PC3270Hi;
  end;  { case }
  SetGraphMode(GraphMode);
  GetViewSettings(ViewPort);
  SetColor(GetMaxColor);
  SetLineStyle(SolidLn,0,NormWidth);
  MaxX := WindX + ((GetMaxX - WindX) div 2);
  MaxY := WindY + ((GetMaxY - WindY) div 2);
  MinX := MaxX - WindX;
  MinY := MaxY - WindY;
  MedY := (MinY + MaxY) div 2;
  Line(MinX,MinY,MinX,MaxY);               { draw axes }
  Line(MinX,MedY,MaxX,MedY);
  SetTextStyle(DefaultFont,HorizDir,1);
  OutTextXY(MinX+3,MinY+3,'+');
  OutTextXY(MinX+3,MaxY-8,'-');
  Str(CurrentYear : 4, Int2Str);
  S := 'BIORITHM for ' + Name + ', ' +
       MonthNames[CurrentMonth] + ' ' + Int2Str + '  ' +
       'Birthday: ';
  S := S + DayNames[BirthDay_DayOfWeek];
  OutTextXY(MinX+100,MinY+8,S);
  SetTextStyle(SmallFont,HorizDir,4);
  X := MinX;
  for  i := 1  to  DaysInMonth[CurrentMonth]  do
  begin
    Inc(X,19);
    MoveTo(X,MedY-3);
    LineTo(X,MedY+3);
    if  (i < 10)  then
      begin
        IntS[1] := char(byte(i)+48);
        IntS[0] := #1;
      end
    else  Str(i : 2, IntS);
    OutTextXY(X-2,MedY+4,IntS);
    if  (i = CurrentDay)  then
      if   (i < 10)  then
      begin
          MoveTo(X-4,MedY+TextHeight('W')+6);
          LineTo(X+4,MedY+TextHeight('W')+6);
        end
      else
        begin
          MoveTo(X-4,MedY+TextHeight('W')+6);
          LineTo(X+10,MedY+TextHeight('W')+6);
        end;
  end;
  SetLineStyle(DottedLn,0,NormWidth);         { first cycle }
  dd := 23;  d := trunc((360/dd)*Cycle[1]);  a:= d;
  a2 := 1020 + d;  step := 360 div dd;  MoveTo(MinX,MedY);
  while  (a < a2)  do
  begin
    X := MinX + trunc((a-d)*(dd/DaysInMonth[Month])*ScaleX);
    Y :9 MedY - trunc(sin(Pi*a/180)*dd*2);
    LineTo(X,Y);  Inc(a,step);
  end;
  MoveTo(MinX+100,MaxY-10);
  LineTo(MinX+130,MaxY-10);
  OutTextXY(MinX+140,MaxY-16,CycleText[1]);
  SetLineStyle(SolidLn,0,ThickWidth);           { second cycle }
  dd := 28;  d := trunc((360/dd)*Cycle[2]);  a:= d;
  a2 := 840 + d;  step := 360 div dd;  MoveTo(MinX,MedY);
  while  (a < a2)  do
  begin
    X := MinX + trunc((a-d)*(dd/DaysInMonth[Month])*ScaleX);
    Y := MedY - trunc(sin(Pi*a/180)*dd*2);
    LineTo(X,Y);  Inc(a,step);
  end;
  MoveTo(MinX+210,MaxY-10);
  LineTo(MinX+240,MaxY-10);
  OutTextXY(MinX+250,MaxY-16,CycleText[2]);
  SetLineStyle(CenterLn,0,ThickWidth);              { third cycle }
  dd := 33;  d := trunc((360/dd)*Cycle[3]);  a:= d;
  a2 := 720 + d;  step := 360 div dd;  MoveTo(MinX,MedY);
  while  (a < a2)  do
  begin
    X := MinX + trunc((a-d)*(dd/DaysInMonth[Month])*ScaleX);
    Y := MedY - trunc(sin(Pi*a/180)*dd*2);
    LineTo(X,Y);  Inc(a,step);
  end;
  MoveTo(MinX+360,MaxY-10);
  LineTo(MinX+390,MaxY-10);
  OutTextXY(MinX+400,MaxY-16,CycleText[3]);
  repeat until (KeyPressed);
  Ch := Upcase(ReadChar);
  if  (Ch in ['V','H'])  then  PrintPicture(Ch);
  CloseGraph;
  ExitProc := OldExitProc;
  RestoreCrtMode;
end;  { DisplayGraphic }


procedure  Quit;
{ say good-bye to user. }
begin
  Writeln('  Good-Bye! Thank you for using the VideoSoft Product...');
end;  { Quit }


begin
  Init;
  GetBirthday;
  DisplayGraphic;
  Quit;
end.