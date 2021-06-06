  {$I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0  DOS  Unit              *
        *    Provides the access to the Ms-Dos functions   *
        *          Version  2.10      01/09/91             *
        *         writtten  by  Dima  Stefankov            *
        *                                                  *
        ****************************************************
  }

   unit   TpDos;

   interface

     uses
        TpSystem, TpString;

     const

       Normal      =   $0;              { Dos file attributs }
       ReadOnly    =   $1;
       Hidden      =   $2;
       SysFile     =   $4;
       VolumeID    =   $8;
       Directory   =   $10;
       Archive     =   $20;
       AnyFile     =   $3F;

       Read        =   $0;              { Dos access codes }
       Write       =   $1;
       ReadWrite   =   $2;
       DenyRW      =   $10;
       DenyWrite   =   $20;
       DenyRead    =   $30;
       DenyNone    =   $40;
       Inherit     =   $80;

       StartPos    =   $0;              { Seek modes }
       CurPos      =   $1;
       EndPos      =   $2;

       MinSpaceForDos   =   20000;      { minimum bytes for Dos shell to run }

       StdInHandle      =   0;          { Dos standard handles }
       StdOutHandle     =   1;
       StdErrHandle     =   2;
       StdAuxHandle     =   3;
       StdPrnHandle     =   4;

       UseTrueDos      :   boolean  =   false;  { check the intercept $21 Int }
       bDos5InUseOk    :   System.Boolean = System.False;

     type
       CommandStr  =   string[127];       {  strings  }
       PathStr     =   string[79];
       DirStr      =   string[67];
       FileStr     =   string[12];
       NameStr     =   string[8];
       ExtStr      =   string[4];

       Registers   =   record            { used by Intr }
                         case  Integer  of
                           0: (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags : word);
                           1: (AL,AH,BL,BH,CL,CH,DL,DH : byte);
                       end;

       DateRecord  =   record                { system date & time }
                         Year       :  word;
                         Month      :  byte;
                         Day        :    byte;
                         DayOfWeek  :  byte;
                       end;

       TimeRecord  =   record
                         Hour    :  byte;
                         Minute  :  byte;
                         Second  :  byte;
                         Sec100  :  byte;
                       end;

       FileTimeRecord  =   record                  { file date & time }
                             Year       :  word;
                             Month      :  byte;
                             Day        :  byte;
                             Hour       :  byte;
                             Minute     :  byte;
                             Second     :  byte;
                           end;

       SearchRecord     =  record                  { used for search files }
                             Fill     :   array[1..21]  of  byte;
                             Attr     :   byte;
                             Time     :   longint;
                             Size     :   longint;
                             Name     :   FileStr;
                           end;

       MemCtrl          =  record                  { DOS Memory Control block }
                              Header     :   byte;
                              OwnerPSP   :   word;
                              Size       :   word;
                              Reserved   :   array[1..11] of byte;
                           end;

       ExecParameterBlock   =   array[0..6]  of  word;      { Exec function }
                                    {  word 0  =  segment of environment  }
                                    {  word 1  =  ofs:seg of command tail }
                                    {  word 3  =  ofs:seg of first FCB    }
                                    {  word 5  =  ofs:seg of second FCB   }

       FileControlBlock              =   array[0..37] of byte;
       ExtendedFileControlBlock      =   array[0..43] of byte;

       DriveInfoBlock   =  record                           { Dos drive info }
                             Drive               :    byte;
                             SubUnitNumber       :    byte;
                             SectorSize          :    word;
                             SectorsPerCluster   :    byte;
                             ClusterToSecShift   :    byte;
                             ReservedSectors     :    word;
                             FATsNumber          :    byte;
                             RootDirEntries      :    word;
                             FirstDataSector     :    word;
                             TotalClusters       :    word;
                             FATsize             :    byte;
                             RootDirStartSector  :    word;
                             DeviceHeader        :    pointer;
                             MediaDescriptor     :    byte;
                             AccessFlag          :    byte;
                             NextBlockLink       :    pointer;
                           end;

       BootSectorBlock     =   record
                             OEMname             :    Str8;
                             SectorSize          :    word;
                             SectorsPerCluster   :    byte;
                             ReservedSectors     :    word;
                             FatsCount           :    byte;
                             RootDirEntries      :    word;
                             TotalSectors        :    word;
                             MediaByte           :    byte;
                             SectorsPerFat       :    word;
                             SectorsPerTrack     :    word;
                             NumberOfHeads       :    word;
                             HiddenSectors       :    longint;
                               end;

       OverlayParameterBlock   =  array[0..1]  of  word;
                                  { word 0  =  segment address to load }
                                  { word 1  =  relocation factor }

  var
     ExecBlock     :   ExecParameterBlock     absolute  OvrCodeList;
     OvBlock       :   OverlayParameterBlock  absolute  OvrDosHandle;
     CurDosVer     :   word;

  function   DosVersion : word;
  function   DosExitCode : word;
  function   FilePos(Handle : word) : longint;
  function   FileSize(Handle : word) : longint;
  function   GetIntVec(IntNo : byte) : pointer;
  function   GetDTA : pointer;
  function   GetDosVerify : boolean;
  function   GetDosCBreak : boolean;
  function   DiskFree(Drive : byte) : longint;
  function   DiskSize(Drive : byte) : longint;
  function   AllocBlock(Paragraphs  :  word) : word;
  function   GetFileTime(Handle : word) : longint;
  function   GetEnvPtr : pointer;
  function   GetEnvCount : integer;
  function   GetProgramPath : PathStr;
  function   EnvStr(Index : integer) : AnyString;
  function   GetEnv(EnvVar : AnyString) : AnyString;
  function   GetPSP : word;
  function   DosActive : boolean;
  function   GetSwitchChar : char;
  function   DosDrives : byte;
  function   CurrentDisk : byte;
  function   DefaultDrive : char;
  procedure  SelectDisk(Drive : byte);
  procedure  SelectDiskDrive(Drive : char);
  procedure  CreateFile(FileName : PathStr; Attribute : word; var Handle : word);
  procedure  OpenFile(FileName : PathStr;var Handle : word);
  procedure  CloseFile(Handle : word);
  procedure  ReadFile(Handle : word; Buffer : pointer; Count : word; var Result : word);
  procedure  ReadFileVar(Handle : word;var Buffer; Count : word; var Result : word);
  procedure  WriteFile(Handle : word; Buffer : pointer; Count : word; var Result : word);
  procedure  WriteFileVar(Handle : word;var  Buffer; Count : word; var Result : word);
  procedure  Seek(Handle : word; Offset : longint);
  procedure  GetDate(var T : DateRecord);
  procedure  SetDate(var T : DateRecord);
  procedure  GetTime(var T : TimeRecord);
  procedure  SetTime(var T : TimeRecord);
  procedure  SetIntVec(IntNo : byte; Vector : pointer);
  procedure  SetDTA(Buffer : pointer);
  procedure  SetDosVerify(Verify : boolean);
  procedure  SetDosCBreak(Break : boolean);
  procedure  SwapVectors;
  procedure  GetFileAttr(FileName : PathStr;var Attr : word);
  procedure  SetFileAttr(FileName : PathStr;Attr : word);
  procedure  FreeBlock(BlockAddr : word);
  procedure  ModifyBlock(BlockAddr, Paragraphs : word);
  procedure  SetFileTime(Handle : word; Time : longint);
  procedure  PackTime(var T : FileTimeRecord; var Time : longint);
  procedure  UnPackTime(Time : longint; var T : FileTimeRecord);
  procedure  RenameFile(FileName,NewName : PathStr);
  procedure  EraseFile(FileName : PathStr);
  procedure  GetDir(Drive : byte; var DirName : DirStr);
  procedure  ChDir(DirName : DirStr);
  procedure  RmDir(DirName : DirStr);
  procedure  CreateDir(DirName : DirStr);
  procedure  FindFirst(Path : PathStr; Attr : word; var F : SearchRecord);
  procedure  FindNext(var F : SearchRecord);
  procedure  Exec(Path : PathStr; CmdLine : CommandStr);
  procedure  ExtendedError(var ErrorCode : word; var ErrorClass : byte;
                           var SuggestedClass : byte; var Locus : byte);
  procedure  DiskInfo(Drive : byte; var Info : DriveInfoBlock);
  procedure  SetSwitchChar(SwitchChar : char);
  procedure  Keep(ReturnCode : byte);
  procedure  DosAbsoluteRead(Drive : byte; SecsNum : word; StartSec : longint;
                             Buffer : pointer);
  procedure  DosAbsoluteWrite(Drive : byte; SecsNum : word; StartSec : longint;
                              Buffer : pointer);
  procedure  MakeTempFile(Path : PathStr; Attr : word; var Handle : word);
  procedure  MakeNewFile(PathName : PathStr; Attr : word; var Handle : word);
  procedure  LockFile(Handle : word; Offset : longint; Region : longint);
  procedure  UnLockFile(Handle : word; Offset : longint; Region : longint);
  procedure  LoadOverlay(PathName : PathStr);
  procedure  ParseName(Mode : byte; var TextStr; var FCBptr : FileControlBlock);
  procedure  GetEnvSize(var EnvSize,BlockSize : word);
  procedure  Intr(IntNo : byte; var Regs : Registers);
  procedure  MsDos(var Regs : Registers);
  procedure  Append(FileName : PathStr;var Handle : word);
  procedure  Reset(FileName : PathStr;var Handle : word);
  procedure  Rewrite(FileName : PathStr;var Handle : word);
  procedure  Truncate(Handle : word);
  procedure  FSplit(Path : PathStr; var Dir : DirStr; var Name : NameStr; var Ext : ExtStr);
  function   FExpand(Path : PathStr) : PathStr;
  function   FSearch(Path : PathStr; DirList : AnyString) : PathStr;

  function   DosInVars : word;
  { return the Dos segment in system memory. }
  inline($B4/$52        {  mov   ax,52h   ; Get Dos InVars  }
        /$CD/$21        {  int   21h      ; call DOS  }
        /$8C/$C0);      {  mov   ax,es    ; AX = DOS data segment }

  function   ExtractFileName(Path : PathStr) : FileStr;
  procedure  NewSystem(NewCmdLine : AnyString);
  function   MakeFileName(Drive : byte; Dir : DirStr; Name : NameStr; Ext : ExtStr) : PathStr;
  function   MasterEnvironment : word;
  procedure  GetCmdLine(var S);
  procedure  RemEnvStr(EnvString : AnyString);
  procedure  PutEnvStr(EnvString : AnyString);
  function   EOF(Handle : word) : boolean;
  function   IsPath(S : PathStr) : boolean;
  procedure  SetTrueDos(On : boolean);
  function   DosErrorMessage(ErrCode : byte) : AnyString;
  function   AddBackSlash(S : PathStr) : PathStr;
  function   GetAllocStrategy : byte;
  procedure  SetAllocStrategy(MemStrategyCode : byte);
  function   MakeExtension(Name : PathStr; Ext : ExtStr) : AnyString;
  function   ExtractPathName(Path : PathStr) : PathStr;
  procedure  Multiplex(var Regs : Registers);

implementation                { private part }

  var
    OldSS, OldSP  :   word;


  {$L KEEPDOS.OBJ }
  { internal subroutines for unit}

  procedure DosControl; external;
  procedure DosError;   external;
  procedure DosIO;      external;
  procedure SaveHandle; external;
  procedure HandleIO;   external;
  procedure MoveString; external;
  procedure PutTrueDosEntry(P : pointer); external;

  {$L DOSVERSN.OBJ }
  function  DosVersion : word; external;
  { return the current version of the operating system. }

  {$L EXITCODE.OBJ }
  function  DosExitCode : word; external;
  { return the code of the terminated process. }

  {$L CURDISK.OBJ }
  function  CurrentDisk : byte; external;
  { return the currently selected drive. }

  function  DefaultDrive : char;
  { returns a char for the current drive. }
  begin
    DefaultDrive := char(65 + CurrentDisk);
  end;  { DefaultDrive }

  {$L SETDISK.OBJ }
  procedure   SelectDisk(Drive : byte); external;
  { selects a specified disk drive. }

  {$L GETVEC.OBJ }
  function   GetIntVec(IntNo : byte) : pointer; external;
  { get the interrupt handler address for a specified interrupt vector. }

  {$L GETDTA.OBJ }
  function   GetDTA : pointer; external;
  { returns the Disk Transfer Area address. }

  {$L GETVERIF.OBJ }
  function   GetDosVerify : boolean; external;
  { get the current state of a Dos Verify Flag. }

  {$L GETCBRK.OBJ }
  function   GetDosCBreak : boolean; external;
  { returns the current state of a Dos Ctrl-Break Flag. }

  {$L DOSACTIV.OBJ }
  function   DosActive : boolean; external;
  { returns the status of Dos operation currently execute. }

  {$L GETSCHAR.OBJ }
  function   GetSwitchChar : char; external;
  { return the current char use for switches. }

  {$L DOSDRIVS.OBJ }
  function  DosDrives : byte; external;
  { returns a Dos logical drives number. }

  {$L DISKDATA.OBJ }
  function   DiskFree(Drive : byte) : longint; external;
  { returns the number of free bytes of a specified disk drive. }

  function   DiskSize(Drive : byte) : longint; external;
  { returns the total size in bytes of a specified disk drive. }

  {$L FILEPOS.OBJ }
  function  FilePos(Handle : word) : longint; external;
  { return the current position of r/w head in the file. }

  {$L FILESIZE.OBJ }
  function  FileSize(Handle : word) : longint; external;
  { returns the current file size. }

  procedure   SelectDiskDrive(Drive : char);
  { selects a specified disk drive. }
  begin
    SelectDisk(byte(UpCase(Drive))-ord('A'));
  end;  { SelectDiskDrive }

  {$L CREATE.OBJ }
  procedure CreateHandle(var FileName : PathStr; Attribute : word; var Handle : word); external;
  { create the handle and returns the assigned handle. }

  {$L OPEN.OBJ }
  procedure OpenHandle(var FileName : PathStr; var Handle : word); external;
  { open the handle and returns and the assigned handle.
    Note: file is opened using to variable <FileMode>. }

  procedure CreateFile(FileName : PathStr; Attribute : word; var Handle : word);
  { create file and if no error then return the assigned dos handle else return -1. }
  begin
    AsciizString(FileName);
    CreateHandle(FileName,Attribute,Handle);
    AscString(FileName);
  end; { CreateFile }

  procedure OpenFile(FileName : PathStr; var Handle : word);
  { open the file and return the assigned handle. }
  begin
    AsciizString(FileName);
    OpenHandle(FileName,Handle);
    AscString(FileName);
  end;  { OpenFile }

  {$L CLOSE.OBJ }
  procedure  CloseFile(Handle : word); external;
  { closes the file using the received handle. }

  {$L FILEOP.OBJ }
  procedure  ReadFile(Handle : word;Buffer : pointer; Count : word; var Result : word); external;
  { reads from the file on disk to the memory buffer. }

  procedure  WriteFile(Handle : word;Buffer : pointer; Count : word; var Result : word); external;
  { writes the contents of the memory buffer to the file on disk. }

  procedure  ReadFileVar(Handle : word;var Buffer; Count : word; var Result : word); external;
  { reads from the file on disk to the memory buffer. }

  procedure  WriteFileVar(Handle : word;var  Buffer; Count : word; var Result : word); external;
  { writes the contents of the memory buffer to the file on disk. }

  {$L SEEK.OBJ }
  procedure  Seek(Handle : word;Offset : longint); external;
  { move the pointer to a wanted position in the file. }

  {$L GETDATE.OBJ }
  procedure  GetDate(var T : DateRecord); external;
  { returns the current date in the operating system. }

  {$L SETDATE.OBJ }
  procedure  SetDate(var T : DateRecord); external;
  { set the current date in the operating system. }

  {$L GETTIME.OBJ }
  procedure  GetTime(var T : TimeRecord); external;
  { returns the current time in the operating system. }

  {$L SETTIME.OBJ }
  procedure  SetTime(var T : TimeRecord); external;
  { set the current time in the operating system. }

  {$L SETVEC.OBJ }
  procedure  SetIntVec(IntNo : byte; Vector : pointer); external;
  { set the  specified interrupt vector to a specified address. }

  {$L SETDTA.OBJ }
  procedure  SetDTA(Buffer : pointer); external;
  { set the specified address for the DTA buffer. }

  {$L SETVERIF.OBJ }
  procedure  SetDosVerify(Verify : boolean); external;
  { set the state of a Dos Verify Flag. }

  {$L SETCBRK.OBJ }
  procedure  SetDosCBreak(Break : boolean); external;
  { switches the state of a Dos Ctrl-Break Flag. }

  {$L SWAPVEC.OBJ }
  procedure  SwapVectors; external;
  { swaps the SaveIntXX pointers in the System units with the current pointers. }

  {$L GETFATTR.OBJ }
  procedure  GetFAttr(var FileName : PathStr; var Attribute : word); external;
  { return the attributes of a file. }

  {$L SETFATTR.OBJ }
  procedure  SetFAttr(var FileName : PathStr; Attribute : word); external;
  { sets the attributes of a file. }

  procedure  GetFileAttr(FileName : PathStr;var Attr : word);
  { returns the attributes of a file. }
  begin
    AsciizString(FileName);
    GetFAttr(FileName,Attr);
    AscString(FileName);
  end; { GetFileAttr }

  procedure  SetFileAttr(FileName : PathStr;Attr : word);
  { sets the attributes of a file. }
  begin
    AsciizString(FileName);
    SetFAttr(FileName,Attr);
    AscString(FileName);
  end; { GetFileAttr }

  {$L ALLOC.OBJ }
  function   AllocBlock(Paragraphs  :  word) : word; external;
  { return the segment address of Dos memory block of a specified memory. }

  {$L DEALLOC.OBJ }
  procedure  FreeBlock(BlockAddr : word); external;
  { frees the allocated Dos memory block for a specified block segment addres. }

  {$L SETBLOCK.OBJ }
  procedure  ModifyBlock(BlockAddr, Paragraphs : word); external;
  { modifies the allocated Dos memory block for a specified segment address
    ans up to a specified size. }

  {$L GETFTIME.OBJ }
  function   GetFileTime(Handle : word) : longint; external;
  { returns a date and time a file was last written. }

  {$L SETFTIME.OBJ }
  procedure  SetFileTime(Handle : word; Time : longint); external;
  { sets a date and time a file was last written. }

  {$L TIMEPACK.OBJ }
  procedure  PackTime(var T : FileTimeRecord;var Time : longint); external;
  { converts a unpacked record to a 4-byte packed record. }

  {$L TMUNPACK.OBJ }
  procedure  UnPackTime(Time : longint; var T : FileTimeRecord); external;
  { converts a 4-byte packed date-time record to an unpacked record. }

  {$L RENAME.OBJ }
  procedure  Rename(var FileName,NewName : PathStr); external;
  { renames the directory entry. }

  {$L ERASE.OBJ }
  procedure  Erase(var FileName : PathStr); external;
  { erases the directory entry. }

  procedure  RenameFile(FileName,NewName : PathStr);
  { renames the file to a new specified filename. }
  begin
    AsciizString(FileName);
    AsciizString(NewName);
    Rename(FileName,NewName);
    AscString(FileName);
    AscString(NewName);
  end; { Rename }

  procedure  EraseFile(FileName : PathStr);
  { deletes the file. }
  begin
    AsciizString(FileName);
    Erase(FileName);
    AscString(FileName);
  end; { EraseFile }

  {$L GETDIR.OBJ }
  procedure  GetDirectory(Drive : byte; var DirName : DirStr); external;
  { returns the current directory. }

  {$L CHDIR.OBJ }
  procedure  ChDirectory(var DirName : DirStr); external;
  { change the directory. }

  {$L RMDIR.OBJ }
  procedure  RemoveDir(var DirName : DirStr); external;
  { remove the directory. }

  {$L CREATDIR.OBJ }
  procedure  CreateDirectory(var DirName : DirStr); external;
  { creates the directory. }

  procedure  GetDir(Drive : byte; var DirName : DirStr);
  { get the current directory. }
  begin
    GetDirectory(Drive,DirName);
    AscString(DirName);
  end;  { GetDir }

  procedure  ChDir(DirName : DirStr);
  { change the current directory to a specified directory. }
  begin
    AsciizString(DirName);
    ChDirectory(DirName);
    AscString(DirName);
  end;  { ChDir }

  procedure  RmDir(DirName : DirStr);
  { change the current directory to a specified directory. }
  begin
    AsciizString(DirName);
    RemoveDir(DirName);
    AscString(DirName);
  end;  { RmDir }

  procedure  CreateDir(DirName : DirStr);
  { change the current directory to a specified directory. }
  begin
    AsciizString(DirName);
    CreateDirectory(DirName);
    AscString(DirName);
  end;  { CreateDir }

  {$L GETPSP.OBJ }
  function   GetPSP : word; external;
  { returns the segment address of a current Program Prefix Segment. }

  {$L ENVPTR.OBJ }
  function   GetEnvPtr : pointer; external;
  { returns the pointer to the Dos environment string. }

  {$L ENVCOUNT.OBJ }
  function   GetEnvCount : integer; external;
  { returns the number of strings in the Dos environment string. }

  {$L GETPATH.OBJ }
  function   GetProgramPath : PathStr; external;
  { returns the path of the current process. }

  {$L ENVSTR.OBJ }
  function   EnvStr(Index : integer) : AnyString; external;
  { returns the specified environment string. }

  {$L ENVSIZE.OBJ }
  procedure  GetEnvSize(var EnvSize,BlockSize : word); external;
  { returns the environment size in bytes and a environment Dos Memory Block size also in bytes. }

  {$L GETENV.OBJ }
  function   GetEnv(EnvVar : AnyString) : AnyString; external;
  { returns the value of a specified enviroment variable. }

  {$L FIND1ST.OBJ }
  procedure  FindFirstEntry(var Path : PathStr; Attr : word; var F : SearchRecord); external;
  { returns the first match directory entry. }

  procedure  FindFirst(Path : PathStr; Attr : word; var F : SearchRecord);
  { returns the first matching entry for a speicifed pathname. }
  begin
    AsciizString(Path);
    FindFirstEntry(Path,Attr,F);
    AscString(Path);
  end;  { FindFirst }

  {$L FINDNEXT.OBJ }
  procedure  FindNext(var F : SearchRecord); external;
  { must be used after the Fn FindFirst. }

  {$L EXECUTE.OBJ }
  procedure  Execute(var Path : PathStr; var CmdLine : CommandStr); external;
  { loads and executes a specified program. }

  procedure  Exec(Path : PathStr; CmdLine : CommandStr);
  { loads and executes a specified program. }
  begin
    AsciizString(Path);
    Execute(Path,CmdLine);
    AscString(Path);
  end; { Exec }

  {$L EXTERROR.OBJ }
  procedure  ExtendedError(var ErrorCode : word; var ErrorClass : byte;
                           var SuggestedClass : byte; var Locus : byte); external;
  { get the Dos extended error. }

  {$L DISKINFO.OBJ }
  procedure  DiskInfo(Drive : byte; var Info : DriveInfoBlock); external;
  { return the disk drive information. }

  {$L SETCHAR.OBJ }
  procedure  SetSwitchChar(SwitchChar : char); external;
  { sets the char will be used for switches. }

  {$L KEEP.OBJ }
  procedure  Keep(ReturnCode : byte); external;
  { terminates a program and makes it stay in memory. }

  {$L ABSRDWRT.OBJ }
  procedure  DosAbsoluteRead(Drive : byte; SecsNum : word; StartSec : longint;
                             Buffer : pointer); external;
  { Dos direct dsik reading. }

  procedure  DosAbsoluteWrite(Drive : byte; SecsNum : word; StartSec : longint;
                              Buffer : pointer); external;
  { Dos direct disk writing. }

  {$L MAKEFILE.OBJ }
  procedure  MakeFile(var Path : PathStr; Attr : word; var Handle : word); external;
  { creates a temporary file. }

  procedure  CreateNewFile(var PathName : PathStr; Attr : word; var Handle : word); external;
  { creates the new file, but fails if it exists. }

  procedure  MakeTempFile(Path : PathStr; Attr : word; var Handle : word);
  { creates a temporary file in a specified directory,the path must be ending by '\'.}
  begin
    AsciizString(Path);
    MakeFile(Path,Attr,Handle);
    AscString(Path);
  end;  { MakeTempFile }

  procedure  MakeNewFile(PathName : PathStr; Attr : word; var Handle : word);
  { try to create the new file by a specified pathname. }
  begin
    AsciizString(PathName);
    CreateNewFile(PathName,Attr,Handle);
    AscString(PathName);
  end;  { MakeNewFile }

  {$L LOCKOPER.OBJ }
  procedure  LockFile(Handle : word; Offset : longint; Region : longint); external;
  { locks a region of file. }

  procedure  UnLockFile(Handle : word; Offset : longint; Region : longint); external;
  { unlocks a region of file. }

  {$L PARSE.OBJ }
  procedure  ParseName(Mode : byte; var TextStr; var FCBptr : FileControlBlock); external;
  { parses a filename. }

  {$L OVERLAY.OBJ }
  procedure  OverlayProgram(var PathName : PathStr); external;
  { overlays a specified program. }

  procedure  LoadOverlay(PathName : PathStr);
  { loads but no executes a program. }
  begin
    AsciizString(PathName);
    OverlayProgram(PathName);
    AscString(PathName);
  end;  { LoadOverlay }

  {$L INTR.OBJ }
  procedure  Intr(IntNo : byte; var Regs : Registers); external;
  { executes a specified software interrupt. }

  procedure  MsDos(var Regs : Registers);
  { executes a Dos function call. }
  begin
    Intr($21,Regs);
  end;  { MsDos }

  {$L GETALLOC.OBJ }
  function   GetAllocStrategy : byte; external;
  { get a memory allocation strategy code. }

  {$L SETALLOC.OBJ }
  procedure  SetAllocStrategy(MemStrategyCode : byte); external;
  { sets a new memory allocation strategy code. }

  procedure  Append(FileName : PathStr;var Handle : word);
  { opens a existing file for appending. }
  var
    ErrorCode,SaveDosHandle  :  word;
  begin
    FileMode := ReadWrite;
    OpenFile(FileName,SaveDosHandle);
    ErrorCode := InOutRes;
    if  (ErrorCode <> 0)  then  Exit;
    Seek(SaveDosHandle,FileSize(SaveDosHandle));
    Handle := SaveDosHandle;
  end;  { Append }

  procedure  Reset(FileName : PathStr;var Handle : word);
  { opens an existing file only for read. }
  var
    SaveFileMode  :  byte;
  begin
    SaveFileMode := FileMode;
    FileMode := Read;
    OpenFile(FileName,Handle);
    FileMode := SaveFileMode;
  end;  { Reset }

  procedure  Rewrite(FileName : PathStr;var Handle : word);
  { creates and opens a new file with normal attribute. }
  begin
    CreateFile(FileName,Normal,Handle);
  end;  { Rewrite }

  procedure  Truncate(Handle : word);
  { truncates the file size at the current file position. }
  var
    Result : word;
  begin
    WriteFile(Handle,nil,0,Result);
  end;  { Truncate }

  procedure  FSplit(Path : PathStr; var Dir : DirStr; var Name : NameStr; var Ext : ExtStr);
  { splits a file name into its three components. }
  var
    I  :  byte;
  begin
    Dir := '';
    Name := '';
    Ext := '';
    I := Pos('\',Path);
    if (I = 0)  then  I := Pos(':',Path);
    while  (I <> 0)  do  begin
      Dir := Dir + Copy(Path,1,I);
      Delete(Path,1,I);
      I := Pos('\',Path);
    end;  { while }
    I := Pos('.',Path);
    Dec(I);
    Name := Copy(Path,1,I);
    Delete(Path,1,I);
    Ext := Path;
  end;  { FSplit }

  function   FExpand(Path : PathStr) : PathStr;
  { expands a file name into a fully qualified file name. }
  var
    DirName  :  DirStr;
  begin
    UpCaseString(Path);
    GetDir(0,DirName);
    FExpand := DefaultDrive + ':\' + DirName + '\' + Path;
  end;  { FExpand }

  function   FSearch(Path : PathStr; DirList : AnyString) : PathStr;
  { searches for a file in a list of directories by DirList. The directories
    must be separated by semicolons. }
  var
    Attr    :  word;
    S       :  PathStr;
    Found   :  boolean;
    I       :  byte;
  begin
    Found := false;
    UpCaseString(Path);
    repeat
      I := Pos(';',DirList);
      if  (I = 0)  then  S := DirList
      else  S := Copy(DirList,1,I-1);
      if  (S[Length(S)] <> '\')  then  S := S + '\';
      S := S + Path;
      GetFileAttr(S,Attr);
      if  (IOResult = 0)  then  Found := true
      else  S := '';
      Delete(DirList,1,I);
    until  (Found) or (DirList = '') or (I = 0);
    FSearch := S;
  end;  { FSearch }

  function   ExtractFileName(Path : PathStr) : FileStr;
  { extracts the file name from a full DOS path. }
  var
    i  :  byte;
  begin
    i := Pos(':',Path);
    if (i <> 0)  then Delete(Path,1,i);
    i := Pos('\',Path);
    while  (i <> 0)  do  begin
      Delete(Path,1,i);
      i := Pos('\',Path);
    end;  { while }
    ExtractFileName := Path;
  end;  { ExtractFileName }

  procedure  NewSystem(NewCmdLine : AnyString);
  { try to load a new command processor. }
  var
    FCB1,FCB2  :  FileControlBlock;
  begin
    ParseName(1,NewCmdLine,FCB1);
    ParseName(1,NewCmdLine,FCB2);
    ExecBlock[0] := 0;
    ExecBlock[3] := Ofs(FCB1);
    ExecBlock[4] := Seg(FCB1);
    ExecBlock[5] := Ofs(FCB2);
    ExecBlock[6] := Seg(FCB2);
    SwapVectors;
    Exec(GetEnv('COMSPEC'),NewCmdLine);
    SwapVectors;
  end;  { NewSystem }

  function   MakeFileName(Drive : byte; Dir : DirStr; Name : NameStr; Ext : ExtStr) : PathStr;
  { constructs a full file path name. }
  begin
    MakeFileName := char(Drive+ord('A')) + '\' + Dir + '\' + Name + '.' + Ext;
  end;  { MakeFileName }

  {$L HOSTENV.OBJ }
  function   MasterEnvironment : word; external;
  { returns a segment address of the original environment (default = 'COMMAND.COM'). }

  procedure  GetCmdLine(var S);
  { gets a original command line of parameters. }
  begin
    Move(Mem[PrefixSeg:$80],S,Mem[PrefixSeg:$80]+1);
  end;  { GetCmdLine }

  procedure  RemEnvStr(EnvString : AnyString);
  { removes a specified string from  environment. }
  var
    Offset, EnvSize, MemBlockSize, SaveOfs  :  word;
    P, L  :  pointer;
  begin
    if  (EnvString[Length(EnvString)] <> '=')  then
      EnvString := EnvString + '=';
    P := GetEnvPtr;
    L := Ptr(Seg(EnvString[1]),Ofs(EnvString[1]));
    GetEnvSize(EnvSize,MemBlockSize);
    Offset := Search(P,EnvSize,L,Length(EnvString));
    if  (Offset = $FFFF)  then  Exit;
    P := AddPtr(P,Offset);
    SaveOfs:= Offset;
    Offset := SearchFirstMatch(P,EnvSize,#0)+1;       { skip a null }
    L := AddPtr(P,Offset);
    TpMove(L,P,MemBlockSize-SaveOfs-Offset);
  end;  { RemEnvStr }

  procedure  AddEnv(S  : AnyString);
  { adds a new environment string. }
  var
    EnvSize, Memsize  :  word;
    P, L  : pointer;
  begin
    GetEnvSize(EnvSize,MemSize);
    Insert(#0#0,S,Length(S)+1);
    if  (Length(S) > (MemSize - EnvSize))  then  Exit;
    P := AddPtr(GetEnvPtr,EnvSize);
    L := Ptr(Seg(S[1]),Ofs(S[1]));
    TpMove(L,P,Length(S));
  end;  { AddEnv }

  procedure  PutEnvStr(EnvString : AnyString);
  { replaces an existing variable or puts a new environment string. }
  var
    S1, S2  :  AnyString;
    EnvSize, Memsize, Offset : word;
    P, P2  :  pointer;
  begin
    P := GetEnvPtr;
    S1 := Copy(EnvString,1,Pos('=',EnvString) + 1);
    S2 := Copy(S1,1,Length(S1)-1);
    if  (GetEnv(S2) = '')   then
       AddEnv(EnvString)
    else  begin
      GetEnvSize(EnvSize,MemSize);
      P2 := Ptr(Seg(S2[1]),Ofs(S2[1]));
      Offset := Search(P,$8000,P2,Length(S2));
      P := AddPtr(P,Offset);
      Offset := SearchFirstMatch(P,255,#0);
      if  (MemSize - (EnvSize) + Offset) < Length(EnvString)  then  Exit;
      RemEnvStr(S1);
      AddEnv(EnvString);
    end;
  end;  { PutEnvStr }

  function   EOF(Handle : word) : boolean;
  { returns the end-of-file status. }
  begin
    EOF := (FileSize(Handle) = FilePos(Handle));
  end;  { EOF }

  function   IsPath(S : PathStr) : boolean;
  { returns true if S ends with '\' }
  var
    SLen : byte absolute S;
  begin
     if  (S[SLen] = '\') then  IsPath := true
     else  IsPath := false;
  end; { IsPath }

  procedure  SetTrueDos(On : boolean);
  { try to find the true entry for Dos $21 Int. }
  const
    BufLen  =   $4100;
    CpmStr      :  Str6  =  #$9C#$FA#$50#$2E#$FF#$36;
    DosStr      :  Str6  =  #$2E#$3A#$26;
    sDos5High   :  Str6  =  #$90#$90#$E8#$CC#$00#$2E;
    sDos5Low    :  Str6  =  #$EB#$03#$E8#$CC#$00#$2E;
    sDos7High   :  Str6  =  #$90#$90#$E8#$CE#$00#$2E;
    sDos7Low    :  Str6  =  #$EB#$03#$E8#$CE#$00#$2E;
    dbMatchDiff :  System.Byte = $13;
    dwDos5MatchOfs  :  System.Word = $109E;
    dwDos7MatchOfs  :  System.Word = $FB2;
  var
    MsDosEntry,DosSeg,dwMatchOfs : word;
    P : pointer;
    sDosTmpLow, sDosTmpHigh : Str6;
  begin
    if  (On)  then  begin
       DosSeg := DosInVars;
       P := Ptr(DosSeg,$0);
       IF (CurDosVer >= $0500)
         THEN  BEGIN
                  dbMatchDiff := $15;
                  CpmStr := #$9C#$FA#$50#$FF#$36;
                  DosStr := #$FA#$80#$FC#$6C#$77#$D2;
                  sDosTmpLow := sDos5Low;
                  sDosTmpHigh := sDos5High;
                  dwMatchOfs := dwDos5MatchOfs;
                  IF (CurDosVer >= $0700)
                    THEN  BEGIN
                       DosStr := #$FA#$80#$FC#$73#$77#$D2;
                       sDosTmpLow := sDos7Low;
                       sDosTmpHigh := sDos7High;
                       dwMatchOfs := dwDos7MatchOfs;                       
                          END;
                  {if-then}
               END;
       MsDosEntry := SearchString(P,BufLen,DosStr);
       if ((MsDosEntry - SearchString(P,BufLen,CpmStr)) = dbMatchDiff)
       then
       begin
          IF (CurDosVer >= $0500)
            THEN
                bDos5InUseOk := System.True
            ELSE BEGIN
              PutTrueDosEntry(Ptr(DosSeg,MsDosEntry));
              UseTrueDos := true;
                 END;
       end
       else begin
             IF (CurDosVer >= $0500)  THEN
               BEGIN
                  IF (SearchString(P,BufLen,sDosTmpHigh) = dwMatchOfs)
                    THEN  bDos5InUseOk := System.True
                    ELSE  BEGIN
                      IF   (SearchString(P,BufLen,sDosTmpLow) = dwMatchOfs)
                        THEN  bDos5InUseOk := System.True;
                      {if-then}
                          END;
                  {if-then-else}
               END; {if-then}
            end; { else }
    end  { if }
    else
      UseTrueDos := false;
  end;  { SetTrueDos }

  function   DosErrorMessage(ErrCode : byte) : AnyString;
  { returns the text message about the error. }
  var
    S  :  AnyString;
  begin
      case  ErrCode  of
              0  :   S :=  '';
              1  :   S :=  'invalid function code';
              2  :   S :=  'file not found';
              3  :   S :=  'path not found';
              4  :   S :=  'too many open files';
              5  :   S :=  'access denied';
              6  :   S :=  'invalid handle';
              7  :   S :=  'memory control blocks destroyed';
              8  :   S :=  'insufficient memory';
              9  :   S :=  'invalid memory block address';
              10 :   S :=  'invalid environment';
              11 :   S :=  'invalid format';
              12 :   S :=  'invalid access code';
              13 :   S :=  'invalid data';
              15 :   S :=  'invalid drive';
              16 :   S :=  'attempt to remove the current directory';
              17 :   S :=  'not same device';
              18 :   S :=  'no more files';
              19 :   S :=  'disk is write-protected';
              20 :   S :=  'bad disk unit';
              21 :   S :=  'drive not ready';
              22 :   S :=  'invalid disk command';
              23 :   S :=  'CRC error';
              24 :   S :=  'invalid length';
              25 :   S :=  'seek error';
              26 :   S :=  'not an MS-DOS disk';
              27 :   S :=  'sector not found';
              28 :   S :=  'out of paper';
              29 :   S :=  'write fault';
              30 :   S :=  'read fault';
              31 :   S :=  'general failure';
              32 :   S :=  'sharing violation';
              33 :   S :=  'lock violation';
              34 :   S :=  'wrong disk';
              35 :   S :=  'FCB unavailable';
              36 :   S :=  'sharing buffer overflow';
              50 :   S :=  'network request not supported';
              51 :   S :=  'remote computer not listing';
              52 :   S :=  'duplicate name on network';
              53 :   S :=  'network name not found';
              54 :   S :=  'network buzy';
              55 :   S :=  'network device no longer exists';
              56 :   S :=  'NETBIOS command limit exceed';
              57 :   S :=  'network adapter hardware error';
              58 :   S :=  'incorrect response from network';
              59 :   S :=  'unexpected network  error';
              60 :   S :=  'incompatible remote adapter';
              61 :   S :=  'print queue full';
              62 :   S :=  'queue not full';
              63 :   S :=  'not enough space for print file';
              64 :   S :=  'network name was deleted';
              65 :   S :=  'access denied';
              66 :   S :=  'network device type incorrect';
              67 :   S :=  'network name not found';
              68 :   S :=  'network name limit exceed';
              69 :   S :=  'NETBIOS session limit exceed';
              70 :   S :=  'temporary paused';
              71 :   S :=  'network request not accepted';
              72 :   S :=  'print or disk redirection is paused';
              80 :   S :=  'file exists';
              82 :   S :=  'cannot make';
              83 :   S :=  'interrupt 24h failure';
              84 :   S :=  'out of structure';
              85 :   S :=  'already assigned';
              86 :   S :=  'invalid password';
              87 :   S :=  'invalid parameter';
              88 :   S :=  'network write fault';
      else
          S := 'unknown error';
   end;  { case }
   DosErrorMessage := S;
  end;  { DosErrorMessage }

  function   AddBackSlash(S : PathStr) : PathStr;
  { make a path name. }
  begin
    AddBackSlash := S + '\';
  end;  { AddBackSlash }

  function  MakeExtension(Name : PathStr; Ext : ExtStr) : AnyString;
  { if extension not found, then add it. }
  begin
    if (Pos('.',Name) = 0) then Name := Name + Ext;
    MakeExtension := Name;
  end;  { MakeExtension }

  function   ExtractPathName(Path : PathStr) : PathStr;
  { extracts the pathname from a full DOS path. }
  var
    Dir : DirStr;
    Name : NameStr;
    Ext : ExtStr;
  begin
    FSplit(Path,Dir,Name,Ext);
    ExtractPathName := Dir;
  end;  { ExtractPathName }

  procedure   Multiplex(var Regs : Registers);
  { DOS multiplex process interface. }
  begin
    Intr($2F,Regs);
  end;  { Multiplex }

  begin   { initialization part }
    FileMode := ReadWrite;
    CurDosVer := DosVersion;
  end.
