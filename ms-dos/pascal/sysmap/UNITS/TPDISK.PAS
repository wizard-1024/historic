  {$D-,I-,S-}

  {     ****************************************************
        *                                                  *
        *         Turbo Pascal 6.0   DISK  Unit            *
        *       Provides access to the ROM-BIOS functions  *
	*          Version  2.10      01/09/91             *
        *          written  by  Dmitry Stefankov           *
        *                                                  *
        ****************************************************
  }

   unit   TpDisk;

   interface                 { public part }

     uses
       TpString,TpDos;       { other units }

     const
        FloppyA      =      0;
        FloppyB      =      1;
        Hard0        =      $80;
        Hard1        =      $81;

     var
       DiskError     :    boolean;
       DiskStatus    :    byte;

     procedure  DiskInt(var Regs : Registers);
     procedure  ResetDisk(Drive : byte);
     procedure  GetDiskStatus(Drive : byte);
     procedure  ReadFromDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                             Buffer : pointer; var Result : byte);
     procedure  WriteToDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                            Buffer : pointer; var Result : byte);
     procedure  VerifyDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                           Buffer : pointer; var Result : byte);
     procedure  FormatTrackOnDiskette(NumSec : byte; Cylinder : word; Head,Drive : byte;
                                      AddressList : pointer);
     procedure  FormatTrackHardXT(Interleave : byte; Cylinder : word; Head,Drive : byte);
     procedure  FormatTrackHardAT(Cylinder : word; Head,Drive : byte;AddressList : pointer);
     procedure  FixedDiskParms(Drive : byte; var Cylinders : word; var Sectors,Heads,Disks : byte);
     procedure  DisketteParms(Drive : byte; var Cylinders : word; var Sectors,Heads,Disks,DriveType : byte;
                              var DDPtable : pointer);
     procedure  InitDiskTable(FixedDisk : byte);
     procedure  ReadLong(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                         Buffer : pointer; var Result : byte);
     procedure  WriteLong(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                          Buffer : pointer; var Result : byte);
     procedure  SeekCylinder(Track : word; Head,Drive : byte);
     procedure  AlternateResetDisk(FixedDisk : byte);
     procedure  TestDriveReady(Drive : byte);
     procedure  RecalibrateDrive(Drive : byte);
     procedure  ReadDASDtype(Drive : byte; var DriveType : byte; var Sectors : longint);
     procedure  ChangeStatusLine(Drive : byte; var StatusLine : byte);
     procedure  SetDASDtype(Combine,Drive : byte);
     procedure  SetMediaType(Tracks : word; SecsPerTrack,Drive : byte; DiskTable : pointer);
     function   DiskErrorMessage(ErrCode : byte) : AnyString;

   implementation                { private part }

      {$L TPDISK.OBJ }

      procedure  DiskInt(var Regs : Registers);
      { call Disk BIOS. }
      begin
        Intr($13,Regs);
      end;  { DiskInt }

      procedure  ResetDisk(Drive : byte); external;
      { resets the disk drive controller. }

      procedure  GetDiskStatus(Drive : byte); external;
      { get the disk status after the last operation. }

      procedure  ReadFromDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                              Buffer : pointer; var Result : byte); external;
      { read the sectors from disk into memory. }

      procedure  WriteToDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                             Buffer : pointer; var Result : byte); external;
      { writes a sectors from memory to disk. }

      procedure  VerifyDisk(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                            Buffer : pointer; var Result : byte); external;
      { verify the sectors on the disk. }

      procedure  FormatTrackOnDiskette(NumSec : byte; Cylinder : word; Head,Drive : byte;
                                       AddressList : pointer); external;
      { formats one track on the diskette. }

      procedure  FormatTrackHardXT(Interleave : byte; Cylinder : word; Head,Drive : byte); external;
      { format one track on the XT hard disk. }

      procedure  FormatTrackHardAT(Cylinder : word; Head,Drive : byte;AddressList : pointer); external;
      { format one track on the AT hard disk. }

      procedure  FixedDiskParms(Drive : byte; var Cylinders : word; var Sectors,Heads,Disks : byte); external;
      { returns the info about current fixed disk. }

      procedure  DisketteParms(Drive : byte; var Cylinders : word; var Sectors,Heads,Disks,DriveType : byte;
                               var DDPtable : pointer); external;
      { returns the current diskette info. }
      procedure  InitDiskTable(FixedDisk : byte); external;
      { init the vectors to the fixed disk tables. }

      procedure  ReadLong(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                          Buffer : pointer; var Result : byte); external;
      { diagnostic reading. }

      procedure  WriteLong(SecNum : byte; Cylinder : word; StartSec,Head,Drive : byte;
                           Buffer : pointer; var Result : byte); external;
      { diagnostic writing. }

      procedure  SeekCylinder(Track : word; Head,Drive : byte); external;
      { moves a head to a specified cylinder. }

      procedure  AlternateResetDisk(FixedDisk : byte); external;
      { alternate reset for the hard disk. }

      procedure  TestDriveReady(Drive : byte); external;
      { test for the disk controller ready. }

      procedure  RecalibrateDrive(Drive : byte); external;
      { recalibrates the hard disk. }

      procedure  ReadDASDtype(Drive : byte; var DriveType : byte; var Sectors : longint); external;
      { read the DASD type of disk. }

      procedure  ChangeStatusLine(Drive : byte; var StatusLine : byte); external;
      { returns the status line of diskette. }

      procedure  SetDASDtype(Combine,Drive : byte); external;
      { sets the DASD type. }

      procedure  SetMediaType(Tracks : word; SecsPerTrack,Drive : byte; DiskTable : pointer); external;
      { set the disk type for format. }

      function   DiskErrorMessage(ErrCode : byte) : AnyString;
      { returns the message about error status. }
      var
        S : Anystring;
      begin
         case  ErrCode  of
            0 :     S := 'No errors';
            1 :     S := 'invalid command';
            2 :     S := 'address mark not found';
            3 :     S := 'attempt to write on write-protected disk';
            4 :     S := 'sector not found';
            5 :     S := 'reset failed';
            7 :     S := 'drive parameter activity failed';
            8 :     S := 'DMA overrun';
            9 :     S := 'attempt to DMA across a 64K boundary';
           10 :     S := 'bad sector flag detected';
           11 :     S := 'bad cylinder found';
           13 :     S := 'invalid number sectors on format';
           14 :     S := 'invalid data address mark detected';
           15 :     S := 'DMA arbitration level out of range';
           16 :     S := 'ECC data error';
           17 :     S := 'ECC corrected data error';
           32 :     S := 'controller failure';
           64 :     S := 'seek failure';
          128 :     S := 'time out';
          170 :     S := 'drive not ready';
          187 :     S := 'Undefined error';
          204 :     S := 'status error';
          255 :     S := 'sense operation failed';
         else
            S := 'unknown error';
        end;  { case }
        DiskErrorMessage := S;
      end;  { DiskErrorMessage }


   {begin}    { initialization }
   end.
