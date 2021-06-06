{****************************************************************************
//                            File PHYSDUP4.PAS
//
//                    Physical drive(s) copy program
//
//      Copyright (c) 1998, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: d:/bp70/source/RCS/physdup4.pas $
//  $RCSfile: physdup4.pas $ 
//   $Author: dstef $
//     $Date: 2000/06/17 19:31:12 $
// $Revision: 1.6 $ 
//   $Locker: dstef $ 
//
//      $Log: physdup4.pas $
//      Revision 1.6  2000/06/17 19:31:12  dstef
//      Added detailed output for INT 13 installation check
//
//      Revision 1.5  2000/04/26 10:25:57  dstef
//      Added full info about INT 13h extensions
//
//      Revision 1.4  1999/08/24 23:16:14  dstef
//      Minor changes
//
//      Revision 1.3  1999/08/24 23:12:18  dstef
//      Updated EBIOS support (added read/write ops)
//      Added BIOS translation scheme algorithm to verify
//
//      Revision 1.2  1999/03/15 14:55:59  dstef
//      Added EBIOS detection
//
//      Revision 1.1  1999/01/03 18:14:47  dstef
//      Initial revision
//
//****************************************************************************}


(*
  Author: Dmitry V. Stefankov
  Dates: 5-11, January, 1998
  Email: wizard@radio-msu.net, dstef@nsl.ru, dima@mccbn.ru

  Advantages:
  Fast physical disk copy.
  BIOS method to access disk.
  Verify-after-copy.
  Main idea: read-write-read-read
             to use built-in on-disk sequential cache
  Estimated formulae for N disks ( 1 source, N-1 targets):
   (N+1)*read_block + (N-1)*write_block + (N-1)*compare_block

  Limitations:
  Same physical geometry for all disks (source and targets)
  No total checks during execution.
  Enough slow compare algorithm (straightforward).

  Additions.
  Logfile for user information.
  EBIOS support for disks more than 8.4 GBytes.
*)

PROGRAM  PhysicalCopyOfDiskToOtherDrives;

{$S-}
{$R-}
{$M 16384,16384,16384 }

{***$DEFINE   EmulationVersion }
{***$DEFINE   EmulPhysicalParameters }
{***$DEFINE   EmulStartBlockNum }
{***$DEFINE   EmulEndBlockNum }
{$DEFINE   EnableWriteVersion }
{$DEFINE   EnableCompareVersion }

USES
  ShowTErr;    {This module from famous DSUTILxx.ZIP on Internet!}

LABEL
   99, 98;

CONST
     aDiskServiceInt            =  $13;
     aDiskReadSecs              =  $02;
     aDiskWriteSecs             =  $03;
     aDiskVerifySecs            =  $04;
     aDiskGetParams             =  $08;
     aDiskPresenceExt           =  $41;
     aDiskReadSecsExt           =  $42;
     aDiskWriteSecsExt          =  $43;
     aDiskVerifySecsExt         =  $44;
     aDiskGetParamsExt          =  $48;
     aDosServicesInt            =  $21;
     aAllocMemBlock             =  $48;
     aFreeMemBlock              =  $49;
     aPhysHardDisk0             =  $80;
     aWord                      =  2;
     aHdStep                    =  2;
     aDiskSectorSiz             =  512;
     aNoVerifyWrite0            =  0;
     aNoVerifyWrite1            =  1;
     aVerifyWrite               =  2;
     MIN_DISK_NUM               =  0;
     MAX_DISK_NUM               =  3;
     MAX_DOS_BLK_SIZ_PARAS      =  4096;
     MAX_BLK_FILL_SIZ           =  65535;
     MAX_BIOS_CYL_NUM           =  1023;


TYPE
    STR2  =  STRING[2];
    STR4  =  STRING[4];

    recDriveCopy    =   RECORD
             dbPhysDrive           :     System.Byte;
             fCopyToThisDrv        :     System.Boolean;
             fVerifyThisDrv        :     System.Boolean;
             lpReadBackBuf         :     System.Pointer;
                        END;
   {recDriveCopy}

    recEDP_Parm      =   RECORD
             dwBufSize             :     System.Word;             {00}
             dwInfoFlags           :     System.Word;             {02}
             liCylinders           :     System.Longint; {1-based}{04}
             liHeads               :     System.Longint; {1-based}{08}
             liSecsOnTrk           :     System.Longint; {1-based}{0C}
             liTotalSectorsLo      :     System.Longint; {1-based}{10}
             liTotalSectorsHi      :     System.Longint;          {14}
             dwBytesPerSec         :     System.Word;             {18}
             lpEDDconfParm         :     System.Longint;          {1A}
             dbFill                :  ARRAY[0..15] OF System.Byte;{1E}
                        END;
   {recDriveCopy}

    recEDP_DiskAddrPkt  =  RECORD
         dbPktSize                  :   System.Byte;
         dbUnused1                  :   System.Byte;
         dbSecCount                 :   System.Byte;
         dbUnused3                  :   System.Byte;
         dwBufOfs                   :   System.Word;
         dwBufSeg                   :   System.Word;
         liSecNumLo                 :   System.Longint;
         liSecNumHi                 :   System.Longint;
                           END;
   {recEDP_DiskAddrPkt}

   QUADWORD  =  ARRAY[0..7] OF System.Byte;

   recEDP_Packet_RW    =   RECORD
             dbBufSize             :     System.Byte;             {00}
             dbUnused1             :     System.Byte;             {01}
             dbSectorsToTransfer   :     System.Byte;      {1-127}{02}
             dbUnused3             :     System.Byte;             {03}
             dwMemBufOfs           :     System.Word;             {04}
             dwMemBufSeg           :     System.Word;             {06}
             qwStartingSecNum      :     QUADWORD;        {64-bit}{08}
                        END;
   {recEDP_Packet_RW}


CONST
{$IFDEF   EnableWriteVersion }
   g_fDoWrite : System.Boolean = System.TRUE;
{$ELSE}
   g_fDoWrite : System.Boolean = System.FALSE;
{$ENDIF   EnableWriteVersion }
   g_fWriteLogFile  : System.Boolean = System.FALSE;
   g_fEBiosInUse    : System.Boolean = System.FALSE;
   g_fVerifyTranslation : System.Boolean = System.FALSE;

VAR
   g_regAL, g_regAH, g_regDH : System.Byte;
   g_regCX : System.Word;
   g_recEDP_ParmSRC : recEDP_Parm;
   g_dwMismatchOfs,
   g_dwCurCylSTD : System.Word;
   g_lpReadVerBufStd : System.Pointer;
   g_dbCurHdSTD,
   g_dbCurSecSTD : System.Byte;
   g_lpReadCacheBuf,
   g_lpReadVerBufTmp : pointer;
   g_dwBlockSize,
   g_dwTemp,
   g_dwPhysCyl,
   g_dwCurCyl,
   g_dwEndCyl,
   g_dwStartCyl     : System.Word;
   g_liPhysCyls,
   g_liPhysSecs,
   g_liPhysHeads    : System.Longint;
   g_LiveDisks,
   g_dbIndex,
   g_dbBlocksRead,
   g_dbActualBlocksRW,
   g_dbPhysHd,
   g_dbEndHd,
   g_dbCurHd,
   g_dbStartHd,
   g_dbPhysDisks,
   g_dbPhysSec,
   g_dbCurSec,
   g_dbEndSec,
   g_dbStartSec,
   g_dbElapsedHour,
   g_dbElapsedMin,
   g_dbElapsedSec,
   g_dbUserDriveSRC,
   g_dbUserDriveTGT,
   g_dbDiskError    : Byte;
   g_fSameContents,
   g_fCopyNotDone,
   g_fVerifyNotDone : Boolean;
   g_chOpStatus,
   g_chVerifyAllDisk,
   g_chVerifyOnRD,
   g_chVerifyOnWR : char;
   g_iErrCode     : integer;
   g_liStartBlockNum,
   g_liCurBlockNum,
   g_liEndBlockNum,
   g_liTemp,
   g_InitTimeTicks,
   g_DiffTimeTicks : longint;
   g_qwBigSecNumCur,
   g_qwBigSecNumStart,
   g_qwBigSecNumEnd : QUADWORD;
   g_EDP_Pkt_Read,
   g_EDP_Pkt_Write : recEDP_Packet_RW;
   g_sUserInput   : STRING;
   g_sElapsedTime : STRING;
   g_DrivesDefArr : ARRAY[MIN_DISK_NUM..MAX_DISK_NUM]  OF  recDriveCopy;
   g_LogFile      : TEXT;
   g_TextBuf      : ARRAY[1..8192] OF System.Byte;


FUNCTION  _fnbReadDiskSectorsExt( dbDiskNum : System.Byte;
                                  recPktBuf : recEDP_Packet_RW
                                 ) : boolean; ASSEMBLER;
ASM
        push    ds
        mov     dl, dbDiskNum
        mov     ah, aDiskReadSecsExt
        lds     si, recPktBuf
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        pop     ds
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbReadDiskSectorsExt }


FUNCTION  _fnbWriteDiskSectorsExt( dbDiskNum : System.Byte;
                                   dbVerifySwitch : System.Byte;
                                   recPktBuf : recEDP_Packet_RW
                                  ) : boolean; ASSEMBLER;
ASM
        push    ds
        mov     dl, dbDiskNum
        mov     ah, aDiskWriteSecsExt
        mov     al, dbVerifySwitch
        lds     si, recPktBuf
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        pop     ds
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbWriteDiskSectorsExt }


FUNCTION  _fnbVerifyDiskSectorsExt(dbDiskNum : System.Byte;
                       recPktBuf : recEDP_Packet_RW) : boolean; ASSEMBLER;
ASM
        push    ds
        mov     dl, dbDiskNum
        mov     ah, aDiskVerifySecsExt
        lds     si, recPktBuf
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        pop     ds
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbVerifyDiskSectorsExt }


FUNCTION  _fnbReadDiskSectors(dbDiskNum : byte; dwCylinderNum : WORD;
                              dbHeadNum, dbSecNum, dbSecCount : BYTE;
                              lpDiskBuf : Pointer) : boolean; ASSEMBLER;
ASM
        mov     dl, dbDiskNum
        mov     dh, dbHeadNum
        mov     cx, dwCylinderNum
        xchg    ch, cl
        and     cl, 00000011b
        ror     cl, 1
        ror     cl, 1
        mov     al, dbSecNum
        and     al, 00111111b
        or      cl, al
        les     bx, lpDiskBuf
        mov     al, dbSecCount
        mov     ah, aDiskReadSecs
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbReadDiskSectors }


FUNCTION  _fnbReadDiskSectorsBig(dbDiskNum : byte; dwCylinderNum : WORD;
                                 dbHeadNum, dbSecNum, dbSecCount : BYTE;
                                 lpDiskBuf : Pointer; bEBios : Boolean;
                                 recEdpPacket : recEDP_Packet_RW;
                                 qwSecNumExt : QUADWORD) : boolean;
{-More general read function-}
VAR
  bResult : System.Boolean;
BEGIN
  IF (bEBios)
     THEN BEGIN
       System.FillChar(recEdpPacket,sizeof(recEdpPacket),0);
       recEdpPacket.dbBufSize := sizeof(recEdpPacket); {Must be exactly 16}
       recEdpPacket.dbSectorsToTransfer := dbSecCount;
       recEdpPacket.dwMemBufOfs := System.Ofs(lpDiskBuf^);
       recEdpPacket.dwMemBufSeg := System.Seg(lpDiskBuf^);
       recEdpPacket.qwStartingSecNum := qwSecNumExt;
       bResult := _fnbReadDiskSectorsExt( dbDiskNum, recEdpPacket );
       IF (recEdpPacket.dbSectorsToTransfer <> dbSecCount)
         THEN BEGIN
           WriteLn;
           WriteLn( 'WARN! Need sectors = ', dbSecCount,
                    ', read sectors = ',
                    recEdpPacket.dbSectorsToTransfer );
              END;
       {if-then}
          END
     ELSE BEGIN
       bResult := _fnbReadDiskSectors( dbDiskNum, dwCylinderNum,
                                       dbHeadNum, dbSecNum,
                                       dbSecCount, lpDiskBuf );
          END;
  {if-then-else}
  _fnbReadDiskSectorsBig := bResult;
END;
{ _fnbReadDiskSectorsBig }


FUNCTION  _fnbWriteDiskSectors(dbDiskNum : byte; dwCylinderNum : WORD;
                               dbHeadNum, dbSecNum, dbSecCount : BYTE;
                               lpDiskBuf : Pointer) : boolean; ASSEMBLER;
ASM
        mov     dl, dbDiskNum
        mov     dh, dbHeadNum
        mov     cx, dwCylinderNum
        xchg    ch, cl
        and     cl, 00000011b
        ror     cl, 1
        ror     cl, 1
        mov     al, dbSecNum
        and     al, 00111111b
        or      cl, al
        les     bx, lpDiskBuf
        mov     al, dbSecCount
        mov     ah, aDiskWriteSecs
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbWriteDiskSectors }


FUNCTION  _fnbWriteDiskSectorsBig(dbDiskNum : byte; dwCylinderNum : WORD;
                                  dbHeadNum, dbSecNum, dbSecCount : BYTE;
                                  lpDiskBuf : Pointer; bEBios : Boolean;
                                  recEdpPacket : recEDP_Packet_RW;
                                  qwSecNumExt : QUADWORD) : boolean;
{-More general read function-}
VAR
  bResult : System.Boolean;
BEGIN
  IF (bEBios)
     THEN BEGIN
       System.FillChar(recEdpPacket,sizeof(recEdpPacket),0);
       recEdpPacket.dbBufSize := sizeof(recEdpPacket); {Must be exactly 16}
       recEdpPacket.dbSectorsToTransfer := dbSecCount;
       recEdpPacket.dwMemBufOfs := System.Ofs(lpDiskBuf^);
       recEdpPacket.dwMemBufSeg := System.Seg(lpDiskBuf^);
       recEdpPacket.qwStartingSecNum := qwSecNumExt;
       bResult := _fnbWriteDiskSectorsExt( dbDiskNum, aNoVerifyWrite0,
                                           recEdpPacket );
       IF (recEdpPacket.dbSectorsToTransfer <> dbSecCount)
         THEN BEGIN
           WriteLn;
           WriteLn( 'WARN! Need sectors = ', dbSecCount,
                    ', written sectors = ',
                    recEdpPacket.dbSectorsToTransfer );
              END;
       {if-then}
          END
     ELSE BEGIN
       bResult := _fnbWriteDiskSectors( dbDiskNum, dwCylinderNum,
                                        dbHeadNum, dbSecNum,
                                        dbSecCount, lpDiskBuf );
          END;
  {if-then-else}
  _fnbWriteDiskSectorsBig := bResult;
END;
{ _fnbWriteDiskSectorsBig }


FUNCTION  _fnbVerifyDiskSectors(dbDiskNum : byte; dwCylinderNum : WORD;
                             dbHeadNum, dbSecNum, dbSecCount : BYTE;
                             lpDiskBuf : Pointer) : boolean; ASSEMBLER;
ASM
        mov     dl, dbDiskNum
        mov     dh, dbHeadNum
        mov     cx, dwCylinderNum
        xchg    ch, cl
        and     cl, 00000011b
        ror     cl, 1
        ror     cl, 1
        mov     al, dbSecNum
        and     al, 00111111b
        or      cl, al
        les     bx, lpDiskBuf
        mov     al, dbSecCount
        mov     ah, aDiskVerifySecs
{$IFDEF   EmulationVersion }
        clc
        xor     ah, ah
{$ELSE}
        int     aDiskServiceInt
{$ENDIF   EmulationVersion }
        mov     g_dbDiskError, ah
        mov     al, FALSE
        jc     @Done
        mov     al, TRUE
   @Done:
END;
{ _fnbVerifyDiskSectors }


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


FUNCTION  _fnsGetDiskErrDesc(dbErrCode : byte) : STRING;
{* Returns error description for disk access. *}
VAR
  sTemp : STRING;
BEGIN
   CASE (dbErrCode) OF
      0 :     sTemp := 'No errors';
      1 :     sTemp := 'invalid command';
      2 :     sTemp := 'address mark not found';
      3 :     sTemp := 'attempt to write on write-protected disk';
      4 :     sTemp := 'sector not found';
      5 :     sTemp := 'reset failed';
      7 :     sTemp := 'drive parameter activity failed';
      8 :     sTemp := 'DMA overrun';
      9 :     sTemp := 'attempt to DMA across a 64K boundary';
      10 :    sTemp := 'bad sector flag detected';
      11 :    sTemp := 'bad cylinder found';
      13 :    sTemp := 'invalid number sectors on format';
      14 :    sTemp := 'invalid data address mark detected';
      15 :    sTemp := 'DMA arbitration level out of range';
      16 :    sTemp := 'ECC data error';
      17 :    sTemp := 'ECC corrected data error';
      32 :    sTemp := 'controller failure';
      64 :    sTemp := 'seek failure';
      128 :   sTemp := 'time out';
      170 :   sTemp := 'drive not ready';
      187 :   sTemp := 'Undefined error';
      204 :   sTemp := 'status error';
      255 :   sTemp := 'sense operation failed';
   ELSE
     sTemp := 'unknown error';
   END;
   {case-of}
   _fnsGetDiskErrDesc := sTemp;
END;
{ _fnsGetDiskErrDesc }


PROCEDURE  _GetCurTime(VAR  dbHr,dbMin,dbSec : byte); ASSEMBLER;
{* Gets a current time from BIOS. *}
{At exit:	AH  =  hours     }
{		    AL  =  minutes  }
{		    BH  =  seconds   }
{		    BL  =  hundreths }
ASM
		mov	ax,$40                          {BIOS data segment}
		mov	es,ax
		mov	dx,es:[$6C+0] 	                {get # of timer tics}
		mov	cx,es:[$6C+2]

		mov	ax,cx			                {code from Microsoft}
		mov	bx,dx			                {CLOCK$ device driver}
		shl	dx,1
		rcl	cx,1
		shl	dx,1
		rcl	cx,1
		add	dx,bx
		adc	ax,cx
		xchg	ax,dx
		mov	cx,0E90Bh
		div	cx
		mov	bx,ax
		xor	ax,ax
		div	cx
		mov	dx,bx
		mov	cx,200
		div	cx
		cmp	dl,100
		jb	@Under
		sub	dl,100
	@Under:
		cmc
		mov	bl,dl
		rcl	ax,1
		mov	dl,0
		rcl	dx,1
		mov	cx,60
		div	cx
		mov	bh,dl
		div	cl
		xchg	al,ah
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
{* Translates a current time from supplied ticks. *}
{At exit:	AH  =  hours     }
{		    AL  =  minutes  }
{		    BH  =  seconds   }
{		    BL  =  hundreths }
ASM
       mov	dx,WORD PTR liTimeTicks+0
       mov	cx,WORD PTR liTimeTicks+2

       mov	ax,cx			                {code from Microsoft}
       mov	bx,dx			                {CLOCK$ device driver}
       shl	dx,1
       rcl	cx,1
       shl	dx,1
       rcl	cx,1
       add	dx,bx
       adc	ax,cx
       xchg	ax,dx
       mov	cx,0E90Bh
       div	cx
       mov	bx,ax
       xor	ax,ax
       div	cx
       mov	dx,bx
       mov	cx,200
       div	cx
       cmp	dl,100
       jb	@Under
       sub	dl,100
@Under:
       cmc
       mov	bl,dl
       rcl	ax,1
       mov	dl,0
       rcl	dx,1
       mov	cx,60
       div	cx
       mov	bh,dl
       div	cl
       xchg	al,ah
       les     di, dbHr
       mov     es:[di], ah
       les     di, dbMin
       mov     es:[di], al
       les     di, dbSec
       mov     es:[di], bh
END;
{ _GetCurTimeNoSrc }


PROCEDURE  _SetQuadValue(VAR qwNum : QUADWORD;
                             liNum : System.Longint);
{-Assign value to quadword-}
VAR
  dbIndex : byte;
BEGIN
  System.FillChar(qwNum,System.Sizeof(qwNum),0);
  System.Move(liNum,qwNum,sizeof(liNum));
END;
{ _SetQuadValue }


PROCEDURE  _AddQuads(VAR qwNum1, qwNum2 : QUADWORD);
BEGIN
   ASM
       push   ds
       lds    si, qwNum1
       les    di, qwNum2
       mov    ax, es:[di]                   {word 0}
       add    [si], ax
       mov    ax, es:[di+2]                 {word 1}
       adc    [si+2], ax
       mov    ax, es:[di+4]                 {word 2}
       adc    [si+4], ax
       mov    ax, es:[di+6]                 {word 3}
       adc    [si+6], ax
       pop    ds                            {Here ignore carry}
   END;
   {asm-end}
END;
{ _AddQuads }


PROCEDURE  _AddLongToQuad(VAR qwNum : QUADWORD;
                             liNum : System.Longint);
VAR
  qwTemp : QUADWORD;
BEGIN
  _SetQuadValue( qwTemp, liNum );
  _AddQuads( qwNum, qwTemp );
END;
{ _AddLongToQuad }


FUNCTION  _fnbCompareQuads( qwNum1, qwNum2 : QUADWORD ) : boolean;
{-Returns TRUE if qwNum1 >= qwNum2 otherwise FALSE-}
VAR
  bRes : boolean;
BEGIN
   ASM
        mov     al, FALSE
        mov     cx, 4
        mov     si, 6
     @Compare:
        mov     bx, WORD PTR qwNum1[si]     {Compare a word}
        mov     dx, WORD PTR qwNum2[si]
        cmp     bx, dx
        jb     @Done
        ja     @Num1Big
        dec     si                          {Next lower word}
        dec     si
        loop   @Compare
     @Num1Big:
         mov    al, TRUE                    {Also default}
     @Done:
         mov    bRes, al
   END;
   {asm-end}
  _fnbCompareQuads := bRes;
END;
{ _fnbCompareQuads }


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



BEGIN

(*
  _SetQuadValue( g_qwBigSecNumCur, $FFE03578 );
  _AddLongToQuad( g_qwBigSecNumCur, $0014FFF);
  _AddLongToQuad( g_qwBigSecNumCur, $30507890);
*)

  {-Display banner-}
  WriteLn('Physical Disks Duplicator v0.7b, Copyright (c) 1998, 2000 Dmitry Stefankov');
  WriteLn('You can use this program for evaluation purposes.');
  WriteLn('This program is without warranty of any kind and any form.');
  Write('Press <CR> to start copy or type any string to exit.');
  ReadLn(g_sUserInput);
  IF  ( g_sUserInput <> '' )
    THEN  BEGIN
      WriteLn('WARN: Terminated by user!');
      Halt(4);
          END;
  {if-then}

  {-Init targets array-}
  FOR  g_dbIndex := MIN_DISK_NUM  TO  MAX_DISK_NUM  DO
  BEGIN
     g_DrivesDefArr[g_dbIndex].dbPhysDrive    := $FF;
     g_DrivesDefArr[g_dbIndex].fCopyToThisDrv := System.FALSE;
     g_DrivesDefArr[g_dbIndex].fVerifyThisDrv := System.FALSE;
     g_DrivesDefArr[g_dbIndex].lpReadBackBuf  := NIL;
  END;
  {for-to-do}

  {-Select source drive-}
  Write('Select SRC physical drive (0..3) [0]: ');
  ReadLn(g_sUserInput);
  IF  (g_sUserInput = '')
    THEN   g_sUserInput := '0';
  {if-then}
  IF (g_sUserInput[1] IN ['0'..'3'])
     THEN  BEGIN
       g_dbUserDriveSRC := aPhysHardDisk0 +
                           System.BYTE(g_sUserInput[1]) -
                           System.Ord('0');
           END
     ELSE  BEGIN
        WriteLn('ERROR: You specified wrong disk number!');
        Halt(1);
           END;
  {if-then-else}

   {-Detect EBIOS presence-}
   ASM
        mov     dl, g_dbUserDriveSRC
        mov     bx, 055AAh
        mov     ah, aDiskPresenceExt
        int     aDiskServiceInt
        jc     @NotFound
        cmp     bx, 0AA55h
        jne    @NotFound
        mov     g_regCX, cx
        mov     g_regAL, al
        mov     g_regAH, ah
        mov     g_regDH, dh
        test    cx, 1                       {Fn $41-$44,$47,$48 valid?}
        jz     @NotFound
        mov     g_fEBiosInUse, System.TRUE
        jmp    @Done
    @NotFound:
    @Done:
   END;
   {asm-end}
   IF (NOT(g_fEBiosInUse))
     THEN BEGIN
        WriteLn('INFO: EBIOS not found.');
          END
     ELSE BEGIN
        WriteLn('INFO: EBIOS found.');
        WriteLn( 'EBIOS Major version=$', _fnsByteToHexFmt(g_regAH) );
        IF (g_regAH = $01)
          THEN WriteLn('** 1.x IBM/MS INT 13 Extensions');
        IF (g_regAH = $20)
          THEN WriteLn('** 2.0 IBM/MS INT 13 Extensions / EDD-1.0');
        IF (g_regAH = $21)
          THEN WriteLn('** 2.1 IBM/MS INT 13 Extensions / EDD-1.1');
        IF (g_regAH = $30)
          THEN WriteLn('** EDD-3.0');
        WriteLn( 'EBIOS Extension version=$', _fnsByteToHexFmt(g_regDH) );
        WriteLn( 'EBIOS API subset bitmap=$', _fnsWordToHexFmt(g_regCX) );
        IF ( (g_regCX AND $0001) <> 0 )
          THEN  WriteLn('** extended disk access functions (AH=42h-44h,47h,48h)');
        IF ( (g_regCX AND $0002) <> 0 )
          THEN  WriteLn('** removable drive controller functions (AH=45h,46h,48h,49h,INT 15/AH=52h)');
        IF ( (g_regCX AND $0004) <> 0 )
          THEN  BEGIN
            WriteLn('** enhanced disk drive (EDD) functions (AH=48h,AH=4Eh)');
            WriteLn('   extended drive parameter table is valid');
                END;
        System.FillChar(g_recEDP_ParmSRC,sizeof(g_recEDP_ParmSRC),0);
        g_recEDP_ParmSRC.dwBufSize := sizeof(g_recEDP_ParmSRC)-2; {-wordsize}
        ASM
             mov     g_dbDiskError, 0
             mov     dl, g_dbUserDriveSRC
             mov     si, OFFSET g_recEDP_ParmSRC.dwBufSize
             mov     ah, aDiskGetParamsExt
             int     aDiskServiceInt
             jnc    @Done
             mov     g_dbDiskError, ah
         @Done:
        END;
        {asm-end}
         IF  ( g_dbDiskError <> 0)
           THEN  BEGIN
             Writeln('ERROR: EDP disk status = ',g_dbDiskError,
                     ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
             Halt(7);
                 END
            ELSE BEGIN
             WriteLn( 'EBIOS: returned EDP buffer size = $',
                      _fnsWordToHexFmt(g_recEDP_ParmSRC.dwBufSize),
                      ' bytes.' );
                 END;
         {if-then-else}
          END;
   {if-then-else}

  {-Get source disk geometry-}
   ASM
         xor     cx, cx
         mov     dl, g_dbUserDriveSRC
         mov     ah, aDiskGetParams
         int     aDiskServiceInt
         mov     g_dbDiskError, ah
         jc     @L1
         mov     g_dbPhysDisks, dl
         inc     dh
         mov     g_dbPhysHd, dh
         mov     al, cl
         and     al, 00111111b
         mov     g_dbPhysSec, al
         and     cl, 11000000b
         rol     cl, 1
         rol     cl, 1
         xchg    ch, cl
         add     cx, 2
         mov     ax, MAX_BIOS_CYL_NUM
         cmp     cx, ax
         jb     @L0
         mov     cx, ax
     @L0:
         mov     g_dwPhysCyl, cx
     @L1:
   END;
   {asm-end}
   IF  ( g_dbDiskError <> 0)
     THEN  BEGIN
       Writeln('ERROR: disk status = ',g_dbDiskError,
               ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
       Halt(5);
           END;
   {if-then}

  {-Ask about EBIOS using-}
  Write('Use EBIOS instead standard BIOS(Y,N) [N]: ');
  ReadLn(g_sUserInput);
  IF (g_sUserInput = '')
    THEN  g_sUserInput := 'N';
  {if-then}
  g_chVerifyAllDisk := System.UpCase(g_sUserInput[1]);
  IF  NOT( g_chVerifyAllDisk IN ['Y','N'] )
    THEN  BEGIN
      Writeln('ERROR: You specified wrong selecton, please be patient!');
      GOTO 98;
          END;
  {if-then}
  IF (g_chVerifyAllDisk = 'Y' )
    THEN BEGIN
      g_fEBiosInUse := System.True;
      WriteLn('INFO: EBIOS enabled by manual way.');
         END
    ELSE BEGIN
      g_fEBiosInUse := System.FALSE;
      WriteLn('INFO: EBIOS disabled by manual way.');
         END;
  {if-then-then}

{$IFDEF   EmulPhysicalParameters }
  IF (g_fEBiosInUse)
    THEN  BEGIN
      WITH g_recEDP_ParmSRC DO
      BEGIN
        liCylinders := 152;
        liHeads := 8;
        liSecsOnTrk := 63;
        liTotalSectorsLo := liCylinders*liHeads*liSecsOnTrk;
        liTotalSectorsHi := 0;
      END;
      {with-do}
          END;
  {if-then}
   g_dwPhysCyl := 5;
   g_dbPhysSec := 60;
   g_dbPhysHd := 255;
   g_dbPhysDisks := 4;
{$ENDIF   EmulPhysicalParameters }

  {-Override source drive geometry-}
  IF (g_fEBiosInUse)
    THEN  BEGIN
      g_liPhysCyls  := g_recEDP_ParmSRC.liCylinders;
      g_liPhysHeads := g_recEDP_ParmSRC.liHeads;
      g_liPhysSecs  := g_recEDP_ParmSRC.liSecsOnTrk;
      g_dwBlockSize := g_recEDP_ParmSRC.dwBytesPerSec;
      WriteLn('Disk ',g_dbUserDriveSRC-aPhysHardDisk0,
              ' geometry (EDP): cyls = ',g_liPhysCyls,
              ', hds = ',g_liPhysHeads,
              ', secs = ',g_liPhysSecs,
              ', blocksiz = ', g_dwBlockSize);
      IF (g_dwBlockSize <> aDiskSectorSiz)
        THEN BEGIN
            Writeln( 'ERROR: disk block size is not equal standard (512 bytes).' );
            Halt(8);
             END;
      {if-then}
          END;
  {if-then}

  {-Display source drive parameters-}
  WriteLn('Total disks per system: ',g_dbPhysDisks);
  WriteLn('Disk ',g_dbUserDriveSRC-aPhysHardDisk0,
          ' geometry (std): cyls = ',g_dwPhysCyl,
          ', hds = ',g_dbPhysHd,
          ', secs = ',g_dbPhysSec);
  WriteLn('Disk ',g_dbUserDriveSRC-aPhysHardDisk0,
          ' geometry (std): total sectors = ',
           (longint(g_dwPhysCyl) * g_dbPhysHd * g_dbPhysSec) );


  {-Select target disks-}
  g_LiveDisks := 0;
  FOR  g_dbIndex := MIN_DISK_NUM  TO  MAX_DISK_NUM  DO
  BEGIN
     g_dbUserDriveTGT := aPhysHardDisk0 + g_dbIndex;
     IF  ( (g_dbUserDriveSRC <> g_dbUserDriveTGT) AND
           (g_dbIndex < g_dbPhysDisks))
       THEN  BEGIN
         Write('Physical drive ',g_dbIndex,' is TARGET? (Y/N) [Y]: ');
         ReadLn(g_sUserInput);
         IF  (g_sUserInput = '')
           THEN   g_sUserInput := 'Y';
         {if-then}
         g_sUserInput[1] := System.UpCase(g_sUserInput[1]);
         IF (g_sUserInput[1] = 'Y')
           THEN BEGIN
             g_DrivesDefArr[g_dbIndex].dbPhysDrive := g_dbUserDriveTGT;
             g_DrivesDefArr[g_dbIndex].fCopyToThisDrv := System.TRUE;
             System.Inc(g_LiveDisks);
                END;
         {if-then}
              END;
     {if-then}
  END;
  {for-to-do}
  IF  (g_LiveDisks = 0)
    THEN  BEGIN
      Writeln('ERROR: you not specified target drives.');
      Halt(6);
          END;
  {if-then}

  {-Display source and targets-}
  WriteLn('SOURCE drive: ',g_dbUserDriveSRC-aPhysHardDisk0);
  Write('TARGET drives: ');
  FOR  g_dbIndex := MIN_DISK_NUM  TO  MAX_DISK_NUM  DO
  BEGIN
     IF (g_DrivesDefArr[g_dbIndex].dbPhysDrive <> $FF)
       THEN  BEGIN
         Write(g_dbIndex);
         IF (g_dbIndex < g_dbPhysDisks-1)
           THEN  Write(', ');
             END;
     {if-then}
  END;
  {for-to-do}
  WriteLn;

  {-Init start,end value-}
{$IFDEF   EmulStartBlockNum }
  g_liStartBlockNum :=  8884008;             {my disk ARC_CDR}
{$ELSE}
  g_liStartBlockNum := 0;
{$ENDIF   EmulStartBlockNum }
  g_liCurBlockNum := g_liStartBlockNum;
{$IFDEF   EmulEndBlockNum }
  g_liEndBlockNum :=   10940264;              {my disk ARC_CDR}
{$ELSE}
  g_liEndBlockNum := (longint(g_dwPhysCyl) * g_dbPhysHd * g_dbPhysSec)-1;
{$ENDIF   EmulEndBlockNum }

  IF (g_fEBiosInUse)
    THEN  BEGIN
      g_liEndBlockNum := g_recEDP_ParmSRC.liTotalSectorsLo-1;
      _SetQuadValue(g_qwBigSecNumStart,0);
      _SetQuadValue(g_qwBigSecNumCur,0);
      _SetQuadValue(g_qwBigSecNumEnd,0);
      WriteLn('Disk ',g_dbUserDriveSRC-aPhysHardDisk0,
              ' geometry (EDP): total sectors = ',
                      g_recEDP_ParmSRC.liTotalSectorsLo,
                ',' , g_recEDP_ParmSRC.liTotalSectorsHi );
      g_dbStartSec := (g_liStartBlockNum MOD g_liPhysSecs) + 1;
      g_liTemp := (g_liStartBlockNum) DIV g_liPhysSecs;
      g_dbStartHd := g_liTemp MOD g_liPhysHeads;
      g_dwStartCyl := g_liTemp DIV g_liPhysHeads;
      WriteLn('Start (C,H,S): ',g_dwStartCyl,',',g_dbStartHd,',',g_dbStartSec);
      {g_liPhysCyls}
      g_dbEndSec := (g_liEndBlockNum MOD g_liPhysSecs) + 1;
      g_liTemp := (g_liEndBlockNum) DIV g_liPhysSecs;
      g_dbEndHd := g_liTemp MOD g_liPhysHeads;
      g_dwEndCyl := g_liTemp DIV g_liPhysHeads;
      WriteLn('End (C,H,S): ',g_dwEndCyl,',',g_dbEndHd,',',g_dbEndSec);
          END
    ELSE  BEGIN
      WriteLn('(STD) Start block = ',g_liStartBlockNum,
              ';  End block = ',g_liEndBlockNum);
      g_dbStartSec := (g_liStartBlockNum MOD g_dbPhysSec) + 1;
      g_liTemp := (g_liStartBlockNum) DIV g_dbPhysSec;
      g_dbStartHd := g_liTemp MOD g_dbPhysHd;
      g_dwStartCyl := g_liTemp DIV g_dbPhysHd;
      WriteLn('Start (C,H,S): ',g_dwStartCyl,',',g_dbStartHd,',',g_dbStartSec);

      g_dbEndSec := (g_liEndBlockNum MOD g_dbPhysSec) + 1;
      g_liTemp := (g_liEndBlockNum) DIV g_dbPhysSec;
      g_dbEndHd := g_liTemp MOD g_dbPhysHd;
      g_dwEndCyl := g_liTemp DIV g_dbPhysHd;
      WriteLn('End (C,H,S): ',g_dwEndCyl,',',g_dbEndHd,',',g_dbEndSec);
          END;
  {if-then-else}

  {-Select transfer block value-}
  Write('Enter # of sectors per transfer block (1..127) [126]: ');
  ReadLn(g_sUserInput);
  IF (g_sUserInput = '')
    THEN  g_sUserInput := '126';
  {if-then}
  System.Val(g_sUserInput,g_dbBlocksRead,g_iErrCode);
  IF  ( (g_iErrCode <> 0) OR NOT(g_dbBlocksRead IN [1..127]) )
    THEN  BEGIN
      Writeln('ERROR: You specified wrong sectors count to transfer.');
      GOTO 98;
          END;
  {if-then}

  {-Allocate read cache-}
  WriteLn('Allocate memory (64 KB) for read cache buffer.');
  IF  ( _fnbAllocLowMemBlock(MAX_DOS_BLK_SIZ_PARAS,g_lpReadCacheBuf) = FALSE )
    THEN BEGIN
       WriteLn('ERROR: cannot allocate memory for read cache buffer!');
       Halt(2);
         END;
  {if-then}

  WriteLn('Zeroes memory.');
  FillChar(Mem[Seg(g_lpReadCacheBuf^):Ofs(g_lpReadCacheBuf^)],MAX_BLK_FILL_SIZ,0);

  {-Verify EBIOS traslation-}
  IF (g_fEBiosInUse)
    THEN  BEGIN
      Write('Enable EBIOS translation check (Y,N) [N]: ');
      ReadLn(g_sUserInput);
      IF (g_sUserInput = '')
        THEN  g_sUserInput := 'N';
      {if-then}
      g_chVerifyAllDisk := System.UpCase(g_sUserInput[1]);
      IF  NOT( g_chVerifyAllDisk IN ['Y','N'] )
        THEN  BEGIN
          Writeln('ERROR: You specified wrong selecton, please be patient!');
          GOTO 98;
              END;
      {if-then}
      IF (g_chVerifyAllDisk = 'Y' )
        THEN g_fVerifyTranslation := System.True;
      {if-then}
      IF (g_fVerifyTranslation)
         THEN BEGIN
           WriteLn('Allocate memory (64 KB) for STD BIOS read buffer.');
           IF  ( _fnbAllocLowMemBlock(MAX_DOS_BLK_SIZ_PARAS,g_lpReadVerBufStd) = FALSE )
             THEN BEGIN
                WriteLn('ERROR: cannot allocate memory for STD BIOS read cache buffer!');
                Halt(9);
                  END;
           {if-then}
           WriteLn('Zeroes memory.');
           FillChar(Mem[Seg(g_lpReadVerBufStd^):Ofs(g_lpReadVerBufStd^)],MAX_BLK_FILL_SIZ,0);
              END;
      {if-then}
          END;
  {if-then}

  {-Maybe,verify?-}
  Write('Enable verifying of disk after copying completion (Y,N) [N]: ');
  ReadLn(g_sUserInput);
  IF (g_sUserInput = '')
    THEN  g_sUserInput := 'N';
  {if-then}
  g_chVerifyAllDisk := System.UpCase(g_sUserInput[1]);
  IF  NOT( g_chVerifyAllDisk IN ['Y','N'] )
    THEN  BEGIN
      Writeln('ERROR: You specified wrong selecton, please be patient!');
      GOTO 98;
          END;
  {if-then}
  IF (g_chVerifyAllDisk = 'Y' )
    THEN BEGIN
      FOR  g_dbIndex := MIN_DISK_NUM TO MAX_DISK_NUM DO
      BEGIN
           IF  ( g_DrivesDefArr[g_dbIndex].fCopyToThisDrv )
             THEN  BEGIN
               g_DrivesDefArr[g_dbIndex].fVerifyThisDrv := System.TRUE;
               WriteLn('Allocate memory (64 KB) for verifying buffer.');
               IF  ( _fnbAllocLowMemBlock(MAX_DOS_BLK_SIZ_PARAS,
                         g_DrivesDefArr[g_dbIndex].lpReadBackBuf) = FALSE )
                 THEN BEGIN
                    WriteLn('ERROR: cannot allocate memory for verifying buffer!');
                    Halt(3);
                      END;
               {if-then}
               WriteLn('Zeroes memory.');
               FillChar(Mem[Seg(g_DrivesDefArr[g_dbIndex].lpReadBackBuf^):
                            Ofs(g_DrivesDefArr[g_dbIndex].lpReadBackBuf^)],MAX_BLK_FILL_SIZ,0);
                   END;
           {if-then}
      END;
      {for-to-do}
         END;
  {if-then}

  {-Want logfile?-}
  Write('Enter logfile name (default=none): ');
  ReadLn(g_sUserInput);
  IF  (g_sUserInput <> '')
    THEN BEGIN
      g_fWriteLogFile := System.True;
      Assign(g_LogFile,g_sUserInput);
      SetTextBuf(g_LogFile,g_TextBuf);
      Rewrite(g_LogFile);
         END;
  {if-then}

  {-Bye,bye my disks!-}
  Write('Press <CR> to start copy or type any string to exit.');
  ReadLn(g_sUserInput);
  IF  ( g_sUserInput <> '' )
    THEN  BEGIN
      WriteLn('WARN: Terminated by user!');
      GOTO 99;
          END;
  {if-then}

  {-Set initial copy process values-}
  g_fCopyNotDone := TRUE;
  g_dbElapsedHour := 0;
  g_dbElapsedMin  := 0;
  g_dbElapsedSec  := 0;
  g_dbActualBlocksRW := g_dbBlocksRead;

  g_InitTimeTicks := _fnliGetCurBIOStimeTicks;

  WHILE  (g_fCopyNotDone) DO
  BEGIN
      {-Do a read-}
      IF (g_fEBiosInUse)
        THEN  BEGIN
          g_dbCurSec := (g_liCurBlockNum MOD g_liPhysSecs) + 1;
          g_liTemp := (g_liCurBlockNum) DIV g_liPhysSecs;
          g_dbCurHd := g_liTemp MOD g_liPhysHeads;
          g_dwCurCyl := g_liTemp DIV g_liPhysHeads;
          System.Move( g_qwBigSecNumCur, g_liTemp, sizeof(g_liTemp) );
          IF (g_liTemp <> g_liCurBlockNum)
            THEN BEGIN
              WriteLn;
              WriteLn(#13#10,'ERROR:  quadword = ', g_liTemp,
                   ' , longint = ', g_liCurBlockNum);
              goto 99;
                 END;
          {if-then}
              END
        ELSE  BEGIN
          g_dbCurSec := (g_liCurBlockNum MOD g_dbPhysSec) + 1;
          g_liTemp := (g_liCurBlockNum) DIV g_dbPhysSec;
          g_dbCurHd := g_liTemp MOD g_dbPhysHd;
          g_dwCurCyl := g_liTemp DIV g_dbPhysHd;
              END;
      {if-then-else}
      g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
      g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
      _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                       g_dbElapsedMin,g_dbElapsedSec);

      g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                       g_dbElapsedSec);
      g_chOpStatus := 'R';
      Write('Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
            '  Cyl: ',g_dwCurCyl:5,
            '  Hd: ',g_dbCurHd:3,
            '  Sec: ',g_dbCurSec:2,
            '  Blks: ',g_dbActualBlocksRW:3,
            '  Op: ',g_chOpStatus,
            '  ETim> ',g_sElapsedTime,
            #13);
(*
      IF NOT(_fnbReadDiskSectors(g_dbUserDriveSRC, g_dwCurCyl,
                                g_dbCurHd, g_dbCurSec, g_dbActualBlocksRW,
                                g_lpReadCacheBuf) )
*)
      IF NOT(_fnbReadDiskSectorsBig( g_dbUserDriveSRC, g_dwCurCyl,
                              g_dbCurHd, g_dbCurSec, g_dbActualBlocksRW,
                                 g_lpReadCacheBuf, g_fEBiosInUse,
                                 g_EDP_Pkt_Read, g_qwBigSecNumCur) )
        THEN  BEGIN
           WriteLn(#13#10,'ERROR: read disk status = ', g_dbDiskError,
                   ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
           WriteLn(#7#7#7'Fatal termination!');
           IF  ( g_fWriteLogFile = System.True )
             THEN BEGIN
               {$I-}
               WriteLn(g_LogFile,'Read error: ',_fnsGetDiskErrDesc(g_dbDiskError));
               WriteLn(g_LogFile,'Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                     '  Cyl: ',g_dwCurCyl:5,
                     '  Hd: ',g_dbCurHd:3,
                     '  Sec: ',g_dbCurSec:2,
                     '  Blks: ',g_dbActualBlocksRW:3);
               {$I+}
                  END;
           {if-then}
           GOTO 99;
              END;
      {if-then}
      {-Check translation by read using both STDBIOS and EBIOS-}
      IF ((g_fVerifyTranslation) AND (g_fEBiosInUse))
         THEN BEGIN
            g_dbCurSecSTD := (g_liCurBlockNum MOD g_dbPhysSec) + 1;
            g_liTemp := (g_liCurBlockNum) DIV g_dbPhysSec;
            g_dbCurHdSTD := g_liTemp MOD g_dbPhysHd;
            g_dwCurCylSTD := g_liTemp DIV g_dbPhysHd;
            IF NOT(_fnbReadDiskSectors(g_dbUserDriveSRC, g_dwCurCylSTD,
                                       g_dbCurHdSTD, g_dbCurSecSTD,
                                       g_dbActualBlocksRW, g_lpReadVerBufStd) )
              THEN BEGIN
                WriteLn(#13#10,'ERROR: read disk status (std) = ', g_dbDiskError,
                        ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
                WriteLn(#7#7#7'Fatal termination!');
                goto 99;
                   END
              ELSE BEGIN
                {-Now compare buffers-}
                ASM
                      xor     cx, cx
                      mov     ax, aDiskSectorSiz SHR 1
                      mov     cl, g_dbActualBlocksRW
                      mul     cx
                      mov     cx, ax
                      mov     dx, ds
                      les     di, g_lpReadVerBufStd
                      lds     si, g_lpReadCacheBuf
                      cld
                      mov     al, System.TRUE
                      rep     cmpsw
                      je     @Done
                      mov     g_dwMismatchOfs, si
                      mov     al, System.FALSE
                  @Done:
                      mov     ds, dx
                      mov     g_fSameContents, al
                END;
                {asm-end}
                IF  (g_fSameContents = System.FALSE )
                  THEN  BEGIN
                     WriteLn( #13#10#7#7#7, 'ERROR (EBIOS chk): mismatch found at offset = ',
                              g_dwMismatchOfs );
                     WriteLn(#7#7#7'Fatal termination!');
                     goto 99;
                        END;
                   END;
            {if-then-else}
              END;
      {if-then}

      {-Do a write-}
      IF  (g_fDoWrite = TRUE)
        THEN  BEGIN
          FOR  g_dbIndex := MIN_DISK_NUM  TO  MAX_DISK_NUM  DO
          BEGIN
             IF  (g_DrivesDefArr[g_dbIndex].fCopyToThisDrv = System.TRUE)
               THEN  BEGIN
                 g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
                 g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
                 _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                                  g_dbElapsedMin,g_dbElapsedSec);

                 g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                                  g_dbElapsedSec);
                 g_chOpStatus := 'W';
                 Write('Drv: ',g_dbIndex:1,
                       '  Cyl: ',g_dwCurCyl:5,
                       '  Hd: ',g_dbCurHd:3,
                       '  Sec: ',g_dbCurSec:2,
                       '  Blks: ',g_dbActualBlocksRW:3,
                       '  Op: ',g_chOpStatus,
                       '  ETim> ',g_sElapsedTime,
                       #13);
(*
                 IF NOT(_fnbWriteDiskSectors(g_DrivesDefArr[g_dbIndex].dbPhysDrive,
                                           g_dwCurCyl, g_dbCurHd, g_dbCurSec,
                                           g_dbActualBlocksRW,
                                           g_lpReadCacheBuf) )
*)
                 IF NOT( _fnbWriteDiskSectorsBig(g_DrivesDefArr[g_dbIndex].dbPhysDrive,
                                           g_dwCurCyl, g_dbCurHd, g_dbCurSec,
                                           g_dbActualBlocksRW, g_lpReadCacheBuf,
                                           g_fEBiosInUse, g_EDP_Pkt_Write,
                                           g_qwBigSecNumCur) )
                   THEN  BEGIN
                      WriteLn(#13#10#7#7#7,'ERROR: write disk status = ', g_dbDiskError,
                              ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
                      g_DrivesDefArr[g_dbIndex].fCopyToThisDrv := System.False;
                      g_DrivesDefArr[g_dbIndex].fVerifyThisDrv:= System.False;
                      IF  ( g_fWriteLogFile = System.True )
                        THEN BEGIN
                          {$I-}
                          WriteLn(g_LogFile,'Write error: ',_fnsGetDiskErrDesc(g_dbDiskError));
                          WriteLn(g_LogFile,'Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                                '  Cyl: ',g_dwCurCyl:5,
                                '  Hd: ',g_dbCurHd:3,
                                '  Sec: ',g_dbCurSec:2,
                                '  Blks: ',g_dbActualBlocksRW:3);
                          {$I+}
                             END;
                      {if-then}
                      System.Dec(g_LiveDisks);
                      IF  (g_LiveDisks = 0)
                        THEN  BEGIN
                          WriteLn('Sorry, no more good disks to copy.');
                          Goto 99;
                              END;
                      {if-then}
                         END;
                 {if-then}
                     END;
             {if-then}
          END;
          {for-to-do}
              END;
      {if-then}

      {-Check terminate condition-}
      g_liCurBlockNum := g_liCurBlockNum + g_dbBlocksRead;
      IF (g_fEBiosInUse)
        THEN _AddLongToQuad( g_qwBigSecNumCur, g_dbBlocksRead);
      {if-then}
      IF  ( g_liCurBlockNum > g_liEndBlockNum)
         THEN  BEGIN
           g_fCopyNotDone := FALSE;
           WriteLn(#13#10#7,'Copy successfully complete.');
           IF  ( g_fWriteLogFile = System.True )
             THEN BEGIN
                g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
                g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
                _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                                 g_dbElapsedMin,g_dbElapsedSec);
                g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                                 g_dbElapsedSec);
               {$I-}
               WriteLn(g_LogFile,'Total writing time: ',g_sElapsedTime);
               WriteLn(g_LogFile,'No errors encountered during writing process.');
               {$I+}
                  END;
           {if-then}

               END
         ELSE  BEGIN
           IF  ( (g_liEndBlockNum - g_liCurBlockNum+1) < g_dbBlocksRead )
             THEN  g_dbActualBlocksRW := g_liEndBlockNum - g_liCurBlockNum+1;
           {if-then}
               END;
       {if-then-else}

  END;
  {while-do}

  {-Time to verify!-}
  IF ( (g_chVerifyAllDisk = 'Y')  AND (g_LiveDisks <> 0) )
    THEN BEGIN
      g_fVerifyNotDone := TRUE;
      g_dbElapsedHour := 0;
      g_dbElapsedMin  := 0;
      g_dbElapsedSec  := 0;
      g_dbActualBlocksRW := g_dbBlocksRead;
      g_liCurBlockNum := g_liStartBlockNum;
      IF (g_fEBiosInUse)
        THEN _SetQuadValue(g_qwBigSecNumCur,0);
      {if-then}

      g_InitTimeTicks := _fnliGetCurBIOStimeTicks;

      WHILE  (g_fVerifyNotDone) DO
      BEGIN
          {-Do a read-}
          IF (g_fEBiosInUse)
            THEN  BEGIN
              g_dbCurSec := (g_liCurBlockNum MOD g_liPhysSecs) + 1;
              g_liTemp := (g_liCurBlockNum) DIV g_liPhysSecs;
              g_dbCurHd := g_liTemp MOD g_liPhysHeads;
              g_dwCurCyl := g_liTemp DIV g_liPhysHeads;
                  END
            ELSE  BEGIN
              g_dbCurSec := (g_liCurBlockNum MOD g_dbPhysSec) + 1;
              g_liTemp := (g_liCurBlockNum) DIV g_dbPhysSec;
              g_dbCurHd := g_liTemp MOD g_dbPhysHd;
              g_dwCurCyl := g_liTemp DIV g_dbPhysHd;
              END;
          {if-then-else}

          g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
          g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
          _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                           g_dbElapsedMin,g_dbElapsedSec);

          g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                           g_dbElapsedSec);
          g_chOpStatus := 'R';
          Write('Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                '  Cyl: ',g_dwCurCyl:5,
                '  Hd: ',g_dbCurHd:3,
                '  Sec: ',g_dbCurSec:2,
                '  Blks: ',g_dbActualBlocksRW:3,
                '  Op: ',g_chOpStatus,
                '  ETim> ',g_sElapsedTime,
                #13);
(*
          IF NOT(_fnbReadDiskSectors(g_dbUserDriveSRC, g_dwCurCyl,
                                    g_dbCurHd, g_dbCurSec, g_dbActualBlocksRW,
                                    g_lpReadCacheBuf) )
*)
          IF NOT(_fnbReadDiskSectorsBig(g_dbUserDriveSRC, g_dwCurCyl,
                                        g_dbCurHd, g_dbCurSec, g_dbActualBlocksRW,
                                        g_lpReadCacheBuf, g_fEBiosInUse,
                                        g_EDP_Pkt_Read, g_qwBigSecNumCur) )
            THEN  BEGIN
               WriteLn(#13#10,'ERROR: read disk status = ', g_dbDiskError,
                              ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
               WriteLn(#7#7#7'Fatal termination!');
               IF  ( g_fWriteLogFile = System.True )
                 THEN BEGIN
                   {$I-}
                   WriteLn(g_LogFile,'Read error: ',_fnsGetDiskErrDesc(g_dbDiskError));
                   WriteLn(g_LogFile,'Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                         '  Cyl: ',g_dwCurCyl:5,
                         '  Hd: ',g_dbCurHd:3,
                         '  Sec: ',g_dbCurSec:2,
                         '  Blks: ',g_dbActualBlocksRW:3);
                   {$I+}
                      END;
               {if-then}
               GOTO 99;
                  END;
          {if-then}

          {-Read targes and compare w/source-}
          FOR  g_dbIndex := MIN_DISK_NUM  TO  MAX_DISK_NUM  DO
          BEGIN
             IF  (g_DrivesDefArr[g_dbIndex].fVerifyThisDrv = System.TRUE)
               THEN  BEGIN
                 g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
                 g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
                 _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                                  g_dbElapsedMin,g_dbElapsedSec);
                 g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour,
                                                  g_dbElapsedMin,
                                                  g_dbElapsedSec);
                 g_chOpStatus := 'R';
                 Write('Drv: ',g_dbIndex:1,
                       '  Cyl: ',g_dwCurCyl:5,
                       '  Hd: ',g_dbCurHd:3,
                       '  Sec: ',g_dbCurSec:2,
                       '  Blks: ',g_dbActualBlocksRW:3,
                       '  Op: ',g_chOpStatus,
                       '  ETim> ',g_sElapsedTime,
                       #13);
                 g_lpReadVerBufTmp := g_DrivesDefArr[g_dbIndex].lpReadBackBuf;
(*
                 IF NOT(_fnbReadDiskSectors(g_DrivesDefArr[g_dbIndex].dbPhysDrive,
                                           g_dwCurCyl, g_dbCurHd, g_dbCurSec,
                                           g_dbActualBlocksRW,
                                           g_lpReadVerBufTmp) )
*)
                 IF NOT(_fnbReadDiskSectorsBig(g_DrivesDefArr[g_dbIndex].dbPhysDrive,
                                           g_dwCurCyl, g_dbCurHd, g_dbCurSec,
                                           g_dbActualBlocksRW, g_lpReadVerBufTmp,
                                           g_fEBiosInUse, g_EDP_Pkt_Write,
                                           g_qwBigSecNumCur) )
                   THEN  BEGIN
                      WriteLn(#13#10#7#7#7,'ERROR: verify disk status (read) = ', g_dbDiskError,
                              ' (',_fnsGetDiskErrDesc(g_dbDiskError),')');
                      g_DrivesDefArr[g_dbIndex].fVerifyThisDrv:= System.False;
                      IF  ( g_fWriteLogFile = System.True )
                        THEN BEGIN
                          {$I-}
                          WriteLn(g_LogFile,'Read error: ',_fnsGetDiskErrDesc(g_dbDiskError));
                          WriteLn(g_LogFile,'Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                                '  Cyl: ',g_dwCurCyl:5,
                                '  Hd: ',g_dbCurHd:3,
                                '  Sec: ',g_dbCurSec:2,
                                '  Blks: ',g_dbActualBlocksRW:3);
                          {$I+}
                             END;
                      {if-then}
                      System.Dec(g_LiveDisks);
                      IF  (g_LiveDisks = 0)
                        THEN  BEGIN
                          WriteLn('Sorry, no more good disks to verify.');
                          Goto 99;
                              END;
                      {if-then}
                         END;
                 {if-then}
{$IFDEF   EnableCompareVersion }
                 {-Now compare buffers-}
                 ASM
                       xor     cx, cx
                       mov     ax, aDiskSectorSiz SHR 1
                       mov     cl, g_dbActualBlocksRW
                       mul     cx
                       mov     cx, ax
                       mov     dx, ds
                       les     di, g_lpReadVerBufTmp
                       lds     si, g_lpReadCacheBuf
                       cld
                       mov     al, System.TRUE
                       rep     cmpsw
                       je     @Done
                       mov     al, System.FALSE
                   @Done:
                       mov     ds, dx
                       mov     g_fSameContents, al
                 END;
                 {asm-end}
                 IF  (g_fSameContents = System.FALSE )
                   THEN  BEGIN
                      WriteLn(#13#10#7#7#7,'ERROR: mismatch found at comparing.');
                       g_DrivesDefArr[g_dbIndex].fVerifyThisDrv:= System.False;
                       IF  ( g_fWriteLogFile = System.True )
                         THEN BEGIN
                           {$I-}
                           WriteLn(g_LogFile,'Compare error encountered.');
                           WriteLn(g_LogFile,'Drv: ',(g_dbUserDriveSRC-aPhysHardDisk0):1,
                                 '  Cyl: ',g_dwCurCyl:5,
                                 '  Hd: ',g_dbCurHd:3,
                                 '  Sec: ',g_dbCurSec:2,
                                 '  Blks: ',g_dbActualBlocksRW:3);
                           {$I+}
                              END;
                       {if-then}
                       System.Dec(g_LiveDisks);
                       IF  (g_LiveDisks = 0)
                         THEN  BEGIN
                           WriteLn('Sorry, no more good disks to verify.');
                           Goto 99;
                               END;
                       {if-then}
                         END;
                 {if-then}
{$ELSE}
    (* Just skip it! *)
{$ENDIF   EnableCompareVersion }
                     END;
             {if-then}
          END;
          {for-to-do}

          {-Test termination condition-}
          g_liCurBlockNum := g_liCurBlockNum + g_dbBlocksRead;
          IF (g_fEBiosInUse)
            THEN _AddLongToQuad( g_qwBigSecNumCur, g_dbBlocksRead);
          {if-then}
          IF  ( g_liCurBlockNum > g_liEndBlockNum)
             THEN  BEGIN
               g_fVerifyNotDone := FALSE;
               WriteLn(#13#10#7,'Verifying successfully complete.');
               IF  ( g_fWriteLogFile = System.True )
                 THEN BEGIN
                    g_DiffTimeTicks := _fnliGetCurBIOStimeTicks;
                    g_DiffTimeTicks := g_DiffTimeTicks - g_InitTimeTicks;
                    _GetCurTimeNoSrc(g_DiffTimeTicks, g_dbElapsedHour,
                                     g_dbElapsedMin,g_dbElapsedSec);
                    g_sElapsedTime := _fnsGetTimeStr(g_dbElapsedHour, g_dbElapsedMin,
                                                     g_dbElapsedSec);
                   {$I-}
                   WriteLn(g_LogFile,'Total verifying time: ',g_sElapsedTime);
                   WriteLn(g_LogFile,'No errors encountered during verifying process.');
                   {$I+}
                      END;
               {if-then}
                   END
             ELSE  BEGIN
               IF  ( (g_liEndBlockNum - g_liCurBlockNum+1) < g_dbBlocksRead )
                 THEN  g_dbActualBlocksRW := g_liEndBlockNum - g_liCurBlockNum+1;
               {if-then}
                   END;
           {if-then-else}

      END;
      {while-do}
         END;
  {if-then}

99:
  {-Exit point 1-}
  IF  ( g_fWriteLogFile = System.True )
    THEN BEGIN
      Close(g_LogFile);
         END;
  {if-then}

  FOR  g_dbIndex := MIN_DISK_NUM TO MAX_DISK_NUM DO
  BEGIN
       IF  ( g_DrivesDefArr[g_dbIndex].lpReadBackBuf <> NIL)
         THEN  BEGIN
           WriteLn('Free memory (64 KB) for verifying buffer.');
           IF ( _fnbReleaseLowMemBlock( Seg(g_DrivesDefArr[g_dbIndex].lpReadBackBuf^) ) = FALSE )
             THEN  WriteLn('WARN: cannot free memory for verifying buffer!');
           {if-then}
               END;
       {if-then}
  END;
  {for-to-do}

98:
  {-Exit point 2-}
  IF (g_fVerifyTranslation)
     THEN BEGIN
       WriteLn('Free memory (64 KB) for read translation check buffer.');
       IF ( _fnbReleaseLowMemBlock( Seg(g_lpReadVerBufStd^) ) = FALSE )
         THEN  BEGIN
           WriteLn('WARN: cannot free memory for read translation check buffer!');
               END;
       {if-then}
          END;
  {if-then}

  WriteLn('Free memory (64 KB) for read cache buffer.');
  IF ( _fnbReleaseLowMemBlock( Seg(g_lpReadCacheBuf^) ) = FALSE )
    THEN  BEGIN
      WriteLn('WARN: cannot free memory for read cache buffer!');
          END;
  {if-then}

  Writeln('Done.');

END.


(*
<<<<<<<<<<<<<< The following info extracted from
<<<<<<<<<<<<<< Ralf Brown Interrupt List v6.0

--------d-1341--BX55AA-----------------------
INT 13 - IBM/MS INT 13 Extensions - INSTALLATION CHECK
	AH = 41h
	BX = 55AAh
	DL = drive (80h-FFh)
Return: CF set on error (extensions not supported)
	    AH = 01h (invalid function)
	CF clear if successful
	    BX = AA55h if installed
	    AH = major version of extensions
		01h = 1.x
		20h = 2.0 / EDD-1.0
		21h = 2.1 / EDD-1.1
		30h = EDD-3.0
	    AL = internal use
	    CX = API subset support bitmap (see #00271)
	    DH = extension version (v2.0+ ??? -- not present in 1.x)
Note:	the Phoenix Enhanced Disk Drive Specification v1.0 uses version 2.0 of
	  the INT 13 Extensions API
SeeAlso: AH=42h"INT 13 Ext",AH=48h"INT 13 Ext"

Bitfields for IBM/MS INT 13 Extensions API support bitmap:
Bit(s)	Description	(Table 00271)
 0	extended disk access functions (AH=42h-44h,47h,48h) supported
 1	removable drive controller functions (AH=45h,46h,48h,49h,INT 15/AH=52h)
	  supported
 2	enhanced disk drive (EDD) functions (AH=48h,AH=4Eh) supported
	extended drive parameter table is valid (see #00273,#00278)
 3-15	reserved (0)
--------d-1342-------------------------------
INT 13 - IBM/MS INT 13 Extensions - EXTENDED READ
	AH = 42h
	DL = drive number
	DS:SI -> disk address packet (see #00272)
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code (see #00234)
	    disk address packet's block count field set to number of blocks
	      successfully transferred
SeeAlso: AH=02h,AH=41h"INT 13 Ext",AH=43h"INT 13 Ext"

Format of disk address packet:
Offset	Size	Description	(Table 00272)
 00h	BYTE	10h (size of packet)
 01h	BYTE	reserved (0)
 02h	WORD	number of blocks to transfer (max 007Fh for Phoenix EDD)
 04h	DWORD	-> transfer buffer
 08h	QWORD	starting absolute block number
		(for non-LBA devices, compute as
		  (Cylinder*NumHeads + SelectedHead) * SectorPerTrack +
		  SelectedSector - 1
--------d-1343-------------------------------
INT 13 - IBM/MS INT 13 Extensions - EXTENDED WRITE
	AH = 43h
	AL = write flags
	   ---v1.0,2.0---
	   bit 0: verify write
	   bits 7-1 reserved (0)
	   ---v2.1+ ---
	   00h,01h write without verify
	   02h write with verify
	DL = drive number
	DS:SI -> disk address packet (see #00272)
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code (see #00234)
	    disk address packet's block count field set to number of blocks
	      successfully transferred
Note:	the BIOS returns CF set/AH=01h (invalid function) if verify is
	  requested but not supported
SeeAlso: AH=03h,AH=41h"INT 13 Ext",AH=42h"INT 13 Ext",AH=44h
--------d-1344-------------------------------
INT 13 - IBM/MS INT 13 Extensions - VERIFY SECTORS
	AH = 44h
	DL = drive number
	DS:SI -> disk address packet (see #00272)
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code (see #00234)
	    disk address packet's block count field set to number of blocks
	      successfully verified
SeeAlso: AH=04h,AH=41h"INT 13 Ext",AH=42h"INT 13 Ext",AH=47h
--------d-1345-------------------------------
INT 13 - IBM/MS INT 13 Extensions - LOCK/UNLOCK DRIVE
	AH = 45h
	AL = operation
	    00h lock media in drive
	    01h unlock media
	    02h check lock status
	DL = drive number
Return: CF clear if successful
	    AH = 00h
	    AL = lock state (00h = unlocked)
	CF set on error
	    AH = error code (see #00234)
Notes:	this function is required to be supported for any removable drives
	  numbered 80h or higher
	up to 255 locks may be placed on a drive, and the media will not
	  be physically unlocked until all locks have been removed
SeeAlso: AH=41h"INT 13 Ext",AH=46h,AH=49h,INT 15/AH=52h"INT 13 Extensions"
--------d-1346-------------------------------
INT 13 - IBM/MS INT 13 Extensions - EJECT MEDIA
	AH = 46h
	AL = 00h (reserved)
	DL = drive number
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code (see #00234)
SeeAlso: AH=49h,INT 15/AH=52h"INT 13 Extensions"
--------d-1347-------------------------------
INT 13 - IBM/MS INT 13 Extensions - EXTENDED SEEK
	AH = 47h
	DL = drive number
	DS:SI -> disk address packet (see #00272)
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code (see #00234)
SeeAlso: AH=0Ch,AH=42h"INT 13 Ext"
--------d-1348-------------------------------
INT 13 - IBM/MS INT 13 Extensions - GET DRIVE PARAMETERS
	AH = 48h
	DL = drive (80h-FFh)
	DS:SI -> buffer for drive parameters (see #00273)
Return: CF clear if successful
	    AH = 00h
	    DS:SI buffer filled
	CF set on error
	    AH = error code (see #00234)
BUG:	several different Compaq BIOSes incorrectly report high-numbered
	  drives (such as 90h, B0h, D0h, and F0h) as present, giving them the
	  same geometry as drive 80h; as a workaround, scan through disk
	  numbers, stopping as soon as the number of valid drives encountered
	  equals the value in 0040h:0075h
SeeAlso: AH=08h,AH=41h,AH=49h,MEM 0040h:0075h

Format of IBM/MS INT 13 Extensions drive parameters:
Offset	Size	Description	(Table 00273)
 00h	WORD	(call) size of buffer
		    (001Ah for v1.x, 001Eh for v2.x, 42h for v3.0)
		(ret) size of returned data
 02h	WORD	information flags (see #00274)
 04h	DWORD	number of physical cylinders on drive
 08h	DWORD	number of physical heads on drive
 0Ch	DWORD	number of physical sectors per track
 10h	QWORD	total number of sectors on drive
 18h	WORD	bytes per sector
---v2.0+ ---
 1Ah	DWORD	-> EDD configuration parameters (see #00278)
		FFFFh:FFFFh if not available
---v3.0 ---
 1Eh	WORD	signature BEDDh to indicate presence of Device Path info
 20h	BYTE	length of Device Path information, including signature and this
		  byte (24h for v3.0)
 21h  3 BYTEs	reserved (0)
 24h  4 BYTEs	ASCIZ name of host bus ("ISA" or "PCI")
 28h  8 BYTEs	ASCIZ name of interface type
		"ATA"
		"ATAPI"
		"SCSI"
		"USB"
		"1394" IEEE 1394 (FireWire)
		"FIBRE" Fibre Channel
 30h  8 BYTEs	Interface Path (see #00275)
 38h  8 BYTEs	Device Path (see #00276)
 40h	BYTE	reserved (0)
 41h	BYTE	checksum of bytes 1Eh-40h (two's complement of sum, which makes
		  the 8-bit sum of bytes 1Eh-41h equal 00h)
Note:	if the size is less than 30 on call, the final DWORD will not be
	  returned by a v2.x implementation; similarly for the Device Path info
SeeAlso: #00277,#03196

Bitfields for IBM/MS INT 13 Extensions information flags:
Bit(s)	Description	(Table 00274)
 0	DMA boundary errors handled transparently
 1	cylinder/head/sectors-per-track information is valid
 2	removable drive
 3	write with verify supported
 4	drive has change-line support (required if drive >= 80h is removable)
 5	drive can be locked (required if drive >= 80h is removable)
 6	CHS information set to maximum supported values, not current media
 15-7	reserved (0)
SeeAlso: #00273

Format of EDD v3.0 Interface Path:
Offset	Size	Description	(Table 00275)
---ISA---
 00h	WORD	16-bit base address
 02h  6 BYTEs	reserved (0)
---PCI---
 00h	BYTE	PCI bus number
 01h	BYTE	PCI device number
 02h	BYTE	PCI function number
 03h  5 BYTEs	reserved (0)
SeeAlso: #00273,#00276

Format of EDD v3.0 Device Path:
Offset	Size	Description	(Table 00276)
---ATA---
 00h	BYTE	flag: 00h = master, 01h = slave
 01h  7 BYTEs	reserved (0)
---ATAPI---
 00h	BYTE	flag: 00h = master, 01h = slave
 01h	BYTE	logical unit number
 02h  6 BYTEs	reserved (0)
---SCSI---
 00h	BYTE	logical unit number
 01h  7 BYTEs	reserved (0)
---USB---
 00h	BYTE	to be determined
 01h  7 BYTEs	reserved (0)
---IEEE1394---
 00h	QWORD	64-bit FireWire General Unique Identifier (GUID)
---FibreChannel---
 00h	QWORD	Word Wide Number (WWN)
SeeAlso: #00273,#00275

Format of Phoenix Enhanced Disk Drive Spec translated drive parameter table:
Offset	Size	Description	(Table 00277)
 00h	WORD	number of cylinders
 02h	BYTE	number of heads
 03h	BYTE	A0h (signature indicating translated table)
 04h	BYTE	number of physical sectors per track
 05h	WORD	starting write precompensation cylinder number
 07h	BYTE	reserved
 08h	BYTE	control byte (see #03198 at INT 41"DISK 0")
 09h	WORD	number of physical cylinders
 0Bh	BYTE	number of physical heads
 0Ch	WORD	cylinder number of landing zone
 0Eh	BYTE	number of logical sectors per track
 0Fh	BYTE	checksum
Program: the Phoenix Enhanced Disk Drive Specification is an addition to the
	  IBM/MS INT 13 extensions
SeeAlso: #00278,#03196

Format of Phoenix Enhanced Disk Drive Spec Fixed Disk Parameter Table:
Offset	Size	Description	(Table 00278)
 00h	WORD	physical I/O port base address
 02h	WORD	disk-drive control port address
 04h	BYTE	drive flags (see #00279)
 05h	BYTE	proprietary information
		bits 7-4 reserved (0)
		bits 3-0: Phoenix proprietary (used by BIOS)
 06h	BYTE	IRQ for drive (bits 3-0; bits 7-4 reserved and must be 0)
 07h	BYTE	sector count for multi-sector transfers
 08h	BYTE	DMA control
		bits 7-4: DMA type (0-2) as per ATA-2 specification
		bits 3-0: DMA channel
 09h	BYTE	programmed I/O control
		bits 7-4: reserved (0)
		bits 3-0: PIO type (1-4) as per ATA-2 specification
 0Ah	WORD	drive options (see #00280)
 0Ch  2 BYTEs	reserved (0)
 0Eh	BYTE	extension revision level (high nybble=major, low nybble=minor)
		(currently 10h for v1.0 and 11h for v1.1-3.0)
 0Fh	BYTE	2's complement checksum of bytes 00h-0Eh
		8-bit sum of all bytes 00h-0Fh should equal 00h
SeeAlso: #00277

Bitfields for Phoenix Enhanced Disk Drive Spec drive flags:
Bit(s)	Description	(Table 00279)
 7	reserved (1)
 6	LBA enabled
 5	reserved (1)
 4	drive is slave
 3-0	reserved (0)
SeeAlso: #00278,#00280

Bitfields for Phoenix Enhanced Disk Drive Spec drive options:
Bit(s)	Description	(Table 00280)
 0	fast PIO enabled
 1	fast DMA access enabled
 2	block PIO (multi-sector transfers) enabled
 3	CHS translation enabled
 4	LBA translation enabled
 5	removable media
 6	ATAPI device (CD-ROM)
 7	32-bit transfer mode
---v1.1+ ---
 8	ATAPI device uses DRQ to signal readiness for packet command
	(must be 0 if bit 6 is 0)
 10-9	translation type (must be 00 if bit 3 is 0)
	00 Phoenix bit-shifting translation
	01 LBA-assisted translation
	10 reserved
	11 proprietary translation
---v3.0---
 11	Ultra DMA access enabled
 15-12	reserved
SeeAlso: #00278,#00279
--------d-1349-------------------------------
INT 13 - IBM/MS INT 13 Extensions - EXTENDED MEDIA CHANGE
	AH = 49h
	DL = drive number
Return: CF clear if media has not changed
	    AH = 00h
	CF set if media may have changed
	    AH = 06h (see #00234)
Note:	unlike AH=16h, any drive number may be specified
SeeAlso: AH=16h,AH=41h"INT 13 Ext",AH=46h
--------d-134A-------------------------------
INT 13 - Bootable CD-ROM - INITIATE DISK EMULATION
	AH = 4Ah
	AL = 00h
	DS:SI -> specification packet (see #00281)
Return: CF clear if successful
	CF set on error (drive will not be in emulation mode)
	AX = return codes
SeeAlso: AH=48h,AX=4B00h,AH=4Ch,AH=4Dh

Format of Bootable CD-ROM Specification Packet:
Offset	Size	Description	(Table 00281)
 00h	BYTE	size of packet in bytes (13h)
 01h	BYTE	boot media type (see #00282)
 02h	BYTE	drive number
		00h floppy image
		80h bootable hard disk
		81h-FFh nonbootable or no emulation
 03h	BYTE	CD-ROM controller number
 04h	DWORD	Logical Block Address of disk image to emulate
 08h	WORD	device specification (see also #00282)
		(IDE) bit 0: drive is slave instead of master
		(SCSI)	bits 7-0: LUN and PUN
			bits 15-8: bus number
 0Ah	WORD	segment of 3K buffer for caching CD-ROM reads
 0Ch	WORD	load segment for initial boot image
		if 0000h, load at segment 07C0h
 0Eh	WORD	number of 512-byte virtual sectors to load
		(only valid for AH=4Ch)
 10h	BYTE	low byte of cylinder count (for INT 13/AH=08h)
 11h	BYTE	sector count, high bits of cylinder count (for INT 13/AH=08h)
 12h	BYTE	head count (for INT 13/AH=08h)
SeeAlso: #00283,AH=08h

Bitfields for Bootable CD-ROM boot media type:
Bit(s)	Description	(Table 00282)
 3-0	media type
	0000 no emulation
	0001 1.2M diskette
	0010 1.44M diskette
	0011 2.88M diskette
	0100 hard disk (drive C:)
	other reserved
 5-4	reserved (0)
 6	image contains ATAPI driver
 7	image contains SCSI driver(s)
SeeAlso: #00281
--------d-134B00-----------------------------
INT 13 - Bootable CD-ROM - TERMINATE DISK EMULATION
	AX = 4B00h
	DL = drive number or 7Fh to terminate all emulations
	DS:SI -> empty specification packet (see #00281)
Return: CF clear if successful
	CF set on error (drive will still be in emulation mode)
	AX = return codes
	DS:SI specification packet filled
SeeAlso: AH=48h,AH=4Ah,AX=4B00h,AH=4Ch,AH=4Dh
--------d-134B01-----------------------------
INT 13 - Bootable CD-ROM - GET STATUS
	AX = 4B01h
	DL = drive number
	DS:SI -> empty specification packet (see #00281)
Return: CF clear if successful
	CF set on error
	AX = return codes
	DS:SI specification packet filled
Note:	same as AX=4B00h, but does not terminate emulation
SeeAlso: AH=48h,AH=4Ah,AX=4B00h,AH=4Ch,AH=4Dh
--------d-134C-------------------------------
INT 13 - Bootable CD-ROM - INITIATE DISK EMULATION AND BOOT
	AH = 4Ch
	AL = 00h
	DS:SI -> specification packet (see #00281)
Return: never, if successful
	CF set (error while attempting to boot)
	AX = error codes
SeeAlso: AH=48h,AH=4Ah,AX=4B00h,AH=4Dh
--------d-134D00-----------------------------
INT 13 - Bootable CD-ROM - RETURN BOOT CATALOG
	AX = 4D00h
	DS:SI -> command packet (see #00283)
Return: CF clear if successful
	CF set on error
	AX = return codes
SeeAlso: AH=48h,AH=4Ah,AX=4B00h,AH=4Ch

Format of Bootable CD-ROM "get boot catalog" command packet:
Offset	Size	Description	(Table 00283)
 00h	BYTE	size of packet in bytes (08h)
 01h	BYTE	number of sectors of boot catalog to read
 02h	DWORD	-> buffer for boot catalog
 06h	WORD	first sector in boot catalog to transfer
SeeAlso: #00281
--------d-134E-------------------------------
INT 13 - IBM/MS INT 13 Extensions v2.1 - SET HARDWARE CONFIGURATION
	AH = 4Eh
	AL = function
	    00h enable prefetch
	    01h disable prefetch
	    02h set maximum PIO transfer mode
	    03h set PIO mode 0
	    04h set default PIO transfer mode
	    05h enable INT 13 DMA maximum mode
	    06h disable INT 13 DMA
	DL = drive number
Return: CF clear if successful
	    AH = 00h
	    AL = status
		00h command was safe (only affected specified drive)
		01h other devices are affected
	CF set on error
	    AH = error code (see #00234)
Note:	DMA and PIO modes are mutually exclusive, so selecting DMA disables
	  PIO (for either the specified device or all devices on that
	  controller), and selecting PIO disables DMA
SeeAlso: AH=41h"INT 13 Extensions",AX=5001h"Enhanced Disk Drive"
--------d-135001-----------------------------
INT 13 - Enhanced Disk Drive Spec v3.0 - SEND PACKET COMMAND
	AX = 5001h
	DL = drive number
	ES:BX -> command packet (see #00284)
Return: CF clear if successful
	    AH = 00h
	CF set on error
	    AH = error code
Desc:	send data to and from a serial packet-oriented device, such as IEEE1394
	  and USB
SeeAlso: AH=41h"INT 13 Extensions",AH=4Eh

Format of Enhanced Disk Drive Spec v3.0 command packet:
Offset	Size	Description	(Table 00284)
 00h	WORD	signature B055h
 02h	BYTE	length of packet in bytes
 03h	BYTE	reserved (0)
 04h  N BYTEs	formatted packet data

>>>>>>>> This is the end.
*)
