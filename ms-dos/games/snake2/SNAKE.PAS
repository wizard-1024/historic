{   VIdeo  TRends  SOftware, V1.00A, 1989   }

program  SnakeGame;

uses
  TpSystem,TpString,TpCrt,TpDos{,TpKbd};

const
  Zero      =   48;
  Block     =   #219;
  UpBlock   =   #223;
  LowBlock  =   #220;
  Ribbit    =   #176;
  HiScoreX  =   8;
  ScoreX    =   54;

type
  ColorArray      =   array[1..4] of byte;
  SnakePixelPtr   =   ^SnakePixel;
  SnakePixel      =   record
                    SnakeX, SnakeY : byte;
                    NextPixel : SnakePixelPtr;
                      end;

const
  Colors  : ColorArray  =  (15,7,0,143);

var
  HiScore,Score,SnakeLen : integer;
  SnakeHead,SnakeTail : SnakePixelPtr;
  Field,HeadX,HeadY,TailX,TailY,RibbitNumber, Direction, TempChar,
  TempX,TempY,AddScore,SnakeRate  :  byte;
  GameCycleEnd, UpHead : boolean;
  CursorSize : word;

function  GetKey : char;
var
  W : word;
  Ch  :  char;
begin
  Ch := #0;
  if  KeyPressed then  begin
                W := ReadKey;
		Ch := char(GetScanCode);
	end;
  GetKey := Ch;
end;  { GetKey }

function  RandomRibbitX : integer;
begin
  RandomRibbitX := Random(78) + 2;
end;  { RandomRibbitX }

function  RandomRibbitY : integer;
begin
  RandomRibbitY := Random(21) + 2;
end;  { RandomRibbitY }

function  RandomX : integer;
var
  TestX : integer;
begin
  TestX := Random(8) + HeadX - 4;
  if  (TestX < 2)   then  TestX := 2;
  if  (TestX > 79)  then  TestX := 79;
  RandomX := TestX;
end;  { RandomX }

function  RandomY : integer;
var
  TestY : integer;
begin
  TestY := Random(4) + HeadY - 2;
  if  (TestY < 2)   then  TestY := 2;
  if  (TestY > 22)  then  TestY := 22;
  RandomY := TestY;
end;  { RandomY }
function ScreenPoint(X,Y : byte) : word;
var
  SaveXY : word;
begin
  SaveXY := WhereXY;
  GotoXY(X,Y);
  ScreenPoint := ReadCharAttr;
  GotoXY(Lo(SaveXY),Hi(SaveXY));
end;  { ScreenPoint }

procedure  Bell;
begin
  Sound(220);
  Delay(440);
  NoSound;
end;  { Bell }

procedure  Pause(Wait : word);
begin
  Delay(Wait);
end;  { Pause  }

procedure  InitVars;
begin
  HiScore := 0;
  Randomize;
end;  { InitVars }

procedure  SnakeMessage(Message : Str40);
begin
  GotoXY(1,24);
  TextColor(Colors[4]);
  CenterWrite(Message);
end;  { SnakeMessage }

procedure  DrawTitle;
var
  Ch : char;
begin
  TextBackGround(Colors[3]);
  TextColor(Colors[1]);
  ClrScr;
  WriteLnStr('           #########');
  WriteLnStr('           ##');
  WriteLnStr('           ##');
  WriteLnStr('           ##');
  WriteLnStr('           #########  #    #    ##    #  #  ####');
  WriteLnStr('                  ##  ##   #   #  #   # #   #');
  WriteLnStr('                  ##  # #  #  #    #  ##    ####');
  WriteLnStr('                  ##  #  # #  ######  # #   #');
  WriteLnStr('           #########  #   ##  #    #  #  #  ####');
  WriteLn;
  WriteLn;
  WriteLnStr('       ษออออออออออออออออออออออออออออออออออออออออออออออป');
  WriteLnStr('       บ                                              บ');
  WriteLnStr('       บ       Video  Trends Software,  1989          บ');
  WriteLnStr('       บ            Public  Domain                    บ');
  WriteLnStr('       บ                                              บ');
  WriteLnStr('       ศออออออออออออออออออออออออออออออออออออออออออออออผ');
  WriteLn;
  WriteLn;
  WriteLn;
  WriteStr('    Game Field (0-9): ');
  FlushKbdBuf;
  repeat
    Ch := char(ReadKey);
    if not(Ch in ['0'..'9'])  then  Bell;
  until  Ch in ['0'..'9'];
  WriteStr(Ch);
  Field := byte(Ch)-Zero;
  WriteLn;
  WriteStr('Snake Rate (1 = fast, 9 = slowly): ');
  repeat
    Ch := char(ReadKey);
    if not(Ch in ['1'..'9'])  then  Bell;
  until  Ch in ['1'..'9'];
  WriteStr(Ch);
  SnakeRate := byte(Ch)-Zero;
  WriteLn;
  WriteStr('                press any key to continue ...');
  Ch := char(ReadKey);
end;  { DrawTitle }

procedure  DrawField;
var
  i,j : byte;
begin
  ClrScr;
  TextColor(Colors[1]); TextBackGround(Colors[3]);
  WriteStr('ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
  for i := 2 to 22 do  begin
    WriteStr('บ');
    GotoXY(80,i);
    WriteStr('บ');
  end;  { for }
  WriteStr('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');
  TextColor(Colors[2]);
  case  Field  of
          1  :  begin
                  for  i := 1  to  5  do
                  for  j := 1  to  7  do
                  begin
                    GotoXY(3 + 9*j,i*4);
                    WriteStr(Block);
                  end;  { for }
                  RibbitNumber := 4;
                  AddScore := 10;
                 end;
          2   :   begin
                    for i := 1  to  141  do  begin
                      GotoXY(RandomRibbitX,RandomRibbitY);
                      WriteStr(Block);
                    end;  { for }
                    RibbitNumber := 6;
                    AddScore := 15;
                  end;
     else  begin
       RibbitNumber := 3;
       AddScore := 5;
     end;  { else }
  end;  { case }
  TextBackGround(Colors[3]);
  for i := 1 to RibbitNumber do  begin
    GotoXY(RandomRibbitX,RandomRibbitY);
    WriteStr(Ribbit);
  end;  { for }
  SnakeMessage('<<<  SNAKE  >>>');
  TextColor(Colors[1]);
  GotoXY(ScoreX,25);
  WriteStr('SCORE = ' + IntegerToString(Score,4) + ' points');
  GotoXY(HiScoreX,25);
  WriteStr('HISCORE = ' + IntegerToString(HiScore,4) + ' points');
end;  { DrawField }

procedure  AddNewSnakePixel(X,Y : byte);
var
  P : SnakePixelPtr;
begin
  New(P);
  P^.SnakeX := X;
  P^.SnakeY := Y;
  P^.NextPixel := nil;
  SnakeHead^.NextPixel := P;
  SnakeHead := P;
end;  { AddNewSnakePixel }

procedure  InitSnake;
begin
  Direction := 3;
  UpHead := true;
  GotoXY(36,14);
  WriteStr('        ');
  GotoXY(36,14);
  WriteStr(UpBlock+UpBlock+UpBlock+UpBlock);
  TailY := 14;
  HeadY := 14;
  TailX := 36;
  HeadX := 39;
  SnakeTail^.SnakeX := TailX;
  SnakeTail^.SnakeY := TailY;
  SnakeTail^.NextPixel := nil;
  SnakeHead := SnakeTail;
  AddNewSnakePixel(TailX+1,TailY);
  AddNewSnakePixel(TailX+2,TailY);
  AddNewSnakePixel(TailX+3,TailY);
  SnakeLen := 4;
end;  { InitSnake }

procedure  UpdateScore;
begin
  TextColor(Colors[1]);
  GotoXY(ScoreX+8,25);
  WriteStr(IntegerToString(Score,4));
  if  (Score >= HiScore)  then  begin
    HiScore := Score;
    GotoXY(HiScoreX+10,25);
  WriteStr(IntegerToString(HiScore,4));
  end;  { if }
  Inc(SnakeLen);
end;  { UpdateScore }

procedure  Fooding;
begin
  SnakeMessage('<<<  FOODING  >>>');
  Inc(Score,AddScore);
  UpdateScore;
  Sound(317); Delay(290);
  Sound(289); Delay(230);
  Sound(310); Delay(320);
  NoSound;
  Pause(50);
  SnakeMessage('<<<  SNAKE  >>>');
end;  { Fooding }

procedure  UpdateSnakeTail;
var
  P : pointer;
  X1,Y1 : byte;
begin
  X1 := SnakeTail^.SnakeX;
  Y1 := SnakeTail^.SnakeY;
  P := SnakeTail;
  SnakeTail := SnakeTail^.NextPixel;
  Dispose(P);
  GotoXY(X1,Y1);
  WriteStr(Blank);
end;  { UpdateSnakeTail }

procedure  WriteSnakeHead;
begin
  if  UpHead then  begin
    WriteStr(UpBlock);
  end  { if }
  else  begin
    WriteStr(LowBlock);
  end;  { else }
end;  { WriteSnakeHead }

procedure  MoveSnakeUp;
begin
  if  (Direction <> 0)  then  Direction := 0;
  if  UpHead  then  begin
    TempX := HeadX;
    TempY := HeadY;
    Dec(TempY);
    TempChar := Lo(ScreenPoint(TempX,TempY));
    if (TempChar = byte(Ribbit))  then
    begin
      Fooding;
      TextColor(Colors[1]);
      GotoXY(RandomRibbitX,RandomRibbitY);
      WriteStr(Ribbit);
      GotoXY(TempX,TempY);
      WriteStr(Blank);
      HeadY := TempY;
      GotoXY(HeadX,HeadY);
      WriteStr(LowBlock);
      AddNewSnakePixel(HeadX,HeadY);
      UpHead := false;
      Exit;
    end;  { if }
    if  (TempChar = byte(Blank))  then  begin
      HeadY := TempY;
      GotoXY(HeadX,HeadY);
      WriteStr(LowBlock);
      AddNewSnakePixel(HeadX,HeadY);
      UpHead := false;
    end  { if }
    else
       GameCycleEnd := true;
  end { if }
  else  begin
    GotoXY(HeadX,HeadY);
    WriteStr(Block);
    UpHead := true;
    AddNewSnakePixel(HeadX,HeadY);
  end;  { else }
  UpdateSnakeTail;
end;  { MoveSnakeUp }

procedure  MoveSnakeDown;
begin
  if  (Direction <> 1)  then  Direction := 1;
  if  not(UpHead)  then  begin
    TempX := HeadX;
    TempY := HeadY;
    Inc(TempY);
    TempChar := Lo(ScreenPoint(TempX,TempY));
    if (TempChar = byte(Ribbit))  then
    begin
      Fooding;
      TextColor(Colors[1]);
      GotoXY(RandomRibbitX,RandomRibbitY);
      WriteStr(Ribbit);
      GotoXY(TempX,TempY);
      WriteStr(Blank);
      HeadY := TempY;
      GotoXY(HeadX,HeadY);
      WriteStr(UpBlock);
      AddNewSnakePixel(HeadX,HeadY);
      UpHead := true;
      Exit;
    end;  { if }
    if  (TempChar = byte(Blank))  then  begin
      HeadY := TempY;
      GotoXY(HeadX,HeadY);
      WriteStr(UpBlock);
      AddNewSnakePixel(HeadX,HeadY);
      UpHead := true;
    end  { if }
    else
       GameCycleEnd := true;
  end { if }
  else  begin
    GotoXY(HeadX,HeadY);
    WriteStr(Block);
    UpHead := false;
    AddNewSnakePixel(HeadX,HeadY);
  end;  { else }
  UpdateSnakeTail;
end;  { MoveSnakeDown }

procedure  MoveSnakeLeft;
begin
  if  (Direction <> 2)  then  Direction := 2;
  TempX := HeadX;
  TempY := HeadY;
  Dec(TempX);
  TempChar := Lo(ScreenPoint(TempX,TempY));
  if (TempChar = byte(Ribbit))  then
    begin
      Fooding;
      TextColor(Colors[1]);
      GotoXY(RandomRibbitX,RandomRibbitY);
      WriteStr(Ribbit);
      GotoXY(TempX,TempY);
      WriteStr(Blank);
      HeadX := TempX;
      GotoXY(HeadX,HeadY);
      AddNewSnakePixel(HeadX,HeadY);
      WriteSnakeHead;
      Exit;
    end;  { if }
    if  (TempChar = byte(Blank))  then  begin
      HeadX := TempX;
      GotoXY(HeadX,HeadY);
      AddNewSnakePixel(HeadX,HeadY);
      WriteSnakeHead;
      UpdateSnakeTail;
    end  { if }
    else
       GameCycleEnd := true;
end;  { MoveSnakeLeft }

procedure  MoveSnakeRight;
begin
  if  (Direction <> 3)  then  Direction := 3;
  TempX := HeadX;
  TempY := HeadY;
  Inc(TempX);
  TempChar := Lo(ScreenPoint(TempX,TempY));
  if (TempChar = byte(Ribbit))  then
    begin
      Fooding;
      TextColor(Colors[1]);
      GotoXY(RandomRibbitX,RandomRibbitY);
      WriteStr(Ribbit);
      GotoXY(TempX,TempY);
      WriteStr(Blank);
      HeadX := TempX;
      GotoXY(HeadX,HeadY);
      AddNewSnakePixel(HeadX,HeadY);
      WriteSnakeHead;
      Exit;
    end;  { if }
    if  (TempChar = byte(Blank))  then  begin
      HeadX := TempX;
      GotoXY(HeadX,HeadY);
      AddNewSnakePixel(HeadX,HeadY);
      WriteSnakeHead;
      UpdateSnakeTail;
    end  { if }
    else
       GameCycleEnd := true;
end;  { MoveSnakeRight }

procedure  SnakeSmashPicture;
var
  i,j : byte;
  tone : word;
begin
  tone := 600;
  i := 0;
  j := SnakeLen mod 16;
  repeat
    Sound(tone);
    GotoXY(RandomX,RandomY);
    WriteStr(UpBlock);
    GotoXY(RandomX,RandomY);
    WriteStr(LowBlock);
    Inc(i);
    Dec(Tone,10);
    Delay(120);
  until  (i = j);
  NoSound;
end;  { SnakeSmashPicture }

procedure  Game;
var
  i : integer;
  GameEnd : boolean;
  Ch : char;
begin
  GameEnd := false;
  {TextMode(Mono);}
  TextMode(BW80);
  SetCursorType(Hi(CursorSize),Lo(CursorSize));
  repeat
    GameCycleEnd := false;
    Score := 0;
    DrawTitle;
    CursorOff;
    DrawField;
    InitSnake;
    repeat
      while  not(KeyPressed or GameCycleEnd)  do
      begin
        {Pause(SnakeRate*50);}
        DelayTimer2(400);
        case  Direction of
                0  :   MoveSnakeUp;
                1  :   MoveSnakeDown;
                2  :   MoveSnakeLeft;
                3  :   MoveSnakeRight;
        end;  { case }
      end;  { while }
      case   GetKey  of
                #72  :   MoveSnakeUp;
                #80  :   MoveSnakeDown;
                #75  :   MoveSnakeLeft;
                #77  :   MoveSnakeRight;
      end;  { case }
    until  GameCycleEnd;
    SnakeMessage('<<<  SMASH  >>>');
    SnakeSmashPicture;
    TextColor(Colors[1]);
    GotoXY(30,25);
    SetCursorType(Hi(CursorSize),Lo(CursorSize));
    WriteStr('Try again? (Y/N): ');
    FlushKbdBuf;
    Ch := char(ReadKey);
    WriteStr(Ch);
    if (UpCase(Ch) = 'N')  then  GameEnd := true;
  until  GameEnd;
end;  { Game }

begin
  {RestoreInt1B;}
  CursorSize := CursorType;
  InitVars;
  Game;
end.
