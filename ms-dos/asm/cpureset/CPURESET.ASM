                        PAGE    63, 132
                        TITLE   CPU Shutdown Method To Get Initial Values of Registers


; Name                  CPURESET.ASM
; Purpose               CPU Shutdown Method (Through BIOS)
; Version/Date          1.0   4/21/94           original
;                       1.1   4/26/94           added 486 support
;                       1.2   8/13/94           added cache/queue results
;                       1.3   5/16/98           fixed Pentium bugs
;                                               added memory dump
; Author                Dmitry Stefankov
; Machine               286,386,486 -based computers
; BIOS                  Any
; Chip Set              Any
; Copyright Notice      Copyright (c) 1994 Dmitry Stefankov
; Distribution          Only for Evaluation Purpose


        bFalse          =       0
        bTrue           =       1

        swEmulationIO           =       bFalse
;*      swEmulationReset        =       bFalse
        swMasm60                =       bTrue
        swCheckCmosWrite        =       bTrue
        swWorkAroundPM_STD      =       bFalse
        swTestCacheQueue        =       bFalse
        swUseShadowRam          =       bFalse
        swUsePentium            =       bTrue
        swWriteDumpFile         =       bFalse
        swStdWaitInResetCode    =       bFalse
        swWorkAroundMemBug      =       bTrue
        swWorkAroundTRreg       =       bTrue
        swWorkAroundStackBug    =       bFalse

         aDelay486Count         =       2
         aNopCount              =       2

         errTerminateOk         =       0
         errProtectedMode       =       1
         errShutdownFailed      =       2
         errNon80x86uP          =       3
         errBadCmosWrite        =       4

        sBlanks                 EQU     <'  '>
        chAsterisk              EQU     <'*'>
        chBlank                 EQU     <' '>

        ioCmosIndex             =       70h
        ioCmosData              =       ioCmosIndex + 1
        btNmiOff                =       80h
        regShutdownCode         =       0Fh
        aShutdownCode10         =       10
        
        ioKbdCntlrOutPort       =       64h
        btPulseResetCpu         =       0FEh

        ioPM486DX2              =       0EBh

        aDosDispChar            =       02h
        aDosDispMessage         =       09h
        aDosTerminateProcess    =       4Ch


        mac@InBytePort          MACRO   Port, Value
                IFNB    <Value>
                        mov     al, Value
                ENDIF
                IFNB    <Port>
                        IF      Port    GE      100h
                                mov     dx, Port
                                in      al, dx
                        ELSE
                                in      al, Port
                        ENDIF
                ELSE
                        in      al, dx
                ENDIF
                                ENDM

        mac@OutBytePort         MACRO   Port, Value
                IFNB    <Value>
                        mov     al, Value
                ENDIF
                IFNB    <Port>
                        IF      Port    GE      100h
                                mov     dx, Port
                                out     dx, al
                        ELSE
                                out     Port, al
                        ENDIF
                ELSE
                        out     dx, al
                ENDIF
                                ENDM


        mac@OutWordPort         MACRO   Port, Value
                IFNB    <Value>
                        mov     ax, Value
                ENDIF
                IFNB    <Port>
                        IF      Port    GE      100h
                                mov     dx, Port
                                out     dx, ax
                        ELSE
                                out     Port, ax
                        ENDIF
                ELSE
                        out     dx, ax
                ENDIF
                                ENDM

        mac@EmptyOperation      MACRO   Times
                        IFNB    <Times>
                          REPT  Times
                                nop
                          ENDM
                        ENDIF
                                ENDM

        
        mac@DelayIO_486         MACRO
                        LOCAL   @D
                                jmp     SHORT   @D
                          @D:
                                ENDM


        mac@DelayIO             MACRO   Times
                        IFNB    <Times>
                         REPT   Times
                                mac@DelayIO_486
                         ENDM
                        ENDIF           
                                ENDM

        mac@WordRegToMem        MACRO   reg, memw
                mov     WORD PTR memw, reg
                        ENDM

        mac@WordMemToReg        MACRO   memw, reg
                mov     reg, WORD PTR memw
                        ENDM


        mac@DoubleWordRegToMem  MACRO   reg, memd
                mov     memd, reg
                        ENDM

        mac@DoubleWordMemToReg  MACRO   memd, reg
                mov     reg, memd
                        ENDM

        mac@DosInterface        MACRO   FnAX, FnAH, FnAL
                        IFNB    <FnAX>
                                MOV     ax, FnAX
                        ENDIF
                        IFNB    <FnAH>
                                MOV     ah, FnAH
                        ENDIF
                        IFNB    <FnAL>
                                MOV     al, FnAL
                        ENDIF
                        int     21h
                                ENDM

        mac@DisplayMessage      MACRO   msg
                mov     dx, OFFSET  msg
                call    _DisplayMessage
                                ENDM

        mac@DisplayWordReg      MACRO   msg, mem
                mac@DisplayMessage      <msg>
                mov     ax, mem
                call    _PrintHexWordAX         
                                ENDM

        mac@DisplayDoubleWordReg        MACRO   msg, mem
                mac@DisplayMessage      <msg>
                mov     eax, mem
                call    _PrintHexDoubleWordEAX          
                                        ENDM

        mac@DispCompWords       MACRO   srcmem, destmem
                mov     ax, srcmem
                mov     bx, destmem
                call    _CompareWords
                                ENDM

        mac@DispCompDoubleWords MACRO   srcmem, destmem
                mov     eax, srcmem
                mov     ebx, destmem
                call    _CompareDoubleWords
                                ENDM

        IF      swMasm60
                IF      swUsePentium
                .586P
                ELSE
                .486P
                ENDIF
        ELSE
                .386P
        ENDIF
        

        BIOS_DATA       SEGMENT  USE16  AT  40h
                ASSUME DS:BIOS_DATA
                ORG  67h
dwJump_IP       dw      ?
dwJump_CS       dw      ?
        BIOS_DATA       ENDS


        BIOS_ROM        SEGMENT  USE16  AT  0F000h
                ASSUME  CS:BIOS_ROM
                ORG  0FFF0h
@lpInit_Rom_Bios_Entry  LABEL   FAR
        BIOS_ROM        ENDS


        CODE    SEGMENT DWORD PUBLIC USE16  'CODE'
        ASSUME  CS:CODE, DS:CODE, SS:STACK
                
                EVEN
        ddUserEFlags            dd      0
        ddUserEAX               dd      0
        ddUserEBX               dd      0
        ddUserECX               dd      0
        ddUserEDX               dd      0
        ddUserESI               dd      0
        ddUserEDI               dd      0
        ddUserEBP               dd      0
        ddUserESP               dd      0
        ddUserCR0               dd      0
        ddUserCR2               dd      0
        ddUserCR3               dd      0
        ddUserDR0               dd      0
        ddUserDR1               dd      0
        ddUserDR2               dd      0
        ddUserDR3               dd      0
        ddUserDR6               dd      0
        ddUserDR7               dd      0
        ddUserTR3               dd      0
        ddUserTR4               dd      0
        ddUserTR5               dd      0
        ddUserTR6               dd      0
        ddUserTR7               dd      0

        dwUserMSW               dw      0
        dwUserFlags             dw      0
        dwUserCS                dw      0
        dwUserDS                dw      0
        dwUserES                dw      0
        dwUserSS                dw      0
        dwUserFS                dw      0
        dwUserGS                dw      0

                ALIGN   4
        ddEFlags                dd      0
        ddEAX                   dd      0
        ddEBX                   dd      0
        ddECX                   dd      0
        ddEDX                   dd      0
        ddESI                   dd      0
        ddEDI                   dd      0
        ddEBP                   dd      0
        ddESP                   dd      0
        ddCR0                   dd      0
        ddCR2                   dd      0
        ddCR3                   dd      0
        ddDR0                   dd      0
        ddDR1                   dd      0
        ddDR2                   dd      0
        ddDR3                   dd      0
        ddDR6                   dd      0
        ddDR7                   dd      0
        ddTR6                   dd      0
        ddTR7                   dd      0
        ddTR3                   dd      0
        ddTR4                   dd      0
        ddTR5                   dd      0
                EVEN
        dwFlags                 dw      0
        dwMSW                   dw      0
        dwCS                    dw      0
        dwDS                    dw      0
        dwES                    dw      0
        dwSS                    dw      0
        dwFS                    dw      0
        dwGS                    dw      0
                EVEN
        bFlag286                db      bFalse
        bFlag486                db      bFalse
                EVEN
        dwCacheCount            dw      0
                EVEN
        ddOldBiosImage          dd      0

        szBlanks                db      sBlanks
                                db      '$'

        szHello                 db      13, 10
                                db      'CpuReset V1.3, Copyright (c) 1994, 1998 Dmitry Stefankov'
                                db      '$'

        szNon80x86uP            db      13, 10
                                db      'CpuReset: Requires 80x86 processor.'
                                db      '$'

        szEmulateReset          db      13, 10
                                db      'CpuReset: Emulation method -> jump to F000:FFF0.'
                                db      '$'

        szDone                  db      13, 10
                                db      'CpuReset: Done.'
                                db      13, 10
                                db      '$'

        szShutdownFalied        db      13, 10
                                db      'CpuReset: Shutdown action failed.'
                                db      '$'

        sz286_Found             db      13, 10
                                db      'CpuReset: 286 processor or compatible found.'
                                db      '$'
        sz386_Found             db      13, 10
                                db      'CpuReset: 386 processor or compatible found.'
                                db      '$'
        sz486_Found             db      13, 10
                                db      'CpuReset: 486+ processor or compatible found.'
                                db      '$'

        szProtModeFound         db      13, 10
                                db      'CpuReset: Protected Mode found. Unable to run.'
                                db      '$'

        szBadCmosWrite          db      13,10
                                db      'CpuReset: CMOS write failure. Unable to continue.'
                                db      '$'

        szDoShutDown            db      13, 10
                                db      'CpuReset: Do a CPU shutdown, * => new value (general/segment/state).'
                                db      '$'

        szCRLF                  db      13, 10
                                db      '$'

        szCpu286_CS             db      13, 10 
                                db      'CpuReset: 16-bit Segment Registers.'
                                db      13, 10
                                db      sBlanks
                                db      'CS = '
                                db      '$'
        szCpu286_DS             db      sBlanks
                                db      'DS = '
                                db      '$'
        szCpu286_ES             db      sBlanks
                                db      'ES = '
                                db      '$'
        szCpu286_SS             db      sBlanks
                                db      'SS = '
                                db      '$'
        szCpu386_FS             db      sBlanks
                                db      'FS = '
                                db      '$'
        szCpu386_GS             db      sBlanks
                                db      'GS = '
                                db      '$'

        szCpu286_AX             db      13, 10 
                                db      'CpuReset: 16-bit General/Index/Stack Registers.'
                                db      13, 10
                                db      sBlanks  
                                db      'AX = '
                                db      '$'
        szCpu286_BX             db      sBlanks
                                db      'BX = '
                                db      '$'
        szCpu286_CX             db      sBlanks
                                db      'CX = '
                                db      '$'
        szCpu286_DX             db      sBlanks
                                db      'DX = '
                                db      '$'

        szCpu286_SI             db      13, 10 
                                db      sBlanks
                                db      'SI = '
                                db      '$'
        szCpu286_DI             db      sBlanks
                                db      'DI = '
                                db      '$'
        szCpu286_BP             db      sBlanks
                                db      'BP = '
                                db      '$'
        szCpu286_SP             db      sBlanks
                                db      'SP = '
                                db      '$'


        szCpu386_EAX            db      13, 10 
                                db      'CpuReset: 32/16-bit General/Index/Stack Registers.'
                                db      13, 10
                                db      sBlanks  
                                db      'EAX = '
                                db      '$'
        szCpu386_EBX            db      sBlanks
                                db      'EBX = '
                                db      '$'
        szCpu386_ECX            db      sBlanks
                                db      'ECX = '
                                db      '$'
        szCpu386_EDX            db      sBlanks
                                db      'EDX = '
                                db      '$'

        szCpu386_ESI            db      13, 10 
                                db      sBlanks  
                                db      'ESI = '
                                db      '$'
        szCpu386_EDI            db      sBlanks                                
                                db      'EDI = '
                                db      '$'
        szCpu386_EBP            db      sBlanks
                                db      'EBP = '
                                db      '$'
        szCpu386_ESP            db      sBlanks
                                db      'ESP = '
                                db      '$'

        szCpu386_CR0            db      13, 10 
                                db      'CpuReset: 32-bit Control Registers.'
                                db      13, 10
                                db      sBlanks  
                                db      'CR0 = '
                                db      '$'
        szCpu386_CR2            db      sBlanks
                                db      'CR2 = '
                                db      '$'
        szCpu386_CR3            db      sBlanks
                                db      'CR3 = '
                                db      '$'
                                
IF      swWorkAroundMemBug
        DB      32      DUP(055h)
ENDIF        

        szCpu386_DR0            db      13, 10 
                                db      'CpuReset: 32-bit Debug Registers.'
                                db      13, 10
                                db      sBlanks  
                                db      'DR0 = '
                                db      '$'
        szCpu386_DR1            db      sBlanks
                                db      'DR1 = '
                                db      '$'
        szCpu386_DR2            db      sBlanks
                                db      'DR2 = '
                                db      '$'
        szCpu386_DR3            db      sBlanks
                                db      'DR3 = '
                                db      '$'
        szCpu386_DR6            db      13, 10
                                db      sBlanks 
                                db      'DR6 = '
                                db      '$'
        szCpu386_DR7            db      sBlanks
                                db      'DR7 = '
                                db      '$'

        szCpu386_TestRegs       db      13, 10 
                                db      'CpuReset: 32-bit Test Registers.'
                                db      '$'
        szCpu486_TR3            db      13, 10
                                db      sBlanks
                                db      'TR3 = '
                                db      '$'
        szCpu486_TR4            db      sBlanks
                                db      'TR4 = '
                                db      '$'
        szCpu486_TR5            db      sBlanks
                                db      'TR5 = '
                                db      '$'
        szCpu386_TR6            db      13, 10
                                db      sBlanks
                                db      'TR6 = '
                                db      '$'
        szCpu386_TR7            db      sBlanks
                                db      'TR7 = '
                                db      '$'

        szCpu386_Status         db      13, 10 
                                db      'CpuReset: Processor State.'
                                db      13, 10
                                db      sBlanks  
                                db      'EFLAGS = '
                                db      '$'

        szCpu286_Status         db      13, 10 
                                db      'CpuReset: Processor State.'
                                db      13, 10
                                db      sBlanks  
                                db      'FLAGS = '
                                db      '$'
        szCpu286_MSW            db      sBlanks
                                db      'MSW = '
                                db      '$'

        szCacheTimes            db      13, 10 
                                db      'CpuReset: Cache/Queue Results.'
                                db      13, 10
                                db      sBlanks  
                                db      'Count = '
                                db      '$'
IF  swWriteDumpFile
        szDumpFile01      DB      'cpureset.d01',0
        szDumpFile02      DB      'cpureset.d02',0
ENDIF

        @Start:
                mov     ax, cs
                mov     ds, ax

                mac@DisplayMessage  szHello

        @TestNon80x86:
                xor     ax, ax
                push    ax
                popf
                pushf
                pop     ax
                and     ax, 0F000h
                cmp     ax, 0F000h
                jne     SHORT   @Found80x86

                mac@DisplayMessage      szNon80x86uP
                mov     al, errNon80x86uP

                jmp     SHORT  @ExitToDos       

        @Found80x86:
                pushf
                pop     ax
                or      ax,0F000h
                push    ax
                popf
                pushf
                pop     ax
                test    ax,0F000h
                jnz   SHORT @CPU_386_Found

        @CPU286_Found:
                mov     BYTE PTR bFlag286, bTrue
                mov     dx, OFFSET sz286_Found
                jmp   SHORT   @DisplayCpuType   

        @CPU_386_Found:
                push    ebx
                push    ecx
                mov     si, sp
                and     sp,0FFFCh
                pushfd
                pop     ebx
                mov     ecx,ebx
                xor     ebx,40000h
                push    ebx
                popfd
                pushfd
                pop     ebx
                xor     ebx,ecx
                mov     dx, OFFSET sz386_Found
                test    ebx,40000h
                jz      SHORT @CPU_Type_Found
        @CPU486_Found:
                mov     dx, OFFSET sz486_Found
                mov     bFlag486, bTrue

        @CPU_Type_Found:
                push    ecx
                popfd
                mov     sp, si
                pop     ecx
                pop     ebx

        @DisplayCpuType:
                call    _DisplayMessage

        @Test_PM:
                smsw    ax
                test    ax, 1
                jz      SHORT  @RealModeFound

                mac@DisplayMessage      szProtModeFound
                mov     al, errProtectedMode

        @ExitToDos:
                mac@DisplayMessage      szDone
                mac@DosInterface        ,aDosTerminateProcess

        @RealModeFound:
                mac@DisplayMessage      szDoShutDown

        @SetupBiosVariables:
                cli
                mov     ax, SEG BIOS_DATA
                mov     es, ax
                ASSUME  ES:BIOS_DATA
                mov     ax, OFFSET @ReturnFromShutdown286
                cmp     bFlag286, bTrue
                je     SHORT @PutShutdownCodeReturnAddress
                mov     ax, OFFSET @ReturnFromShutdown386
        @PutShutdownCodeReturnAddress:
        IF      swUseShadowRam
                push    eax
                mov     ax, SEG BIOS_ROM
                mov     es, ax
                ASSUME  ES:BIOS_ROM
                mov     eax, DWORD PTR @lpInit_Rom_Bios_Entry+1
                mov     DWORD PTR cs:ddOldBiosImage, eax
                pop     eax
                mov     WORD PTR es:[@lpInit_Rom_Bios_Entry+1], ax
                mov     WORD PTR es:[@lpInit_Rom_Bios_Entry+3], cs
        ELSE
                mac@WordRegToMem        ax, <es:dwJump_IP>
                mac@WordRegToMem        cs, <es:dwJump_CS>
;;**            mov     es:dwJump_IP, ax
;;**            mov     es:dwJump_CS, cs
        ENDIF

        @SaveRegsToFurtherTest:
                mov     ax, cs
                mov     es, ax
                mac@WordRegToMem        cs, dwUserCS
                mac@WordRegToMem        es, dwUserES
                mac@WordRegToMem        ss, dwUserSS
                mac@WordRegToMem        ds, dwUserDS

                cmp     bFlag286, bTrue
                jne    SHORT @PutTestValues386

        @PutTestValues286:
                mov     ax, 55AAh
                mov     bx, ax
                mov     cx, ax
                mov     dx, ax
                mov     si, ax
                mov     di, ax
                mov     bp, ax
        @SaveUserRegs286:
                mac@WordRegToMem        ax, ddUserEAX
                mac@WordRegToMem        bx, ddUserEBX
                mac@WordRegToMem        cx, ddUserECX
                mac@WordRegToMem        dx, ddUserEDX
                mac@WordRegToMem        si, ddUserESI
                mac@WordRegToMem        di, ddUserEDI
                mac@WordRegToMem        sp, ddUserESP
                mac@WordRegToMem        bp, ddUserEBP
                smsw    dwUserMSW
                pushf
                pop     ax
                mac@WordRegToMem        ax, dwUserFlags
                jmp    SHORT @UserRegsSaveDone

        @PutTestValues386:
                mov     eax, 05555AAAAh
                mov     fs, ax
                mov     gs, ax
                mov     ebx, eax
                mov     ecx, eax
                mov     edx, eax
                mov     esi, eax
                mov     edi, eax
                mov     ebp, eax
        @SaveUserRegs386:
IF  swWriteDumpFile
                pusha
                pushf
                mov     ah, 3Ch
                mov     cx, 0
                mov     dx, OFFSET szDumpFile01
                int     21h
                jc     @F
                mov     bx, ax
                mov     dx, 0
                mov     cx, OFFSET dwTempTOS
                mov     ah, 40h
                int     21h
                mov     ah, 3Eh
                int     21h
    @@:
                popf
                popa
ENDIF        
                mac@WordRegToMem        fs,  dwUserFS
                mac@WordRegToMem        gs,  dwUserGS
                mac@DoubleWordRegToMem  eax, ddUserEAX
                mac@DoubleWordRegToMem  ebx, ddUserEBX
                mac@DoubleWordRegToMem  ecx, ddUserECX
                mac@DoubleWordRegToMem  edx, ddUserEDX
                mac@DoubleWordRegToMem  esp, ddUserESP
                mac@DoubleWordRegToMem  ebp, ddUserEBP
                mac@DoubleWordRegToMem  esi, ddUserESI
                mac@DoubleWordRegToMem  edi, ddUserEDI
                pushfd
                pop     eax
                mac@DoubleWordRegToMem  eax, <ddEFlags>

        @UserRegsSaveDone:

                call    _DoCpuShutdown

        @ShutdownFailedHere:
                mac@DisplayMessage      szShutdownFalied
                mov     al, errShutdownFailed
                jmp    @ExitToDos               

        @ReturnFromShutdown286:
                mac@WordRegToMem        cs,  <cs:dwCS>
                mac@WordRegToMem        ds,  <cs:dwDS>
                mac@WordRegToMem        es,  <cs:dwES>
                mac@WordRegToMem        ss,  <cs:dwSS>
                mac@WordRegToMem        ax,  <cs:ddEAX+0>
                mac@WordRegToMem        bx,  <cs:ddEBX+0>
                mac@WordRegToMem        cx,  <cs:ddECX+0>
                mac@WordRegToMem        dx,  <cs:ddEDX+0>
                mac@WordRegToMem        si,  <cs:ddESI+0>
                mac@WordRegToMem        di,  <cs:ddEDI+0>
                mac@WordRegToMem        bp,  <cs:ddEBP+0>
                mac@WordRegToMem        sp,  <cs:ddESP+0>
                smsw    cs:dwMSW
                mov     ax, cs
                mov     ss, ax
                mov     sp, OFFSET dwTempTOS
                pushf
                pop     ax
                mac@WordRegToMem        ax,  <cs:cs:dwFlags>
                jmp    @RestoreSomeUsefulRegs

        @ReturnFromShutdown386:
IF  swWorkAroundStackBug
                mov     ss, cs:dwUserSS                
                mov     sp, word ptr cs:ddUserESP
ENDIF        
                mac@WordRegToMem        cs,  <cs:dwCS>
                mac@WordRegToMem        ds,  <cs:dwDS>
                mac@WordRegToMem        es,  <cs:dwES>
                mac@WordRegToMem        ss,  <cs:dwSS>
                mac@WordRegToMem        fs,  <cs:dwFS>
                mac@WordRegToMem        gs,  <cs:dwGS>
                mac@DoubleWordRegToMem  eax, <cs:ddEAX>
                mac@DoubleWordRegToMem  ebx, <cs:ddEBX>
                mac@DoubleWordRegToMem  ecx, <cs:ddECX>
                mac@DoubleWordRegToMem  edx, <cs:ddEDX>
                mac@DoubleWordRegToMem  esi, <cs:ddESI>
                mac@DoubleWordRegToMem  edi, <cs:ddEDI>
                mac@DoubleWordRegToMem  ebp, <cs:ddEBP>
                mac@DoubleWordRegToMem  esp, <cs:ddESP>

                mov     eax, cr0
                mac@DoubleWordRegToMem  eax, <cs:ddCR0>
                mov     eax, cr2
                mac@DoubleWordRegToMem  eax, <cs:ddCR2>
                mov     eax, cr3
                mac@DoubleWordRegToMem  eax, <cs:ddCR3>

                mov     eax, dr0
                mac@DoubleWordRegToMem  eax, <cs:ddDR0>
                mov     eax, dr1
                mac@DoubleWordRegToMem  eax, <cs:ddDR1>
                mov     eax, dr2
                mac@DoubleWordRegToMem  eax, <cs:ddDR2>
                mov     eax, dr3

                mac@DoubleWordRegToMem  eax, <cs:ddDR3>
                mov     eax, dr6
                mac@DoubleWordRegToMem  eax, <cs:ddDR6>
                mov     eax, dr7
IF  swWorkAroundTRreg
ELSE
                mac@DoubleWordRegToMem  eax, <cs:ddDR7>
                mov     eax, tr6
                mac@DoubleWordRegToMem  eax, <cs:ddTR6>
                mov     eax, tr7
                mac@DoubleWordRegToMem  eax, <cs:ddTR7>
ENDIF
                mov     ax, cs
                mov     ss, ax
                mov     sp, OFFSET dwTempTOS
                pushfd
                pop     eax
                mac@DoubleWordRegToMem  eax, <cs:ddEFlags>

                cmp     cs:bFlag486, bTrue
                jne   SHORT @Skip486CacheRegs

IF  swWorkAroundTRreg
ELSE
        IF      swMasm60
                mov     eax, tr3
        ELSE
                db      00Fh, 024h, 0D8h
        ENDIF
                mac@DoubleWordRegToMem  eax, <cs:ddTR3>
        IF      swMasm60
                mov     eax, tr4
        ELSE
                db      00Fh, 024h, 0E0h
        ENDIF
                mac@DoubleWordRegToMem  eax, <cs:ddTR4>

        IF      swMasm60        
                mov     eax, tr5
        ELSE
                db      00Fh, 024h, 0E8h
        ENDIF
                mac@DoubleWordRegToMem  eax, <cs:ddTR5>
ENDIF        

        @Skip486CacheRegs:

        IF      swUseShadowRam
                mov     ax, SEG BIOS_ROM
                mov     es, ax
                ASSUME  ES:BIOS_ROM
                mov     eax, cs:ddOldBiosImage
                mov     DWORD PTR es:[@lpInit_Rom_Bios_Entry+1], eax
        ENDIF
        @RestoreSomeUsefulRegs:
IF  swWorkAroundStackBug
                mov     ds, cs:dwUserDS
ELSE        
                cli
                mov     ds, cs:dwUserDS
                mov     ss, dwUserSS                
                mov     sp, word ptr ddUserESP
ENDIF                
                sti
IF  swWriteDumpFile
                mov     ah, 3Ch
                mov     cx, 0
                mov     dx, OFFSET szDumpFile02
                int     21h
                jc     @F
                mov     bx, ax
                mov     dx, 0
                mov     cx, OFFSET dwTempTOS
                mov     ah, 40h
                int     21h
                mov     ah, 3Eh
                int     21h
    @@:
ENDIF
                cmp     bFlag286, bTrue
                je   SHORT  @DispRegs286
                jmp    @DispRegs386

        @DispRegs286:
                mac@DisplayWordReg      szCpu286_AX, <word ptr ddEAX+0>
                mac@DispCompWords       <word ptr ddEAX+0>, <word ptr ddUserEAX+0>
                mac@DisplayWordReg      szCpu286_BX, <word ptr ddEBX+0>
                mac@DispCompWords       <word ptr ddEBX+0>, <word ptr ddUserEBX+0>
                mac@DisplayWordReg      szCpu286_CX, <word ptr ddECX+0>
                mac@DispCompWords       <word ptr ddECX+0>, <word ptr ddUserECX+0>
                mac@DisplayWordReg      szCpu286_DX, <word ptr ddEDX+0>
                mac@DispCompWords       <word ptr ddEDX+0>, <word ptr ddUserEDX+0>
                mac@DisplayWordReg      szCpu286_SI, <word ptr ddESI+0>
                mac@DispCompWords       <word ptr ddESI+0>, <word ptr ddUserESI+0>
                mac@DisplayWordReg      szCpu286_DI, <word ptr ddEDI+0>
                mac@DispCompWords       <word ptr ddEDI+0>, <word ptr ddUserEDI+0>
                mac@DisplayWordReg      szCpu286_BP, <word ptr ddEBP+0>
                mac@DispCompWords       <word ptr ddEBP+0>, <word ptr ddUserEBP+0>
                mac@DisplayWordReg      szCpu286_SP, <word ptr ddESP+0>
                mac@DispCompWords       <word ptr ddESP+0>, <word ptr ddUserESP+0>

                call    _PrintSegmentRegistersValues

                mac@DisplayWordReg      szCpu286_Status, <dwFlags>
                mac@DispCompWords       <dwFlags>, <dwUserFlags>
                mac@DisplayWordReg      szCpu286_MSW, <dwMSW>
                mac@DispCompWords       <dwMSW>, <dwUserMSW>

                jmp     @DispRegsDone

        @DispRegs386:
                mac@DisplayDoubleWordReg        szCpu386_EAX, <ddEAX>
                mac@DispCompDoubleWords         <ddEAX>, <ddUserEAX>
                mac@DisplayDoubleWordReg        szCpu386_EBX, <ddEBX>
                mac@DispCompDoubleWords         <ddEBX>, <ddUserEBX>
                mac@DisplayDoubleWordReg        szCpu386_ECX, <ddECX>
                mac@DispCompDoubleWords         <ddECX>, <ddUserECX>
                mac@DisplayDoubleWordReg        szCpu386_EDX, <ddEDX>
                mac@DispCompDoubleWords         <ddEDX>, <ddUserEDX>
                mac@DisplayDoubleWordReg        szCpu386_ESI, <ddESI>
                mac@DispCompDoubleWords         <ddESI>, <ddUserESI>
                mac@DisplayDoubleWordReg        szCpu386_EDI, <ddEDI>
                mac@DispCompDoubleWords         <ddEDI>, <ddUserEDI>
                mac@DisplayDoubleWordReg        szCpu386_EBP, <ddEBP>
                mac@DispCompDoubleWords         <ddEBP>, <ddUserEBP>
                mac@DisplayDoubleWordReg        szCpu386_ESP, <ddESP>
                mac@DispCompDoubleWords         <ddESP>, <ddUserESP>

                call    _PrintSegmentRegistersValues

                mac@DisplayDoubleWordReg        szCpu386_Status, <ddEFlags>
                mac@DispCompDoubleWords         <ddEFlags>, <ddUserEFlags>

                mac@DisplayDoubleWordReg        szCpu386_CR0, <ddCR0>
                mac@DisplayDoubleWordReg        szCpu386_CR2, <ddCR2>
                mac@DisplayDoubleWordReg        szCpu386_CR3, <ddCR3>

                mac@DisplayDoubleWordReg        szCpu386_DR0, <ddDR0>
                mac@DisplayDoubleWordReg        szCpu386_DR1, <ddDR1>
                mac@DisplayDoubleWordReg        szCpu386_DR2, <ddDR2>
                mac@DisplayDoubleWordReg        szCpu386_DR3, <ddDR3>

                mac@DisplayDoubleWordReg        szCpu386_DR6, <ddDR6>
                mac@DisplayDoubleWordReg        szCpu386_DR7, <ddDR7>

IF  swWorkAroundTRreg
ELSE
                mac@DisplayMessage      szCpu386_TestRegs
                
                cmp     bFlag486, bTrue
                jne    SHORT  @Skip486TestRegs

                mac@DisplayDoubleWordReg        szCpu486_TR3, <ddTR3>
                mac@DisplayDoubleWordReg        szCpu486_TR4, <ddTR4>
                mac@DisplayDoubleWordReg        szCpu486_TR5, <ddTR5>

        @Skip486TestRegs:
                mac@DisplayDoubleWordReg        szCpu386_TR6, <ddTR6>
                mac@DisplayDoubleWordReg        szCpu386_TR7, <ddTR7>
ENDIF

        @DispRegsDone:
        IF      swTestCacheQueue
                mac@DisplayWordReg      szCacheTimes, <dwCacheCount>
        ENDIF
                mov     al, errTerminateOk
                jmp    @ExitToDos               


        _DoCpuShutdown          PROC    NEAR
                cli
                mac@OutBytePort ioCmosIndex, <(btNmiOff + regShutdownCode)>
        IF      swWorkAroundPM_STD
                mac@OutWordPort ioPM486DX2
        ENDIF
                mac@DelayIO     aDelay486Count
                mac@OutBytePort ioCmosData, aShutdownCode10
                mac@DelayIO     aDelay486Count

        IF      swCheckCmosWrite
                mac@OutBytePort ioCmosIndex, <(btNmiOff + regShutdownCode)>
        IF      swWorkAroundPM_STD
                mac@OutWordPort ioPM486DX2
        ENDIF
                mac@DelayIO     aDelay486Count
                mac@InBytePort  ioCmosData
                cmp     al, aShutdownCode10
                je     SHORT  @GoodCmosWrite

                mac@DisplayMessage      szBadCmosWrite
                mov     al, errBadCmosWrite
                jmp    @ExitToDos
        @GoodCmosWrite:
        ENDIF
        IF      swEmulationReset
                push    dx
                mac@DisplayMessage      szEmulateReset
                pop     dx
        IF      swTestCacheQueue
                REPT    512
                inc     cs:dwCacheCount
                ENDM
        ENDIF
                jmp      @lpInit_Rom_Bios_Entry
        ELSE
                mac@OutBytePort ioKbdCntlrOutPort, btPulseResetCpu
        IF      swWorkAroundPM_STD
                mac@OutWordPort ioPM486DX2
        ENDIF
        IF      swTestCacheQueue
                REPT    1024
                inc     cs:dwCacheCount
                ENDM
        ENDIF
        ENDIF
@@:
IF      swStdWaitInResetCode
                cli
@@:             hlt
                jmp @B
ELSE
                hlt
ENDIF                
                ret


        _DoCpuShutdown          ENDP


        _PrintHexNibbleAL       PROC    NEAR
                push    ax
                push    dx
                and     al, 0Fh
                cmp     al, 9
                jbe    SHORT @F
                add     al, 'A'-'9'-1
        @@:
                add     al, '0'
                mov     dl, al
                mac@DosInterface        ,aDosDispChar
                pop     dx
                pop     ax
                ret
        _PrintHexNibbleAL       ENDP


        _PrintHexByteAL         PROC    NEAR
                push    ax
                push    ax
                shr     al, 4
                call    _PrintHexNibbleAL
                pop     ax
                and     al, 0Fh
                call    _PrintHexNibbleAL
                pop     ax
                ret
        _PrintHexByteAL ENDP


        _PrintHexWordAX         PROC    NEAR
                push    ax
                push    ax
                mov     al, ah
                call    _PrintHexByteAL
                pop     ax
                call    _PrintHexByteAL
                pop     ax
                ret
        _PrintHexWordAX         ENDP


        _PrintHexDoubleWordEAX          PROC    NEAR
                push    eax
                push    eax
                shr     eax, 16
                call    _PrintHexWordAX
                pop     eax
                call    _PrintHexWordAX
                pop     eax
                ret
        _PrintHexDoubleWordEAX          ENDP


        _DisplayMessage PROC    NEAR
                push    ax
                mac@DosInterface        ,aDosDispMessage
                pop     ax
                ret
        _DisplayMessage ENDP


        _CompareWords           PROC    NEAR
                push    ax
                push    bx
                push    dx
                mov     dl, chBlank
                cmp     ax, bx
                je    SHORT  @MatchFound
                mov     dl, chAsterisk
         @MatchFound:
                mac@DosInterface        ,aDosDispChar
                pop     dx
                pop     bx
                pop     ax
                ret
        _CompareWords           ENDP


        _CompareDoubleWords             PROC    NEAR
                push    eax
                push    ebx
                push    dx
                mov     dl, chBlank
                cmp     eax, ebx
                je    SHORT  @MatchFoundDouble
                mov     dl, chAsterisk
         @MatchFoundDouble:
                mac@DosInterface        ,aDosDispChar
                pop     dx
                pop     ebx
                pop     eax
                ret
        _CompareDoubleWords             ENDP


        _PrintSegmentRegistersValues    PROC    NEAR
                mac@DisplayWordReg      szCpu286_CS, <dwCS>
                mac@DispCompWords       <dwCS>, <dwUserCS>
                mac@DisplayWordReg      szCpu286_DS, <dwDS>
                mac@DispCompWords       <dwDS>, <dwUserDS>
                mac@DisplayWordReg      szCpu286_ES, <dwES>
                mac@DispCompWords       <dwES>, <dwUserES>
                mac@DisplayWordReg      szCpu286_SS, <dwSS>
                mac@DispCompWords       <dwSS>, <dwUserSS>

                cmp     bFlag286, bTrue
                je     SHORT @SkipExtraSeg386

                mac@DisplayWordReg      szCpu386_FS, <dwFS>
                mac@DispCompWords       <dwFS>, <dwUserFS>
                mac@DisplayWordReg      szCpu386_GS, <dwGS>
                mac@DispCompWords       <dwGS>, <dwUserGS>

        @SkipExtraSeg386:
                ret
        _PrintSegmentRegistersValues    ENDP


                ALIGN   4
        db      32      DUP     ('TEMPxxxx')
        dwTempTOS       LABEL   WORD


CODE    ENDS


STACK   SEGMENT STACK   'STACK'
        ALIGN   4
        db    256  DUP  ('STACKxxx')
dwTOS   LABEL   WORD
STACK   ENDS


        END     @Start
