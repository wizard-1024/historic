const
  RTLStr : Str52 =
      'TP 6.0 Run-Time Library (C) 1989,1991 Dima Stefankov';
  MyName : Str14 =
      #$11#$A5#$B5#$85#$80#$4D#$D1#$95#$99#$85#$B9#$AD#$BD#$D9;
var
  MyNamePtr : pointer;

procedure  DisplayCopyRightMessage(S1,S2 : AnyString);
{ display the copyright message on screen. }
begin
  WriteLn;
  WriteLnStr(S1); WriteLnStr(S2);
end;  { DisplayCopyRightMessage }
