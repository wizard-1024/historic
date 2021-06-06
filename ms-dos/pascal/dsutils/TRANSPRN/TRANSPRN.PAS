{****************************************************************************
//                            File TRANSPRN.PAS
//
//               Stream translator for DOS print device
//
//      Copyright (c) 1993, 1997 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/FREEWARE/TRANSPRN/RCS/transprn.pas $
//  $RCSfile: transprn.pas $ 
//   $Author: dstef $ 
//     $Date: 1998/10/03 14:52:58 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: transprn.pas $
//      Revision 1.1  1998/10/03 14:52:58  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               NON-PROFIT HIGH QUALITY PROFESSIONAL SOFTWARE,  }
{                       AVAILABLE FOR ALL WORLD                         }
{ LIBRARY               SYSTEM UTILITIES                                }
{ MODULE                PRINT_UTILITIES                                 }
{ FILE NAME             TRANSPRN.PAS                                    }
{ PURPOSE               Translate input character stream for standard   }
{                       DOS print device                                }
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
{ COPYRIGHT NOTICE      Copyright (C) 1993, 1997  Dmitry Stefankov      }
{ RESTRICTED RIGHTS     AVAILABLE ONLY FOR FREE DISTRIBUTION,           }
{                       NOT FOR COMMERCIAL PURPOSE                      }
{ COMPUTER              IBM PC or compatible                            }
{ OPERATING SYSTEM      MS/PC-DOS Version 3.30 or higher                }
{ COMPILER              Turbo Pascal Version 6.0                        }
{                       (Borland International Inc.)  or compatible     }
{ ASSEMBLY LANGUAGE     Microsoft MASM 5.10 or compatible               }
{ LINKER                Turbo Pascal internal                           }
{ ARGUMENTS             None                                            }
{ RETURN                See error return codes definitions              }
{ REQUIRES              Source Code Files                               }
{                       NONE                                            }
{                       External Object Files                           }
{                       SHOWTERR.TPU   (Turbo Errors)                   }
{                       Maintence Project Files                         }
{                       NONE                                            }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       1.00   01-Sep-93  DS  initial release           }
{                       1.01   26-Jul-97  DS  updated documentation     }
{                       1.02   02-Aug-97  DS  removed tabs              }
{-----------------------------------------------------------------------}


{**======================== PROGRAM HEADER PART ========================*}
PROGRAM   TRANSLATE_PRINT_STREAM;


{*** other modules ***}
USES
     Dos, ShowTErr;


{** switches for compilation *}
{$S-}           {*  stack checking   *}
{$R-}           {*  range checking   *}

{* generate version for debugging practice *}
{***$DEFINE  DebugVersion}
{***$DEFINE  TranslateMainToAlternateRussianFont}


{**======================== CONSTANTS DEFINITIONS PART ================**}

CONST

    { program definitions }
     asPurpose                  =       'Print Stream Translator';
     asVersion                  =       '1.02';
     asAuthor                   =       'Dima Stefankov';
     asCopyright                =       'Copyright (c) 1993, 1997';
     asProgram                  =       'TransPRN';
     asProgramPrompt            =       asProgram+': ';
     asUProgram                 =       'TRANSPRN';

    { exit codes }
      errTerminateOK            =     0;
      errNoParmsDispHelp        =     1;

    { miscellaneous }
      asBlank                   =     '';
      achHexPrefix              =     '$';
      aBytesPerPara             =     16;
      aPSP_Size                 =     256;

    { ASCII codes }
      achNULL                   =     00;
      achLF                     =     10;
      achCR                     =     13;

   { MS-DOS functions }
     aDosFunctionsCall          =     $21;
     aTerminateAndStay          =     $31;
     aFreeMemoryBlock           =     $49;

   { iAPX86 opcode }
     aFarJumpOpCode             =     $EA;      

   { IBM PC BIOS functions }
     aRomPrintDriver            =     $17;
     aRomPrintChar              =     $00;
     aRomInitPrinter            =     $01;
     aRomGetPrinerStatus        =     $02;
     aRomAvailFuncMax           =     aRomGetPrinerStatus;

     aLPT1                      =     $00;
     aLPT2                      =     $01;
     aLPT3                      =     $02;
     aLPT4                      =     $03;      { may not work for most machines }
     aMaxLPT                    =     aLPT4;

   { new print driver functions }
     aBasePrintDriverFn         =    $04;
     aInstallCheck              =    aBasePrintDriverFn+$00;
     aGetResidentInfo           =    aBasePrintDriverFn+$01;
     aNewFuncMaxNum             =    aBasePrintDriverFn+$01;

   { driver state flags }
     aFullWordMask              =    $FFFF;
     aTransModeON               =    $0001;

   { driver identification values }
    aFunctionOK                 =    $0000;
    aDriverID                   =    $4453;    {'DS'}

   { ATTENTION!!! hard-coded values }
    adwPutOldIntVec             =    $0004;


{**======================== TYPES DEFINITIONS PART ====================**}

TYPE

  {* strings *}
       STR2                     =     STRING[2];
       STR4                     =     STRING[4];
       STR8                     =     STRING[8];


{**======================== VARIABLES DEFINITIONS PART ====================**}

VAR

   gsTempInput          :   STRING;
   glpPrintDevIntVec    :   System.Pointer;
   dwTSRPartSize        :   System.Word;



{**============== ASSEMBLY FUNCTIONS/PROCEDURES PART ==================**}


PROCEDURE  _lpNewPrintStreamDriver;  FAR;  ASSEMBLER;
{* Interrupt handler for print device driver. *}
asm
{$IFDEF  DebugVersion}
{$ENDIF}
{offset = $00}
        jmp     @SkipDataSection

{offset = $03}

  @JumpToOldPrintDriver:
        DB      aFarJumpOpCode
  @ddOldPrintDriverAddress:
        DW      0                       { offset  part }
        DW      0                       { segment part }

{offset = $08}
  @dwPspSegment:
        DW      0

{offset = $0A}
  @dwPrintPort:
        DW      aLPT1

{offset = $0C}
  @dwStateFlags:
        DW     aTransModeON

{offset = $0E}
{  SOURCE FILE:  ASCII.BIN                                               }
{  Created by Bin2asm utility, Copyright (c) 1987, 1993  Dima Stefankov  }

{$IFDEF  TranslateMainToAlternateRussianFont}
 @dwCharacterStreamTranslateTable:
        DB      000h,001h,002h,003h,004h,005h,006h,007h         {........}
        DB      008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh         {........}
        DB      010h,011h,012h,013h,014h,015h,016h,017h         {........}
        DB      018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh         {........}
        DB      020h,021h,022h,023h,024h,025h,026h,027h         { !"#$%&'}
        DB      028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh         {()*+,-./}
        DB      030h,031h,032h,033h,034h,035h,036h,037h         {01234567}
        DB      038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh         {89:;<=>?}
        DB      040h,041h,042h,043h,044h,045h,046h,047h         {@ABCDEFG}
        DB      048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh         {HIJKLMNO}
        DB      050h,051h,052h,053h,054h,055h,056h,057h         {PQRSTUVW}
        DB      058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh         {XYZ[\]^_}
        DB      060h,061h,062h,063h,064h,065h,066h,067h         {`abcdefg}
        DB      068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh         {hijklmno}
        DB      070h,071h,072h,073h,074h,075h,076h,077h         {pqrstuvw}
        DB      078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh         {xyz.|.~.}
        DB      0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h         {∞±≤≥¥µ∂∑}
        DB      0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh         {∏π∫ªºΩæø}
        DB      0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h         {¿¡¬√ƒ≈∆«}
        DB      0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh         {»… ÀÃÕŒœ}
        DB      0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h         {–—“”‘’÷◊}
        DB      0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh         {ÿŸ⁄€‹›ﬁﬂ}
        DB      080h,081h,082h,083h,084h,085h,086h,087h         {ÄÅÇÉÑÖÜá}
        DB      088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh         {àâäãåçéè}
        DB      090h,091h,092h,093h,094h,095h,096h,097h         {êëíìîïñó}
        DB      098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh         {òôöõúùûü}
        DB      0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h         {†°¢£§•¶ß}
        DB      0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh         {®©™´¨≠ÆØ}
        DB      0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h         {‡·‚„‰ÂÊÁ}
        DB      0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh         {ËÈÍÎÏÌÓÔ}
        DB      0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h         {ÒÚÛÙıˆ˜}
        DB      0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh         {¯˘˙˚¸˝˛ˇ}
{$ELSE}
 @dwCharacterStreamTranslateTable:
        DB      000h,001h,002h,003h,004h,005h,006h,007h         {........}
        DB      008h,009h,00Ah,00Bh,00Ch,00Dh,00Eh,00Fh         {........}
        DB      010h,011h,012h,013h,014h,015h,016h,017h         {........}
        DB      018h,019h,01Ah,01Bh,01Ch,01Dh,01Eh,01Fh         {........}
        DB      020h,021h,022h,023h,024h,025h,026h,027h         { !"#$%&'}
        DB      028h,029h,02Ah,02Bh,02Ch,02Dh,02Eh,02Fh         {()*+,-./}
        DB      030h,031h,032h,033h,034h,035h,036h,037h         {01234567}
        DB      038h,039h,03Ah,03Bh,03Ch,03Dh,03Eh,03Fh         {89:;<=>?}
        DB      040h,041h,042h,043h,044h,045h,046h,047h         {@ABCDEFG}
        DB      048h,049h,04Ah,04Bh,04Ch,04Dh,04Eh,04Fh         {HIJKLMNO}
        DB      050h,051h,052h,053h,054h,055h,056h,057h         {PQRSTUVW}
        DB      058h,059h,05Ah,05Bh,05Ch,05Dh,05Eh,05Fh         {XYZ[\]^_}
        DB      060h,061h,062h,063h,064h,065h,066h,067h         {`abcdefg}
        DB      068h,069h,06Ah,06Bh,06Ch,06Dh,06Eh,06Fh         {hijklmno}
        DB      070h,071h,072h,073h,074h,075h,076h,077h         {pqrstuvw}
        DB      078h,079h,07Ah,07Bh,07Ch,07Dh,07Eh,07Fh         {xyz.|.~.}
        DB      080h,081h,082h,083h,084h,085h,086h,087h         {ÄÅÇÉÑÖÜá}
        DB      088h,089h,08Ah,08Bh,08Ch,08Dh,08Eh,08Fh         {àâäãåçéè}
        DB      090h,091h,092h,093h,094h,095h,096h,097h         {êëíìîïñó}
        DB      098h,099h,09Ah,09Bh,09Ch,09Dh,09Eh,09Fh         {òôöõúùûü}
        DB      0A0h,0A1h,0A2h,0A3h,0A4h,0A5h,0A6h,0A7h         {†°¢£§•¶ß}
        DB      0A8h,0A9h,0AAh,0ABh,0ACh,0ADh,0AEh,0AFh         {®©™´¨≠ÆØ}
        DB      0B0h,0B1h,0B2h,0B3h,0B4h,0B5h,0B6h,0B7h         {∞±≤≥¥µ∂∑}
        DB      0B8h,0B9h,0BAh,0BBh,0BCh,0BDh,0BEh,0BFh         {∏π∫ªºΩæø}
        DB      0C0h,0C1h,0C2h,0C3h,0C4h,0C5h,0C6h,0C7h         {¿¡¬√ƒ≈∆«}
        DB      0C8h,0C9h,0CAh,0CBh,0CCh,0CDh,0CEh,0CFh         {»… ÀÃÕŒœ}
        DB      0D0h,0D1h,0D2h,0D3h,0D4h,0D5h,0D6h,0D7h         {–—“”‘’÷◊}
        DB      0D8h,0D9h,0DAh,0DBh,0DCh,0DDh,0DEh,0DFh         {ÿŸ⁄€‹›ﬁﬂ}
        DB      0E0h,0E1h,0E2h,0E3h,0E4h,0E5h,0E6h,0E7h         {‡·‚„‰ÂÊÁ}
        DB      0E8h,0E9h,0EAh,0EBh,0ECh,0EDh,0EEh,0EFh         {ËÈÍÎÏÌÓÔ}
        DB      0F0h,0F1h,0F2h,0F3h,0F4h,0F5h,0F6h,0F7h         {ÒÚÛÙıˆ˜}
        DB      0F8h,0F9h,0FAh,0FBh,0FCh,0FDh,0FEh,0FFh         {¯˘˙˚¸˝˛ˇ}
{$ENDIF}
@dwFunctionsJumpTable:
        DW      OFFSET    @InstallationCheck
        DW      OFFSET    @GetInfoAboutTSR

{ use as return point to original ROM driver }
@JumpBack:
                 popf
                 jmp    @JumpToOldPrintDriver

@SkipDataSection:
                 pushf

@CheckPortToPrint:
                 cmp     dx, cs:[OFFSET @dwPrintPort]
                 jne    @JumpBack

@CheckFuncToPrint:
                 cmp     ah, aRomPrintChar
                 jne    @CheckOtherROMFunctions

@CheckTransModeState:
                 test    WORD PTR cs:[OFFSET @dwStateFlags], aTransModeON
                 jz     @JumpBack

@DoCharacterTranslation:
                 push    bx

                 xor     bx, bx
                 mov     bl, al
                 mov     al, BYTE PTR cs:[bx.@dwCharacterStreamTranslateTable]

                 pop     bx
                 jmp    @JumpBack

@CheckOtherROMFunctions:
                 cmp     ah, aRomAvailFuncMax
                 jbe     @JumpBack

@CheckNewFunctions:
                 cmp     ah, aBasePrintDriverFn
                 jb     @JumpBack

                 cmp     ah, aNewFuncMaxNum
                 ja     @JumpBack

@JumpToDispatchTable:
                 sub    ah, aBasePrintDriverFn
                 mov    al, ah
                 sub    ah, ah
                 shl    ax, 1
                 add    ax, OFFSET  @dwFunctionsJumpTable
                 jmp    ax


@InstallationCheck:
                 mov    bx, aDriverID
                 jmp   @ExitFromDriver


@GetInfoAboutTSR:
                 mov    bx, cs:[OFFSET @dwPspSegment]
                 mov    cx, cs:[OFFSET @dwStateFlags]
                 mov    dx, cs:[OFFSET @dwPrintPort]
                 mov    es, cs:[(OFFSET @ddOldPrintDriverAddress)+$02]
                 mov    di, cs:[(OFFSET @ddOldPrintDriverAddress)+$00]
                 jmp   @ExitFromDriver


@ExitFromDriver:
                 mov    ax, aFunctionOK

                 popf
                 iret
END; {end-asm}
{ _lpNewPrintStreamDriver }



{**========================= PROCEDURES PART ==========================**}

PROCEDURE    _DummyProc;
{* It is used for reference only. Don't remove this code!!! *}
BEGIN
  {** nothing!!! *}
END;
{ _DummyProc }



{**========================== FUNCTIONS PART ==========================**}

FUNCTION   _fnchGetFirstChar(sInput : STRING) : System.Char;
{* Returns a first char from string. *}
VAR
  chTemp  :  System.Char;

BEGIN
   IF (System.Length(sInput) <> 0)
     THEN  chTemp := sInput[1]
     ELSE  chTemp := System.Char(achNULL);
   {if-then-else}
  _fnchGetFirstChar := chTemp;
END;
{ _fnchGetFirstChar }



{**========================= PROCEDURES PART ==========================**}


PROCEDURE    _CopyrightDisplay;
{* Outputs the copyright notice. *}
BEGIN
     System.WriteLn(asPurpose+
                    '  Version '+
                    asVersion+
                    ',  '+
                    asCopyright+
                    '  '+
                    asAuthor);
END;  { _CopyrightDisplay }



{**======================= MAIN STATEMENTS PART =======================**}

BEGIN

  {* copyright message *}
    _CopyrightDisplay;


  {* install driver *}
     Dos.GetIntVec(aRomPrintDriver,glpPrintDevIntVec);
     System.Move(glpPrintDevIntVec,
                 System.Mem[System.Seg(_lpNewPrintStreamDriver):System.Ofs(_lpNewPrintStreamDriver)+adwPutOldIntVec],
                 System.SizeOf(System.Pointer));
     Dos.SetIntVec(aRomPrintDriver,@_lpNewPrintStreamDriver);

  {* say to DOS that we ready to use *}
     dwTSRPartSize := (aPSP_Size +
                       (System.Ofs(_DummyProc)) +
                      aBytesPerPara) DIV aBytesPerPara;

     ASM
           mov      dx, dwTSRPartSize
           mov      ah, aTerminateAndStay
           int      aDosFunctionsCall
     END;
     {asm-end}


  {* terminate message *}
    System.WriteLn(asProgramPrompt+'Done.');


  {* System.Halt(errTerminateOk); *}
END.
