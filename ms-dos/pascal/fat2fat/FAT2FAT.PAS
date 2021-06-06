{****************************************************************************
//                            File FAT2FAT.PAS
//
//              FAT16 logical drive smart copy program
//
//      Copyright (c) 1998, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/RCS/fat2fat.pas $
//  $RCSfile: fat2fat.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 18:13:15 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: fat2fat.pas $
//      Revision 1.1  1999/01/03 18:13:15  dstef
//      Initial revision
// 
//
//****************************************************************************}


{* Original: January-March 1998 *}

PROGRAM  CopyDosLogicalDrive;

{$S-}
{$R-}
{$M 8192,0,0 }

{***$DEFINE   SaveReadFatFile}
{***$DEFINE   SaveWriteFatFile}
{***$DEFINE   WriteLogFile}
{***$DEFINE   DebugVersion}
{$DEFINE   ReadEnableVersion }
{$DEFINE   WriteEnableVersion}
{$DEFINE   WriteFatVersion}


USES
  ShowTErr;    {This module from famous DSUTILxx.ZIP on Internet!}


CONST
     aDosServicesInt            =  $21;
     aDosAbsReadInt             =  $25;
     aDosAbsWriteInt            =  $26;
     aAllocMemBlock             =  $48;
     aFreeMemBlock              =  $49;
     aWord                      =  2;
     BYTES_PER_PARA             =  16;
     MAX_DOS_BLK_SIZ_PARAS      =  4096;
     MAX_SECTORS_PER_BLK        =  128;  {65536 / 512}
     MAX_FAT_SIZ_PARAS          =  MAX_DOS_BLK_SIZ_PARAS; {64 KB}
     MAX_BLK_FILL_SIZ           =  32768;
     SEC_SIZ                    =  512;
     DIR_ENTRY_SIZ              =  32;
     BOOT_SEC_ID                =  $AA55;
     FREE_CLUSTER               =  0;
     UNUSED_CODE_1              =  1;
     UNUSED_CODE_2              =  2;
     BAD_CLUSTER                =  $FFF7;
     RESERVD_CLUSTER_BGN        =  $FFF0;
     RESERVD_CLUSTER_END        =  $FFF6;
     END_OF_CHAIN_BG            =  $FFF8;
     END_OF_CHAIN_END           =  $FFFF;
     CLUSTERS_PER_SEG           =  32768;
     MAX_SECS_BLOCK             =  128;
     FIXED_BPB_EPB_SIZ          =  36-11+1;

TYPE

   STR2  =  STRING[2];
   STR4  =  STRING[4];
   STR10 =  STRING[10];

   recDosAbsPacketRW  =  RECORD
              liStartingSectorNum       :  longint;   {+00}
              dwTransferSectorCount     :  word;      {+04}
              lpTransferBuffer          :  pointer;   {+06}
                         END;
   {recDosAbsPacketRW}

   recBootSector      =  RECORD
                dbNearJump              :  ARRAY[1..3] OF byte;   {00}
                chOemID                 :  ARRAY[1..8] OF byte;   {02}
                dwBytesPerSector        :  word;                  {11}
                dbSectorsPerCluster     :  byte;                  {13}
                dwReservedSectors       :  word;                  {14}
                dbFATs                  :  byte;                  {16}
                dwRootEntries           :  word;                  {17}
                dwSmallSectors          :  word;                  {19}
                dbMediaDescriptor       :  byte;                  {21}
                dwSectorsPerFAT         :  word;                  {22}
                dwSectorsPerTrack       :  word;                  {24}
                dwHeads                 :  word;                  {26}
                liHiddenSectors         :  longint;               {28}
                liLargeSectors          :  longint;               {32}
                dbPhysicalDriveNumber   :  byte;                  {36}
                dbCurrentHead           :  byte;                  {37}
                dbSignature             :  byte;                  {38}
                liID                    :  longint;               {39}
                chVolumeLabel           :  ARRAY[1..11]  OF byte; {43}
                chSystemID              :  ARRAY[1..8]   OF byte; {54}
                dbBootSecCode           :  ARRAY[1..448] OF byte; {62}
                dwBootSecID             :  word;                  {510}
                         END;
  {recBootSector}

   recDriveParam    =   RECORD
             liBootSectorOfs            :  longint;
             liFat1Ofs                  :  longint;
             liFat2Ofs                  :  longint;
             dwFatSecs                  :  word;
             liRootDirOfs               :  longint;
             liDataAreaOfs              :  longint;
             dwRootDirSecs              :  word;
             dwDataClusters             :  word;
             dwSectorsInCluster         :  word;
                        END;
  {recDriveParam}

CONST
   g_fCopyBootSector       :   boolean = TRUE;
   g_fCopyDataFreeSpace    :   boolean = TRUE;
   g_fFillUnusedSpace      :   boolean = TRUE;
   g_fBatchModeOk          :   boolean = FALSE;
   g_lpFatReadCacheBuf     :   pointer = NIL;
   g_lpFatWriteCacheBuf    :   pointer = NIL;
   g_lpReadDataCluster     :   pointer = NIL;
   g_lpWriteDataCluster    :   pointer = NIL;

VAR
  g_sElapsedTime : STR10;
  g_dbSrcDrv,
  g_dbDestDrv,
   g_dbElapsedHour,
   g_dbElapsedMin,
   g_dbElapsedSec,
  g_dbDosError : byte;
  g_chTemp : char;
  g_sTemp : STRING;
  g_lpTemp : pointer;
  g_DosTransferPacket : recDosAbsPacketRW;
  g_fLastCluster,
  g_fTestRes,
  g_fWaitData : boolean;
  g_recSrcBootSec,
  g_recDestBootSec : recBootSector;
  g_recSrcDrvParams,
  g_recDestDrvParams : recDriveParam;
  g_dwDestDataClusSiz,
  g_dwSrcDataClusSiz,
  g_dwUnusedClusters1,
  g_dwUnusedClusters2,
  g_dwChainClusters,
  g_dwBadClusters,
  g_dwDataClusters,
  g_dwResrvdClusters,
  g_dwFreeSrcClusters,
  g_dwWrkClusValue,
  g_dwTemp,
  g_dwCurReadClusNum,
  g_dwCurWriteClusNum,
  g_dwContReadClusNum,
  g_dwMaxReadClusNum : word;
  g_InitTimeTicks,
  g_liReadFatBufSize,
  g_liNextWrtBufOfs,
  g_liTemp,
  g_liDestDataAreaOfs,
  g_liSrcDataAreaOfs : longint;
{$IFDEF   SaveReadFatFile}
  g_fFatFile : FILE;
{$ENDIF   SaveReadFatFile}
{$IFDEF   SaveWriteFatFile}
  g_fWrtFatFile : FILE;
{$ENDIF   SaveWriteFatFile}
{$IFDEF   WriteLogFile}
  g_fLogFile : TEXT;
  g_LogTextBuf : ARRAY[1..32768] OF char;
{$ENDIF   WriteLogFile}


FUNCTION  _fbDosAbsoluteRead(dbDosDrive : byte;
                             liStartSector : longint;
                             dwSectorCount : word;
                             lpMemBuf : pointer) : boolean; ASSEMBLER;

ASM
      mov     bx, OFFSET g_DosTransferPacket
      les     dx, lpMemBuf
      mov     WORD PTR [bx][recDosAbsPacketRW.lpTransferBuffer+0], dx
      mov     WORD PTR [bx][recDosAbsPacketRW.lpTransferBuffer+2], es
      les     dx, liStartSector
      mov     WORD PTR  [bx][recDosAbsPacketRW.liStartingSectorNum]+0, dx
      mov     WORD PTR  [bx][recDosAbsPacketRW.liStartingSectorNum+2], es
      mov     ax, dwSectorCount
      mov     WORD PTR  [bx][recDosAbsPacketRW.dwTransferSectorCount], ax
      mov     cx, 0FFFFh                    {Extended sign}
      mov     al, dbDosDrive
{$IFDEF    ReadEnableVersion }
      int     aDosAbsReadInt
      pop     dx                            {Discard old flags}
{$ELSE}
      xor      al, al                       {CF->0 automatically}
{$ENDIF    ReadEnableVersion }
      mov     g_dbDosError, al
      mov     al, FALSE
      jc     @Done
      mov     al, TRUE
 @Done:
END;
{ _fbDosAbsoluteRead }


FUNCTION  _fbDosAbsoluteWrite(dbDosDrive : byte;
                             liStartSector : longint;
                             dwSectorCount : word;
                             lpMemBuf : pointer) : boolean; ASSEMBLER;

ASM
      mov     bx, OFFSET g_DosTransferPacket
      les     dx, lpMemBuf
      mov     WORD PTR [bx][recDosAbsPacketRW.lpTransferBuffer+0], dx
      mov     WORD PTR [bx][recDosAbsPacketRW.lpTransferBuffer+2], es
      mov     ax, dwSectorCount
      mov     WORD PTR  [bx][recDosAbsPacketRW.dwTransferSectorCount], ax
      les     dx, liStartSector
      mov     WORD PTR  [bx][recDosAbsPacketRW.liStartingSectorNum]+0, dx
      mov     WORD PTR  [bx][recDosAbsPacketRW.liStartingSectorNum+2], es
      mov     cx, 0FFFFh                    {Extended sign}
      mov     al, dbDosDrive
{$IFDEF    WriteEnableVersion }
      int     aDosAbsWriteInt
      pop     dx                            {Discard old flags}
{$ELSE}
      xor      al, al                       {CF->0 automatically}
{$ENDIF    WriteEnableVersion }
      mov     g_dbDosError, al
      mov     al, FALSE
      jc     @Done
      mov     al, TRUE
 @Done:
END;
{ _fbDosAbsoluteWrite }


FUNCTION
        _fnbAllocLowMemBlock(dwMemSizeInParas : System.Word;
             VAR lpAllocatedMemBlock : System.Pointer) : System.Boolean; ASSEMBLER;
{*
Description.
      Allocates the low memory block using DOS services.
*}
ASM
                les     di, lpAllocatedMemBlock
                mov     bx, dwMemSizeInParas
                mov     ah, aAllocMemBlock
                int     aDosServicesInt
                mov     bx, 0
                mov     es:[di][0], bx           {Offset=zero}
                jc     @1
                mov     bx, ax                   {Save segment value}
                mov     al, System.True          {Return success}
                jmp    @2
       @1:
                mov     al, System.False         {Return an error}
       @2:
                mov     es:[di][aWord*1], bx     {Offset=zero}
END;
{ _fnbAllocLowMemBlock }


FUNCTION
        _fnbReleaseLowMemBlock(dwSegment : System.Word) : System.Boolean; ASSEMBLER;
{*
Description.
    Returns specified low memory block back to DOS memory pool.
*}
ASM
            mov     es, dwSegment
            mov     ah, $49
            int     aDosServicesInt
            jc     @1
            mov     al, System.True          {Return success}
            jmp    @2
   @1:      mov     al, System.False         {Return an error}
   @2:
END;
{ _fnbReleaseLowMemBlock }


FUNCTION   _fnsByteToHexFmt(dbInput : System.Byte) : STR2;
{* Converts a byte to the hex format number representation. *}
CONST
    dbHexCharTable : ARRAY[0..15] OF System.Char = '0123456789ABCDEF';

BEGIN
  _fnsByteToHexFmt := dbHexCharTable[dbInput SHR 4] + dbHexCharTable[dbInput AND $0F];
END;  { _fnsByteToHexFmt }


FUNCTION   _fnsWordToHexFmt(dwInput : System.Word) : STR4;
{* Converts a word to the hex format number representation. *}
BEGIN
  _fnsWordToHexFmt := _fnsByteToHexFmt(System.Hi(dwInput)) +
                      _fnsByteToHexFmt(System.Lo(dwInput));
END;  { _fnsWordToHexFmt }


FUNCTION  _fndwGetClusterValue(dwClusterNum : word;
                               lpFatBuf : pointer) : word;
{* Extracts a cluster value. *}
VAR
  dwSeg, dwOfs, dwValue, dwClustT : word;
BEGIN
  IF  (lpFatBuf <> NIL)
    THEN BEGIN
      dwClustT := dwClusterNum;
      dwSeg := Seg(lpFatBuf^);
      IF (dwClustT >= CLUSTERS_PER_SEG)
        THEN BEGIN
           Dec(dwClustT,CLUSTERS_PER_SEG);
           Inc(dwSeg,MAX_DOS_BLK_SIZ_PARAS);
             END;
      {if-then}
      dwOfs := Ofs(lpFatBuf^) + dwClustT*aWord;
      dwValue := MemW[dwSeg:dwOfs];
         END
    ELSE BEGIN
       dwValue := UNUSED_CODE_1;
         END;
  {if-then-else}
{$IFDEF   WriteLogFile}
    IF  (g_lpFatReadCacheBuf = lpFatBuf)
      THEN  WriteLn(g_fLogFile,'GET::ReadFat> clus=',dwClusterNum,'; val=',dwValue);
    {if-then}
    IF  (g_lpFatWriteCacheBuf = lpFatBuf)
      THEN  WriteLn(g_fLogFile,'GET::WritFat> clus=',dwClusterNum,'; val=',dwValue);
    {if-then}
{$ENDIF   WriteLogFile}
  _fndwGetClusterValue := dwValue;
END;
{ _fndwGetClusterValue }


PROCEDURE  _PutClusterValue(dwClusterNum : word;
                            dwNewValue : word;
                            lpFatBuf : pointer);
{* Writes a new cluster value. *}
VAR
  dwSeg, dwOfs : word;
BEGIN
{$IFDEF   WriteLogFile}
    IF  (g_lpFatReadCacheBuf = lpFatBuf)
      THEN  WriteLn(g_fLogFile,'PUT::ReadFat> clus=',dwClusterNum,'; val=',dwNewValue);
    {if-then}
    IF  (g_lpFatWriteCacheBuf = lpFatBuf)
      THEN  WriteLn(g_fLogFile,'PUT::WritFat> clus=',dwClusterNum,'; val=',dwNewValue);
    {if-then}
{$ENDIF   WriteLogFile}
  IF (lpFatBuf <> NIL)
    THEN  BEGIN
      dwSeg := Seg(lpFatBuf^);
      IF (dwClusterNum >= CLUSTERS_PER_SEG)
        THEN BEGIN
           Dec(dwClusterNum,CLUSTERS_PER_SEG);
           Inc(dwSeg,MAX_DOS_BLK_SIZ_PARAS);
             END;
      {if-then}
      dwOfs := Ofs(lpFatBuf^) + dwClusterNum*aWord;
      MemW[dwSeg:dwOfs] := dwNewValue;
          END;
  {if-then}
END;
{ _PutClusterValue }


PROCEDURE  _DumpBootSector(recSectorToDump : recBootSector);
{* Dumps a contents of boot sector. *}
VAR
  dbIndex : byte;

BEGIN
  Write('Jump: ');
  FOR  dbIndex := 1 TO 3 DO
    Write( '$', _fnsByteToHexFmt(recSectorToDump.dbNearJump[dbIndex]) );
  Write(';  ');
  Write('OEM ID: ');
  FOR  dbIndex := 1 TO 8 DO
    Write( char(recSectorToDump.chOemID[dbIndex]) );
  WriteLn;
  Write('Bytes/sector=',recSectorToDump.dwBytesPerSector);
  Write(';  ');
  Write('Sectors/cluster=',recSectorToDump.dbSectorsPerCluster);
  Write(';  ');
  Write('Reserved sectors=',recSectorToDump.dwReservedSectors);
  Write(';  ');
  WriteLn('FATs=',recSectorToDump.dbFATs);

  Write('Root entries=',recSectorToDump.dwRootEntries);
  Write(';  ');
  Write('Small sectors=',recSectorToDump.dwSmallSectors);
  Write(';  ');
  Write('Media=$', _fnsByteToHexFmt(recSectorToDump.dbMediaDescriptor) );
  Write(';  ');
  WriteLn('Sectors/FAT=',recSectorToDump.dwSectorsPerFAT);

  Write('Sectors/track=',recSectorToDump.dwSectorsPerTrack);
  Write(';  ');
  Write('Heads=',recSectorToDump.dwHeads);
  Write(';  ');
  Write('Hidden sectors=',recSectorToDump.liHiddenSectors);
  Write(';  ');
  WriteLn('Large sectors=',recSectorToDump.liLargeSectors);

  Write('PhysDrive=$',_fnsByteToHexFmt(recSectorToDump.dbPhysicalDriveNumber) );
  Write('; ');
  Write('CurHead=',recSectorToDump.dbCurrentHead);
  Write('; ');
  Write('Signature=',recSectorToDump.dbSignature);
  Write('; ');
  WriteLn('ID=',recSectorToDump.liID);

  Write('Volume: ');
  FOR  dbIndex := 1 TO 11 DO
    Write( char(recSectorToDump.chVolumeLabel[dbIndex]) );
  Write(';  ');
  Write('SystemID: ');
  FOR  dbIndex := 1 TO 8 DO
    Write( char(recSectorToDump.chSystemID[dbIndex]) );
  Write(';  ');
  WriteLn( 'Sector ID: $',_fnsWordToHexFmt(recSectorToDump.dwBootSecID) );
END;
{ _DumpBootSector }


PROCEDURE  _InitDriveParameters(VAR recWrkDrvParam  : recDriveParam;
                                recBootSectInfo : recBootSector);
{* Initializes working drive parameters *}
BEGIN
  WITH  (recWrkDrvParam)  DO
  BEGIN
    liBootSectorOfs := 0;      {default}
    liFat1Ofs := recBootSectInfo.dwReservedSectors;
    dwFatSecs := recBootSectInfo.dwSectorsPerFAT;
    IF (recBootSectInfo.dbFATs > 1)
      THEN  liFat2Ofs := liFat1Ofs + recBootSectInfo.dwSectorsPerFAT
      ELSE  liFat2Ofs := 0;
    {if-then-else}
    liRootDirOfs    := liFat1Ofs + recBootSectInfo.dbFATs*dwFatSecs;
    dwRootDirSecs   :=  ( longint(recBootSectInfo.dwRootEntries) * DIR_ENTRY_SIZ )
                        DIV SEC_SIZ;
    liDataAreaOfs   := liRootDirOfs + dwRootDirSecs;
    dwDataClusters  := (recBootSectInfo.liLargeSectors - liDataAreaOfs)
                        DIV recBootSectInfo.dbSectorsPerCluster;
    dwSectorsInCluster := recBootSectInfo.dbSectorsPerCluster;
{$IFDEF  DebugVersion}
    WriteLn('DEBUG:  <<< dump drive info >>>');
    Write('BootSectOfs=',liBootSectorOfs);
    Write(';  ');
    Write('FAT1ofs=',liFat1Ofs);
    Write(';  ');
    Write('FAT2ofs=',liFat2Ofs);
    Write(';  ');
    Write('RootDirOfs=',liRootDirOfs);
    Write(';  ');
    WriteLn('RootDirSecs=',dwRootDirSecs);
    Write('DataAreaOfs=',liDataAreaOfs);
    Write(';  ');
    Write('DataClusters=',dwDataClusters);
    Write(';  ');
    Write('Sectors/Cluster=',dwSectorsInCluster);
    Write(';  ');
    Write('Sectors/FAT=',dwFatSecs);
    Writeln;
{$ENDIF  DebugVersion}
  END;
  {with-do}
END;
{ _InitDriveParameters }


PROCEDURE  _ReadLargeBuf(dbLogDrive : byte;
                         liStartSectorNum : longint;
                         dwReadSectorCount : word;
                         lpReadMemBuf : pointer);
{* Transfer buffer more than 64 Kbytes. *}
VAR
  fTestRes : boolean;
  lpTempBuf : pointer;
  dwXfrBlock : word;
BEGIN
  lpTempBuf := lpReadMemBuf;
  WHILE  (dwReadSectorCount <> 0)  DO
  BEGIN
    IF ( dwReadSectorCount > MAX_SECS_BLOCK )
      THEN  dwXfrBlock := MAX_SECS_BLOCK
      ELSE  dwXfrBlock := dwReadSectorCount;
    {if-then-else}
    fTestRes :=_fbDosAbsoluteRead(dbLogDrive,
                                  liStartSectorNum,
                                  dwXfrBlock,
                                  lpTempBuf);
    IF  (fTestRes = FALSE)
      THEN BEGIN
         Writeln(#7#7#7,'ERROR: read error on source drive, code = ',g_dbDosError);
         Halt(11);
           END;
    {if-then}
    lpTempBuf := Ptr(Seg(lpTempBuf^)+MAX_DOS_BLK_SIZ_PARAS,0);
    Inc(liStartSectorNum,dwXfrBlock);
    Dec(dwReadSectorCount,dwXfrBlock);
  END;
  {while-do}
END;
{ _ReadLargeBuf }


PROCEDURE  _WriteLargeBuf(dbLogDrive : byte;
                         liStartSectorNum : longint;
                         dwReadSectorCount : word;
                         lpReadMemBuf : pointer);
{* Transfer buffer more than 64 Kbytes. *}
VAR
  fTestRes : boolean;
  lpTempBuf : pointer;
  dwXfrBlock : word;
BEGIN
  lpTempBuf := lpReadMemBuf;
  WHILE  (dwReadSectorCount <> 0)  DO
  BEGIN
    IF ( dwReadSectorCount > MAX_SECS_BLOCK )
      THEN  dwXfrBlock := MAX_SECS_BLOCK
      ELSE  dwXfrBlock := dwReadSectorCount;
    {if-then-else}
    fTestRes :=_fbDosAbsoluteWrite(dbLogDrive,
                                   liStartSectorNum,
                                   dwXfrBlock,
                                   lpTempBuf);
    IF  (fTestRes = FALSE)
      THEN BEGIN
         Writeln(#7#7#7,'ERROR: write error on source drive, code = ',g_dbDosError);
         Halt(12);
           END;
    {if-then}
    lpTempBuf := Ptr(Seg(lpTempBuf^)+MAX_DOS_BLK_SIZ_PARAS,0);
    Inc(liStartSectorNum,dwXfrBlock);
    Dec(dwReadSectorCount,dwXfrBlock);
  END;
  {while-do}
END;
{ _WriteLargeBuf }


PROCEDURE  _FillLargeMemBuf(lpMemBuf : pointer;
                            liBufSiz : longint;
                            dbFill : byte);
{* Fills a buffer with specified char. *}
VAR
  lpTempBuf : pointer;
  dwFillBlock : word;
BEGIN
   IF  (lpMemBuf <> NIL)
     THEN  BEGIN
       lpTempBuf := lpMemBuf;
       WHILE  (liBufSiz <> 0)  DO
       BEGIN
         IF ( liBufSiz > MAX_BLK_FILL_SIZ )
           THEN  dwFillBlock := MAX_BLK_FILL_SIZ
           ELSE  dwFillBlock := liBufSiz;
         {if-then-else}
         FillChar(Mem[Seg(lpTempBuf^):Ofs(lpTempBuf^)],dwFillBlock,dbFill);
         lpTempBuf := Ptr(Seg(lpTempBuf^)+MAX_BLK_FILL_SIZ DIV 16,0);
         Dec(liBufSiz,dwFillBlock);
       END;
       {while-do}
           END;
   {if-then}
END;
{ _FillLargeMemBuf }


FUNCTION   _fnbFindClusterInFAT(dwClustNum : word;
                                lpFatBuf : pointer;
                                liFatSiz : longint) : boolean;
{* Searches FAT for reference to given cluster. *}
VAR
   fFound : boolean;
  lpTempBuf : pointer;
  dwSrchBlock : word;
BEGIN
   fFound := FALSE;
   IF  (lpFatBuf <> NIL)
     THEN  BEGIN
       lpTempBuf := lpFatBuf;
       WHILE  (liFatSiz <> 0)  AND (NOT(fFound) )  DO
       BEGIN
         IF ( liFatSiz > MAX_BLK_FILL_SIZ )
           THEN  dwSrchBlock := MAX_BLK_FILL_SIZ
           ELSE  dwSrchBlock := liFatSiz;
         {if-then-else}
         ASM
                les     di, lpTempBuf
                mov     cx, dwSrchBlock
                shr     cx, 1
                mov     ax, dwClustNum
                cld
                repne   scasw
                jne    @Done
                mov      fFound, TRUE
             @Done:
         END;
         {asm-end}
         lpTempBuf := Ptr(Seg(lpTempBuf^)+MAX_BLK_FILL_SIZ DIV 16,0);
         Dec(liFatSiz,dwSrchBlock);
       END;
       {while-do}
           END;
   {if-then}
   _fnbFindClusterInFAT := fFound;
END;
{ _fnbFindClusterInFAT }


FUNCTION   _fnliCluster2Sector(dwClustNum, dwClustSiz : word;
                          liDataAreaBegin : longint) : longint;
{* Translates cluster number to logical sector value. *}
BEGIN
  _fnliCluster2Sector := liDataAreaBegin +
                         longint((dwClustNum-2))*dwClustSiz;
END;
{ _fnliCluster2Sector }


PROCEDURE  _ReadDataCluster(dbReadDrv : byte;
                            dwClustNum : word;
                            dwClustSizeInSecs : word;
                            liStartDataArea : longint;
                            lpMemBuf : pointer;
                            fStopOnErr : boolean);
{* Read data cluster into memory buffer. *}
VAR
  liDataClusOfs : longint;
  fTestRes : boolean;
BEGIN
    liDataClusOfs := _fnliCluster2Sector(dwClustNum,
                                         dwClustSizeInSecs,
                                         liStartDataArea);
    fTestRes :=_fbDosAbsoluteRead(dbReadDrv,
                                  liDataClusOfs,
                                  dwClustSizeInSecs,
                                  lpMemBuf);
    IF  (fTestRes = FALSE)
      THEN BEGIN
         Writeln(#7#7#7,'ERROR: read error on source drive, code = ',g_dbDosError);
         IF  (fStopOnErr = TRUE)
            THEN  Halt(13);
         {if-then}
           END;
    {if-then}
END;
{ _ReadDataCluster }


PROCEDURE  _WriteDataCluster(dbReadDrv : byte;
                            dwClustNum : word;
                            dwClustSizeInSecs : word;
                            liStartDataArea : longint;
                            lpMemBuf : pointer;
                            fStopOnErr : boolean);
{* Write data cluster from memory buffer. *}
VAR
  liDataClusOfs : longint;
  fTestRes : boolean;
BEGIN
    liDataClusOfs := _fnliCluster2Sector(dwClustNum,
                                         dwClustSizeInSecs,
                                         liStartDataArea);
    fTestRes :=_fbDosAbsoluteWrite(dbReadDrv,
                                  liDataClusOfs,
                                  dwClustSizeInSecs,
                                  lpMemBuf);
    IF  (fTestRes = FALSE)
      THEN BEGIN
         Writeln(#7#7#7,'ERROR: write error on target drive, code = ',g_dbDosError);
         IF  (fStopOnErr = TRUE)
            THEN  Halt(14);
         {if-then}
           END;
    {if-then}
END;
{ _WriteDataCluster }

FUNCTION  _fnliGetCurBIOStimeTicks : longint; ASSEMBLER;
{* Read current time from BIOS. *}
ASM
        mov     ax, $40
        mov     es, ax
        mov     ax, es:[$6C+0]
        mov     dx, es:[$6C+2]
END;
{ _fnliGetCurBIOStimeTicks }


FUNCTION  _fnsGetTimeStr(dbHr,dbMin,dbSec : byte) : STRING;
{* Returns time string. *}
VAR
  sTemp2 : STRING[2];
  sTime : STRING;
BEGIN
      System.Str(dbHr:2,sTime);
      IF (dbHr < 10)
        THEN  sTime[1] := '0';
      {if-then}
      System.Str(dbMin:2,sTemp2);
      IF (dbMin < 10)
        THEN  sTemp2[1] := '0';
      {if-then}
      sTime := sTime + ':' + sTemp2;
      System.Str(dbSec:2,sTemp2);
      IF (dbSec < 10)
        THEN  sTemp2[1] := '0';
      {if-then}
      sTime := sTime + ':' + sTemp2;
      _fnsGetTimeStr := sTime;
END;
{ _fnsGetTimeStr }


PROCEDURE  _GetCurTime(VAR  dbHr,dbMin,dbSec : byte); ASSEMBLER;
{* Gets a current time from BIOS. *}
{At exit:   AH  =  hours     }
{           AL  =  minutes  }
{           BH  =  seconds   }
{           BL  =  hundreths }
ASM
        mov ax,$40                          {BIOS data segment}
        mov es,ax
        mov dx,es:[$6C+0]                   {get # of timer tics}
        mov cx,es:[$6C+2]

        mov ax,cx                           {code from Microsoft}
        mov bx,dx                           {CLOCK$ device driver}
        shl dx,1
        rcl cx,1
        shl dx,1
        rcl cx,1
        add dx,bx
        adc ax,cx
        xchg    ax,dx
        mov cx,0E90Bh
        div cx
        mov bx,ax
        xor ax,ax
        div cx
        mov dx,bx
        mov cx,200
        div cx
        cmp dl,100
        jb  @Under
        sub dl,100
    @Under:
        cmc
        mov bl,dl
        rcl ax,1
        mov dl,0
        rcl dx,1
        mov cx,60
        div cx
        mov bh,dl
        div cl
        xchg    al,ah
        les     di, dbHr
        mov     es:[di], ah
        les     di, dbMin
        mov     es:[di], al
        les     di, dbSec
        mov     es:[di], bh
END;
{ _GetCurTime }


PROCEDURE  _GetCurTimeNoSrc(liTimeTicks : longint;
                       VAR  dbHr,dbMin,dbSec : byte); ASSEMBLER;
{* Translates ticks to a time . *}
{At exit:   AH  =  hours     }
{           AL  =  minutes  }
{           BH  =  seconds   }
{           BL  =  hundreths }
ASM
        mov dx,WORD PTR liTimeTicks+0
        mov cx,WORD PTR liTimeTicks+2

        mov ax,cx                           {code from Microsoft}
        mov bx,dx                           {CLOCK$ device driver}
        shl dx,1
        rcl cx,1
        shl dx,1
        rcl cx,1
        add dx,bx
        adc ax,cx
        xchg    ax,dx
        mov cx,0E90Bh
        div cx
        mov bx,ax
        xor ax,ax
        div cx
        mov dx,bx
        mov cx,200
        div cx
        cmp dl,100
        jb  @Under
        sub dl,100
    @Under:
        cmc
        mov bl,dl
        rcl ax,1
        mov dl,0
        rcl dx,1
        mov cx,60
        div cx
        mov bh,dl
        div cl
        xchg    al,ah
        les     di, dbHr
        mov     es:[di], ah
        les     di, dbMin
        mov     es:[di], al
        les     di, dbSec
        mov     es:[di], bh
END;
{ _GetCurTimeNoSrc }



{main part}
BEGIN
  IF (ParamCount <> 0)
    THEN  BEGIN
      g_fBatchModeOk := TRUE;
          END;
  {if-then}

  Writeln('Smart DOS logical drive copier v1.0a, Copyright (c) 1998 Dmitry Stefankov');
  WriteLn('Private edition. Distribution is strictly prohibited.');
  WriteLn('!!! READ THIS BEFORE CONTINUE !!!');
  WriteLn('BACKUP YOUR DATA BEFORE PROCEED, CHECK AND DEFRAGMENT YOUR DRIVES.');
  WriteLn('YOU WILL USE THIS PROGRAM WITHOUT WARRANTY OF ANY KIND.');
  WriteLn('RUN PROGRAM ONLY UNDER DOS WITHOUT ANY DRIVERS AND PROGRAMS.');
  IF  (g_fBatchModeOk = FALSE)
    THEN  BEGIN
      WriteLn('Press <CR> to continue.');
      ReadLn;
          END;
  {if-then-else}


  {-Ask drives-}
  Write('Enter source drive (A-Z): ');
  IF  (g_fBatchModeOk = FALSE)
    THEN  BEGIN
        ReadLn(g_chTemp);
          END
    ELSE  BEGIN
        g_sTemp := ParamStr(1);
        g_chTemp := g_sTemp[1];
        WriteLn(g_chTemp);
          END;
  {if-then-else}

  g_dbSrcDrv := Ord(UpCase(g_chTemp)) - Ord('A');

  Write('Enter destination drive (A-Z): ');
  IF  (g_fBatchModeOk = FALSE)
    THEN  BEGIN
        ReadLn(g_chTemp);
          END
    ELSE  BEGIN
        g_sTemp := ParamStr(2);
        g_chTemp := g_sTemp[1];
        WriteLn(g_chTemp);
          END;
  {if-then-else}
  g_dbDestDrv := Ord(UpCase(g_chTemp)) - Ord('A');

  {-Read boot sectors-}
  g_lpTemp := Ptr( Seg(g_recSrcBootSec),Ofs(g_recSrcBootSec) );
  g_fTestRes :=_fbDosAbsoluteRead(g_dbSrcDrv,0,1,g_lpTemp);
  IF  (g_fTestRes = FALSE)
    THEN BEGIN
       Writeln(#7#7#7,'ERROR: cannot read boot sector of source drive.');
       Halt(3);
         END;
  {if-then}
  IF  (g_recSrcBootSec.dwBootSecID <> BOOT_SEC_ID)
    THEN BEGIN
       Writeln(#7#7#7,'ERROR: invalid boot sector ID of source drive.');
       Halt(4);
         END;
  {if-then}

  g_lpTemp := Ptr( Seg(g_recDestBootSec),Ofs(g_recDestBootSec) );
  g_fTestRes :=_fbDosAbsoluteRead(g_dbDestDrv,0,1,g_lpTemp);
   IF  (g_fTestRes = FALSE)
    THEN BEGIN
       Writeln(#7#7#7,'ERROR: cannot read boot sector of destination drive.');
       Halt(5);
         END;
  {if-then}
  IF  (g_recDestBootSec.dwBootSecID <> BOOT_SEC_ID)
    THEN BEGIN
       Writeln(#7#7#7,'ERROR: invalid boot sector ID of destination drive.');
       Halt(6);
         END;
  {if-then}


{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< dump of source boot sector >>>');
  _DumpBootSector(g_recSrcBootSec);
  WriteLn('DEBUG:  <<< dump of destination boot sector >>>');
  _DumpBootSector(g_recDestBootSec);
{$ENDIF  DebugVersion}

  {-Init drive info-}
  _InitDriveParameters(g_recSrcDrvParams,g_recSrcBootSec);
  _InitDriveParameters(g_recDestDrvParams,g_recDestBootSec);

  {-Check target drive space-}
  IF  (g_recSrcDrvParams.dwSectorsInCluster > g_recDestDrvParams.dwSectorsInCluster)
    THEN  BEGIN
       Writeln(#7#7#7,'ERROR: sectors per cluster must not be greater on source drive.');
       Halt(16);
          END;
  {if-then}
  IF  (g_recSrcDrvParams.dwDataClusters > g_recDestDrvParams.dwDataClusters)
    THEN  BEGIN
       Writeln(#7#7#7,'ERROR: data clusters number must not be greater on source drive.');
       Halt(17);
          END;
  {if-then}
  IF  (g_recSrcDrvParams.dwRootDirSecs> g_recDestDrvParams.dwRootDirSecs)
    THEN  BEGIN
       Writeln(#7#7#7,'ERROR: root directory must not be greater on source drive.');
       Halt(18);
          END;
  {if-then}
  

  {-Ask before go!}
  IF  (g_fBatchModeOk = FALSE)
    THEN  BEGIN
      Writeln('LAST CHANCE! Now you have a chance to quit. Try it if you not sure!');
      Write('Press <CR> to continue, or type any string to exit.');
      ReadLn(g_sTemp);
      IF (g_sTemp <> '')
        THEN BEGIN
          WriteLn(#7,'WARN: aborted by user.');
          Halt(1);
             END;
      {if-then}
          END;
  {if-then-else}


  {-Allocate FAT read cache-}
  g_liTemp := longint(g_recSrcDrvParams.dwFatSecs) * SEC_SIZ;
  g_liReadFatBufSize := g_liTemp;
  g_dwTemp := g_liTemp DIV BYTES_PER_PARA;
  Write('Allocate memory for FAT read buffer');
{$IFDEF  DebugVersion}
  WriteLn(' = ',g_liTemp,' bytes (',g_dwTemp,' paras).');
{$ELSE}
  Writeln('.');
{$ENDIF  DebugVersion}
  IF  ( _fnbAllocLowMemBlock(g_dwTemp,g_lpFatReadCacheBuf) = FALSE )
    THEN BEGIN
       WriteLn(#7#7#7,'ERROR: cannot allocate memory for FAT read buffer!');
       Halt(2);
         END;
  {if-then}

  {-Allocate data read cache-}
  g_liTemp := g_recSrcDrvParams.dwSectorsInCluster * SEC_SIZ;
  g_dwTemp := g_liTemp DIV BYTES_PER_PARA;
  Write('Allocate memory for read data buffer');
{$IFDEF  DebugVersion}
  WriteLn(' = ',g_liTemp,' bytes (',g_dwTemp,' paras).');
{$ELSE}
  Writeln('.');
{$ENDIF  DebugVersion}
  IF  ( _fnbAllocLowMemBlock(g_dwTemp,g_lpReadDataCluster) = FALSE )
    THEN BEGIN
       WriteLn(#7#7#7,'ERROR: cannot allocate memory for read data buffer!');
       Halt(7);
         END;
  {if-then}

  {-Allocate data write cache-}
  g_liTemp := g_recDestDrvParams.dwSectorsInCluster * SEC_SIZ;
  g_dwTemp := g_liTemp DIV BYTES_PER_PARA;
  Write('Allocate memory for data write buffer');
{$IFDEF  DebugVersion}
  WriteLn(' = ',g_liTemp,' bytes (',g_dwTemp,' paras).');
{$ELSE}
  Writeln('.');
{$ENDIF  DebugVersion}
  IF  ( _fnbAllocLowMemBlock(g_dwTemp,g_lpWriteDataCluster) = FALSE )
    THEN BEGIN
       WriteLn(#7#7#7,'ERROR: cannot allocate memory for data write buffer!');
       Halt(8);
         END;
  {if-then}

{$IFDEF   WriteFatVersion}
  {-Allocate FAT write cache-}
  g_liTemp := longint(g_recDestDrvParams.dwFatSecs) * SEC_SIZ;
  g_dwTemp := g_liTemp DIV BYTES_PER_PARA;
  Write('Allocate memory for FAT write buffer');
{$IFDEF  DebugVersion}
  WriteLn(' = ',g_liTemp,' bytes (',g_dwTemp,' paras).');
{$ELSE}
  Writeln('.');
{$ENDIF  DebugVersion}
  IF  ( _fnbAllocLowMemBlock(g_dwTemp,g_lpFatWriteCacheBuf) = FALSE )
    THEN BEGIN
       WriteLn(#7#7#7,'ERROR: cannot allocate memory for FAT write buffer!');
       Halt(9);
         END;
  {if-then}
  _FillLargeMemBuf(g_lpFatWriteCacheBuf,g_liTemp,0);
{$ENDIF   WriteFatVersion}

  {-Read source drive FAT-}
  WriteLn('Read FAT of source drive into memory.');
{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< drv=',g_dbSrcDrv,
           '; sectnum=',g_recSrcDrvParams.liFat1Ofs,
           '; sectcount=',g_recSrcDrvParams.dwFatSecs,
          ' >>>');
{$ENDIF  DebugVersion}
  _ReadLargeBuf(g_dbSrcDrv,
                g_recSrcDrvParams.liFat1Ofs,
                g_recSrcDrvParams.dwFatSecs,
                g_lpFatReadCacheBuf);

{$IFDEF   SaveReadFatFile}
   g_liTemp := longint(g_recSrcDrvParams.dwFatSecs) * SEC_SIZ;
   g_dwTemp := g_liTemp-65520;
   Assign(g_fFatFile,'FAT1.SAV');
   Rewrite(g_fFatFile,1);
   BlockWrite(g_fFatFile,
              Mem[Seg(g_lpFatReadCacheBuf^):0],
              65520);
   BlockWrite(g_fFatFile,
              Mem[Seg(g_lpFatReadCacheBuf^)+(65520 DIV 16):0],
              g_dwTemp);
   Close(g_fFatFile);
{$ENDIF   SaveReadFatFile}

  {-Process source drive FAT-}
  g_dwCurReadClusNum := 2;
  g_dwMaxReadClusNum := g_dwCurReadClusNum + g_recSrcDrvParams.dwDataClusters - 1;
  g_dwFreeSrcClusters := 0;
  g_dwChainClusters := 0;
  g_dwUnusedClusters1 := 0;
  g_dwUnusedClusters2 := 0;
  g_dwBadClusters := 0;
  g_dwResrvdClusters := 0;
  g_fWaitData := false;
  g_dwDataClusters := 0;
  g_liSrcDataAreaOfs := g_recSrcDrvParams.liDataAreaOfs;
  g_dwSrcDataClusSiz := g_recSrcDrvParams.dwSectorsInCluster;
  g_liDestDataAreaOfs := g_recDestDrvParams.liDataAreaOfs;
  g_dwDestDataClusSiz := g_recDestDrvParams.dwSectorsInCluster;

{$IFDEF   WriteLogFile}
    Assign(g_fLogFile,'fat2fat.log');
    SetTextBuf(g_fLogFile,g_LogTextBuf);
    Rewrite(g_fLogFile);
{$ENDIF   WriteLogFile}

   g_InitTimeTicks := _fnliGetCurBIOStimeTicks;

  {Just copy first 2 entries}
  g_dwTemp := _fndwGetClusterValue(0,g_lpFatReadCacheBuf);
  _PutClusterValue(0,g_dwTemp,g_lpFatWriteCacheBuf);
  g_dwTemp := _fndwGetClusterValue(1,g_lpFatReadCacheBuf);
  _PutClusterValue(1,g_dwTemp,g_lpFatWriteCacheBuf);

  {Here heart of any user will be trashed!}
  WHILE  (g_dwCurReadClusNum <= g_dwMaxReadClusNum) DO
  BEGIN
      _GetCurTimeNoSrc(_fnliGetCurBIOStimeTicks-g_InitTimeTicks,
                       g_dbElapsedHour,g_dbElapsedMin,g_dbElapsedSec);

      g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                       g_dbElapsedSec);
     g_dwWrkClusValue := _fndwGetClusterValue(g_dwCurReadClusNum,g_lpFatReadCacheBuf);
     Write('Cluster: ',g_dwCurReadClusNum:5,
{$IFDEF  DebugVersion}
           '; value=$',_fnsWordToHexFmt(g_dwWrkClusValue),
{$ENDIF  DebugVersion}
           '; ETim> ',g_sElapsedTime,#13);

     CASE  (g_dwWrkClusValue)  OF
        UNUSED_CODE_1    :    BEGIN
                            Inc(g_dwUnusedClusters1);
                            Inc(g_dwCurReadClusNum);
                               END;
        UNUSED_CODE_2    :     BEGIN
                            Inc(g_dwUnusedClusters2);
                            Inc(g_dwCurReadClusNum);
                               END;
        RESERVD_CLUSTER_BGN..RESERVD_CLUSTER_END,
        FREE_CLUSTER, BAD_CLUSTER  :    BEGIN
                            IF  (g_dwWrkClusValue = BAD_CLUSTER)
                              THEN  Inc(g_dwBadClusters);
                            {if-then}
                            IF  (g_dwWrkClusValue = FREE_CLUSTER)
                              THEN  Inc(g_dwFreeSrcClusters);
                            {if-then}
                            IF ( (g_dwWrkClusValue >= RESERVD_CLUSTER_BGN)
                                          AND
                                 (g_dwWrkClusValue <= RESERVD_CLUSTER_END) )
                              THEN  Inc(g_dwResrvdClusters);
                            {if-then}
                            _PutClusterValue(g_dwCurReadClusNum,
                                             UNUSED_CODE_2,
                                             g_lpFatReadCacheBuf);
                            _PutClusterValue(g_dwCurReadClusNum,
                                             g_dwWrkClusValue,
                                             g_lpFatWriteCacheBuf);
(*
                            IF  (g_fFillUnusedSpace)
                              THEN _FillLargeMemBuf(g_lpWriteDataCluster,
                                                    g_dwDestDataClusSiz * SEC_SIZ,
                                                    0);
                            {if-then}
                            IF  (g_fCopyDataFreeSpace)
                              THEN  BEGIN
                                 _ReadDataCluster(g_dbSrcDrv,
                                                  g_dwCurReadClusNum,
                                                  g_dwSrcDataClusSiz,
                                                  g_liSrcDataSectorBgn,
                                                  g_lpWriteDataCluster,
                                                  FALSE);
                                 _WriteDataCluster(g_dbDestDrv,
                                                  g_dwCurReadClusNum,
                                                  g_dwDestDataClusSiz,
                                                  g_liDestDataSectorBgn,
                                                  g_lpWriteDataCluster,
                                                  FALSE);
                                    END;
                            {if-then}
*)
                            Inc(g_dwCurReadClusNum);
                               END;
      ELSE  BEGIN
         IF  (_fnbFindClusterInFAT(g_dwCurReadClusNum,
                                   g_lpFatReadCacheBuf,
                                   g_liReadFatBufSize) )
           THEN   BEGIN
                {We have reference to this entry, therefore skip!}
{$IFDEF   WriteLogFile}
              WriteLn(g_fLogFile,'DO::skip=',g_dwCurReadClusNum,'; next=',g_dwCurReadClusNum+1);
{$ENDIF   WriteLogFile}
                Inc(g_dwCurReadClusNum);
                  END
           ELSE   BEGIN
         IF  ( (g_dwWrkClusValue >= END_OF_CHAIN_BG)
                      AND
               (END_OF_CHAIN_END <= g_dwWrkClusValue) )
           THEN  BEGIN
              Inc(g_dwChainClusters);
              g_fLastCluster := TRUE;
                 END
           ELSE  BEGIN
              Inc(g_dwDataClusters);
              g_fLastCluster := FALSE;
                 END;
         {if-then-else}
         _ReadDataCluster(g_dbSrcDrv,
                          g_dwCurReadClusNum,
                          g_dwSrcDataClusSiz,
                          g_liSrcDataAreaOfs,
                          g_lpReadDataCluster,
                          TRUE);
         {We mark that data cluster copied}
         _PutClusterValue(g_dwCurReadClusNum,
                          UNUSED_CODE_2,
                          g_lpFatReadCacheBuf);
         {First or next?}
         IF  (g_fWaitData = FALSE)
           THEN  BEGIN
              g_fWaitData := TRUE;
              g_dwCurWriteClusNum := g_dwCurReadClusNum;
              g_dwContReadClusNum := g_dwCurReadClusNum;
              g_liNextWrtBufOfs := 0;
              _FillLargeMemBuf(g_lpWriteDataCluster,
                               g_dwDestDataClusSiz * SEC_SIZ,
                               0);
                 END
           ELSE  BEGIN
              {Check for full buffer}
              IF  (g_liNextWrtBufOfs >= (g_dwDestDataClusSiz*SEC_SIZ) )
                THEN  BEGIN
                  _WriteDataCluster(g_dbDestDrv,
                                    g_dwCurWriteClusNum,
                                    g_dwDestDataClusSiz,
                                    g_liDestDataAreaOfs,
                                    g_lpWriteDataCluster,
                                    TRUE);
                  g_liNextWrtBufOfs := 0;
                 _FillLargeMemBuf(g_lpWriteDataCluster,
                                  g_dwDestDataClusSiz * SEC_SIZ,
                                  0);
                  {Filled data cluster}
                  _PutClusterValue(g_dwCurWriteClusNum{g_dwCurReadClusNum},
                                   g_dwCurReadClusNum{g_dwWrkClusValue},
                                   g_lpFatWriteCacheBuf);
                  g_dwCurWriteClusNum := g_dwCurReadClusNum;
                      END;
              {if-then}
                 END;
         {if-then-else}
         g_dwTemp := g_dwSrcDataClusSiz * SEC_SIZ;
         Move(Mem[Seg(g_lpReadDataCluster^):Ofs(g_lpReadDataCluster^)],
              Mem[Seg(g_lpWriteDataCluster^):(Ofs(g_lpWriteDataCluster^)+g_liNextWrtBufOfs)],
              g_dwTemp);
         Inc( g_liNextWrtBufOfs, g_dwTemp);
         IF  (g_fLastCluster)
           THEN  BEGIN
              {Finish chain}
              _WriteDataCluster(g_dbDestDrv,
                                g_dwCurWriteClusNum,
                                g_dwDestDataClusSiz,
                                g_liDestDataAreaOfs,
                                g_lpWriteDataCluster,
                                TRUE);
              _FillLargeMemBuf(g_lpWriteDataCluster,
                               g_dwDestDataClusSiz * SEC_SIZ,
                               0);
              _PutClusterValue(g_dwCurWriteClusNum,
                               g_dwWrkClusValue,
                               g_lpFatWriteCacheBuf);
              g_fWaitData := FALSE;
              g_dwCurReadClusNum := g_dwContReadClusNum;
              Inc(g_dwCurReadClusNum);  {continue from next!}
{$IFDEF   WriteLogFile}
              WriteLn(g_fLogFile,'RESET::cont=',g_dwContReadClusNum,
                                 '; cur=',g_dwCurReadClusNum);
{$ENDIF   WriteLogFile}
                 END
           ELSE  BEGIN
              {Take next from chain}
{$IFDEF   WriteLogFile}
              WriteLn(g_fLogFile,'DO::next=',g_dwWrkClusValue);
{$ENDIF   WriteLogFile}
              g_dwCurReadClusNum := g_dwWrkClusValue;
                 END;
         {if-then-else}
                  END;
         {if-then-else}
            END;
         {else}
     END;
     {case-of}
  END;
  WriteLn;
  {while-do}
{$IFDEF  DebugVersion}
   WriteLn('DEBUG:  <<<  free=',g_dwFreeSrcClusters,
           '; bad=',g_dwBadClusters,
           '; chains=',g_dwChainClusters,
           '; rsvd=',g_dwResrvdClusters,
           '; unsd1=',g_dwUnusedClusters1,
           '; data=',g_dwDataClusters,
            ' >>>');
{$ENDIF  DebugVersion}

{$IFDEF   WriteLogFile}
    Close(g_fLogFile);
{$ENDIF   WriteLogFile}

  {-Write boot sector-}
  IF  (g_fCopyBootSector)
    THEN  BEGIN
       WriteLn('Write new boot sector of target drive.');
       Move(g_recDestBootSec.dwBytesPerSector,
            g_recSrcBootSec.dwBytesPerSector,
            FIXED_BPB_EPB_SIZ);
            g_lpTemp := Ptr( Seg(g_recSrcBootSec),Ofs(g_recSrcBootSec) );
            g_fTestRes :=_fbDosAbsoluteWrite(g_dbDestDrv,0,1,g_lpTemp);
            IF  (g_fTestRes = FALSE)
              THEN BEGIN
                 Writeln(#7#7#7,'ERROR: cannot write boot sector of target drive.');
                 Halt(15);
                   END;
            {if-then}
          END
    ELSE  WriteLn('Skip writing of new boot sector of target drive.');
  {if-then}

{$IFDEF   SaveWriteFatFile}
   g_liTemp := longint(g_recDestDrvParams.dwFatSecs) * SEC_SIZ;
   g_dwTemp := g_liTemp-65520;
   Assign(g_fWrtFatFile,'FAT2.SAV');
   Rewrite(g_fWrtFatFile,1);
   BlockWrite(g_fWrtFatFile,
              Mem[Seg(g_lpFatWriteCacheBuf^):0],
              65520);
   BlockWrite(g_fWrtFatFile,
              Mem[Seg(g_lpFatWriteCacheBuf^)+(65520 DIV 16):0],
              g_dwTemp);
   Close(g_fWrtFatFile);
{$ENDIF   SaveWriteFatFile}

{$IFDEF   WriteFatVersion}
  {-Write FAT #1 copy-}
  WriteLn('Write FAT #1 of target drive from memory.');
{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< drv=',g_dbDestDrv,
           '; sectnum=',g_recDestDrvParams.liFat1Ofs,
           '; sectcount=',g_recDestDrvParams.dwFatSecs,
          ' >>>');
{$ENDIF  DebugVersion}
  _WriteLargeBuf(g_dbDestDrv,
                g_recDestDrvParams.liFat1Ofs,
                g_recDestDrvParams.dwFatSecs,
                g_lpFatWriteCacheBuf);

  {-Write FAT #2 copy-}
  WriteLn('Write FAT #2 of target drive from memory.');
{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< drv=',g_dbDestDrv,
           '; sectnum=',g_recDestDrvParams.liFat2Ofs,
           '; sectcount=',g_recDestDrvParams.dwFatSecs,
          ' >>>');
{$ENDIF  DebugVersion}
  _WriteLargeBuf(g_dbDestDrv,
                g_recDestDrvParams.liFat2Ofs,
                g_recDestDrvParams.dwFatSecs,
                g_lpFatWriteCacheBuf);

  {-Write root directory-}
  WriteLn('Read root directory of source drive into memory.');
{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< drv=',g_dbSrcDrv,
           '; sectnum=',g_recSrcDrvParams.liRootDirOfs,
           '; sectcount=',g_recSrcDrvParams.dwRootDirSecs,
          ' >>>');
{$ENDIF  DebugVersion}
  _ReadLargeBuf(g_dbSrcDrv,
                g_recSrcDrvParams.liRootDirOfs,
                g_recSrcDrvParams.dwRootDirSecs,
                g_lpFatReadCacheBuf);
  WriteLn('Write root directory of target drive from memory.');
{$IFDEF  DebugVersion}
  WriteLn('DEBUG:  <<< drv=',g_dbDestDrv,
           '; sectnum=',g_recDestDrvParams.liRootDirOfs,
           '; sectcount=',g_recDestDrvParams.dwRootDirSecs,
          ' >>>');
{$ENDIF  DebugVersion}
  _WriteLargeBuf(g_dbDestDrv,
                 g_recDestDrvParams.liRootDirOfs,
                 g_recDestDrvParams.dwRootDirSecs,
                 g_lpFatReadCacheBuf);

  {-Free memory-}
  WriteLn('Free memory for FAT write buffer.');
  IF ( _fnbReleaseLowMemBlock( Seg(g_lpFatWriteCacheBuf^) ) = FALSE )
    THEN  BEGIN
      WriteLn(#7,'WARN: cannot free memory for FAT write buffer!');
          END;
  {if-then}
{$ENDIF   WriteFatVersion}

  WriteLn('Free memory for data write buffer.');
  IF ( _fnbReleaseLowMemBlock( Seg(g_lpWriteDataCluster^) ) = FALSE )
    THEN  BEGIN
      WriteLn(#7,'WARN: cannot free memory for data write buffer!');
          END;
  {if-then}

  WriteLn('Free memory for read data buffer.');
  IF ( _fnbReleaseLowMemBlock( Seg(g_lpReadDataCluster^) ) = FALSE )
    THEN  BEGIN
      WriteLn(#7,'WARN: cannot free memory for read data buffer!');
          END;
  {if-then}

  WriteLn('Free memory for FAT read buffer.');
  IF ( _fnbReleaseLowMemBlock( Seg(g_lpFatReadCacheBuf^) ) = FALSE )
    THEN  BEGIN
      WriteLn(#7,'WARN: cannot free memory for FAT read buffer!');
          END;
  {if-then}

END.


(*
<<<<< The following articles from Microsoft KnowLedge Base will give
<<<<< all necessary information to understand of principles FAT for MS-DOS.


DOCUMENT:Q140418  05-AUG-1996  [crossnet]
TITLE   :Detailed Explanation of FAT Boot Sector
PRODUCT :Windows for Workgroups and Windows NT Networking Issues
PROD/VER:3.10 3.50 3.51
OPER/SYS:WINDOWS
KEYWORDS:kbhowto

-------------------------------------------------------------------------
The information in this article applies to:

 - Microsoft Windows NT operating system version 3.1
 - Microsoft Windows NT Advanced Server version 3.1
 - Microsoft Windows NT Workstation versions 3.5 and 3.51
 - Microsoft Windows NT Server versions 3.5 and 3.51
-------------------------------------------------------------------------

SUMMARY
=======

Understanding the content and function of a file system "boot sector" can
be helpful when troubleshooting boot failures or disk corruption.

From time to time, usually due to hardware failure or virus infection, a
boot sector may become corrupted.  If the partition is the active primary
partition, or a partition containing operating system files, this can
prevent the system from starting.  Otherwise, it may simply prevent access
to data on the drive.

Usually, if you suspect disk corruption, it is best to use commercial anti-
virus or disk recovery software.  In some cases, however, detailed
knowledge of the boot sector can come in handy.

This article explains the various fields of a FAT boot sector.  Using the
following information, it may be possible to manually repair a damaged FAT
boot sector.  In order to attempt such a repair, disk editing tools capable
of editing raw disk sectors are required.  This article does not
discuss specific tools which can be used to perform such a repair
operations.

While every effort has been made to ensure the accuracy of the following
information, different operating systems, including future versions of
Microsoft operating systems, may use different data structures. Therefore
you should make use of the following information at your own risk.

MORE INFORMATION
================

Background and Terminology
--------------------------

In this document, a "file system boot sector" is the first physical sector
on a logical volume. A logical volume might be a primary partition, a
logical drive in an extended partition, or a composite of two or more
partitions, as is the case with mirrors, stripe sets, and volume sets.

On floppy disks, the boot sector is the first sector on the disk. In the
case of hard drives, the first sector is referred to as the "Master Boot
Record" or "MBR." This MBR is different from a file system boot sector and
contains a partition table, which describes the layout of logical
partitions on that hard drive. The file system boot sector would be the
first sector in one of those partitions.

The Boot Process
----------------

The boot process of 80x86-based personal computers (as opposed to RISC-
based systems) makes direct use of a file system boot sector for executing
instructions.  The initial boot process can be summarized as follows:

1. Power On Self Test (or POST) initiated by system BIOS and CPU.
2. BIOS determines which device to use as the "boot device."
3. BIOS loads the first physical sector from the boot device into memory
   and transfers CPU execution to the start of that memory address.

If the boot device is a hard drive, the sector loaded in step 3 is the MBR,
and the boot process proceeds as follows:

4. MBR code loads the boot sector referenced by the partition table for
   the "active primary partition" into memory and transfers CPU execution
   to the start of that memory address.

Up to this point, the boot process is entirely independent of how the disk
is formatted and what operating system is being loaded.  From this point
on, both the operating and file systems in use play a part.

In the case of FAT volumes which have Windows NT installed, the FAT boot
sector is responsible for identifying the location of the file "NTLDR" on
the volume, loading it into memory, and transferring control to it.

Inside the FAT Boot Sector
--------------------------

Because the MBR transfers CPU execution to the boot sector, the first few
bytes of the FAT boot sector must be valid executable instructions for an
80x86 CPU.  In practice these first instructions constitute a "jump"
instruction and occupy the first 3 bytes of the boot sector.  This jump
serves to skip over the next several bytes which are not "executable."

Following the jump instruction is an 8 byte "OEM ID".  This is typically a
string of characters that identifies the operating system that formatted
the volume.

Following the OEM ID is a structure known as the BIOS Parameter Block, or
"BPB." Taken as a whole, the BPB provides enough information for the
executable portion of the boot sector to be able to locate the NTLDR file.
Because the BPB always starts at the same offset, standard parameters are
always in a known location.  Because the first instruction in the boot
sector is a jump, the BPB can be extended in the future, provided new
information is appended to the end.  In such a case, the jump instruction
would only need a minor adjustment.  Also, the actual executable code can
be fairly generic.  All the variability associated with running on disks of
different sizes and geometries is encapsulated in the BPB.

The BPB is stored in a packed (that is, unaligned) format. The following
table lists the byte offset of each field in the BPB. A description of each
field follows the table.

Field               Offset     Length
-----               ------     ------
Bytes Per Sector      11         2
Sectors Per Cluster   13         1
Reserved Sectors      14         2
FATs                  16         1
Root Entries          17         2
Small Sectors         19         2
Media Descriptor      21         1
Sectors Per FAT       22         2
Sectors Per Track     24         2
Heads                 26         2
Hidden Sectors        28         4
Large Sectors         32         4

Bytes Per Sector: This is the size of a hardware sector and for most disks
in use in the United States, the value of this field will be 512.

Sectors Per Cluster: Because FAT is limited in the number of clusters (or
"allocation units") that it can track, large volumes are supported by
increasing the number of sectors per cluster.  The cluster factor for a FAT
volume is entirely dependent on the size of the volume.  Valid values for
this field are 1, 2, 4, 8, 16, 32, 64, and 128. Query in the Microsoft
Knowledge Base for the term "Default Cluster Size" for more information on
this subject.

Reserved Sectors: This represents the number of sectors preceding the start
of the first FAT, including the boot sector itself.  It should always have
a
value of at least 1.

FATs: This is the number of copies of the FAT table stored on the disk.
Typically, the value of this field is 2.

Root Entries: This is the total number of file name entries that can be
stored in the root directory of the volume.  On a typical hard drive, the
value of this field is 512.  Note, however, that one entry is always used
as a Volume Label, and that files with long file names will use up multiple
entries per file.  This means the largest number of files in the root
directory is typically 511, but that you will run out of entries before
that if long file names are used.

Small Sectors: This field is used to store the number of sectors on the
disk if the size of the volume is small enough.  For larger volumes, this
field has a value of 0, and we refer instead to the "Large Sectors" value
which comes later.

Media Descriptor: This byte provides information about the media being
used.  The following table lists some of the recognized media descriptor
values and their associated media.  Note that the media descriptor byte may
be associated with more than one disk capacity.

Byte   Capacity   Media Size and Type
--------------------------------------------------
F0     2.88 MB    3.5-inch, 2-sided, 36-sector
F0     1.44 MB    3.5-inch, 2-sided, 18-sector
F9     720 KB     3.5-inch, 2-sided, 9-sector
F9     1.2 MB     5.25-inch, 2-sided, 15-sector
FD     360 KB     5.25-inch, 2-sided, 9-sector
FF     320 KB     5.25-inch, 2-sided, 8-sector
FC     180 KB     5.25-inch, 1-sided, 9-sector
FE     160 KB     5.25-inch, 1-sided, 8-sector
F8     -----      Fixed disk

Sectors Per FAT: This is the number of sectors occupied by each of the FATs
on the volume.  Given this information, together with the number of FATs
and reserved sectors listed above, we can compute where the root directory
begins.  Given the number of entries in the root directory, we can also
compute where the user data area of the disk begins.

Sectors Per Track and Heads: These values are a part of the apparent disk
geometry in use when the disk was formatted.

Hidden Sectors: This is the number of sectors on the physical disk
preceding the start of the volume. (that is, before the boot sector itself)
It is used during the boot sequence in order to calculate the absolute
offset to the root directory and data areas.

Large Sectors: If the Small Sectors field is zero, this field contains the
total number of sectors used by the FAT volume.

Some additional fields follow the standard BIOS Parameter Block and
constitute an "extended BIOS Parameter Block." The next fields are:

Field                  Offset   Length
-----                  ------   ------
Physical Drive Number    36        1
Current Head             37        1
Signature                38        1
ID                       39        4
Volume Label             43       11
System ID                54        8

Physical Drive Number: This is related to the BIOS physical drive number.
Floppy drives are numbered starting with 0x00 for the A: drive, while
physical hard disks are numbered starting with 0x80.  Typically, you would
set this value prior to issuing an INT 13 BIOS call in order to specify the
device to access.  The on-disk value stored in this field is typically
0x00 for floppies and 0x80 for hard disks, regardless of how many physical
disk drives exist, because the value is only relevant if the device is a
boot device.

Current Head: This is another field typically used when doing INT13 BIOS
calls.  The value would originally have been used to store the track on
which the boot record was located, but the value stored on disk is not
currently used as such.  Therefore, Windows NT uses this field to store two
flags:

 - The low order bit is a "dirty" flag, used to indicate that autochk
   should run chkdsk against the volume at boot time.
 - The second lowest bit is a flag indicating that a surface scan should
   also be run.

Signature: The extended boot record signature must be either 0x28 or 0x29
in order to be recognized by Windows NT.

ID: The ID is a random serial number assigned at format time in order to
aid in distinguishing one disk from another.

Volume Label: This field was used to store the volume label, but the volume
label is now stored as a special file in the root directory.

System ID: This field is either "FAT12" or "FAT16," depending on the format
of the disk.

On a bootable volume, the area following the Extended BIOS Parameter Block
is typically executable boot code.  This code is responsible for
performing whatever actions are necessary to continue the boot-strap
process.  On Windows NT systems, this boot code will identify the location
of the NTLDR file, load it into memory, and transfer execution to that
file.  Even on a non-bootable floppy disk, there is executable code in this
area.  The code necessary to print the familiar message,  Non-system disk
or disk error  is found on most standard, MS-DOS formatted floppy disks
that were not formatted with the  system  option.

Finally, the last two bytes in any boot sector always have the hexidecimal
values: 0x55 0xAA.

Troubleshooting
---------------

If you suspect that a FAT boot sector is corrupt, you can check several of
the fields listed above to see whether the values listed there make sense.
For example, BytesPerSector will be 512 in the vast majority of cases.  You
would also expect to see text strings in the executable code section of the
boot sector that are appropriate for the operating system that formatted
the disk.

Typical text strings on FAT volumes formatted by MS-DOS include: "Invalid
system disk."; "Disk I/O error."; "Replace the disk, and then press any
key"; "Non-System disk or disk error"; "Replace and press any key when
ready."; and "Disk Boot failure." Text strings on FAT volumes formatted by
Windows NT include: "BOOT: Couldn t find NTLDR."; "I/O error reading
disk."; and "Please insert another disk." You should not regard this list
as being all-inclusive. If you find other messages in the boot sector, this
does not necessarily indicate that there is a problem with the boot sector.
Different versions of MS-DOS and Windows NT will sometimes have slightly
different message strings in their boot sectors. On the other hand, if you
find no text whatsoever, or if the text is clearly not related to MS-DOS or
Windows NT, you should consider the possibility that your boot sector may
have been infected by a virus or that some other form of data corruption
may have taken place.

To recover from a boot sector that has been infected by a virus, it is
usually best to use a commercial anti-virus program.  Many viruses will do
much more than just write data to the boot sector, so manual repair of the
boot sector is not recommended, as it may not completely eliminate the
virus and in some cases, may do more harm than good.

If you suspect that the boot sector was damaged for some other reason, it
is usually best to use commercial disk recovery tools.  While it may be
possible to recover from boot sector damage without resorting to
reformatting the drive by manually modifying the fields described above,
manual editing of boot sectors should only be attempted as a last resort
and cannot be guaranteed to work in situations where other disk structures
may also have been damaged.

KBCategory: kbhowto
KBSubcategory: nthowto
Additional reference words: 3.10 3.50 3.51 prodnt


=============================================================================

THE INFORMATION PROVIDED IN THE MICROSOFT KNOWLEDGE BASE IS
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.  MICROSOFT DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL MICROSOFT CORPORATION OR ITS SUPPLIERS BE LIABLE FOR
ANY DAMAGES WHATSOEVER INCLUDING DIRECT, INDIRECT, INCIDENTAL,
CONSEQUENTIAL, LOSS OF BUSINESS PROFITS OR SPECIAL DAMAGES, EVEN IF
MICROSOFT CORPORATION OR ITS SUPPLIERS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO NOT ALLOW THE EXCLUSION
OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES
SO THE FOREGOING LIMITATION MAY NOT APPLY.

Copyright Microsoft Corporation 1996.


DOCUMENT:Q65541  22-NOV-1994  [msdos]
TITLE   :How to Interpret 12-Bit FATs
PRODUCT :Microsoft Disk Operating System
PROD/VER:3.x 4.x 5.00
OPER/SYS:MS-DOS
KEYWORDS:kbhw kbenv

--------------------------------------------------------------------
The information in this article applies to:

 - Microsoft MS-DOS operating system versions 3.x, 4.x, and 5.0
--------------------------------------------------------------------

SUMMARY
=======

The following is a description of 12-bit FAT field entries, followed
by an explanation of how to locate and interpret them.

MORE INFORMATION
================

=======================================================================
               DESCRIPTION OF 12-BIT FAT FIELD ENTRIES
=======================================================================

The following are some definitions and explanations of FAT field
entries:

1. Twelve-bit FAT entries were used exclusively in DOS versions 1.x
   and 2.x. They are also used in versions 3.00 and later if the
   medium contains less than 4087 clusters. Media containing 4087 or
   more clusters use 16-bit FAT fields in DOS versions 3.00 and later.
   Each field corresponds directly to an assignable cluster on the
   disk.

2. Several FAT field entries have fixed meanings. They are defined as
   follows:

      12-Bit Entry     Meaning
      ------------     -------

        000h           Free cluster
        001h           Unused code
      FF0-FF6h         Reserved values
        FF7h           Bad cluster
      FF8-FFFh         Last cluster of file

   (Any FAT field entry not found in the table above should be
   considered the next FAT field number in the chain of the file to be
   examined.)

3. Also, the first two fields or first three bytes (FAT field numbers
   0 and 1) in the FAT are always reserved. The first byte contains a
   copy of the media descriptor byte and the two remaining bytes
   contain 0FFh.

4. A broad view of a 12-bit FAT is as follows: if the FAT were divided
   into groups of three bytes each, each group would contain two FAT
   field entries.

5. Finally, a FAT field number (n) refers to the nth field in the FAT,
   not the nth byte in the FAT. A FAT entry is the value stored in the
   field being examined.


=======================================================================
           HOW TO LOCATE AND INTERPRET A FAT FIELD ENTRY
=======================================================================

Twelve-bit FATs are set up so that if the FAT field number is even, it
must be interpreted differently than if it is an odd field number.


HOW TO INTERPRET AN EVEN FAT FIELD NUMBER
-----------------------------------------

Formula
-------

Multiply the FAT field number by 1.5. Read the next two bytes at the
resulting offset in the FAT. Strip off the last four bits from the
second byte and shift the result left 8 bits. OR the resulting value
with the first byte. This will give you the entry stored in the FAT
field. This entry could be a link or a last cluster marker depending
on the value.

Example
-------

You are given the FAT field number 306 (132h).

First, perform the following calculations:

   (FAT field number) * 1.5 = FAT byte offset (N)

   132h * 1.5 = 1CBh or 459

Read the 459th (N) and 460th (N + 1) bytes in the FAT table. Suppose
they contain the values 33h and 41h, respectively. The next field in
the chain would be as follows:

   (byte N) OR ((strip last 4 bits of byte N + 1) shift left 8 bits) =
                                                 Next FAT field number

   33h | ((41h & 0Fh) << 8) = 133h or the 307th field in the FAT


HOW TO INTERPRET AN ODD FAT ENTRY NUMBER
----------------------------------------

Formula
-------

Once again, multiply the FAT field number by 1.5 and floor it down to
the next integer less than the result. Read two bytes at the resulting
offset. Take the second byte and shift it left four bits. Then, shift
the first byte right four bits and AND the two together. The result is
the entry for this FAT field.

Example
-------

You are given the FAT field number 307 (133h).

Multiply and floor it:

   floor ((FAT field number) * 1.5) = FAT byte offset (N)

   floor (307 * 1.5) = 1CCh or 460

Read bytes 460 (N) and 461(N + 1) from the FAT. In this example, they
contain the values 41h and 14h, respectively. To interpret the entry
perform the following:

   (byte N >> 4) OR (byte N + 1 << 4) = FAT Entry

   (41h >> 4) | (14h << 4) = 144h or the 324th field in the FAT

KBCategory: kbhw kbenv
KBSubcategory: msdos
Additional reference words: 3.20 3.21 3.30 3.30a 4.00 4.01 5.00 howto

=============================================================================

THE INFORMATION PROVIDED IN THE MICROSOFT KNOWLEDGE BASE IS
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.  MICROSOFT DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL MICROSOFT CORPORATION OR ITS SUPPLIERS BE LIABLE FOR
ANY DAMAGES WHATSOEVER INCLUDING DIRECT, INDIRECT, INCIDENTAL,
CONSEQUENTIAL, LOSS OF BUSINESS PROFITS OR SPECIAL DAMAGES, EVEN IF
MICROSOFT CORPORATION OR ITS SUPPLIERS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO NOT ALLOW THE EXCLUSION
OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES
SO THE FOREGOING LIMITATION MAY NOT APPLY.

Copyright Microsoft Corporation 1994.


DOCUMENT:Q67321  17-NOV-1995  [msdos]
TITLE   :FAT Type and Cluster Size Depends on Logical Drive Size
PRODUCT :Microsoft Disk Operating System
PROD/VER:3.x 4.x 5.x 6.00 6.20 6.21 6.22
OPER/SYS:MS-DOS
KEYWORDS:kbref

--------------------------------------------------------------------
The information in this article applies to:

 - Microsoft MS-DOS operating system versions 3.x, 4.x, 5.x, 6.0,
   6.2, 6.21, 6.22
 - Microsoft Windows 95
--------------------------------------------------------------------

SUMMARY
=======

MS-DOS allocates disk space for files in units of one or more sectors;
these units are called "clusters" or "allocation units." On any MS-DOS
disk, a 1-byte file is allocated 1 cluster of disk space, wasting the
unused area of the cluster. A file that is 3.2 clusters large is given
4 clusters. Overall, a smaller cluster size means less waste.

The cluster size for a drive is decided by FORMAT, depending on the
size of the logical drive (see table, below). "Logical drive" refers
to an MS-DOS volume accessed by a drive letter (A:, B:, C:, D:, and so
forth). Hard disk users may want to consider cluster size when
choosing how to partition their drive(s).

The cluster size of a floppy drive cannot be changed. The cluster size
of a hard drive can be changed only by changing the size of the
logical drive, which is done by repartitioning the hard drive.

CHKDSK displays the allocation unit size for a logical drive. FDISK's
option 4 displays the size(s) of logical drives on the hard drive(s).

NOTE: DoubleSpace-compressed drives appear to have 8K clusters, but
internally vary the sectors-per-cluster as necessary (this information
is recorded in the MDFAT). For example, a 10K file  which compresses
by a factor of 2:1 actually uses 5K, or 10 sectors, of drive space.

MORE INFORMATION
================

The following is a table of logical drive sizes, FAT (File Allocation
Table) types, and cluster sizes:

                  Drive Size      FAT Type     Sectors     Cluster
               (logical volume)              Per Cluster     Size
               ----------------   --------   -----------   -------

(Floppy Disks)      360K           12-bit         2         1K
                    720K           12-bit         2         1K
                   1.2 MB          12-bit         1       512 bytes
                   1.44 MB         12-bit         1       512 bytes
                   2.88 MB         12-bit         2         1K


(Hard Disks)     0 MB - 15 MB      12-bit         8         4K
                16 MB - 127 MB     16-bit         4         2K
               128 MB - 255 MB     16-bit         8         4K
               256 MB - 511 MB     16-bit        16         8K
               512 MB - 1023 MB    16-bit        32        16K
              1024 MB - 2048 MB    16-bit        64        32K

NOTES:

 - Sectors are 512 bytes in size, except on some RAM drives.

 - In the past, some OEMs have modified their versions of MS-DOS to
   support other sector and/or cluster sizes. The Microsoft MS-DOS 5
   Upgrade Setup will, if possible, convert the logical drive to
   MS-DOS 5.0 compatible. This entails converting the sector size to
   512 bytes while retaining the nonstandard cluster size.

 - MS-DOS determines the FAT size based on the number of clusters. If
   there are 4085 or fewer clusters, a 12-bit FAT is used. If there are
   4086 or more clusters, a 16-bit FAT is used.

For more information on this topic, query on the following words:

   cluster and disk and FAT

KBCategory: kbref
KBSubcategory: msdos
Additional reference words: dblspace 3.20 3.21 3.30 3.30a 4.00 4.01 5.00
5.00a partition allocation unit 6.00 6.20 cluster granularity 6.21 6.22
win95

=============================================================================

THE INFORMATION PROVIDED IN THE MICROSOFT KNOWLEDGE BASE IS
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.  MICROSOFT DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL MICROSOFT CORPORATION OR ITS SUPPLIERS BE LIABLE FOR
ANY DAMAGES WHATSOEVER INCLUDING DIRECT, INDIRECT, INCIDENTAL,
CONSEQUENTIAL, LOSS OF BUSINESS PROFITS OR SPECIAL DAMAGES, EVEN IF
MICROSOFT CORPORATION OR ITS SUPPLIERS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO NOT ALLOW THE EXCLUSION
OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES
SO THE FOREGOING LIMITATION MAY NOT APPLY.

Copyright Microsoft Corporation 1995.


DOCUMENT:Q140365  12-NOV-1997  [winnt]
TITLE   :Default Cluster Size for FAT and NTFS
PRODUCT :Microsoft Windows NT
PROD/VER:3.5 3.51 4.0
OPER/SYS:winnt
KEYWORDS:ntfilesys kbother

======================================================================
-------------------------------------------------------------------------
The information in this article applies to:

 - Microsoft Windows NT Workstation versions 3.5 and 3.51
 - Microsoft Windows NT Server versions 3.5 and 3.51
 - Microsoft Windows NT Workstation versions 4.0
 - Microsoft Windows NT Server versions 4.0
-------------------------------------------------------------------------

SUMMARY
=======

All file systems used by Windows NT organize your hard disk based upon
cluster (or allocation unit) size, which represents the smallest amount of
disk space which can be allocated to hold a file. So when file sizes do not
come out to an even multiple of the cluster size, extra space must be used
to hold the file (up to the next multiple of the cluster size). On the
typical partition, this means that (cluster size)/2 * (number of files)
worth of space is lost this way.

If no cluster size is specified during format, NTFS picks defaults based
upon the size of the partition. These defaults have been selected to reduce
the amount of space lost and to reduce the amount of fragmentation on the
partition.

MORE INFORMATION
================

Windows NT uses the following default cluster sizes for NTFS (the value for
number of sectors assumes a standard, 512 byte sector. On systems with
sectors that are not 512 bytes, the number of sectors per cluster may
change, but the cluster size is fixed):

   Drive Size              Cluster Size       Number of Sectors
   ---------------------   ----------------   -----------------
   512MB or less              512 bytes          1
   513MB  to 1024MB(1GB)      1024 bytes (1KB)   2
   1025MB to 2048MB(2GB)      2048 bytes (2KB)   4
   2049MB to  4096MB(4GB)     4KB                8
   4097MB  to  8192MB(8GB)    8KB                16
   8193MB  to  16384MB(16GB)  16KB               32
   16385MB to  32768MB (32GB) 32KB               64
   >      to  32768MB (32GB)  64KB               128

These values are only used if an allocation unit size is not specified at
format time, using the /A:<size> switch with the format command.

The FAT file system uses the following cluster sizes. These sizes the same
under Microsoft Windows NT, Microsoft MS-DOS, Microsoft Windows 95 and any
other operating system that supports FAT:

   Drive Size          FAT Type   Sectors       Cluster
   (logical volume)               Per Cluster   Size
   -----------------   --------   -----------   -------
   0 MB - 15 MB        12-bit     8             4K
   16 MB - 127 MB      16-bit     4             2K
   128 MB - 255 MB     16-bit     8             4K
   256 MB - 511 MB     16-bit     16            8K
   512 MB - 1023 MB    16-bit     32            16K
   1024 MB - 2048 MB   16-bit     64            32K
   2048 MB - 4096 MB   16-bit     128           64K
   4096 MB - 8192 MB   16-bit     256           128K   NT V4.0 only
   8192 MB - 16384 MB  16-bit     512           256K   NT V4.0 only

NOTE: On very small FAT partitions, a 12-bit FAT is used instead of a
16-bit FAT. The FAT files system only supports 512 byte sectors, so both
the sectors per cluster and the cluster size is fixed.


Windows NT version 4.0 NTFS Compatibility with Windows NT version 3.51 NTFS
===========================================================================

The Windows NT File System (NTFS) file system supports clusters up to 64K.
However, the file record size is always 1K regardless of the cluster size.
The File Allocation Table (FAT) file system supports clusters up to 256K.

Due to the cluster size change, formatting a volume with 2K or larger
clusters with NTFS can generate a volume that is not usable by Windows NT
version 3.51. File record sizes that are smaller than the cluster size is
not supported by Windows NT version 3.51. However, you can ensure backwards
compatibility by running format from the command line and specifying the /a
parameter. This parameter is used to override the default disk allocation
unit size.

Default settings are strongly recommended for general use.
NTFS supports 512 bytes, 1K, 2K, 4K, 8K, 16K, 32K, 64K.
FAT supports 8K, 16K, 32K, 64K, 128K, 256K.
NTFS compression is not supported for allocation unit sizes above 4K.

Additional query words: prodnt
======================================================================
Keywords          : ntfilesys kbother
Version           : 3.5 3.51 4.0
Platform          : winnt

=============================================================================

THE INFORMATION PROVIDED IN THE MICROSOFT KNOWLEDGE BASE IS
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.  MICROSOFT DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL MICROSOFT CORPORATION OR ITS SUPPLIERS BE LIABLE FOR
ANY DAMAGES WHATSOEVER INCLUDING DIRECT, INDIRECT, INCIDENTAL,
CONSEQUENTIAL, LOSS OF BUSINESS PROFITS OR SPECIAL DAMAGES, EVEN IF
MICROSOFT CORPORATION OR ITS SUPPLIERS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO NOT ALLOW THE EXCLUSION
OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES
SO THE FOREGOING LIMITATION MAY NOT APPLY.

Copyright Microsoft Corporation 1997.


DOCUMENT:Q73736  22-NOV-1994  [msdos]
TITLE   :Effects of FDISK on Boot Record, Root Directory, and FATs
PRODUCT :Microsoft Disk Operating System
PROD/VER:3.20 3.21 3.30a 4.01a 5.x 6.00 6.20 6.21 6.22
OPER/SYS:MS-DOS
KEYWORDS:kbref

---------------------------------------------------------------------
The information in this article applies to:

 - Microsoft MS-DOS operating system versions 3.x, 4.x, 5.x, 6.0,
   6.2, 6.21, 6.22
---------------------------------------------------------------------

SUMMARY
=======

If you use MS-DOS FDISK to delete and then recreate a partition or
logical drive on your hard disk, the boot record, root directory, and
file allocation tables (FATs) of these logical drives may be affected
in varying degrees, depending on the particular version of FDISK used.

MORE INFORMATION
================

MS-DOS Version 3.2
------------------

   Area                Effect
   ----                ------

   Boot record         Preserves boot record.
   Root directory      Preserves root directory.
   1st copy of FAT     Preserves 1st copy of FAT.
   2nd copy of FAT     Preserves 2nd copy of FAT.

MS-DOS Version 3.21
-------------------

   Area                Effect
   ----                ------

   Boot record         Zeros area formerly occupied by boot record.
   Root directory      Zeros area formerly occupied by root directory.
   1st copy of FAT     Zeros area formerly occupied by 1st copy of FAT.
   2nd copy of FAT     Zeros area formerly occupied by 2nd copy of FAT.

MS-DOS Version 3.30a
--------------------

   Area                Effect
   ----                ------

   Boot record         Fills area formerly occupied by boot record
                       with bytes containing value F6.
   Root directory      Fills area formerly occupied by root directory
                       with bytes containing value F6.
   1st copy of FAT     Fills area formerly occupied by 1st copy of FAT
                       with bytes containing value F6.
   2nd copy of FAT     Fills area formerly occupied by 2nd copy of FAT
                       with bytes containing value F6.

MS-DOS Version 4.01a
--------------------

   Area                Effect
   ----                ------

   Boot record         Fills area formerly occupied by boot record
                       with bytes containing value F6.
   Root directory      Invalidates root directory; may contain
                       "garbage" values.
   1st copy of FAT     Invalidates 1st copy of FAT; may contain
                       "garbage" values.
   2nd copy of FAT     Invalidates 2nd copy of FAT; may contain
                       "garbage" values.

MS-DOS Versions 5.0 and 6.0
---------------------------

   Area                Effect
   ----                ------

   Boot record         Fills area formerly occupied by boot record with
                       bytes containing value F6.
   Root directory      Preserves root directory information.
   1st copy of FAT     Preserves 1st copy of FAT.
   2nd copy of FAT     Preserves 2nd copy of FAT.

KBCategory: kbref
KBSubcategory: msdos
Additional reference words: 6.22 3.20 3.21 3.30a 4.01a 5.00 5.00a 6.00 6.20

=============================================================================

THE INFORMATION PROVIDED IN THE MICROSOFT KNOWLEDGE BASE IS
PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.  MICROSOFT DISCLAIMS
ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING THE WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  IN NO
EVENT SHALL MICROSOFT CORPORATION OR ITS SUPPLIERS BE LIABLE FOR
ANY DAMAGES WHATSOEVER INCLUDING DIRECT, INDIRECT, INCIDENTAL,
CONSEQUENTIAL, LOSS OF BUSINESS PROFITS OR SPECIAL DAMAGES, EVEN IF
MICROSOFT CORPORATION OR ITS SUPPLIERS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO NOT ALLOW THE EXCLUSION
OR LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES
SO THE FOREGOING LIMITATION MAY NOT APPLY.

Copyright Microsoft Corporation 1994.

*)
