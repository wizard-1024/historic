{ (c) Copyright 1988, 1999  Dmitry Stefankov }

{$I-,S-}
{$M 8192,0,655360 }

{ use for debugging }
{*** $DEFINE  Debug }

program  SystemMap;
uses
  TpSystem,TpString,TpDos,TpCrt,TpPack,TpKey,TpWindow,TpExtend,TpEms,TpMouse;
type
   DataRecord  =   record           { BIOS/DOS variables }
          Segment  : word;
          Offset   : word;
          DataType : byte;
          DataLen  : byte;
          TimeFlag : byte;
                   end;
   InfoRecord  =   record           { intercept vectors }
          InfoType   : byte;
          DynamicPtr : pointer;
          CookedVecs : byte;
                    end;
   ProgramPtr   =  ^ProgramInfo;
   ProgramInfo  =   record          { resident program description }
	      FirstSeg  : word;
	      LastSeg   : word;
	      Size      : longint;
	      Name      : Str12;
	      Parent    : Str12;
	      Link      : ProgramPtr;
                    end;
const
   MainLen  =  100;    { number of strings for main window }
   Version  =  'V1.17A';
   AddrLine =  6;      { lines in main window }
   MemLine  =  17;
   ParaLine =  30;
   ByteLine =  40;
   NameLine =  51;
   ParLine  =  66;
   LastInfoLine : integer  =  0;  { number of last record }

   LastDataLine  =  113;          { BIOS/DOS data area length }
   DataArray  :  array[1..LastDataLine] of DataRecord  =
     ((Segment :$40; Offset:$0;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$2;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$4;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$6;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$A;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$C;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$E;  DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$10; DataType:4; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$12; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$13; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$15; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$17; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$18; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$19; DataType:2; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$1A; DataType:3; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$1C; DataType:3; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$1E; DataType:3; DataLen:4; TimeFlag:1),
      (Segment :$40; Offset:$26; DataType:3; DataLen:4; TimeFlag:1),
      (Segment :$40; Offset:$2E; DataType:3; DataLen:4; TimeFlag:1),
      (Segment :$40; Offset:$36; DataType:3; DataLen:4; TimeFlag:1),
      (Segment :$40; Offset:$3E; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$3F; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$40; DataType:2; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$41; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$42; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$46; DataType:2; DataLen:3; TimeFlag:0),
      (Segment :$40; Offset:$49; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$4A; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$4C; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$4E; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$50; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$52; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$54; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$56; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$58; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$5A; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$5C; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$5E; DataType:2; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$60; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$62; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$63; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$65; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$66; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$67; DataType:3; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$69; DataType:3; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$6B; DataType:2; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$6C; DataType:5; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$70; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$71; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$72; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$74; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$75; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$76; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$77; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$78; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$7C; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$80; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$82; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$84; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$85; DataType:3; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$87; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$88; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$89; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8A; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8B; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8C; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8D; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8E; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$8F; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$90; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$91; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$92; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$93; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$94; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$95; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$96; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$97; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$98; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$9C; DataType:5; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$A0; DataType:1; DataLen:1; TimeFlag:1),
      (Segment :$40; Offset:$A1; DataType:2; DataLen:4; TimeFlag:1),
      (Segment :$40; Offset:$A5; DataType:2; DataLen:3; TimeFlag:1),
      (Segment :$40; Offset:$A8; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$AC; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$B0; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$B4; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$B8; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$BC; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$C0; DataType:5; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$CE; DataType:3; DataLen:2; TimeFlag:1),
      (Segment :$40; Offset:$D0; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$D1; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$D2; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$E0; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$E1; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$40; Offset:$F0; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$F4; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$F8; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$40; Offset:$FC; DataType:2; DataLen:4; TimeFlag:0),
      (Segment :$50; Offset:$00; DataType:2; DataLen:1; TimeFlag:1),
      (Segment :$50; Offset:$04; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$22; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$23; DataType:1; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$24; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$25; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$26; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$27; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$28; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$29; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$2A; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$2B; DataType:2; DataLen:1; TimeFlag:0),
      (Segment :$50; Offset:$2C; DataType:2; DataLen:1; TimeFlag:0));
   RootPtr : ProgramPtr =  nil;  { info records pointers }
   MarkPtr : ProgramPtr =  nil;
   LastPtr : ProgramPtr =  nil;
   ValidDrives : byte =  0;
   SaveBytes = 20;
   SaveImageFlag  : boolean = false;
   ShellNameFound : boolean = false;
   ComSpec  :  Str7   =  'COMSPEC';
   TSRMap : boolean = false;
   EGAswitch : boolean = false;
var
  MainWindowStr : array[1..MainLen] of Str78;    { global vbariables }
  InfoArray : array[1..MainLen] of InfoRecord; VecWindowStr : array[1..256] of Str76;
  VectorArray : array[0..255] of word; SaveImage : array[0..SaveBytes-1] of byte;
  DefaultShellName : Str12; ExtMem,ExpMem : longint;
  DosSegment,FirstMCB,TopOfMem,FoundMem,Offset,HighSeg : word;
  DeviceListPtr,DosTablePtr,DosBufPtr,DosDrivePtr,
  P2E : pointer; PcDosFlag : boolean;
  TSRInfoLine, SaveVideoMode, SaveVideoLines : byte;
  DeviceList : SegOfs absolute DeviceListPtr;
  DosTables : SegOfs absolute DosTablePtr;
  DosBuffers : SegOfs absolute DosBufPtr;
  DosDrives : SegOfs absolute DosDrivePtr;
  Int2E : SegOfs absolute P2E;
  IntrVecPtr : array[0..255] of pointer absolute $0:$0;
  BiosDate : array[0..8] of char absolute $F000:$FFF5;

{ copyright module. }
{$I HEADER.INC }

function  DefaultName(Index : byte) : Str12;
{ return the predefined name. }
var
  S : Str12;
begin
  case  Index of
      1   :  S := 'IBMBIO.COM';
      2   :  S := 'IBMDOS.COM';
      3   :  S := 'COMMAND.COM';
      4   :  S := 'Free';
      5   :  S := 'Unknown';
      6   :  S := 'Boot Record';
      7   :  S := 'Environment';
      8   :  S := 'IO.SYS';
      9   :  S := 'MSDOS.SYS';
     10   :  S := 'Handle Table';
     11   :  S := 'Memory Block';
     12   :  S := 'FCBs Table';
     13   :  S := 'DOS Buffers';
     14   :  S := 'Drives Table';
     15   :  S := 'DOS Stacks';
     16   :  S := 'Resident';
     17   :  S := 'Transient';
     18   :  S := 'SHARE.EXE';
     19   :  S := 'MOUSE.COM';
     20   :  S := 'TIMEPARK.EXE';
     21   :  S := 'MOUSEKEY.EXE';
  end; { case }
  DefaultName := S;
end;  { DefaultName }

function  ConstructNumber(L : longint) : Str7;
{ converts to string representation. }
begin
  ConstructNumber := Decimal(L div 1000,3,true)+','+Decimal(L mod 1000,3,true);
end;  { ConstructNumber }

function  MakeLong(L : longint) : Str11;
{ converts to string representation. }
begin
  MakeLong := Decimal(L div 1000000,3,true)+','+Decimal(L div 1000,3,true)+','+Decimal(L mod 1000,3,true);
end;  { MakeLong }

function  DeviceDriverName(DeviceSeg, DeviceOfs : word) : Str8;
{ try to find the installed character device driver name. }
var  NameOfs : word; S : Str8; i : byte; Ch : char;
begin
  Move(Mem[DeviceSeg:(DeviceOfs+$0A)],S[1],8);
  S[0] := #8; DeviceDriverName := FilterAsciiString(S,true);
end;  { DeviceDriverName }

function  BlockOwnerName(BlockSeg : word) : Str12;
{ returns a program name owns the speficied memory block. }
var
    SaveSeg,FoundSeg : word;
    i : byte;
    S : AnyString;
begin
  S := '';
  if (BlockSeg = Int2E.S) and (DefaultShellName = DefaultName(3)) then begin  { check for original shell }
    S := DefaultShellName; if not(SaveImageFlag) then begin SaveImageFlag := true;
      Move(Mem[Int2E.S:Int2E.O],SaveImage,SaveBytes); end { if }
  end { if }  else
  { environment present? }
  if (MemW[BlockSeg:$2C] = 0) then S := DefaultShellName
  else  begin
     SaveSeg := PrefixSeg; PrefixSeg := BlockSeg;
     if (MemW[(MemW[PrefixSeg:$2C]-1):1] <> PrefixSeg) then S := DefaultName(5)
     else begin S := ExtractFileName(GetProgramPath);
       if (Pos('.',S) = 0) then S := DefaultShellName;
     end;
     { check for the COMMAND.COM image }
     if (CompareBuffers(Mem[BlockSeg:Int2E.O],SaveImage,SaveBytes) = $FFFF) then S := DefaultShellName;
     if (BlockSeg+$10 = MemW[DosSegment:$96]) then S := DefaultName(18);
     if  (BlockSeg = GetMouseDriverSeg) then S := DefaultName(19);
     if  (S <> '')  then  begin
        asm
           mov   ax,9000h      { TimePark ID }
           sub   bx,bx         { ext ID }
           int   2Fh           { multiplex process }
           sub   ax,ax         { assume that fails }
           cmp   bx,'DS'       { our response? }
           jne   @Done
           mov   ax,9001h      { get info }
           int   2Fh
           mov   ax,bx         { assume that found }
         @Done:
           mov   FoundSeg,ax   { put the segment value }
        end;
        if (BlockSeg = FoundSeg) then  S := DefaultName(20);
     end; { if }
     if  (S <> '')  then  begin
        asm
           mov   ax,9300h      { MouseKey ID }
           sub   bx,bx         { ext ID }
           int   2Fh           { multiplex process }
           sub   ax,ax         { assume that fails }
           cmp   bx,'DS'       { our response? }
           jne   @Done
           mov   ax,9301h      { get info }
           int   2Fh
           mov   ax,bx         { assume that found }
         @Done:
           mov   FoundSeg,ax   { put the segment value }
        end;
        if (BlockSeg = FoundSeg) then  S := DefaultName(21);
     end; { if }
     if (S = '') then S := DefaultName(5);
     PrefixSeg := SaveSeg;
  end;  { else }
  BlockOwnerName := FilterAsciiString(S,false);
end;  { BlockOwnerName }

procedure  ScanIntrVectors(StartSeg,EndSeg : word;ProgLine : integer);
{ build a dynamic table of the cooked vectors. }
var  TempPtr : pointer; VecOffs : word; VecNum,i : byte;
begin
  VecNum := 0;         { assume that no vectors }
  InfoArray[ProgLine].InfoType := 0;  { no info }
  for i := 0 to 255 do
    if (StartSeg <= VectorArray[i]) and (VectorArray[i] <= EndSeg) then Inc(VecNum);
  if (VecNum <> 0) then begin
    GetMem(InfoArray[ProgLine].DynamicPtr,VecNum);
    InfoArray[ProgLine].CookedVecs := VecNum;
    InfoArray[ProgLine].InfoType := 4; VecOffs := 0;
    TempPtr := InfoArray[ProgLine].DynamicPtr;
    for i := 0 to 255 do
      if (StartSeg <= VectorArray[i]) and (VectorArray[i] <= EndSeg) then begin
        Mem[Seg(TempPtr^):Ofs(TempPtr^)+VecOffs] := i; Inc(VecOffs); end; { if }
   end; { if }
end;  { ScanIntrVectors }

function GetFirstMCB : word;
{ *broot force* algorithm to find the 1st DOS MCB. }
const  MemOffset : word = $FFFF; var MemBlockID : char;
begin
  repeat Inc(MemOffset); MemBlockID := char(Mem[MemOffset+MemW[MemOffset:3]+1:$0]);
  until (char(Mem[MemOffset:$0]) = 'M') and ((MemBlockID = 'M') or (MemBlockID = 'Z'));
  GetFirstMCB := MemOffset;
end; { GetFirstMCB }

procedure  InitVars;
{ initialize variables }
var  i : integer;
begin
  {$IFDEF Debug }
    WriteLnStr('*** Initialize internal variables ***');
  {$ENDIF}
  P2E := GetIntVec($2E);   { get INT $2E }
  { undocumented feature, used by bootstrap loader. }
  PcDosFlag := (Mem[$50:$21] = byte('B'));
  { undocumented DOS call }
  DosSegment := DosInVars; FirstMCB := GetFirstMCB;
  { a first MCB scan separately }
  Offset := FirstMCB + 1 + MemW[FirstMCB:3];
  { DOS versions differences }
  case CurDosVer of
     $0314,$031E,$031F : TopOfMem := MemW[DosSegment:$2F2];
     $0400,$0500,$0600,$60A,$0614,$0615,$0616 
                       : TopOfMem := MemW[DosSegment:$346];
     $0700,$070A : TopOfMem := MemW[DosSegment:$346];
  else TopOfMem := GetMemorySize;
  end; { case }
  { read a IDT }
  for  i := 0  to 255  do
    VectorArray[i] := (MemW[0:i*4+2]) + (MemW[0:i*4] shr 4);
  { initialize the info structures }
  for  i := 1 to  MainLen  do  begin
    MainWindowStr[i] := CharStr(Blank,SizeOf(Str78)-1);
    with  InfoArray[i]  do  begin
      InfoType := 0;           { no info }
      DynamicPtr := nil;       { no dynamic info }
      CookedVecs := 0;         { no intercept vectors }
    end;  { with }
  end;  { for }
  DefaultShellName := DefaultName(3);
end;  { InitVars }

procedure  PCGeneralVars;
{ look the first data areas. }
var  S : AnyString; TempPtr : pointer; VecOffs : word; i : byte;
begin
  {$IFDEF Debug }
    WriteLnStr('*** See areas from 0:0 to 70:0 ***');
  {$ENDIF}
  { 1st data area }
  OverWriteStr(HexWord($0),MainWindowStr[1],AddrLine);
  OverWriteStr('system',MainWindowStr[1],18);
  OverWriteStr(HexWord($400 shr 4),MainWindowStr[1],ParaLine);
  OverWriteStr(ConstructNumber($400),MainWindowStr[1],ByteLine);
  OverWriteStr('Interrupt Descriptor Table',MainWindowStr[1],NameLine);
  Inc(LastInfoLine); InfoArray[1].InfoType := 1;
  GetMem(InfoArray[1].DynamicPtr,256);
  InfoArray[1].CookedVecs := $FF;
  VecOffs := 0; TempPtr := InfoArray[1].DynamicPtr;
  for i := 0 to 255 do  begin
     Mem[Seg(TempPtr^):Ofs(TempPtr^)+VecOffs] := i; Inc(VecOffs);
  end;  { for }
  { 2nd data area }
  OverWriteStr(HexWord($40),MainWindowStr[2],AddrLine);
  OverWriteStr('system',MainWindowStr[2],18);
  OverWriteStr(HexWord($100 shr 4),MainWindowStr[2],ParaLine);
  OverWriteStr(ConstructNumber($100),MainWindowStr[2],ByteLine);
  OverWriteStr('BIOS  RAM  data  Area',MainWindowStr[2],NameLine);
  Inc(LastInfoLine); InfoArray[2].InfoType := 2;
  { 3rd data area }
  OverWriteStr(HexWord($50),MainWindowStr[3],AddrLine);
  OverWriteStr('scratch',MainWindowStr[3],MemLine);
  OverWriteStr(HexWord($200 shr 4),MainWindowStr[3],ParaLine);
  OverWriteStr(ConstructNumber($200),MainWindowStr[3],ByteLine);
  OverWriteStr('DOS  Communication  Area',MainWindowStr[3],NameLine);
  Inc(LastInfoLine); ScanIntrVectors($50,$70,LastInfoLine);
end;  { PCGeneralVars }

function DefaultParent : Str12;
{ based on the DOS switch. }
var  S : Str12;
begin
  if  (PcDosFlag)  then S := DefaultName(1)  else S := DefaultName(8);
  DefaultParent := S;
end; { DefaultParent }

procedure  IbmBioInfo;
{ build info block for 1st Dos system file. }
var
  P : ProgramPtr;
begin
   {$IFDEF Debug }
    WriteLnStr('*** First system file ***');
  {$ENDIF}
   New(P); RootPtr := P; LastPtr := P; Inc(LastInfoLine);
   with  P^  do  begin
      FirstSeg := $70; LastSeg := DosSegment - 1; Size := LongIntSize(FirstSeg,DosSegment);
      Link := nil;
      Name := DefaultParent;
      Parent := DefaultName(6);
   end;  { with }
end;  { IbmBioInfo }

procedure  IbmDosInfo;
{ build info block for 2nd Dos system file. }
var  P : ProgramPtr;
begin
   {$IFDEF Debug }
    WriteLnStr('*** Second system file ***');
  {$ENDIF}
   New(P); LastPtr^.Link := P; LastPtr := P; MarkPtr := P; Inc(LastInfoLine);
   with  P^  do  begin
      FirstSeg := DosSegment; LastSeg := FirstMCB-1; Size := LongIntSize(DosSegment,FirstMCB);
      if (PcDosFlag) then Name := DefaultName(2) else  Name := DefaultName(9);
      Parent := DefaultParent; Link := nil;
   end;  { with }
end;  { IbmDosInfo }

procedure  ScanListOfDeviceDrivers;
{ scan the list of device drivers. }
const  DriveOffset : word = $51; HandleOffset : word = $35;
var  P : ProgramPtr; TempPtr : pointer; DevicePtr : SegOfs absolute TempPtr;
     NextDeviceSeg,FCBstart,TempBufSeg : word; DosBufSeg: word  absolute  NextDeviceSeg;
     FullSize : longint; i : byte;
begin
    {$IFDEF Debug }
       WriteLnStr('*** Enter section for DOS data blocks ***');
    {$ENDIF}
    { undocumented DOS absolute addresses used here }
    DeviceListPtr := Ptr(DosSegment,$48);
    DosTablePtr := Ptr(DosSegment,$2A); DosTablePtr := NextPointer(DosTablePtr);
    if (DosTables.O <> $FFFF) then DosTablePtr := NextPointer(DosTablePtr)
    else ;
    { try to find the FCB area beginning. }
    {$IFDEF Debug }
       WriteLnStr('*** Try to find FCB area ***');
    {$ENDIF}
    TempBufSeg := DosSegment;
    repeat
      TempPtr := Ptr(TempBufSeg,$0);
      FCBstart := SearchString(TempPtr,$8000,#0#0'AAAA');
      if (FCBstart = $FFFF) then Inc(TempBufSeg,$800)
      else FCBstart := TempBufSeg + ((FCBstart - 6) shr 4);
    until (FCBstart <> $FFFF);
    { check for the installed device drivers, $0070 - BIOS resident drivers segment }
    {$IFDEF Debug }
       WriteLnStr('*** Scan installed device drivers ***');
    {$ENDIF}
    if  (MemW[DeviceList.S:DeviceList.O+2] <>  $0070)  then
    begin
      TempPtr := NextPointer(DeviceListPtr);
      New(P); LastPtr^.Link := P; LastPtr := P;
      with  P^  do  begin
        FirstSeg := DevicePtr.S;
        if (DosTables.O <> $FFFF) then LastSeg := DosTables.S - 1
        else LastSeg := FCBStart-1;
        Size := LongIntSize(FirstSeg,LastSeg+1); Link := nil;
        { character or block device? }
        if  ((MemW[DevicePtr.S:$04] and $8000) = 0)  then
          Name := ByteToString(Mem[DevicePtr.S:$0A]) + ' units'
        else  Name := DeviceDriverName(DevicePtr.S,DevicePtr.O);
        Parent := DefaultParent;
      end;  { with }
      Inc(LastInfoLine); FullSize := P^.Size;
      NextDeviceSeg := DevicePtr.S; TempPtr := NextPointer(TempPtr);
      while  (DevicePtr.S <> $0070)  do  begin  New(P);
      with  P^  do begin
        FirstSeg := DevicePtr.S;  LastSeg := NextDeviceSeg - 1;
        if  (NextDeviceSeg = DevicePtr.S)  then  Size := FullSize
        else  Size := LongIntSize(FirstSeg,LastSeg+1);
        Link := MarkPtr^.Link;  MarkPtr^.Link := P;
        { character or block device? }
        if ((MemW[DevicePtr.S:$04] and $8000) = 0)  then
          Name := ByteToString(Mem[DevicePtr.S:$0A]) + ' units'
        else  Name := DeviceDriverName(DevicePtr.S,DevicePtr.O);
        Parent := DefaultParent;
      end;  { with }
      Inc(LastInfoLine); TempPtr := NextPointer(TempPtr); FullSize := P^.Size;
      if (DevicePtr.S <> P^.FirstSeg) then NextDeviceSeg := P^.FirstSeg;
      end;  {  do  }
    end; { if }
  { DOS Handles table }
  {$IFDEF Debug }
       WriteLnStr('*** Build info struc about DOS handle tables ***');
  {$ENDIF}
  if (DosTables.S <> $FFFF) then begin
  New(P); LastPtr^.Link := P; LastPtr := P; Inc(LastInfoLine);
  if (CurDosVer >= $0400) then HandleOffset := $3B;
  with  P^  do  begin
    FirstSeg := DosTables.S; LastSeg := FirstSeg + (HandleOffset * MemW[DosTables.S:DosTables.O + 4]+6+15) shr 4;
    Size := LongIntSize(FirstSeg,LastSeg+1); Link := nil;
    Name := DefaultName(10); Parent := DefaultParent;
  end;  { with }
  end; { if }
  { now process FCB table }
  {$IFDEF Debug }
       WriteLnStr('*** Build info struc about DOS FCB tables ***');
  {$ENDIF}
  New(P); LastPtr^.Link := P; LastPtr := P; Inc(LastInfoLine);
  with  P^  do  begin
    FirstSeg := FCBstart; LastSeg := FirstSeg + (HandleOffset * MemW[FCBstart:4]+6+15) shr 4;
    if (CurDosVer < $0400) then Dec(LastSeg);
    Size := LongIntSize(FirstSeg,LastSeg+1); Link := nil;
    Name := DefaultName(12);  Parent := DefaultParent;
    DosBufSeg := LastSeg+1;
  end;  { with }
  { DOS buffers }
  {$IFDEF Debug }
       WriteLnStr('*** Build info struc about DOS disk buffers ***');
  {$ENDIF}
  DosBufPtr := Ptr(DosSegment,$38);
  DosDrivePtr := Ptr(DosSegment,$3C); DosDrivePtr := NextPointer(DosDrivePtr);
  if  (CurDosVer < $0400)  then  begin
  DosBufPtr := NextPointer(DosBufPtr); TempBufSeg := DosBuffers.S;
  while  (DosBuffers.S <> $FFFF)  do  begin
    DosBufPtr := NextPointer(DosBufPtr);
    if (DosBuffers.S > TempBufSeg) and (DosBuffers.S <> $FFFF) then TempBufSeg := DosBuffers.S;
  end;  { while }
  New(P); LastPtr^.Link := P; LastPtr := P;
  with  P^  do  begin
    FirstSeg := DosBufSeg; LastSeg := TempBufSeg + MemW[DosSegment:$36] shr 4;
    Size := LongIntSize(FirstSeg,LastSeg+1); Link := nil;
    Name := DefaultName(13); Parent := DefaultParent;
  end;  { with }
  end
  else  begin
    { I'm not know the link scheme for DOS V4.0 }
    New(P);  LastPtr^.Link := P; LastPtr := P;
    DosBufPtr := NextPointer(DosBufPtr); DosBufPtr := NextPointer(DosBufPtr);
    with  P^  do  begin
      FirstSeg := DosBuffers.S;  LastSeg := DosDrives.S-1;
      Size := LongIntSize(FirstSeg,LastSeg+1); Link := nil;
      Name := DefaultName(13);  Parent := DefaultParent;
    end;  { with }
  end;  { if }
  Inc(LastInfoLine);
  { DOS Drives Table }
  {$IFDEF Debug }
       WriteLnStr('*** Build info struc about DOS drives tables ***');
  {$ENDIF}
  if  (CurDosVer >= $0400)  then  DriveOffset := $58;
  New(P); LastPtr^.Link := P; LastPtr := P;
  with  P^  do  begin
    FirstSeg := DosDrives.S;
    LastSeg := DosDrives.S + (DriveOffset * Mem[DosSegment:$47] + 15) shr 4 - 1;
    TempBufSeg := LastSeg + 1; Size := LongIntSize(FirstSeg,LastSeg+1);
    Link := nil; Name := DefaultName(14);  Parent := DefaultParent;
  end;  { with }
  Inc(LastInfoLine);
  { find the number of the valid DOS logical drives. }
  for i := 0  to  (TpDos.DosDrives-1)   do
    if (Ptr(MemW[DosDrives.S:(DosDrives.O+$45+DriveOffset*i)],MemW[DosDrives.S:(DosDrives.O+$47+DriveOffset*i)]) <> nil)
      then  Inc(ValidDrives);
  { check for the DOS stack pool }
  if  (Offset > TempBufSeg) then  begin
     New(P);  LastPtr^.Link := P;  LastPtr := P; Inc(LastInfoLine);
     with  P^  do  begin
       FirstSeg :=  TempBufSeg; LastSeg := Offset - 1; Size := LongIntSize(FirstSeg,LastSeg+1);
       Link := nil; Name := DefaultName(15); Parent := DefaultParent;
     end;  { with }
  end;
end;  { ScanListOfDeviceDrivers }

procedure  BuildInfoBlock(MCBSeg : word);
{ builds a program info block. }
var  P : ProgramPtr; Owner, MemBlockSize : word; S : AnyString;
begin
  if  not(ShellNameFound)  then  begin
    Owner := SearchString(Ptr(MCBSeg+1,$0),MemBlockSize shl 4,ComSpec);
    if  (Owner <> $FFFF)  then  begin
       DefaultShellName := ExtractFileName(AsciizFromBuffer(AddPtr(Ptr(MCBSeg+1,$0),Owner+Length(ComSpec)+1)));
       ShellNameFound := true;
    end; { if }
  end;  { if }
  MemBlockSize := MemW[MCBSeg:3];
  New(P); LastPtr^.Link := P; LastPtr := P; Inc(LastInfoLine);
  with  P^  do  begin
    FirstSeg := MCBSeg + 1; LastSeg := MCBSeg + MemBlockSize;
    Size := Longint(MemBlockSize) shl 4; Owner := MemW[MCBSeg:1];
    case   Owner   of
       0 : begin  Name := DefaultName(4);      { free block }
		  Parent := DefaultName(5); end;
       else   if  (MemW[MCBSeg+1:0] = $20CD)  then  begin  { PSP? }
	    Name := BlockOwnerName(Owner); Parent := BlockOwnerName(MemW[Owner:$16]);
            if (Parent = Name) and (Name = DefaultShellName)  then Parent := DefaultName(16);
	  end
	  else   begin
	      Name := BlockOwnerName(Owner);
              if  (SearchString(Ptr(MCBSeg+1,$0),MemBlockSize shl 4,ComSPec+'=') <> $FFFF)  then
                 Parent := DefaultName(7)
              else
              if  (SearchString(Ptr(MCBSeg+1,$0),MemBlockSize shl 4,'PATH=') <> $FFFF)  then
                 Parent := DefaultName(7)
                    else  Parent := DefaultName(11);
	  end;  { else }
    end;
    Link := nil;
  end;  { while }
end;  { BuildInfoBlock }

procedure  ConventionalMemoryTest;
{ test the high memory up 640K. }
begin
   {$IFDEF Debug }
       WriteLnStr('*** Test conventional memory ***');
   {$ENDIF}
   FoundMem := TopOfMem;
   if (CurDosVer <> $0401) then
   while ((TestOneMemPara(FoundMem)) and (FoundMem < $A000)) do Inc(FoundMem);
end;  { ConventionalMemoryTest }

procedure  SearchAllMemoryBlocks;
{ searchs all Dos memory blocks. }
var  TempMCB : word;
begin
  {$IFDEF Debug }
       WriteLnStr('*** Find all MCB links ***');
  {$ENDIF}
  repeat
  {$IFDEF Debug }
       WriteStr(HexWord(Offset)+' ');
  {$ENDIF}
  BuildInfoBlock(Offset); TempMCB := Offset;
  Inc(Offset,MemW[Offset:3]+1);
  until  (Mem[Offset:0] = $5A);
  {$IFDEF Debug }
       WriteLnStr('last: '+HexWord(Offset));
  {$ENDIF}
  HighSeg := Offset+1+MemW[Offset:3];
  if (TSRMap) then Offset := TempMCB else BuildInfoBlock(Offset);
end;  { SearchAllMemoryBlocks }

procedure  ExtendedMemoryTest;
{ finds the memory above 1 Mbyte. }
var  TotalSize : word; ErrorCode : boolean;
begin
  {$IFDEF Debug }
       WriteLnStr('*** Test extended memory ***');
  {$ENDIF}
  ExtMem := longint(ExtendedMemSize) shl 10;
end;  { ExtendedMemoryTest }

procedure  ExpandedMemoryTest;
{ finds the EMS LIM 3.0-4.0 }
begin
  {$IFDEF Debug }
       WriteLnStr('*** Test expanded memory ***');
  {$ENDIF}
  ExpMem := 0; if (EmsInstalled) then  ExpMem := longint(EmsTotalPages) shl 14;
end;  { ExpandedMemoryTest }

procedure  ConvertInfoToText;
{ writes the info text to the window string. }
const  CurrentLine : byte  =  4-1;    { don't update this value! }
       SaveSeg : word  =  $C000;
var  P,L  : ProgramPtr; RomPtr : pointer;
     TempL : longint; NameID,ParentID : Str12;
     RomSeg : word; MemBID : char; CardType, j : byte; Done : boolean;

begin
  { other areas }
  {$IFDEF Debug }
    WriteLnStr('*** Scan the program areas ***');
  {$ENDIF}
  P := RootPtr;
  repeat  Inc(CurrentLine);
    with  P^  do  begin
       if (TSRMap) then j := 1 else j := 6;
       OverWriteStr(HexWord(FirstSeg),MainWindowStr[CurrentLine],j);
       if (TSRMap) then else begin
       MemBID := char(Mem[FirstSeg-1:0]);
       if  (MemBID = 'M') or (MemBID = 'Z') then
          OverWriteStr(HexWord(MemW[FirstSeg-1:1]),MainWindowStr[CurrentLine],18)
       else  begin
           NameID := 'No MCB'; j := 18;
           case  CurrentLine  of
             4 : begin NameID := 'DOS-Low'; j := MemLine; end;
             5 : begin NameID := 'DOS-High'; j := MemLine; end;
           end;
           OverWriteStr(NameID,MainWindowStr[CurrentLine],j);
       end;  { else }
       end; { if }
       if (TSRMap) then begin
         TempL := Size+5; NameID := Decimal(TempL div 1024,3,false)+'.'+LeftStr(Decimal(TempL mod 1024,3,true),2);
         j := Pos('.',NameID); if (j < 4) then begin
           ParentID := CharStr(' ',4 -j); Insert(ParentID,NameId,1);
         end; { if }
         OverWriteStr(NameID,MainWindowStr[CurrentLine],8);
         OverWriteStr(Name,MainWindowStr[CurrentLine],MemLine);
         OverWriteStr(Parent,MainWindowStr[CurrentLine],32);
       end
       else begin
         OverWriteStr(HexWord(Size shr 4),MainWindowStr[CurrentLine],ParaLine);
         OverWriteStr(ConstructNumber(Size),MainWindowStr[CurrentLine],ByteLine);
         OverWriteStr(Name,MainWindowStr[CurrentLine],NameLine);
         OverWriteStr(Parent,MainWindowStr[CurrentLine],ParLine);
       end; { if }
       ScanIntrVectors(FirstSeg,LastSeg,CurrentLine);
    end;  { with }
    L := P; Dispose(L); P := P^.Link;
  until (P = nil);
  if (TSRMap) then  { nothing }  else begin
  { try to find the transient part of shell }
  {$IFDEF Debug }
    WriteLnStr('*** Transient part of DOS shell ***');
  {$ENDIF}
  RomSeg := SearchString(P2E,$800,#$2B#$D8#$2E#$89#$1E);
  if  (RomSeg <> $FFFF)  then  begin
     Inc(RomSeg,Int2E.O);
     RomSeg := MemW[Int2E.S:RomSeg+5]; RomSeg := MemW[Int2E.S:RomSeg];
     Inc(LastInfoLine); TempL := LongIntSize(RomSeg,HighSeg);
     OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
     OverWriteStr('no MCB',MainWindowStr[LastInfoLine],18);
     OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
     OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
     OverWriteStr(DefaultShellName,MainWindowStr[LastInfoLine],NameLine);
     OverWriteStr('Transient',MainWindowStr[LastInfoLine],ParLine);
     ScanIntrVectors(RomSeg,HighSeg,LastInfoLine);
  end;  { if }
  { for DOS 5+ }
  RomSeg := SearchString(P2E,$800,#$50#$03#$C3#$2B#$C2#$A3);
  if  (RomSeg <> $FFFF)  then  begin
     Inc(RomSeg,Int2E.O);
     RomSeg := MemW[Int2E.S:RomSeg+6]; RomSeg := MemW[Int2E.S:RomSeg];
     Inc(LastInfoLine); TempL := LongIntSize(RomSeg,HighSeg);
     OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
     OverWriteStr('no MCB',MainWindowStr[LastInfoLine],18);
     OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
     OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
     OverWriteStr(DefaultShellName,MainWindowStr[LastInfoLine],NameLine);
     OverWriteStr('Transient',MainWindowStr[LastInfoLine],ParLine);
     ScanIntrVectors(RomSeg,HighSeg,LastInfoLine);
  end;  { if }  
  { if the last memory block cuted. }
  {$IFDEF Debug }
    WriteLnStr('*** Check that last MCB no cuted ***');
  {$ENDIF}
  if  (TopOfMem <> HighSeg)  then  begin     { if where }
       Inc(LastInfoLine); NameID := DefaultName(5); ParentID := DefaultShellName;
       RomSeg := HighSeg; MemBID := char(Mem[RomSeg:0]);
       if  (MemBID = 'M') or (MemBID = 'Z')  then  begin
         case   MemW[RomSeg:1]  of
            0 : begin NameID := DefaultName(4); ParentID := DefaultName(5); end;
            else if  (MemW[RomSeg+1:0] = $20CD)  then  begin
                   NameID := BlockOwnerName(RomSeg+1);
                   ParentID := BlockOwnerName(MemW[RomSeg+1:$16]);
                 end
                   else  begin NameID := DefaultName(11); ParentID := DefaultShellName; end; { else }
         end;
         Inc(RomSeg);
       end;
       OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
       MemBID := char(Mem[RomSeg-1:0]); TempL := LongIntSize(RomSeg,TopOfMem);
       if  (MemBID = 'M') or (MemBID = 'Z') then
          OverWriteStr(HexWord(MemW[RomSeg-1:1]),MainWindowStr[LastInfoLine],18)
       else  OverWriteStr('no MCB',MainWindowStr[LastInfoLine],18);
       OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
       OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
       OverWriteStr(NameID,MainWindowStr[LastInfoLine],NameLine);
       OverWriteStr(ParentID,MainWindowStr[LastInfoLine],ParLine);
       ScanIntrVectors(RomSeg,TopOfMem,LastInfoLine);
  end;
  { if active memory not used. }
  {$IFDEF Debug }
    WriteLnStr('*** Check for unused memory on top ***');
  {$ENDIF}
   if  (FoundMem > TopOfMem)  then  begin     { if where }
    Inc(LastInfoLine); TempL := LongIntSize(TopOfMem,FoundMem);
    OverWriteStr(HexWord(TopOfMem),MainWindowStr[LastInfoLine],AddrLine);
    OverWriteStr('no MCB',MainWindowStr[LastInfoLine],18);
    OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
    OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
    OverWriteStr('Not used-active Memory',MainWindowStr[LastInfoLine],NameLine);
    ScanIntrVectors(TopOfMem,FoundMem,LastInfoLine);
   end; { if }
  { common video memory }
  {$IFDEF Debug }
    WriteLnStr('*** Test for video memory ***');
  {$ENDIF}
  RomSeg := $A000;
  Inc(LastInfoLine); TempL := LongIntSize(RomSeg,$C000);
  OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
  OverWriteStr('Video-RAM',MainWindowStr[LastInfoLine],MemLine);
  OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
  OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
  OverWriteStr('Used by video adapter',MainWindowStr[LastInfoLine],NameLine);
  ScanIntrVectors(RomSeg,$BFFF,LastInfoLine);
  { ROM Extensions }
  {$IFDEF Debug }
    WriteLnStr('*** Scan ROM extensions ***');
  {$ENDIF}
  RomSeg := $C000; j := 0;
  repeat
    {$IFDEF Debug }
      WriteStr(HexWord(RomSeg)+' ');
    {$ENDIF }
    if  (MemW[RomSeg:$0] = $AA55) or (MemW[RomSeg:$0] = $55AA) then begin
     if (j <> 0)  then  begin
       Inc(LastInfoLine); TempL := longint(j*$80) shl 4;
       OverWriteStr(HexWord(SaveSeg),MainWindowStr[LastInfoLine],AddrLine);
       OverWriteStr('SPECIAL',MainWindowStr[LastInfoLine],MemLine);
       OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
       OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
       OverWriteStr('Reserved ROM Space',MainWindowStr[LastInfoLine],NameLine);
       ScanIntrVectors(SaveSeg,RomSeg-1,LastInfoLine);
       j := 0;
     end;  { if }
    {$IFDEF Debug }
      WriteLn;  { skip to next line if ROM CARD present }
    {$ENDIF }
    TempL := longint(Mem[RomSeg:2]) shl 9;
    if (TempL > $10000) then TempL := $1000;
    Inc(LastInfoLine);
    OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
    OverWriteStr('Read-Only',MainWindowStr[LastInfoLine],MemLine);
    OverWriteStr('ROM BIOS Extension Card',MainWindowStr[LastInfoLine],NameLine);
    OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
    OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
    ScanIntrVectors(RomSeg,RomSeg + ((TempL shr 4) - 1),LastInfoLine);
    Inc(RomSeg,TempL div 16); SaveSeg := RomSeg;
       end  { else }
    else  begin  Inc(RomSeg,$80); Inc(j)  end;
  until  (RomSeg >= $F800);
  {$IFDEF Debug }
      WriteLn;
      WriteStr(HexWord(j)+' ');
      WriteStr(HexWord(RomSeg)+' ');
      WriteLnStr(HexWord(SaveSeg)+' ');
   {$ENDIF }
  { save the info }
  { motherboard ROM }
  {$IFDEF Debug }
    WriteLnStr('*** see what motheboard ROM BIOS ***');
  {$ENDIF}
  RomSeg := $FE00; Done := false;
  repeat
    RomPtr := Ptr(RomSeg,$0); Done := (BytesCheckSum(RomPtr,($10000-RomSeg) shl 4) = 0);
    if not(Done) then  Dec(RomSeg,$200);
  until  (Done) or (RomSeg = $F000);
    {$IFDEF Debug }
      WriteLnStr(HexWord(RomSeg)+' ');
    {$ENDIF }
  if (j <> 0)  then  begin
    Inc(LastInfoLine); TempL := longint(RomSeg-SaveSeg) shl 4;
    OverWriteStr(HexWord(SaveSeg),MainWindowStr[LastInfoLine],AddrLine);
    OverWriteStr('SPECIAL',MainWindowStr[LastInfoLine],MemLine);
    OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
    OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
    OverWriteStr('Reserved ROM Space',MainWindowStr[LastInfoLine],NameLine);
    ScanIntrVectors(SaveSeg,RomSeg-1,LastInfoLine);
  end
  else  if (RomSeg < SaveSeg) then RomSeg := SaveSeg;
  Inc(LastInfoLine); TempL := ($10000 - RomSeg) shl 4;
  OverWriteStr(HexWord(RomSeg),MainWindowStr[LastInfoLine],AddrLine);
  OverWriteStr('Read-Only',MainWindowStr[LastInfoLine],MemLine);
  OverWriteStr(HexWord(TempL shr 4),MainWindowStr[LastInfoLine],ParaLine);
  OverWriteStr(ConstructNumber(TempL),MainWindowStr[LastInfoLine],ByteLine);
  OverWriteStr('System   ROM   BIOS',MainWindowStr[LastInfoLine],NameLine);
  ScanIntrVectors(RomSeg,$FFFF,LastInfoLine);
 end; { if }
end;  { ConvertInfoToText }

procedure  DrawHelpScreen;
{ display a user help window. }
var  HelpBufPtr : pointer; RevAttr, HelpHandle : byte;
begin
   RevAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
                HiNibble(TextAttr),HelpBufPtr,true,false,0,HelpHandle);
   DecryptE(MyNamePtr,Length(MyName));
   OpenWindow(HelpHandle); ClrScr;
   WindowFrames(HelpHandle,LeftUpperFrames[1],LeftLowerFrames[1],RightUpperFrames[1],
       RightLowerFrames[1],HorizFrames[1],VertFrames[1],' Help Window ',' ESC to exit ',
       RevAttr,RevAttr);
   WriteLnStr(' The SYSMAP Utility was written by '+MyName+', Moscow (095) 944-6304');
   EncryptE(MyNamePtr,Length(MyName));
   WriteLnStr(' Important Note: the supported DOS Versions => 3.2 - 7.10, 10.0 (OS/2 1.xx)');
   WriteLnStr('               (My acknowledgements to my friends.)');
   WriteLnStr(' 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
   WriteLnStr('  CURSOR  Movement:  Up Arrow,Down Arrow,Home,End,PgUp,PgDn keys');
   WriteLnStr('  CONTROL Keys:  CR -- next screen, ESC -- exit , F3 -- memory dump');
   WriteLnStr(' 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
   WriteLnStr('                      Registered  Trademarks  of');
   WriteLnStr('   International Business Machine Corp., COMPAQ Corp., Microsoft Corp.,');
   WriteLnStr('   Borland International Inc., Hewlett-Packard Corp., Logitech Corp.,');
   WriteLnStr('   Quarterdeck Office Systems, Digital Equipment Corp., Intel Corp.,');
   WriteStr('   Digital Research Corp., Lotus Development Company, Western Digital Inc.');
   repeat  until (ReturnChar(ReadKey) = ESC);
   CloseWindow(HelpHandle);
end;  { DrawHelpScreen }

procedure  InitializeDataRecords;
{ decodes the info array elements. }
var  i : integer; S : AnyString; L : longint; W : word; B : byte;
begin
  for  i := 1 to  256  do VecWindowStr[i] := CharStr(Blank,SizeOf(Str76)-1);
  for i := 1  to  LastDataLine  do
    with  DataArray[i] do  begin
    OverWriteStr(HexWord(Segment)+':'+HexWord(Offset),VecWindowStr[i],3); S := '';
    case  DataType  of
            1  :   begin B := Mem[Segment:Offset]; S := HexByte(B)+'['+BitByte(B,'0','1')+']'; end;
            2  :   for B := 0 to DataLen-1 do  S := S + HexByte(Mem[Segment:(Offset+B)])+Blank;
            3  :   for W := 0 to DataLen-1 do  S := S + HexWord(MemW[Segment:(Offset+2*W)])+Blank;
            4  :   begin W := MemW[Segment:Offset]; S := HexWord(W)+'['+BitWord(W,'0','1')+']'; end;
            5  :   S := HexWord(MemW[Segment:Offset])+Blank+HexWord(MemW[Segment:Offset+2]);
    end;   { case }
    OverWriteStr(S,VecWindowStr[i],15);
           case   i  of
   1..4 : S := 'RS-232 Line Port Base Address COM'+char(i+$30)+':';
   5..8 : S := 'Printer Port Base Address LPT'+char(i+$30-4)+':';
      9 : S := 'Installed  Equipment/Hardware';
     10 : S := 'Init Test Flag,PC-Conv POST Status';
     11 : S := 'Memory Size in 1K units';
     12 : S := 'POST scratch, PC-Conv Battery Status';
     13 : S := 'Keyboard Shift Status';
     14 : S := 'Keyboard Extended Shift Status';
     15 : S := 'Alternate Keypad Entry';
     16 : S := 'Keyboard Buffer Head Pointer';
     17 : S := 'Keyboard Buffer Tail Pointer';
     18 : S := 'Keyboard Buffer (length = 16 words)';
     19 : S := '   head = tail (empty buffer)';
     22 : S := 'Diskette Drive Recalibrate Status';
     23 : S := 'Diskette Drive Motor Status';
     24 : S := 'Motor Off Counter';
     25 : S := 'Last Diskette Drive Operation Status';
     26 : S := 'Diskette Drive Controller Status Info';
     27 : S := '    (length = 7 bytes)';
     28 : S := 'Display Mode';
     29 : S := 'Number of video columns';
     30 : S := 'Length of Regen Buffer (in bytes)';
     31 : S := 'Starting Address of Regen Buffer';
 32..39 : S := 'Cursor Position for Page '+char(i-32+$30)+' (Column,Row)';
     40 : S := 'Cursor End Scan Line & Start Scan Line';
     41 : S := 'Current Display Page';
     42 : S := 'CRT Controller Base Address';
     43 : S := 'Setting of the Mode Control Register';
     44 : S := 'Setting of the Color Select Register';
     45 : S := 'ROM initialization offset pointer';
     46 : S := 'ROM initialization segment pointer';
     47 : S := 'Unused interrupt occurred flag';
     48 : S := '8253 Timer Counter (longint)';
     49 : S := 'Timer Overflow Flag (rolled)';
     50 : S := 'Break Key State (bit 7=1 if pressed)';
     51 : S := 'Reset Flag State (warm-boot start,etc)';
     52 : S := 'Last Fixed Disk Operation Status';
     53 : S := 'Number of fixed disks';
     54 : S := 'XT-hard disk head control byte options';
     55 : S := 'XT-hard disk control port (rel. 320h)';
     56 : S := 'Time-Out Values for Parallel Printers';
     57 : S := 'Time-Out Values for RS-232 Comm. Lines';
     58 : S := 'Keyboard Buffer Start Offset Offset';
     59 : S := 'Keyboard Buffer End Offset Pointer';
     60 : S := 'Number of char rows-1, EGA/VGA';
     61 : S := 'Number of bytes per char, EGA/VGA';
     62 : S := 'EGA video options/info';
     63 : S := 'EGA feature bits/DIP switches';
  64,65 : S := 'Video Card reserved byte';
     66 : S := 'Diskette Media Control Byte';
     67 : S := 'Fixed Disk Controller Status';
     68 : S := 'Fixed Disk Controller Error Status';
     69 : S := 'Fixed Disk Interrupt Control Byte';
     70 : S := 'Hard-File Card Options Byte';
     71 : S := 'Diskette Drive 0 Media State';
     72 : S := 'Diskette Drive 1 Media State';
     73 : S := 'Diskette Drive 0 Initial Media State';
     74 : S := 'Diskette Drive 1 Initial Media State';
     75 : S := 'Diskette Drive 0 Current Track';
     76 : S := 'Diskette Drive 1 Current Track';
     77 : S := 'Advanced Keyboard Status and Type Flags';
     78 : S := 'Advanced Keyboard LED Status';
     79 : S := 'Pointer to User Wait Complete Flag';
     80 : S := 'User Wait Count (microseconds)';
     81 : S := 'Wait Active Flag (RTC)';
     82 : S := 'Local Area Network data (Reserved)';
     83 : S := '       (length = 7 bytes)';
     84 : S := 'EGA/VGA Video Parameter Table Pointer';
     85 : S := '??EGA/VGA Dynamic Parameter Save Area';
     86 : S := '??EGA/VGA Text Mode Aux Font Area';
     87 : S := '??EGA/VGA Graphic Mode Aux Font Area';
     88 : S := '??VGA Secondary Save Area Pointer';
 89..90 : S := 'Video Cards Reserved';
     91 : S := 'Days past since 1 January 1980';
     92 : S := 'Diskette Drive 0 Media State (HP)';
     93 : S := 'Diskette Drive 1 Media State (HP)';
     94 : S := 'Hewlett-Packard Machine ID byte';
     95 : S := 'Diskette Drive 0 Media State (Apricot)';
     96 : S := 'Diskette Drive 1 Media State (Apricot)';
     97 : S := 'Intra-Application Communications Area';
    100 : S := '      (length = 16 bytes)';
    101 : S := 'Print Screen Status byte';
    102 : S := 'Phantom Drive Flag (Logical Drive)';
    103 : S := '4-7 Step Rate Time,0-3 Head Unload Time';
    104 : S := '0=1 use DMA, 2-7 Head Load Time';
    105 : S := 'Motor Off Wait Time (55 ms incrs)';
    106 : S := 'Sector Size (0=128,1=256,2=512,3=1024)';
    107 : S := 'Last Sector On Track';
    108 : S := 'Gap Length for Read/Write Operations';
    109 : S := 'Data Transfer Length (0FFh=max)';
    110 : S := 'Format Gap Length';
    111 : S := 'Format Fill Byte';
    112 : S := 'Head Settle Time (ms)';
    113 : S := 'Motor Start-Up Time (*0.125 ms)';
         else  S := '';
    end;  { case }
    OverWriteStr(S,VecWindowStr[i],38);
    end;  { with }
end;  { InitializeDataRecords }


procedure  UpdateScreen(FirstL,LastL : word);
{ checks the time flag at the current variables. }
var  i : word; W : word; B : byte; S : AnyString; SaveXY : word;
begin
  SaveXY := WhereXY;
  for  i := FirstL to LastL do
    with  DataArray[i]  do  begin
    if  (TimeFlag <> 0)  then  begin  S := '';
    case  DataType  of
     1 : begin  B := Mem[Segment:Offset]; S := HexByte(B)+'['+BitByte(B,'0','1')+']'; end;
     2 : for B := 0 to DataLen-1 do S := S + HexByte(Mem[Segment:(Offset+B)])+Blank;
     3 : for W := 0 to DataLen-1 do S := S + HexWord(MemW[Segment:(Offset+2*W)])+Blank;
     4 : begin W := MemW[Segment:Offset]; S := HexWord(W)+'['+BitWord(W,'0','1')+']'; end;
     5 : S := HexWord(MemW[Segment:Offset])+Blank+HexWord(MemW[Segment:Offset+2]);
    end;   { case }
    OverWriteStr(S,VecWindowStr[i],15); GotoXY(15,i-FirstL+1); WriteStrNoAttr(S);
    end;  { if }
  end;  { with }
  GotoXYW(SaveXY);
end;  { UpdateScreen }

procedure  RefreshDataWindow(StartLine,EndLine : word);
{ refresh the current window. }
var  i : word;
begin
  GotoXY(1,1);
  for i := StartLine to EndLine-1 do WriteStr(VecWindowStr[i]);
  WriteStrNoScroll(VecWindowStr[EndLine]);
end;  { RefreshDataWindow }

procedure  RefreshCursor(var GetY : byte; MainWindow : boolean; VideoAttr : byte);
{ use for optimize code. }
begin
   if (MainWindow) then FillAttr(VideoAttr,SizeOf(Str78)-1)
   else  FillAttr(VideoAttr,SizeOf(Str76)-1);
   GotoXY(1,WhereY); GetY := WhereY;
end;  { RefreshCursor }

procedure  FillAttrString(Main : boolean);
{ fast fill attr of string. }
begin
  if (Main) then  FillAttr(TextAttr,SizeOf(Str78)-1)
  else  FillAttr(TextAttr,SizeOf(Str76)-1);
end;  { FillAtrrString }

procedure  DisplayData;
{ draw a help window. }
var  DataBufPtr : pointer; Line,LastWinLine,Ystart,Yend : integer;
  Key,SaveBufHead : word; Ch,AsciiCh : char; UpDirection : boolean;
  DataWinHandle,VidAttr,OldY,i,SaveAttr : byte;
  BiosKbdTail : word absolute $40:$1C;
begin
   InitializeDataRecords;
   VidAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
        HiNibble(TextAttr),DataBufPtr,true,false,0,DataWinHandle);
   OpenWindow(DataWinHandle); ClrScr;
   WindowFrames(DataWinHandle,LeftUpperFrames[1],LeftLowerFrames[1],RightUpperFrames[1],
        RightLowerFrames[1], HorizFrames[1],VertFrames[1],' BIOS/DOS Low Map ',
        ' Alt+Shift - flush kbd buffer ',VidAttr,VidAttr);
   WriteLnStr('  Location          Value(s)               Description  of Variable(s)');
   WriteLnStr(' 컴컴컴컴컴   컴컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
   Window(3,7,CurrentWidth-1,CurrentHeight+1-9);
   if (LastDataLine > WindowSizeY) then  LastWinLine := WindowSizeY
   else  LastWinLine := LastDataLine;
   RefreshDataWindow(1,LastWinLine); GotoXY(1,1);
   Line := 1;  Ystart := 1;  Yend := LastWinLine; FlushKbdBuf;
     repeat
       SaveBufHead := BiosKbdTail;
       repeat UpdateScreen(Ystart,Yend);
         if ((Mem[$40:$17] and $0B) > 8) then
            FlushKbdBuf;
         RefreshCursor(OldY,false,VidAttr);
       until (SaveBufHead <> BiosKbdTail);
       Key := MemW[$40:SaveBufHead]; Ch := ReturnScanCode(Key); AsciiCh := ReturnChar(Key);
       case  Ch  of
         UpArrow,PageUp,HomeKey     : UpDirection := true;
         DownArrow,PageDown,EndKey  : UpDirection := false;
         F1key                      : begin
                                        FlushKbdBuf;
                                        DrawHelpScreen;
                                       end;
       end;  { case }
       i := WindowBrowse(Line,LastDataLine,Ch);
       if  (OldY <> WhereY)  then  begin
         GotoXY(1,OldY); FillAttr(TextAttr,SizeOf(Str76)-1);
         if  (UpDirection)  then GotoXY(1,OldY-1) else  GotoXY(1,OldY+1);
       end;
       if (i <> 0)  then
          case  i  of
             1  : begin
         if (UpDirection) then GotoXY(1,OldY+1) else GotoXY(1,OldY-1);
         FillAttrString(false);
         GotoXY(1,OldY); WriteStrNoScroll(VecWindowStr[Line]);
         if (UpDirection) then begin Dec(Yend); Dec(Ystart); end { if }
         else  begin  Inc(Ystart); Inc(Yend);  end; { if }
                  end;
             $FF  :  begin
         FillAttrString(false);
         if  (UpDirection)  then  begin
         Ystart := 1; Yend := LastWinLine; RefreshDataWindow(1,LastWinLine); GotoXY(1,1);
         end  { if }
                     else    begin
         Ystart := LastDataLine-LastWinLine+1; Yend := LastDataLine;
         RefreshDataWindow(Ystart,Yend);
                       end; { else }
                     end;
            else  begin
               FillAttrString(false);
               Ystart := Line; Yend := Line+LastWinLine-1;
               RefreshDataWindow(Line,Yend);
               GotoXY(1,1);
            end;  { else }
          end;  { case }
       GotoXY(1,WhereY);
     until  (AsciiCh = ESC);
     FlushKbdBuf;
   CloseWindow(DataWinHandle);
end;  { DisplayData }

procedure  PrintVectors(CurLine : integer);
{ find the interrupt vectors. }
var P : pointer; LastIntLine, i : integer; TempOfs : word; Num, Y : byte;
begin
  LastIntLine := InfoArray[CurLine].CookedVecs;
  { now extract the interrupt vectors numbers. }
  P := InfoArray[CurLine].DynamicPtr; TempOfs := 0;
  GotoXY(50,WhereY); Y := 0;
  for i := 1 to LastIntLine  do  begin
     Num := Mem[Seg(P^):Ofs(P^)+TempOfs]; Inc(Y);
     if (Y > 9) then begin WriteLn; GotoXY(50,WhereY); Y := 0; end;
     WriteStr(HexByte(Num)+' '); Inc(TempOfs);
  end; { for }
end; { PrintVectors }

procedure  DisplayNextInfo(CurLine : byte);
{ displays the additional info, based on current line number. }
var  LastVecLine : integer;

procedure  BuildTextVecTable;
{ decodes the info array elements. }
var   P,L  : pointer; i : integer;
      TempOfs : word; S : AnyString; Num : byte;
begin
  LastVecLine := InfoArray[CurLine].CookedVecs;
  if  (LastVecLine = $FF) then  Inc(LastVecLine);
  for i := 1 to 256 do VecWindowStr[i] := CharStr(Blank,SizeOf(Str76)-1);
  { now extract the interrupt vectors numbers. }
  P := InfoArray[CurLine].DynamicPtr; TempOfs := 0;
  for i := 1 to LastVecLine  do  begin
     Num := Mem[Seg(P^):Ofs(P^)+TempOfs];
     OverWriteStr(HexWord($0)+':'+HexWord((Num)*4),VecWindowStr[i],3);
     OverWriteStr('Int'+HexByte(Num),VecWindowStr[i],15);
     L := IntrVecPtr[Num]; OverWriteStr(HexPtr(L),VecWindowStr[i],26);
     { check for IRET instruction }
     if (Mem[Seg(L^):Ofs(L^)] = $CF) then OverWriteStr(' [iret]',VecWindowStr[i],35);
     Inc(TempOfs);
     { interrupt vectors description }
     case  Num  of
          $00 : S := 'Divide by zero exception';
          $01 : S := 'Single Step (trap)';
          $02 : S := 'Non-Maskable Hardware Interrupt';
          $03 : S := 'Debug Break-Point Interrupt';
          $04 : S := 'Divide Overflow Interrupt';
          $05 : S := 'Print Screen/Bound Check Failed';
          $06 : S := 'Reserved/Undefined Opcode';
          $07 : S := 'Reserved/Coprocessor not present';
          $08 : S := 'Timer 0 hdwr/Double fault';
          $09 : S := 'Keyboard hdwr/Segment overrun ';
          $0A : S := 'Slave 8259,some EGAs/invalid TSS';
          $0B : S := 'COM2: hdwr/Segment not present';
          $0C : S := 'COM1: hdwr/Stack exception';
          $0D : S := 'Disk,LPT2:hdwr/General protection';
          $0E : S := 'Diskette hdwr service/Page fault';
          $0F : S := 'LPT1: hardware';
          $10 : S := 'Video service/Coprocessor error';
          $11 : S := 'Equipment Check';
          $12 : S := 'Memory Size';
          $13 : S := 'Fixed Disk,Diskette service';
          $14 : S := 'Serial communication';
          $15 : S := 'Cassette,System Extended service';
          $16 : S := 'Keyboard I/O';
          $17 : S := 'Printer service';
          $18 : S := 'Resident BASIC';
          $19 : S := 'Bootstrap Loader';
          $1A : S := 'Time-Of-Day service';
          $1B : S := 'Keyboard Break';
          $1C : S := 'User Timer Tick';
          $1D : S := 'Video Hardware Parameter Table';
          $1E : S := 'Diskette Hardware Parameter Table';
          $1F : S := 'Video Graphics Chars Table';
          $20 : S := 'DOS - Terminate Program';
          $21 : S := 'DOS - Function Dispatcher';
          $22 : S := 'DOS - Terminate Address';
          $23 : S := 'DOS - Ctrl/Break Exit Address';
          $24 : S := 'DOS - Critical Error Handler';
          $25 : S := 'DOS - Absolute Logical Disk Read';
          $26 : S := 'DOS - Absolute Logical Disk Write';
          $27 : S := 'DOS - Terminate & Stay Resident';
          $28 : S := 'DOS - Idle Signal';
          $29 : S := 'DOS - TTY output';
          $2A : S := 'DOS - Microsoft Network';
     $2B..$2D : S := 'DOS - Reserved';
          $2E : S := 'DOS - COMMAND.COM executive';
          $2F : S := 'DOS - Multiplex process';
          $30 : S := 'DOS - \_ Long Jump to Interface';
          $31 : S := 'DOS - /  Table (Address)';
          $32 : S := 'DOS - Reserved';
          $33 : S := 'DOS - Microsoft Mouse Driver';
     $34..$3E : S := 'DOS - Reserved,used by TC/MS FPE';
          $3F : S := 'DOS - Overlay Manager';
          $40 : S := 'Revectored Diskette I/O (floppy)';
          $41 : S := 'Fixed Disk 0 Parameter Table';
          $42 : S := 'Revectored Video Service by EGA';
          $43 : S := 'EGA video chars font';
          $44 : S := 'Lap-top/PCjr graphic chars table';
          $45 : S := 'some extended VGAs';
          $46 : S := 'Fixed Disk 1 Parameter Table';
          $47 : S := 'Used by Western Digital XT-BIOS';
          $48 : S := 'PCjr translate from 62-key kbd';
          $49 : S := 'TI graphics/PCjr scan code trans.';
          $4A : S := 'User alarm signal';
          $4D : S := 'Used by some OEMs disk handlers';
     $50..$57 : S := 'Used by DESQview,Relocated IRQ'+char(Num-$50+$30);
          $59 : S := 'GSS/Computer Graphics Interface';
          $5A : S := 'PC cluster - BIOS functions';
          $5B : S := 'PC cluster - old INT 19h';
          $5C : S := 'PC cluster - NetBIOS interface';
          $60 : S := 'User reserved/FTP Driver/10-NET';
     $61..$66 : S := 'Reserved for user routines';
          $67 : S := 'LIM EMS,EEMS Manager/VCPI';
          $68 : S := 'APPC/PC';
          $6A : S := 'DECnet LAT driver';
          $6B : S := 'DECnet Port driver';
          $6C : S := 'DECnet RT Sheduler/PC-Conv SRV';
          $6D : S := 'DECnet Data Link Layer/some VGAs';
          $6E : S := 'DECnet Network Process';
          $6F : S := '10-NET/PCOX API';
          $70 : S := 'Real-Time-Clock hardware';
          $71 : S := 'LAN Adapter 1/Redirected to IRQ2';
          $72 : S := 'Hardware Reserved';
          $73 : S := 'Hardware Reserved';
          $74 : S := 'PS/2 50+ Mouse Interrupt';
          $75 : S := '80287 error';
          $76 : S := 'AT-Fixed disk Controller service';
          $77 : S := 'Hardware Reserved';
          $7A : S := 'Low-Level API/AutoCAD Device';
          $7F : S := 'HLL API/8514A video support';
     $80..$85 : S := 'Reserved for BASIC';
          $86 : S := 'Relocated by NetBIOS (Int 18h)';
     $87..$A3,$A5..$DF : S := 'Used by BASIC-Interpreter';
          $A4 : S := 'Right Hand Man API';
          $E0 : S := 'CP/M-86 function calls';
          $E1 : S := 'PC Cluster disk server info';
          $E2 : S := 'PC Cluster - revectored INT 1Ch';
          $E4 : S := 'Used by Logitech Modula-2';
 $E3,$E5..$EB,$ED,$EE,$F0 : S := 'Used by BASIC-Interpreter';
          $EC : S := 'Apricot Text/Graphics Driver';
          $EF : S := 'GEM Interface';
     $FE..$FF : S := 'Used for protected mode';
      else  S := 'Reserved';
     end; { case }
     OverWriteStr(S,VecWindowStr[i],44);
  end;  { for }
end;  { BuildTextVecTable }

procedure  DisplayVectors(Title : AnyString);
{ draw a help window. }
var  VecBufPtr : pointer; Line,LastWinLine : integer;
     Key : word; Ch,AsciiCh : char; VecWinHandle,VidAttr,OldY,i : byte;
     UpDirection : boolean;
begin
   BuildTextVecTable;
   VidAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
                HiNibble(TextAttr),VecBufPtr,true,false,0,VecWinHandle);
   OpenWindow(VecWinHandle); ClrScr;
   WindowFrames(VecWinHandle,LeftUpperFrames[1],LeftLowerFrames[1],
                RightUpperFrames[1],RightLowerFrames[1],
                HorizFrames[1],VertFrames[1],Title,'',VidAttr,VidAttr);
   WriteLnStr('  Location     Int     Segment:Offset             Description');
   WriteLnStr(' 컴컴컴컴컴   컴컴�   컴컴컴컴컴컴컴컴    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
   Window(3,7,CurrentWidth-1,CurrentHeight+1-9);
   if (LastVecLine > WindowSizeY)  then LastWinLine := WindowSizeY
   else  LastWinLine := LastVecLine;
   RefreshDataWindow(1,LastWinLine); GotoXY(1,1); Line := 1;
     repeat  RefreshCursor(OldY,false,VidAttr);
       Key := ReadKey; AsciiCh := ReturnChar(Key); Ch := ReturnScanCode(Key);
       case  Ch  of
         UpArrow,PageUp,HomeKey    : UpDirection := true;
         DownArrow,PageDown,EndKey : UpDirection := false;
         F1key                     : DrawHelpScreen;
       end;  { case }
       i := WindowBrowse(Line,LastVecLine,Ch);
       if  (OldY <> WhereY)  then  begin
         GotoXY(1,OldY); FillAttrString(false);
         if (UpDirection)  then GotoXY(1,OldY-1)  else GotoXY(1,OldY+1); end;
       if (i <> 0)  then
          case  i  of
             1 : begin
           if (UpDirection) then GotoXY(1,OldY+1) else GotoXY(1,OldY-1);
           FillAttrString(false); GotoXY(1,OldY); WriteStrNoScroll(VecWindowStr[Line]);
                 end;
             $FF : begin
          FillAttrString(false);
          if (UpDirection) then begin RefreshDataWindow(1,LastWinLine); GotoXY(1,1); end
          else RefreshDataWindow(LastVecLine-LastWinLine+1,LastVecLine);
                   end;
            else  begin
          FillAttrString(false);
          RefreshDataWindow(Line,Line+LastWinLine-1); GotoXY(1,1);
            end;  { else }
          end;  { case }
       GotoXY(1,WhereY);
     until  (AsciiCh = ESC);
   CloseWindow(VecWinHandle);
end;  { DisplayVectors }

begin
  case InfoArray[CurLine].InfoType of
     1 : DisplayVectors(' IDT layout ');
     2 : DisplayData;
     4 : DisplayVectors(' Hooked Vectors ');
  end;  { case }
end;  { DisplayNextInfo }

function  ExtractHexNum(S : AnyString) : word;
{ get the word value from the hexadecimal string. }
var  i : word;
begin
  i := SearchFirstNoMatchStr(S,Length(S),' ');
  ExtractHexNum := HexStrToWord(Copy(S,i,4));
end;  { ExtractHexNum }

procedure  GetLine(var S);
{ read the text line with TURBO edit keys. }
var  SaveVideo : boolean;
begin
   SaveVideo := DirectVideo; DirectVideo := false;
   ReadLnStr(S); DirectVideo := SaveVideo;
end; { GetLine }

procedure  AskNewDumpParameter(var MemSeg,MemOfs : word);
{ request the new user parameters to memory dump  }
var  AskMemBufPtr : pointer;  S  :  Str7; S4 : Str4;
  AskMemWinHandle,VidAttr,SaveAttr : byte;
begin
   VidAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
        HiNibble(TextAttr),AskMemBufPtr,true,false,0,AskMemWinHandle);
   OpenWindow(AskMemWinHandle); ClrScr;
   WindowFrames(AskMemWinHandle,LeftUpperFrames[1],LeftLowerFrames[1],RightUpperFrames[1],
        RightLowerFrames[1], HorizFrames[1],VertFrames[1],' Memory Address ',
        ' Enter 4 digits ',VidAttr,VidAttr);
   CursorOn; WriteStr(' Enter new segment (hex.): '); ReadHexWord(S4);
   MemSeg := ExtractHexNum(S4); WriteLn; WriteStr(' Enter new offset (hex.): ');
   ReadHexWord(S4); MemOfs := ExtractHexNum(S4);
   CursorOff; CloseWindow(AskMemWinHandle);
end; { AskNewDumpParameter }

procedure  SearchStringInMemory(var MemSeg,MemOfs : word);
{ request the new user parameters to memory dump  }
const  SearchMessage  =  'Enter string to search: ';
var  SearchMemBufPtr : pointer;  S  :  ANyString;
  Key : word; AsciiCh : char;
  SearchMemWinHandle,VidAttr : byte;
begin
   VidAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
        HiNibble(TextAttr),SearchMemBufPtr,true,false,0,SearchMemWinHandle);
   OpenWindow(SearchMemWinHandle); ClrScr;
   WindowFrames(SearchMemWinHandle,LeftUpperFrames[1],LeftLowerFrames[1],RightUpperFrames[1],
        RightLowerFrames[1], HorizFrames[1],VertFrames[1],' String Search In Memory ',
        ' InterSegment and Case-Sensitive ',VidAttr,VidAttr);
   WriteStr(' (A)scii or (H)ex search: '); S := 'ASCII'; CursorOn;
   AsciiCh := UpCase(ReturnChar(ReadKey)); if (AsciiCh = 'H') then S := 'hex';
   WriteLn; WriteStr(' Enter new '+ S +' string: ');
   GetLine(S); if (AsciiCh = 'H') then S := HexStrToCharStr(S);
   Key := SearchString(Ptr(MemSeg,MemOfs),$FFFF-MemOfs,S);
   if (Key <> $FFFF) then Inc(MemOfs,Key);
   CursorOff; CloseWindow(SearchMemWinHandle);
end; { SearchStringInMemory }

function MakeMemString(MemSeg,MemOfs : word) : AnyString;
{ write the memory contens to text format. }
var  S,A : AnyString; i : word; Byt : byte;
begin
  A := ' '; S := HexWord(MemSeg)+':'+HexWord(MemOfs)+'  ';
  for i := 0  to  15  do  begin
    Byt := Mem[MemSeg:MemOfs+i]; S := S + HexByte(Byt) + ' ';
    { filter the following control chars }
    if char(Byt) in [#7,#8,#9,#10,#13] then Byt := byte('.');
    A := A + char(Byt);
  end; { for }
  MakeMemString := S + A;
end; { MakeString }

procedure  RefreshMemWindow(StartLine,EndLine,CurSeg,CurOfs : word);
{ refresh the current window. }
var  i : word; S : Str76;
begin
  GotoXY(1,1);
  for i := StartLine to EndLine-1 do WriteStr(MakeMemString(CurSeg,CurOfs+(i-1)*16));
  WriteStrNoScroll(MakeMemString(CurSeg,CurOfs+16*(EndLine-1)));
end;  { RefreshMemWindow }

procedure  MemoryView(InitMemSeg : word);
{ memory viewer to time and screen. }
const  Para = 16;
var  MemBufPtr, MemOnHeapInit,NewPtr : pointer; LastMemLine : integer;
  Key,LastMemOfs,InitMemOfs,ParaPage : word; Ch,AsciiCh : char;
  MemWinHandle,VidAttr,i : byte; MakeRefresh : boolean;
begin
   VidAttr := 16 * LoNibble(TextAttr) + HiNibble(TextAttr);   { reverse video }
   DefineWindow(ActivePage,2,4,CurrentWidth,CurrentHeight+1-8,LoNibble(TextAttr),
        HiNibble(TextAttr),MemBufPtr,true,false,0,MemWinHandle);
   OpenWindow(MemWinHandle); ClrScr;
   {$IFDEF Debug }
     CursorOn;
   {$ENDIF }
   WindowFrames(MemWinHandle,LeftUpperFrames[1],LeftLowerFrames[1],RightUpperFrames[1],
        RightLowerFrames[1], HorizFrames[1],VertFrames[1],'  Memory View/Watch  ',
        ' F2 - new address, F7 - search ',VidAttr,VidAttr);
   WriteLnStr(' Seg:Off   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F       ASCII');
   WriteStr('컴컴컴컴�  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴');
   Window(3,7,CurrentWidth-1,CurrentHeight+1-9);
   LastMemLine := WindowSizeY;  InitMemOfs := $0; MakeRefresh := true;
   ParaPage := (LastMemLine) shl 4; LastMemOfs := $10000 - ParaPage;
   GetMem(MemOnHeapInit,ParaPage);
   repeat
     { refresh the memory dump window. }
     if MakeRefresh then RefreshMemWindow(1,LastMemLine,InitMemSeg,InitMemOfs); GotoXY(1,1);
     { now the copy the contents of memory region to view. }
     NewPtr := Ptr(InitMemSeg,InitMemOfs); TpMove(NewPtr,MemOnHeapInit,ParaPage);
     repeat
       if  (ComparePtrBuffers(MemOnHeapInit,NewPtr,ParaPage) <> $FFFF) then begin
           RefreshMemWindow(1,LastMemLine,InitMemSeg,InitMemOfs); GotoXY(1,1);
           TpMove(NewPtr,MemOnHeapInit,ParaPage); end;
     until KeyPressed;
     Key := ReadKey; Ch := ReturnScanCode(Key); AsciiCh := ReturnChar(Key); MakeRefresh := true;
     case  Ch  of
       UpArrow     : if (InitMemOfs <> $0) then Dec(InitMemOfs,Para);
       PageUp      : if (InitMemOfs >= ParaPage) then Dec(InitMemOfs,ParaPage)
                     else  InitMemOfs := $0;
       HomeKey     : InitMemOfs := $0;
       DownArrow   : if (InitMemOfs <> LastMemOfs) then Inc(InitMemOfs,Para);
       PageDown    : if (InitMemOfs <= (LastMemOfs-ParaPage)) then Inc(InitMemOfs,ParaPage)
                     else InitMemOfs := LastMemOfs;
       EndKey      : InitMemOfs := LastMemOfs;
       F2key       : AskNewDumpParameter(InitMemSeg,InitMemOfs);
       F7key       : SearchStringInMemory(InitMemSeg,InitMemOfs);
       F1key       : DrawHelpScreen;
     else
        MakeRefresh := false;
     end;  { case }
   until  (AsciiCh = ESC);
   FreeMem(MemOnHeapInit,ParaPage);
   {$IFDEF Debug }
     CursorOff;
   {$ENDIF }
   CloseWindow(MemWinHandle);
end; { MemoryView }

procedure  DisplayInfo;
{ display all information on screen. }
const
  MemBytes = ' bytes  ($'; DeLim = ')';
  DefStr = ' Memory:  '; UpDirection : boolean = false;
  Allocation  : array[0..3]  of Str9 = ('first fit','best fit','last fit','unknown');
var  S,NewS : AnyString; A : SysDescrTable;  MainBufPtr : pointer;
     TempL : longint; Line : integer; SaveXY,Key : word;
     MainWinHandle,LastWinLine,i,OldY,NewAttr : byte;
     Ch,AsciiCh : char; Valid : boolean;


procedure  RefreshWindow(StartLine,EndLine : integer);
{ refresh the current window. }
var  i : integer;
begin
  GotoXY(1,1);
  for i := StartLine to EndLine-1 do WriteStr(MainWindowStr[i]);
  WriteStrNoScroll(MainWindowStr[EndLine]);
end;  { RefreshWindow }

begin
   {$IFDEF Debug }
    WriteLnStr('*** Enter main window ***');
  {$ENDIF}
   if (TSRMap) then  begin
     WriteLnStr('Addr   KBytes      Owner         Parent           Hooked Vectors');
     WriteStr('컴컴   컴컴컴   컴컴컴컴컴컴   컴컴컴컴컴�    컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
     if (MemW[Offset:1] = PrefixSeg) then Dec(LastInfoLine);
     for i := (TSRInfoLine+1) to LastInfoLine do begin
       WriteStr(MainWindowStr[i]); PrintVectors(i); WriteLn;
     end; { for }
     WriteStr('  Free  ' +DefStr +ConstructNumber(LongIntSize(Offset,HighSeg))+' bytes');
     WriteLn;
   end  else  begin SaveXY := WhereXY;
   if EGAswitch then TextMode(Font8x8+CurrentMode);
   NewAttr := TextAttr; SwapInByte(TextAttr);
   DefineWindow(ActivePage,1,1,CurrentWidth+1,CurrentHeight+1,LoNibble(TextAttr),
                HiNibble(TextAttr),MainBufPtr,true,false,0,MainWinHandle);
   OpenWindow(MainWinHandle); ClrScr;
   WindowFrames(MainWinHandle,LeftUpperFrames[2],LeftLowerFrames[2],RightUpperFrames[2],
        RightLowerFrames[2],HorizFrames[2],VertFrames[2],' PC SYSTEM MAP '+Version+' ',
        ' F1 key - help ',NewAttr,NewAttr);
   GotoXY(1,CurrentHeight+1-8); FillCharInWindow('�',WindowSizeX);
   GotoXY(17,WhereY); WriteStr(' Total Memory Info ');
   GotoXY(56,WhereY); WriteStr(' DOS/BIOS Info ');
   GotoXY(48,WhereY); WriteChar('�'); WriteLn; TempL := LongIntSize(0,FoundMem);
   WriteLnStr(' Conventional'+DefStr+ConstructNumber(TempL)+MemBytes+HexWord(FoundMem)+DeLim);
   TempL := LongIntSize(0,TopOfMem);
   WriteLnStr(' Dos Internal'+DefStr+ConstructNumber(TempL)+MemBytes+HexWord(TopOfMem)+DeLim);
   TempL := LongIntSize(0,HighSeg);
   WriteLnStr(' Block  Link '+DefStr+ConstructNumber(TempL)+MemBytes+HexWord(HighSeg)+DeLim);
   TempL := LongIntSize(Offset,HighSeg);
   WriteLnStr(' Free   RAM  ' +DefStr +ConstructNumber(TempL)+MemBytes+HexWord(HighSeg-Offset)+DeLim);
   WriteLnStr(' Extended RAM'+DefStr+MakeLong(ExtMem)+' bytes');
   WriteStr(' Expanded RAM'+DefStr +MakeLong(ExpMem)+' bytes');
   for Line := 1 to 6 do begin
     GotoXY(48,CurrentHeight+Line-7); WriteChar('�');
     case  Line  of
            1 : begin
          S := '/DOS Versn: '+DeleteLeft(ByteToString(HiByte(CurDosVer)),Blank)+
          +'.'+DeleteLeft(ByteToString(LoByte(CurDosVer)),Blank);
          if (PcDosFlag) then  Insert('PC',S,1)  else Insert('MS',S,1);
                end;
            2 : S := 'Logic.Drives: A: - '+char(TpDos.DosDrives+64)+':';
            3 : S := 'Valid Drives: A: - '+char(ValidDrives+64)+':';
            4 : S := 'Memory Alloc: '+Allocation[GetAllocStrategy and 4];
            5 : begin
          SystemConfiguration(A,Valid); { assume that fail } NewS := 'Unknown';
          case  MachineID  of
             $FF : NewS := 'Original PC';
             $FE : NewS := 'PC/XT';
             $FD : NewS := 'PC/Junior';
             $FC : case  A.Submodel of
                      2 : News := 'PC XT/286';
                      4 : NewS := 'PS/2 model 50';
                      5 : NewS := 'PS/2 model 60';
                    else  NewS := 'PC/AT';
                   end;  { case }
             $FB : NewS := 'PC/XT2';
             $FA : case A.Submodel of
                     0 : NewS := 'PS/2 model 30';
                     1 : NewS := 'PS/2 model 25';
                   end; { case }
             $F9 : NewS := 'PC Convertible';
             $F8 : NewS := 'PS/2 model 80';
             $B6 : NewS := 'HP 110 Portbl';
             $9A : NewS := 'COMPAQ Portbl+';
             $2D : NewS := 'COMPAQ Portbl';
          end;  { case }
                    S := 'Machine Type: '+NewS;
                end;
            6 :    begin
          i := 0;  NewS := '';
          repeat Ch := BiosDate[i];  Inc(i);
            if ((Ch in DigitSet) or (Ch = '/')) then NewS := NewS + Ch;
          until (i = 8);
          S := 'BIOS Release: '+NewS;
                  end;
     end;  { of }
     GotoXY(50,WhereY); WriteStrNoScroll(S);
   end;  { for }
   GotoXY(1,1);
   WriteLnStr('    Address     MCB link     Paras    Bytes,dec     Owner          Parent');
   WriteLnStr('  컴컴컴컴컴   컴컴컴컴컴   컴컴컴�   컴컴컴컴�    컴컴컴�        컴컴컴컴');
   Window(2,4,CurrentWidth,CurrentHeight+1-8);
   if (LastInfoLine > WindowSizeY) then LastWinLine := WindowSizeY
   else  LastWinLine := LastInfoLine;
   RefreshWindow(1,LastWinLine); GotoXY(1,1); Line := 1; CursorOff;
     repeat
       RefreshCursor(OldY,true,NewAttr); Key := ReadKey;
       Ch := ReturnScanCode(Key); AsciiCh := ReturnChar(Key);
       case  Ch  of
         UpArrow,PageUp,HomeKey    : UpDirection := true;
         DownArrow,PageDown,EndKey : UpDirection := false;
         F1key                     : DrawHelpScreen;
         F3key                     : MemoryView(ExtractHexNum(MainWindowStr[Line]));
       end;  { case }
       if (AsciiCh = CR) then DisplayNextInfo(Line);
       i := WindowBrowse(Line,LastInfoLine,Ch);
       if (OldY <> WhereY) then begin
         GotoXY(1,OldY); FillAttrString(true);
         if (UpDirection) then GotoXY(1,OldY-1) else GotoXY(1,OldY+1);
       end;
       if (i <> 0) then
          case  i  of
             1 : begin
       if (UpDirection) then GotoXY(1,OldY+1) else GotoXY(1,OldY-1);
       FillAttrString(true); GotoXY(1,OldY); WriteStrNoScroll(MainWindowStr[Line]);
                  end;
             $FF : begin
       FillAttrString(true);
       if (UpDirection)  then  begin RefreshWindow(1,LastWinLine); GotoXY(1,1); end
       else RefreshWindow(LastInfoLine-LastWinLine+1,LastInfoLine);
                   end;
            else  begin
       FillAttrString(true);
       RefreshWindow(Line,Line+LastWinLine-1); GotoXY(1,1);
            end;  { else }
          end;  { case }
       GotoXY(1,WhereY);
     until  (AsciiCh = ESC);
   CursorOn; CloseWindow(MainWinHandle);
   if (EGAswitch) then  begin
         if (SaveVideoLines in [43,50]) then TextMode(SaveVideoMode+Font8x8)
         else TextMode(SaveVideoMode);
         GotoXYW(SaveXY); SaveVideoBuffer := false; ForceEGAcard; end;
 end; { if }
end;  { DisplayInfo }

procedure DisplayHelp;
{ display the help for the program. }
begin
   {$IFDEF Debug }
    WriteLnStr('*** Display command syntax ***');
  {$ENDIF}
   WriteLnStr('SYSMAP.EXE  -  useful utility program for ALL PC programmers.');
   WriteLnStr('Command Syntax:  SYSMAP [options] , where the following options supported:');
   WriteLnStr('               /snow=false     --> no check for snow');
   WriteLnStr('               /snow=true      --> check for snow  (old CGAs, some lap-tops)');
   WriteLnStr('               /bios=true      --> use for video output BIOS calls');
   WriteLnStr('               /bios=false     --> use the direct access to video memory');
   WriteLnStr('               /program        --> display TSR map only');
   WriteLnStr('               /43             --> 43/50 EGA/VGA line mode');
   WriteLnStr('Default settings:');
   WriteLnStr('  Parameter:     bios=false   --> see above');
   WriteLnStr('  Parameter:     snow=false   --> see above');
   WriteLnStr('    Example:  SYSMAP   /snow=false  /bios=false');
   WriteLnStr(' Note: the switches are not case-sensitive.');
   WriteLn;
end; { DisplayHelp }

procedure ProgramLogo;
{ display the initial info. }
begin
  {$IFDEF Debug }
    WriteLnStr('*** Display Program Logo ***');
  {$ENDIF}
  MyNamePtr := Ptr(Seg(MyName[1]),Ofs(MyName[1]));
  DecryptE(MyNamePtr,Length(MyName));
  DisplayCopyRightMessage('SYSMAP '+Version+' --- PC System Map Utility.',
     'Copyright (c) 1988-1999 '+MyName+'. All rights reserved.');
  EncryptE(MyNamePtr,Length(MyName));
  WriteLnStr('Welcome to the great PC Memory Analyzer Program!');
  WriteLn;
end; { ProgramLogo }

procedure  ParseCommandParameters;
{ detect the various switches. }
var
   S : AnyString;
begin
  {$IFDEF Debug }
    WriteLnStr('*** Parse command line ***');
  {$ENDIF}
  GetCmdLine(S);
  UpCaseString(S);
  if (Pos('?',S) <> 0) then  begin
      ProgramLogo;
      DisplayHelp;
      Halt(0);
  end; { if }
  if (Pos(GetSwitchChar+'PROGRAM',S) <> 0) then
     TSRMap := true;
  if (Pos(GetSwitchChar+'43',S) <> 0) then
    if (EGAinstalled) and (CurrentMode <> Mono) then begin
      EGAswitch := true; SaveVideoLines := CurrentHeight + 1;
      if (TSRMap) then
          begin
            TextMode(Font8x8+CurrentMode);
            ForceEGAcard;
          end
      else
         begin SaveVideoBuffer := true; SaveVideoMode := CurrentMode; end; { else }
  end; { if }
  case CurDosVer of
     $0314,$031E,$031F,$0400,$0401,$0500,$0600,$060A,$0614,$0615,$0616 : ;
     $0700, $070A : ;
     $0A00 : TSRMap := true;
     else Abort('$Unsupported Dos Version.',1);
  end; { case }
end;  { ParseCommandParameters }

begin
  ParseCommandParameters;
  if (CurrentWidth+1 < 80) then Abort('$Unsupported video mode.',2);;
  SwapVectors;
  InitVars;
  ProgramLogo;
  PCGeneralVars;
  IbmBioInfo;
  if  (TSRMap)  then TSRInfoLine := LastInfoLine
  else  begin IbmDosInfo; ScanListOfDeviceDrivers; end; { if }
  SearchAllMemoryBlocks;
  ConventionalMemoryTest;
  ExtendedMemoryTest;
  ExpandedMemoryTest;
  ConvertInfoToText;
  DisplayInfo;
  SwapVectors;
end.
