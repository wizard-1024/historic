//****************************************************************************
//                             File FPROTO.HPP
//
//                   Function prototype definitions
//
//    Copyright (c) 1996, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BC31/SOURCE/ATAPICD/RCS/fproto.hpp $
//  $RCSfile: fproto.hpp $
//   $Author: dstef $
//     $Date: 1999/01/02 01:19:24 $
// $Revision: 1.1 $
//   $Locker: dstef $
//
//      $Log: fproto.hpp $
//      Revision 1.1  1999/01/02 01:19:24  dstef
//      Initial revision
//
//
//****************************************************************************



//---------------------------Function Prototypes-------------------------------
void  OutputMessage             (const char * chMsg);
void  OutputMessageLF           (const char * chMsg);

void  OutputHexByte             (BYTE bNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF);
void  OutputHexWord             (WORD wNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF);
void  OutputHexDWord            (DWORD dwNum, BOOLEAN fAddPrefix, BOOLEAN fAddLF);
void  OutputBoolean             (WORD wValue, BOOLEAN fAddLF);
void  OutputByte                (BYTE bNum);
void  OutputWord                (WORD wNum);
void  OutputDoubleWord          (DWORD dwNum);
void  OutputByteLF              (BYTE bNum);
void  OutputWordLF              (WORD wNum);
void  OutputDoubleWordLF        (DWORD dwNum);
void  OutputBit                 (BYTE bValue);

void  OutputDataRate            (WORD wTimingCycle);
void  OutputTransferMode        (WORD wTransferMode, WORD wTimingCycle, BOOLEAN fAddLF);
void  OutputModePIO             (const char * chMsg, WORD wPioTransferMode);
void  OutputModeSingleWordDMA   (const char * chMsg, WORD wDmaTransferMode);
void  OutputModeMultiWordDMA    (const char * chMsg, WORD wDmaTransferMode);
void  OutputTransferTime        (const char * chMsg, WORD wTransferTime);
void  OutputDeviceType          (WORD wDevType);
void  OutputBitStatus           (BYTE bStatus, BOOLEAN fAddLF);
void  OutputBitError            (BYTE bError, BOOLEAN fAddLF);
void  OutputFieldasASCII        (const char * chField, WORD wFieldSize);
void  OutputFieldFmtASCII       (const char * chField, WORD wFieldSize);
void  OutputSpeedX              (WORD wKBytesPerSecond, WORD wUnit);
void  OutputMediumType          (BYTE bMediumCode);
void  OutputPageSaveableStatus  (BYTE bSaveableStatus);
void  OutputPortChannelSelect   (BYTE bSelectCode);
void  OutputPortVolume          (BYTE bBinaryLevel);
void  OutputHoldTrackTime       (BYTE bInactiveTimerMultiplier);
void  OutputWarnNonAtapiDev     ();
void  OutputWarnNotReadyDev     ();
void  OutputAudioPlayInProgress ();

void  WriteBinaryFile           (const char * chFileName, PBYTE pbBuf, WORD wBufSize);
void  WaitBiosTicksSec18        (const DWORD wUserTicks);
void  EnableIRQ                 (const BYTE bIrqNum);
void  DisableIRQ                (const BYTE bIrqNum);
void  Hsg2Red                   (const DWORD dwLBA, PBYTE pbMinutes, PBYTE pbSeconds, PBYTE pbFrames);
DWORD Red2Hsg                   (const BYTE bMinutes, const BYTE bSeconds, const BYTE bFrames);
void  OutputInputLBA            (DWORD dwStartBlock, DWORD dwEndBlock);

#if defined(_SOUNDBLASTER)
BOOLEAN  DetectSoundBlaster     (WORD wBaseAddr);
void     InitSoundBlaster       (WORD wBaseAddr);
void     DeinitSoundBlaster     (WORD wBaseAddr);
#endif                                      // #if defined(_SOUNDBLASTER)
