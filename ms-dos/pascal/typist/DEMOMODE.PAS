{****************************************************************************
//                            File DEMOMODE.PAS
//
//                        Demo simulation library
//
//      Copyright (c) 1994, 1999 Dmitry Stefankov. All rights reserved.
//
//****************************************************************************
//
//   $Source: D:/BP70/SOURCE/TYPIST/RCS/demomode.pas $
//  $RCSfile: demomode.pas $ 
//   $Author: dstef $ 
//     $Date: 1999/01/03 17:52:05 $ 
// $Revision: 1.1 $ 
//   $Locker: dstef $ 
//
//      $Log: demomode.pas $
//      Revision 1.1  1999/01/03 17:52:05  dstef
//      Initial revision
// 
//
//****************************************************************************}


{-----------------------------------------------------------------------}
{ PROJECT               MICROSOFT/IBM DISK OPERATING SYSTEM UTILITIES   }
{                       (COMMERCIAL PURPOSE)                            }
{ LIBRARY               TEXT_PROCESSING                                 }
{ MODULE                INTELLECTUAL_TYPIST                             }
{ FILE NAME             DEMOMODE.PAS                                    }
{ PURPOSE               Demo simulation library                         }
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
{                       STRLIB.TPU     (strings support library)        }
{                       Project Maintence Files                         }
{                       TYPIST.MAK        (auto compiling & linking)    }
{ NATURAL LANGUAGE      English Language                                }
{ SPECIAL               None                                            }
{ DESCRIPTION           None                                            }
{ REVISION HISTORY      Dima Stefankov (DS)                             }
{                       0.01   13-Sep-94  DS  initial release           }
{-----------------------------------------------------------------------}



UNIT
     DemoMode;


INTERFACE

USES
    Dos,
    Globals,
    StrLib;


FUNCTION    _fnliCurrentBiosTimeCount : System.Longint;
PROCEDURE   _WaitMoreSecondsDiv18(dwTimes : System.Word);
PROCEDURE   _WaitMoreSeconds(dwSeconds : System.Word);
PROCEDURE   _InitStringToSimulateUserInput(sUserToSimulate : STRING);
PROCEDURE   _SetupTimerIntInSimulationMode;


IMPLEMENTATION


FUNCTION
        _fnliCurrentBiosTimeCount : System.Longint;
{*
Description.
       Reads current time counters from BIOS data area.
*}
BEGIN
   _fnliCurrentBiosTimeCount := System.MemL[Globals.aBiosDataSeg:Globals.addDayTimeCounter];
END;
{ _fnliCurrentBiosTimeCount }



PROCEDURE
         _WaitMoreSecondsDiv18(dwTimes : System.Word);
{*
Description.
     Time-independent waiting cycle based on BIOS service.
*}
VAR
  liInitValue,
  liCurrentValue   :  System.Longint;

BEGIN
  liInitValue := _fnliCurrentBiosTimeCount;

  REPEAT
     liCurrentValue := _fnliCurrentBiosTimeCount;
  UNTIL System.Word(liCurrentValue - liInitValue) >= dwTimes;
  {repeat-until}
END;
{ _WaitMoreSecondsDiv18 }



PROCEDURE
         _WaitMoreSeconds(dwSeconds : System.Word);
{*
Description.
         Time-independent waiting cycle based on BIOS service.
*}
VAR
  liInitValue,
  liCurrentValue   :  System.Longint;

BEGIN
  liInitValue := _fnliCurrentBiosTimeCount;
  REPEAT
     liCurrentValue := _fnliCurrentBiosTimeCount;
  UNTIL System.Word(liCurrentValue - liInitValue) >= (dwSeconds*18);
  {repeat-until}
END;
{ _WaitMoreSeconds }



PROCEDURE
         _PushSymToKbdBuf(chSymToPush : System.Char); ASSEMBLER;
{*
Description.
    Pushes a character to the BIOS keyboard buffer if space is enough.
*}
ASM
              mov       ax, Globals.aBiosDataSeg
              mov       es, ax
              mov       al, chSymToPush
              sub       ah, ah
              mov       bx, es:[Globals.adwKbdBufTail]
              mov       si, bx
              inc       bx
              inc       bx
              cmp       bx, es:[Globals.adwKbdBufEnd]
              jne      @NoBufWrap
              mov       bx, es:[Globals.adwKbdBufStart]
      @NoBufWrap:
              cmp       bx, es:[Globals.adwKbdBufHead]
              je       @PushDone
              mov       es:[si], ax
              mov       es:[Globals.adwKbdBufTail], bx
      @PushDone:
END;
{asm-end}
{ _PushSymToKbdBuf }



PROCEDURE
         _InitPauseDelayCounters;
{*
Description.
        Initiates time counters.
*}
BEGIN
    Globals.gdwInitTicks := (Globals.gdbPauseDelayInSec * Globals.aTicksPerSecond)
                            DIV Globals.gdbUserTimeFactor;
    Globals.gdwCurTicks := Globals.gdwInitTicks;
END;
{ _InitPauseDelayCounters }



PROCEDURE
         _InitStringToSimulateUserInput(sUserToSimulate : STRING);
{*
Description.
      Initiates a string to simulate user keystrokes. *}
BEGIN
    Globals.gsSimulatedUserInput := sUserToSimulate + Globals.achCR;
    Globals.gdbSimCharsCount := System.Length(gsSimulatedUserInput);
    Globals.gdbSimCharsStrOfs := 1;
    _InitPauseDelayCounters;
END;
{ _InitStringToSimulateUserInput }



PROCEDURE
          _TimerIntHandler; INTERRUPT;
{*
Description.
        Service of timer interrupt.
*}
BEGIN
    ASM
           pushf
           call   DWORD PTR  [Globals.glpCurIntVec08]
    END;
    {asm-end}
    IF  ((Globals.gdwCurTicks <> 0)  AND
         (Globals.gbDemoModeOK))
      THEN  System.Dec(Globals.gdwCurTicks);
    {if-then}
    IF  ((Globals.gdwCurTicks = 0)  AND
         (Globals.gdbSimCharsCount <> 0))
      THEN  BEGIN
         Globals.gdwCurTicks := Globals.gdwInitTicks;
         _PushSymToKbdBuf(Globals.gsSimulatedUserInput[Globals.gdbSimCharsStrOfs]);
         System.Inc(Globals.gdbSimCharsStrOfs);
         System.Dec(Globals.gdbSimCharsCount);
            END;
    {if-then}
END;
{ _TimerServiceInt }



PROCEDURE
         _SetupTimerIntInSimulationMode;
{*
Description.
     Sets the out interrupt vector for simulation mode.
*}
BEGIN
   Dos.SetIntVec(Globals.aHardTimerInt,@_TimerIntHandler);
END;
{ _SetupTimerIntInSimulationMode }



{BEGIN}
END.
