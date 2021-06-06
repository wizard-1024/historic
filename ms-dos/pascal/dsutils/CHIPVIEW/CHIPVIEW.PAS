{****************************************************************************
//                            File CHIPVIEW.PAS
//
//              Read PC/AT CMOS standard/extended chipset
//
//      Copyright (c) 1994, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/CHIPVIEW/RCS/chipview.pas $
//  $RCSfile: chipview.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:59:33 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: chipview.pas $
//      Revision 1.1  1998/10/03 14:59:33  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                IBM_PC_AT_SYSTEM_SETUP                          }
{ FILE NAME             CHIPVIEW.PAS                                    }
{ PURPOSE               Read PC/AT chipset specific information         }
{ VERSION               1.02                                            }
{ DATE                  02-Aug-1997                                     }
{ DESIGN                Dmitry Stefankov                                }
{ IMPLEMENTATION        Dmitry Stefankov                                }
{ COMPANY               Freelance Software Engineer                     }
{ ADDRESS               Isakowskogo str, 4-2-30                         }
{                       Moscow, 123181                                  }
{                       Russia                                          }
{                       Telephone: +007 (095) 944-6304                  }
{ INTERNET              wizard@radio-msu.net, dima@mccbn.ru             }
{ COPYRIGHT NOTICE      Copyright (C) 1994, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 7.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             <screenlines>  ---  # lines for each screen page}
{                       <yeschip>      ---  ask extended chipset access }
{                       Note: chipset is hard coded, you must change it }
{                             to wanted values of base/index registers. }
{ REQUIRES              Source Code Files                               }
{                       None                                            }
{                       Object Code Files                               }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Project Maintence Files                         }
{                       None                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               For 80286-based computers or higher             }
{ DESCRIPTION           1. Read standard CMOS memory (64 bytes)         }
{                       2. Read extended CMOS memory (64 bytes)         }
{                       3. Read chipset specific memory (256 bytes)     }
{                           if user ask about it                        }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   07-May-94  DS  initial release           }
{                       1.01   26-Jul-97  DS  updated documentation     }
{                       1.02   02-Aug-97  DS  removed tabs              }
{-----------------------------------------------------------------------}


{*======================= PROGRAM HEADER PART ==========================*}

PROGRAM   Chip_Regs_View;


{** switches for compilation **}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}
{$X-}           {*  extended syntax  *}


{*** other modules ***}
USES
  ShowTErr;



{** miscellaneous version **}
{**$DEFINE  DebugVersion}               {* generate a debugging version *}



{*========================== CONSTANTS PART ============================*}

CONST
     asPurpose                  =       'CHIPVIEW';
     asVersion                  =       '1.02';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1994, 1997';
     asProgram                  =       'ChipView';
     asProgramPrompt            =       asProgram+': ';

     { exit codes }
       errTerminateOK           =     0;
       errUserAbort             =     1;
       errBadNumeric            =     2;
       errBadCPU                =     3;

    { miscellaneous }
      achSpace                  =     ' ';
      asBlank                   =     '';
      achHexPrefix              =     '$';
      achDosDelim               =     '.';
      achZero                   =     '0';
      achOne                    =     '1';


     { screen output }
       aDisableScreenPage       =     0;
       aMinOutLineOnScreen      =     1;
       aDefMaxOutLineForScreen  =     23;
       aBigOutLinesForScreenNum =     2048;

     { Dos equates }
       aBytesPerKByte           =     1024;
       aKBytesPerMbyte          =     1024;

     { magic words }
       asAskChip                =    'YES';


    { bit values }
       btBit_0_ON               =       $0001;
       btBit_1_ON               =       $0002;
       btBit_2_ON               =       $0004;
       btBit_3_ON               =       $0008;
       btBit_4_ON               =       $0010;
       btBit_5_ON               =       $0020;
       btBit_6_ON               =       $0040;
       btBit_7_ON               =       $0080;
       btBit_8_ON               =       $0100;
       btBit_9_ON               =       $0200;
       btBit_A_ON               =       $0400;
       btBit_B_ON               =       $0800;
       btBit_C_ON               =       $1000;
       btBit_D_ON               =       $2000;
       btBit_E_ON               =       $4000;
       btBit_F_ON               =       $8000;


{*==================== TYPE DECLARATIONS PART ==========================*}

TYPE
  {* strings *}
       STR2                     =     STRING[2];
       STR4                     =     STRING[4];
       STR8                     =     STRING[8];


{*====================== TYPED CONSTANTS PART ==========================*}

CONST
    setAscii7_NoCtrl  :    SET OF System.Char  =  [#32..#127];
    setHexChars       :    SET OF System.Char  =  ['0'..'9','A'..'F','a'..'f'];

    gdwTextLineNum    :    System.Word         =  aMinOutLineOnScreen;
    gdwMaxScreenLines :    System.Word         =  aDefMaxOutLineForScreen;
    gbChipSetYes      :    System.Boolean      =  System.False;

    gioCMOS_Data      :    System.Word         =  $70;
    gioCMOS_Index     :    System.Word         =  $71;
    gioXCMOS_Data     :    System.Word         =  $22;
    gioXCMOS_Index    :    System.Word         =  $24;



{*=========================== VARIABLES PART ===========================*}

VAR
   giErrorCode           :   System.Integer;
   gdwIndex              :   System.Word;
   gsTemp                :   STRING;





{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE  _IO_DELAY_486_2;
{* Some i/o bus delay. *}
INLINE($E3/$00/     { jcxz short $ + 2 }
       $E3/$00);    { jcxz short $ + 2 }
{ _IO_DELAY_486_2 }


PROCEDURE _IO_DELAY_2;
{* Some i/o bus delay. *}
INLINE($EB/$00/     { jmp short $ + 2 }
       $EB/$00);    { jmp short $ + 2 }
{ _IO_DELAY_2 }


PROCEDURE _IO_DELAY_4;
{* Some i/o bus delay. *}
INLINE($EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00);    { jmp short $ + 2 }
{ _IO_DELAY_4 }


PROCEDURE _IO_DELAY_6;
{* Some i/o bus delay. *}
INLINE($EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00);    { jmp short $ + 2 }
{ _IO_DELAY_6 }


PROCEDURE _IO_DELAY_8;
{* Some i/o bus delay. *}
INLINE($EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00/     { jmp short $ + 2 }
       $EB/$00);    { jmp short $ + 2 }
{ _IO_DELAY_8 }


{*=========================== FUNCTIONAL PART ==========================*}


FUNCTION  _fndbReadCMOS(dwDataPort,dwIndexPort,dwPortValue : System.Word) : System.Byte;
{* Read a CMOS value from a given port. *}
BEGIN
 {$IFDEF DebugVersion}
   _fndbReadCMOS := $AA;
 {$ELSE}
  System.Port[dwDataPort] := dwPortValue;
 asm
   out 0EBh, ax
 end;
 { System.PortW[$EB] := dwPortValue; }
  _IO_DELAY_486_2;
  _fndbReadCMOS := System.Port[dwIndexPort];
 asm
     out  0EBh, ax
 end;
 {$ENDIF}
END;  { _fndbReadCMOS }


FUNCTION  _fnsByteToBitString(dbInput : System.Byte; chZero,chOne : System.Char) : STR8;
{* Return the bit representation of the byte. *}
      inline($5A                 {    pop   dx          ; DL = One           }
            /$5B                 {    pop   bx          ; BL = Zero          }
            /$58                 {    pop   ax          ; AL = Number        }
            /$88/$C7             {    mov   bh,al       ; BH = Number        }
            /$89/$E7             {    mov   di,sp       ; make stack frame   }
            /$36/$C4/$3D         {    les   di,ss:[di]  ; ES:DI -> string    }
            /$B9/$08/$00         {    mov   cx,8        ; repeat count       }
            /$FC                 {    cld               ; forward direction  }
            /$88/$C8             {    mov   al,cl       ; AL = string length }
            /$AA                 {    stosb             ; store it           }
                                 { NextBit:                                  }
            /$88/$D8             {    mov   al,bl       ; AL = Zero          }
            /$D0/$E7             {    shl   bh,1        ; transfer bit in CF }
            /$73/$02             {    jnc   BitDone     ; if not (CY), zero  }
            /$88/$D0             {    mov   al,dl        ; AL = One          }
                                 { BitDone:                                  }
            /$AA                 {    stosb             ; put a Char         }
            /$E2/$F5);           {    loop  NextBit     ; repeat till done   }
{ _fnsByteToBitString }


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


FUNCTION  _fnsNumToStr(liNum : System.Longint; dwWidth : System.Word) : STRING;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  IF (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  WHILE (System.Length(sTemp) <> 0) AND (sTemp[1] = achSpace)
  DO  System.Delete(sTemp,1,1);
  {while-do}

  _fnsNumToStr := sTemp;
END;
{ _fnsNumToStr }


FUNCTION  _fnsNumToStrNoAdj(liNum : System.Longint; dwWidth : System.Word) : STRING;
{* Convert a numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  IF (dwWidth <> 0)
    THEN  System.Str(liNum:dwWidth,sTemp)
    ELSE  System.Str(liNum,sTemp);
  {if-then-else}

  _fnsNumToStrNoAdj := sTemp;
END;
{ _fnsNumToStrNoAdj }


FUNCTION  _fnsNumToRealStr(rNum : System.Real;dwWidth,dwDecimals : System.Word) : STRING;
{* Convert a real numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);

  WHILE (System.Length(sTemp) <> 0) AND (sTemp[1] = achSpace)
  DO  System.Delete(sTemp,1,1);
  {while-do}

  _fnsNumToRealStr := sTemp;
END;
{ _fnsNumToRealStr }


FUNCTION  _fnsNumToRealStrNoAdj(rNum : System.Real;dwWidth,dwDecimals : System.Word) : STRING;
{* Convert a real numeric value to its string representation. *}
VAR
  sTemp : STRING;

BEGIN
  System.Str(rNum:dwWidth:dwDecimals,sTemp);

  _fnsNumToRealStrNoAdj := sTemp;
END;
{ _fnsNumToRealStrNoAdj }


FUNCTION   _fnsUpCase(sInput : STRING) : STRING;
{* Translate characters to upper case. *}
VAR
   dbIndex  :  System.Byte;
   dbCount  :  System.Byte  ABSOLUTE  sInput;

BEGIN
  IF (dbCount <> 0)
    THEN   FOR  dbIndex := 1 TO dbCount DO
               sInput[dbIndex] := System.UpCase(sInput[dbIndex]);
           {for-to-do}
  {if-then}

   _fnsUpCase := sInput;
END;
{  _fnsUpCase }



{*=========================== PROCEDURAL PART ==========================*}

PROCEDURE    _OutputMessageNoLF(sMessage : STRING);
{* Writes a message without the linefeed. *}
BEGIN
  System.Write(sMessage);
END;
{ _OutputMessageNoLF }


PROCEDURE    _OutputMessage(sMessage : STRING);
{* Writes a message through the paged stream output. *}
VAR
  sTemp   :   STRING;

BEGIN
   System.WriteLn(sMessage);
   IF (gdwTextLineNum <> aDisableScreenPage)
     THEN  BEGIN
      System.Inc(gdwTextLineNum);
      IF (gdwTextLineNum > gdwMaxScreenLines)
        THEN  BEGIN
           gdwTextLineNum := aMinOutLineOnScreen;
           System.Write(asProgramPrompt+' Press <ENTER> to continue or type any string to abort:');
           System.ReadLn(sTemp);
           IF (sTemp <> asBlank)
             THEN  BEGIN
                System.WriteLn(asProgramPrompt+' Aborted by user.');
                System.Halt(errUserAbort);
                   END;
           {if-then}
              END;
      {if-then}
            END;
   {if-then}
END;
{ _OutputMessage }


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     _OutputMessage(asPurpose+'  Version '+asVersion+',  '+asCopyright+'  '+asAuthor);
END;  { _CopyrightDisplay }


PROCEDURE    _DisplayCMOSregisters(dwChipDataPort,
                                   dwChipIndexPort,
                                   dwStartIndexValue,
                                   dwEndIndexValue : System.Byte;
                                   sTitle : STRING);
{* Outputs a standard CMOS map. *}
VAR
  dwIndex    :  System.Word;
  dbTempVal  :  System.Byte;

BEGIN
   _OutputMessage(asProgramPrompt+sTitle);
   _OutputMessage(asProgramPrompt+
                  ' '+
                  'DataPort='+_fnsByteToHexFmt(dwChipDataPort)+
                  ',  '+
                  'IndexPort='+_fnsByteToHexFmt(dwChipIndexPort)+
                  ',  '+
                  'Start/End Values='+
                  _fnsByteToHexFmt(dwStartIndexValue)+
                  '/'+
                  _fnsByteToHexFmt(dwEndIndexValue));
   _OutputMessage(asProgramPrompt+'  Reg.  Val.(76543210)   Reg.  Val.(76543210)   Reg.  Val.(76543210)');
   _OutputMessage(asProgramPrompt+'  ----  --------------   ----  --------------   ----  --------------');
   dwIndex := dwStartIndexValue;
   REPEAT
     IF (dwIndex <= dwEndIndexValue)
       THEN  BEGIN
          dbTempVal := _fndbReadCMOS(dwChipDataPort,dwChipIndexPort,dwIndex);
         _OutputMessageNoLF(asProgramPrompt+'   '+
                        _fnsByteToHexFmt(dwIndex)+'    '+
                        _fnsByteToHexFmt(dbTempVal)+
                        ' ('+
                        _fnsByteToBitString(dbTempVal,achZero,achOne)+
                        ')');
          System.Inc(dwIndex);
             END;
     {if-then}
     IF (dwIndex <= dwEndIndexValue)
       THEN  BEGIN
         dbTempVal := _fndbReadCMOS(dwChipDataPort,dwChipIndexPort,dwIndex);
         _OutputMessageNoLF('    '+
                        _fnsByteToHexFmt(dwIndex)+'    '+
                        _fnsByteToHexFmt(dbTempVal)+
                        ' ('+
                        _fnsByteToBitString(dbTempVal,achZero,achOne)+
                        ')');
         System.Inc(dwIndex);
             END;
     {if-then}
     IF (dwIndex <= dwEndIndexValue)
       THEN  BEGIN
          dbTempVal := _fndbReadCMOS(dwChipDataPort,dwChipIndexPort,dwIndex);
          _OutputMessage('    '+
                         _fnsByteToHexFmt(dwIndex)+'    '+
                         _fnsByteToHexFmt(dbTempVal)+
                         ' ('+
                         _fnsByteToBitString(dbTempVal,achZero,achOne)+
                         ')');
          System.Inc(dwIndex);
             END
       ELSE  BEGIN
          _OutputMessage(asBlank);
             END;
     {if-then-else}
   UNTIL (dwIndex > dwEndIndexValue);
   {repeat-until}
END;  { _DisplayCMOSregisters }


{*============================== MAIN PART =============================*}

BEGIN

  {* simple test for CPU type *}
    giErrorCode := 0;
    asm
          push    sp
          pop     ax

          cmp     ax, sp
          je      @CPU186

          mov     giErrorCode, -1
       @CPU186:
    end;
    {asm-end}
    IF (giErrorCode <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+' Requires Intel 80186 processor or higher.');
             System.Halt(errBadCPU);
          END;
    {if-then}

    IF  (System.ParamCount <> 0)
      THEN  BEGIN
        System.Val(System.ParamStr(1),gdwMaxScreenLines,giErrorCode);
        IF (giErrorCode <> 0)
          THEN  BEGIN
             System.WriteLn(asProgramPrompt+' Bad value for screen lines.');
             System.Halt(errBadNumeric);
                END
        ELSE  IF (gdwMaxScreenLines = aDisableScreenPage)
                THEN  gdwTextLineNum := aDisableScreenPage;
              {if-then}
        {if-then-else}
            END;
    {if-then}

    IF (System.ParamCount > 1)
      THEN  BEGIN
          IF (_fnsUpCase(System.ParamStr(2)) = asAskChip)
            THEN  gbChipSetYes := System.True;
          {if-then}
            END;
    {if-then}

   {* copyright message *}
    _CopyrightDisplay;

  {* display standard CMOS *}
    _DisplayCMOSregisters(gioCMOS_Data,gioCMOS_Index,$00,$3F,' Standard CMOS Registers Map.');

  {* display extended CMOS *}
    _DisplayCMOSregisters(gioCMOS_Data,gioCMOS_Index,$40,$7F,' Extended CMOS Registers Map.');

  {* display extended chip registers *}
    IF (gbChipSetYes)
       THEN  BEGIN
       _DisplayCMOSregisters(gioXCMOS_Data,gioXCMOS_Index,$00,$FF,' Specific Chip Registers Map.');
             END;
    {if-then}

  {** last report  **}
    _OutputMessage(asProgramPrompt+'Done.');


  {* System.Halt(errTerminateOk); *}

END.
