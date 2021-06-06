{****************************************************************************
//                            File DOSCTL.PAS
//
//          Advanced DOS functions and procedures library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/dosctl.pas $
//  $RCSfile: dosctl.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:54:04 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: dosctl.pas $
//      Revision 1.1  1999/01/03 17:54:04  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             DOSCTL.PAS                                      }
{ PURPOSE               Advanced DOS functions and procedures library   }
{ VERSION               0.01                                            }
{ DATE                  13-Sep-94                                       }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Tel. 007 (095) 944-6304                         }
{ COPYRIGHT NOTICE      Copyright (C) 1987-1994, Dmitry Stefankov       }
{ RESTRICTED RIGHTS     FOR INTERNAL USE ONLY.                          }
{                       THIS FILE CONTAINS PROPRIETARY AND CONFIDENTIAL }
{                       INFORMATION. COPYING AND REPRODUCTION WITHOUT   }
{                       PRIOR WRITTEN PERMISSION IS PROHIBITED.         }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                None                                            }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       DOS.TPU        (DOS functions and procedures)   }
{                       GLOBALS.TPU    (global public definitions)      }
{                       MESSAGES.TPU   (text user messages)             }
{                       VIDEO.TPU      (user screen interface)          }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
     DosCtl;


INTERFACE


USES
    Dos,
    Globals,
    Messages,
    Video;


PROCEDURE   _SaveCurrentVectors;
PROCEDURE   _RestoreCurrentVectors;
PROCEDURE   _SetCurLanguageBasedOnCurCountryCode;
PROCEDURE   _ExtractDefaultsFromDosEnvironment;
FUNCTION    _fnliUMB_MaxAvail : System.Longint;
FUNCTION    _fnbReleaseLowMemBlock(dwSegment : System.Word) : System.Boolean;
FUNCTION    _fnbReleaseHighMemBlock(dwUMBSeg : System.Word) : System.Boolean;
FUNCTION    _fnbAllocLowMemBlock(dwMemSizeInParas : System.Word;
                   VAR lpAllocatedMemBlock : System.Pointer) : System.Boolean;
FUNCTION    _fnbAllocHighMemBlock(dwMemSizeInParas : System.Word;
                   VAR lpAllocatedMemBlock : System.Pointer) : System.Boolean;
FUNCTION    _fnbResizeMemBlock(dwMemSeg,
                               dwNewMemSizeInParas : System.Word) : System.Boolean;
FUNCTION    _fnbIsLowMemBlock(dwMemSeg : System.Word) : System.Boolean;
FUNCTION    _fnliCMB_MaxAvail : System.Longint;



IMPLEMENTATION


VAR
   gdwSaveMemStrat  :  System.Word;
   gdwSaveUMBLink   :  System.Word;



{*=========================== PROCEDURAL PART ==========================*}


PROCEDURE
         _SaveCurrentVectors;
{*
Description.
    Saves current vectors $8,$9,$15,$16,$2F.
*}
BEGIN
{$IFDEF   DebVer}
  IF  ((Globals.gdwDebugLevel AND Globals.btTraceDosCtl) <> 0)
       THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(24),
                                       aModuleDosCtl);
  {if-then}
{$ENDIF} {DebVer}
  Dos.GetIntVec(Globals.aHardTimerInt,Globals.glpCurIntVec08);
  Dos.GetIntVec(Globals.aHardKbdInt,Globals.glpCurIntVec09);
  Dos.GetIntVec(Globals.aServerInt,Globals.glpCurIntVec15);
  Dos.GetIntVec(Globals.aSoftKbdInt,Globals.glpCurIntVec16);
  Dos.GetIntVec(Globals.gdbCallBackIntNum,Globals.glpCurIntVec2F);
  Globals.gbRestoreInts := System.True;
  IF  (Globals.glpCurIntVec2F = NIL)
    THEN  BEGIN
       Dos.SetIntVec(Globals.gdbCallBackIntNum,
                     System.Ptr(Globals.aRomBiosSeg,Globals.aRomDummyIRET));
          END;
  {if-then}
END;
{ _SaveCurrentVectors }



PROCEDURE
         _RestoreCurrentVectors;
{*
Description.
      Restores current vectors $8,$9,$15,$16,$2F.
*}
BEGIN
  IF  (Globals.gbRestoreInts)
    THEN  BEGIN
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceDosCtl) <> 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(25),
                                            aModuleDosCtl);
       {if-then}
{$ENDIF} {DebVer}
       Dos.SetIntVec(Globals.aHardTimerInt,Globals.glpCurIntVec08);
       Dos.SetIntVec(Globals.aHardKbdInt,Globals.glpCurIntVec09);
       Dos.SetIntVec(Globals.aServerInt,Globals.glpCurIntVec15);
       Dos.SetIntVec(Globals.aSoftKbdInt,Globals.glpCurIntVec16);
       Dos.SetIntVec(Globals.gdbCallBackIntNum,Globals.glpCurIntVec2F);
       Globals.gbRestoreInts := System.False;
          END
    ELSE  BEGIN
{$IFDEF   DebVer}
       IF  ((Globals.gdwDebugLevel AND Globals.btTraceDosCtl) <> 0)
            THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(26),
                                            aModuleDosCtl);
       {if-then}
{$ENDIF} {DebVer}
          END;
  {if-then-else}
END;
{ _RestoreCurrentVectors }



FUNCTION
        _fndwGetCountryCode : System.Word;
{*
Description.
      Returns a current country code used by DOS.
*}
VAR
  dwCountryCode   :   System.Word;

BEGIN
    dwCountryCode := $FFFF;  {assume that failed}
    ASM
              mov       dx, OFFSET  Globals.gdbTempBuf
              mov       ax, (Globals.aCountryInfo SHL 8) + (Globals.aGetCountryInfo)
              int       Globals.aDosServicesInt
              jc       @CallDone
              mov       dwCountryCode, ax          {DOS 2+}
              cmp       ax, bx
              je       @CallDone
              mov       dwCountryCode, bx          {DOS 3+}
     @CallDone:
    END;
    {asm-end}

    _fndwGetCountryCode := dwCountryCode;
END;
{ _fndwGetCountryCode }



PROCEDURE
         _SetCurLanguageBasedOnCurCountryCode;
{*
Description.
        Sets a new current language for user interface.
*}
VAR
  dwCurCountryCode  :  System.Word;

BEGIN
     dwCurCountryCode := _fndwGetCountryCode;
     IF  (dwCurCountryCode <> $FFFF)
       THEN  BEGIN
         CASE  (dwCurCountryCode)  OF
             aCountryCode_US,
             aCountryCode_UK,
             aCountryCode_Australia   :  BEGIN
                   Globals.gdwCurLanguage := Globals.aEnglishLanguage;
                                         END;
             aCountryCode_Switzerland,
             aCountryCode_Germany     :  BEGIN
                   Globals.gdwCurLanguage := Globals.aEnglishLanguage;
                                         END;
             aCountryCode_Russia      :  BEGIN
                   Globals.gdwCurLanguage := Globals.aRussianLanguage;
                                         END;
           ELSE
              Globals.gdwCurLanguage :=  Globals.aEnglishLanguage;
         END;
         {case-of}
             END;
     {if-then}
END;
{ _SetCurLanguageBasedOnCurCountryCode }



PROCEDURE   _ExtractDefaultsFromDosEnvironment;
{*
Description.
     Extracts the current user settings from the DOS environment.
*}
VAR
  sTempDosEnv     :  STRING;
  iErrorCode      :  System.Integer;
  iTempPos        :  System.Integer;
  dbStrLen        :  System.Byte;
  bNotErrFound    :  System.Boolean;
  chTemp          :  System.Char;


FUNCTION  _fnsSubVarDesc : STRING;
{*
Description.
     Extracts the string of description.
*}
VAR
  sTempVar   :  STRING;
BEGIN
  System.Delete(sTempDosEnv,1,iTempPos+1);
  iTempPos := System.Pos(Globals.achUnixSwitch,sTempDosEnv);
  IF  (iTempPos = 0)
    THEN  iTempPos := System.Length(sTempDosEnv)+1;
  {if-then}
  sTempVar := System.Copy(sTempDosEnv,1,iTempPos-1);
  System.Delete(sTempDosEnv,1,iTempPos-1);
  dbStrLen := System.Length(sTempDosEnv);
  _fnsSubVarDesc := sTempVar;
END;
{ _fnsSubVarDesc }

BEGIN
  sTempDosEnv := StrLib._fnsUpCase(Dos.GetEnv(Globals.gsDosEnvVar));
{$IFDEF   DebVer}
   IF  ((Globals.gdwDebugLevel AND Globals.btTraceDosCtl) <> 0)
      THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(569)+
                                      sTempDosEnv,
                                      aModuleDosCtl);
   {if-then}
{$ENDIF} {DebVer}
  bNotErrFound := System.True;
  dbStrLen := System.Length(sTempDosEnv);
  WHILE  ((dbStrLen > 2) AND (bNotErrFound))  DO
  BEGIN
      iTempPos := System.Pos(Globals.achUnixSwitch,sTempDosEnv);
      IF  (iTempPos = 0)
        THEN  BEGIN
          bNotErrFound := System.False;
              END
        ELSE  BEGIN
          chTemp := sTempDosEnv[iTempPos+1];
          CASE  (chTemp)  OF
           achDosEnvVarConfigPathPrefix : BEGIN
              Globals.gsDefaultConfigPath := StrLib._fnsAddBackSlash(_fnsSubVarDesc);
                                          END;
           achDosEnvVarIntNumPrefix     : BEGIN
              gdbCallBackIntNum := System.Lo(StrLib._fndwGetValue(iErrorCode,_fnsSubVarDesc));
                                          END;
           achDosEnvVarChannelNumPrefix : BEGIN
              gdbUserMultiplexChannel := System.Lo(StrLib._fndwGetValue(iErrorCode,_fnsSubVarDesc));
                                          END;
            ELSE
              bNotErrFound := System.False;
          END;
          {case-of}
              END;
      {if-then-else}
  END;
  {while-do}

  IF  NOT(bNotErrFound)
    THEN  Video._HaltProgram(Messages._fnsTextMessageByIndex(568),
                             Globals.errBadUserConfigDosVar);

{$IFDEF   DebVer}
   IF  ((Globals.gdwDebugLevel AND Globals.btTraceDosCtl) <> 0)
      THEN  Video._OutputDebugMessage(Messages._fnsTextMessageByIndex(255)+
                                      Globals.gsDefaultConfigPath,
                                      aModuleDosCtl);
   {if-then}
{$ENDIF} {DebVer}
END;
{ _ExtractDefaultsFromDosEnvironment }



FUNCTION
        _fnbChangeMemoryStrategy : System.Boolean; ASSEMBLER;
{*
Description.
     Saves the current memory allocation strategy and
     changes it in order to allocate upper memory blocks.
*}
ASM
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aGetMemStrategy
    INT   Globals.aDosServicesInt
    sub   ah, ah
    MOV   gdwSaveMemStrat, AX
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aGetUmbLinkState
    INT   Globals.aDosServicesInt
    sub   ah, ah
    MOV   gdwSaveUMBLink, AX
    JC    @1                           {Exit if DOS 5- or no UMA}
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetMemStrategy
    MOV   BX, Globals.aFirstFitHighMem
    INT   Globals.aDosServicesInt
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetUmbLinkState
    MOV   BX, Globals.aAddUMBsfromDosChain
    INT   Globals.aDosServicesInt
    JNC   @2                           {Error: no UMB provider}
@1: MOV   AX, System.False             {Return an error}
    JMP   @3
@2: MOV   AX, System.True              {Return success}
@3:
END;
{ _fnbChangeMemoryStrategy }



PROCEDURE
         _ResetMemoryStrategy; ASSEMBLER;
{*
Description.
     Restores the memory allocation strategy.
*}
ASM
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetMemStrategy
    MOV   BX, gdwSaveMemStrat
    INT   Globals.aDosServicesInt
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetUmbLinkState
    MOV   BX, gdwSaveUMBLink
    INT   Globals.aDosServicesInt
END;
{ _ResetMemoryStrategy }



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
                mov     ah, Globals.aAllocMemBlock
                int     Globals.aDosServicesInt
                mov     bx, 0
                mov     es:[di][0], bx           {Offset=zero}
                jc     @1
                mov     bx, ax                   {Save segment value}
                mov     al, System.True          {Return success}
                jmp    @2
       @1:
                mov     al, System.False         {Return an error}
       @2:
                mov     es:[di][aWord*1], bx     {Segment=zero}
END;
{ _fnbAllocLowMemBlock }



FUNCTION
        _fnbAllocHighMemBlock(dwMemSizeInParas : System.Word;
              VAR lpAllocatedMemBlock : System.Pointer) : System.Boolean; ASSEMBLER;
{*
Description.
      Allocates the high memory block using DOS services.
*}
ASM
    CALL  _fnbChangeMemoryStrategy     {Allow the use of upper memory}
    les     di, lpAllocatedMemBlock
    xor     bx, bx
    mov     es:[di][0], bx             {Offset}
    CMP   AX, System.False
    JZ    @1                           {if it not possible, return 0}
    MOV   AH, Globals.aAllocMemBlock   {Try to allocate too much memory}
    MOV   BX, dwMemSizeInParas         {BX contains the size of block}
    INT   Globals.aDosServicesInt
    jc    @1
    mov     bx, ax                     {Save segment value}
    mov     al, System.True            {Return success}
    jmp   @2
@1:
    mov     al, System.False           {Return an error}
@2:
    mov     es:[di][aWord*1], bx       {Segment}
    push    ax
    CALL  _ResetMemoryStrategy         {Reset the memory allocation strategy}
    pop     ax
END;
{ _fnbAllocHighMemBlock }



FUNCTION
        _fnliUMB_MaxAvail : System.Longint; ASSEMBLER;
{*
Description.
      Returns the size of the biggest available upper memory block.
*}
ASM
    CALL  _fnbChangeMemoryStrategy     {Allow the use of upper memory}
    CMP   AX, System.False
    JZ    @1                           {if it not possible, return 0}
    MOV   AH, Globals.aAllocMemBlock   {Try to allocate too much memory}
    MOV   BX, Globals.aFullWord        {BX contains the size of the biggest}
    INT   Globals.aDosServicesInt      {available block = ~1MB}
    MOV   AX, BX
    XOR   DX, DX
    SHL   AX, 1                        {Multiply by 16 and put the result}
    RCL   DX, 1                        {  in DX:AX}
    SHL   AX, 1
    RCL   DX, 1
    SHL   AX, 1
    RCL   DX, 1
    SHL   AX, 1
    RCL   DX, 1
    JMP   @2
@1: XOR   AX, AX
    XOR   DX, DX
@2: PUSH  AX
    PUSH  DX
    CALL  _ResetMemoryStrategy         {Reset the memory allocation strategy}
    POP   DX
    POP   AX
END;
{ _fnliUMB_MaxAvail }



FUNCTION
        _fnbReleaseLowMemBlock(dwSegment : System.Word) : System.Boolean; ASSEMBLER;
{*
Description.
    Returns specified low memory block back to DOS memory pool.
*}
ASM
                mov     es, dwSegment
                mov     ah, Globals.aFreeMemBlock
                int     Globals.aDosServicesInt
                jc     @1
                mov     al, System.True          {Return success}
                jmp    @2
       @1:      mov     al, System.False         {Return an error}
       @2:
END;
{ _fnbReleaseLowMemBlock }



FUNCTION
        _fnbReleaseHighMemBlock(dwUMBSeg : System.Word) : System.Boolean; ASSEMBLER;
{*
Description.
     Returns specified high memory block back to DOS memory pool.
*}
ASM
    MOV   AX, dwUMBSeg                 {If the segment is zero, do nothing}
    OR   AX, AX
    JZ    @1
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aGetUmbLinkState
    INT   Globals.aDosServicesInt
    jc   @1
    MOV   gdwSaveUMBLink, AX
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetUmbLinkState
    MOV   BX, Globals.aRemoveUMBsfromDosChain
    INT   Globals.aDosServicesInt
    jc   @1
    MOV   AH, Globals.aFreeMemBlock
    MOV   ES, dwUMBSeg
    INT   Globals.aDosServicesInt
    pushf
    MOV   AX, (Globals.aMemStrategy SHL 8) + Globals.aSetUmbLinkState
    MOV   BX, gdwSaveUMBLink
    INT   Globals.aDosServicesInt
    popf
    jc   @1
    mov     al, System.True          {Return success}
    jmp    @2
@1: mov     al, System.False         {Return an error}
@2:
END;
{ _ReleaseHighMemBlock }



FUNCTION
        _fnbResizeMemBlock(dwMemSeg,
                dwNewMemSizeInParas : System.Word) : System.Boolean; ASSEMBLER;
{*
Description.
     Resizes the allocated memory block using DOS services.
*}
ASM
                mov     es, dwMemSeg
                mov     bx, dwNewMemSizeInParas
                mov     ah, Globals.aResizeMemBlock
                int     Globals.aDosServicesInt
                mov     al, System.False         {Return an error}
                jc     @1
                mov     al, System.True          {Return success}
       @1:
END;
{ _fnbResizeMemBlock }



FUNCTION
        _fnbIsLowMemBlock(dwMemSeg : System.Word) : System.Boolean;
{*
Description.
     Returns a type of the allocated DOS memory block.
*}
BEGIN
   _fnbIsLowMemBlock := (dwMemSeg < Globals.aConvMemSegMax);
END;
{ _fnbIsLowMemBlock }


FUNCTION
        _fnliCMB_MaxAvail : System.Longint; ASSEMBLER;
{*
Description.
      Returns the size of the biggest available conventional memory block.
*}
ASM
                mov     bx, $FFFF                       {1 MB - 16 bytes}
                mov     ah, Globals.aAllocMemBlock
                int     Globals.aDosServicesInt
                mov     ax, bx
                mov     bx, Globals.aBytesPerParagraph
                mul     bx                              {DX:AX <- result}
END; {asm-end}
{ _fnliCMB_MaxAvail }




{BEGIN}
END.
