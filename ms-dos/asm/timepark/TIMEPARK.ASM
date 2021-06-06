                        PAGE    60,132
                        TITLE   Park Utility V1.10A
                        mac@Break  <General Info>

;-----------------------------------------------------------------
; Name                  TIMEPARK.ASM                             ;
; Purpose               Resident Hard Disk Parker                ;
; Date                  07/24/91                                 ;
; Version               1.00A   01/17/91                         ;
;                       1.20A   07/24/91                         ;
; Programmer            Dmitry Stefankov                         ;
; Copyright Notice      (C) Copyright Dmitry Stefankov 1990,1991 ;
;-----------------------------------------------------------------

                        mac@Break  <Equates,macros,structures>

; equates, macros, structures

        DeLim           EQU     ':'
        MyValue         =       18*60*5         ;5 minutes
        MinParkValue    =       18*5            ;5 seconds
        HookedVecs      =       3               ;08h,13h,2Fh
        Version         EQU    "V1.20B"

; inlude files

        .XLIST
        INCLUDE         MACRODEF.INC            ;definitions
        .LIST

                        mac@Break       <Source  Code>

; ************* AREA #1
; program code

CODE    SEGMENT PARA    PUBLIC  'CODE'
        ASSUME  CS:CODE, DS:CODE, SS:STACK

; DOS predefined labels

                .XLIST
                mac@DosPSP
                .LIST

; reset for EXE-style
                mac@SetORG      <0>

; ========================================
;               variables
; ========================================

        VectorArrayPtr          LABEL   DWORD
         mac@VecEntry   HookedVecs,<TimerHdwrInt,DiskSoftInt,MultiplexInt>

        InitValue       DW      MyValue
        Counter         DW      ?

; program flags bits descriptions

        TimeIntInUse            =       00000001b   ; time int in progress
        DiskIntInUse            =       00000010b   ; disk int in progress
        ParkInUse               =       00000100b   ; need to park heads
        EnableProgram           =       00001000b   ; enable/disable program
        FullMask                =       11111111b
        SysFlags        DW      EnableProgram

        DiskCount       DB      0
        CylinderC       DW      0
        CylinderD       DW      0
        PSPSeg          DW      ?

; ===============================================
;               resident code
; ===============================================

;
; timer interrupt service routine
;

        NewInt08        PROC    FAR

; call old routine

                mac@OldIntCall    off,cs:VectorArrayPtr[3+5*0]  

; save registers

                mac@Save        <ax,ds>                 

; init DS segment register

                mac@MoveToDS    cs,ax
                ASSUME  DS:CODE

;check the our activity

                mac@TestBit  SysFlags,<TimeIntInUse or DiskIntInUse>
                jnz     IntDone

;counter is decremented, zero reached?

                dec     Counter                 
                jz      EnterInt                

; recover world

        IntDone:
                mac@Restore       <ds,ax>       
                iret

; main part to disk park

        EnterInt:
                sti                             ;re-enable interrupts
                mac@SetBit  SysFlags,TimeIntInUse
                call    DiskPark
                call    InitVars
                mac@ResetBit   SysFlags,<FullMask - (TimeIntInUse + ParkInUse)>
                mac@sJump   IntDone
        NewInt08        ENDP

;
; disk interrupt handler
;

        NewInt13        PROC    FAR

;set the disk activity in progress

                or      cs:SysFlags,DiskIntInUse        
                mac@OldIntCall  off,cs:VectorArrayPtr[3+5*1]
                pushf
                call    InitVars

; set all needed bits

                mac@ResetBit   cs:SysFlags,<FullMask - DiskIntInUse>
                mac@SetBit     cs:SysFlags,ParkInUse
                popf
                ret     2
        NewInt13        ENDP

;
; disk heads parking routine
;

        DiskPark        PROC    NEAR
                mac@Save        <cx,dx,si,bx>           ;save registers

; init the varaibles

                mov     bl,DiskCount
                mac@LoadZero     si
                mov     dl,80h                  ;1st hard disk

; parks 1,or disks

        NextDisk:
                mov     cx,CylinderC.[si]       ;CX = max cylinder
                mov     dh,0                    ;head 0
                mov     ah,0Ch                  ;Seek cylinder
                call    DiskOp
                inc     dl                      ;DL = drive
                mac@IncVal    si                ;next word
                mac@IncVal    si
                dec     bl                      ;decr count
                jnz     NextDisk

                mac@Restore   <bx,si,dx,cx>     ;restore regs
                ret
        DiskPark        ENDP

;
; disk BIOS call here
;

        DiskOp          PROC    NEAR
                mac@OldIntCall   off,VectorArrayPtr[3+5*1]      ;emulate the interrupt
                ret
        DiskOp          ENDP

;
; initialize counter
;
        InitVars        PROC    NEAR
                mov     ax,cs:InitValue         ;new counter value
                mov     cs:Counter,ax
                ret
        InitVars        ENDP

;
; multiplex process handler
;
        NewInt2F        PROC    FAR
                cmp     ah,TimeParkID           ;our ID?
                jne     OldCall
                mac@ZeroValue?   al                      ;install?
                jnz     Func_1
                mov     al,Already_Installed    ;put back the program ID
                mov     bx,ExtID                ;additional check
                mac@sJump       Just_Return

        Int_2F_Ret:
                mac@LoadZero   al                        ;AL = good return
        
        Just_Return:
                clc                             ;no errors
                ret     2

        Func_1:
                cmp     al,GetProgInfo          ;subfunction 1
                jne     Func_2
                mov     bx,cs:PSPseg            ;BX = program PSP
                push    cs                      ;ES:DI -> structures array
                pop     es
                mov     di,OFFSET VectorArrayPtr
                mac@sJump       Int_2F_Ret

        Func_2:                                 
                cmp     al,GetSetSystemFlags    ;subfunction 2
                jne     Func_3
                cmp     bl,GetFlags             ;get flags?
                jne     Try_Set_Flags           ;no,then skip
                mov     cx,cs:SysFlags          ;CX = program flags
                mac@sJump       Int_2F_Ret

        Try_Set_Flags:
                cmp     bl,SetFlags             ;set flags?
                jne     Bad_Function
                mov     cs:SysFlags,cx          ;put the new program flags
                mac@sJump       Int_2F_Ret

        Bad_Function:
                mov     al,BadReturn            ;indicate that fails
                stc                             ;set error flag
                ret     2                       ;far return
                
        Func_3:                                 ;subfunction 3 test
                cmp     al,3                    ;filter other subfunctions!
                jne     Bad_Function            
                mov     cs:InitValue,bx         ;BX = new time park value
                call    InitVars                ;reset counter to new value
                mac@sJump  Int_2F_Ret

        OldCall:
                mac@OldJump   cs:VectorArrayPtr[3+5*2]
        NewInt2F        ENDP

;
; text for messages
;

        InitMessage   DB  'Resident Hard Disk Time Park Utility ',Version,'.',CR,LF
                      DB  '(C) Copyright 1990,1991 Dmitry Stefankov. All Rights reserved.',CR,LF
        MsgLen        =   $ - InitMessage

        OnLineHelp    DB  'TIMEPARK accepts the following command line syntax:',CR,LF
                      DB  '  TIMEPARK [Options]',CR,LF
                      DB  '    Options may be preceded by either / or -.',CR,LF
                      DB  '    Valid Options are as follows:',CR,LF
                      DB  '    /h,?,/?    write this help screen,',CR,LF
                      DB  '    /u         remove the program from memory,',CR,LF
                      DB  '    /s:dd      number of seconds to park time value,',CR,LF
                      DB  '    /m:dd      number of minutes to park time value,',CR,LF
                      DB  '    /p         park heads immediately',CR,LF
                      DB  '    /e         enable program',CR,LF
                      DB  '    /d         disable program',CR,LF
                      DB  '  Where: d is the decimal digit, the letters are not case-sensitive,',CR,LF
                      DB  '         the default time to park is 5 minutes, min. value is 5 seconds.',CR,LF,CR,LF
                      DB  '    Example:  TIMEPARK   -M:1 /s:25',CR,LF
                      DB  '$'

        Invalid       DB  'No hard disks present or too many hard disks...',CR,LF,'$'
        Removed       DB  'Successfully removed from memory...',CR,LF,'$'
        ErrorMessage  DB  'Invalid switches found...',CR,LF,'$'
        NotUnInstall  DB  'Unable to removed from memory...',CR,LF,'$'
        Passed        DB  'Passed to existing program...',CR,LF,'$'
        Resident      DB   'Already present in memory...',CR,LF,'$'
        ParkMessage   DB   'Now switch off the power...',CR,LF,'$'
        GoResident    DB   'Stay resident to memory...',CR,LF,'$'

;
; initialization code
;
        Start:

;init data seg reg

                mac@MoveToDS    cs,ax
                ASSUME  DS:CODE

                mov     PSPSeg,es               ;ES = our PSP

;display init message

                mac@WriteHandle  STD_OUTPUT,MsgLen,<OFFSET InitMessage>

; get the disk parameters

                mac@GetDiskParms 80h            ;get the parms
                                                ;1nd hard disk
                or      dl,dl
                jnz     DiskFound

; only 1,or 2 disks supporting

        DisksTooMany:
                mac@LoadOfs  dx,Invalid         ;exit to DOS with error

; exit to DOS

        GoToDos:
                mac@DispStr
                mac@Terminate    01h            ;set ERRORLEVEL = 1

        DiskFound:
                cmp     dl,2                    ;only 2 hard disks supported
                ja      DisksTooMany

; save the disk parms

                mov     DiskCount,dl
                mov     CylinderC,cx

; only one disk drive in system?

                cmp     dl,1                    
                je      Skip2nd

; get disk parms for second drive

                mac@GetDiskParms 81h            
                mov     CylinderD,cx

        Skip2nd:
                nop                             ;I got pleasure!!!
                nop
                nop

; scan the command parameters line

                mov     di,offset @psp_cmd_line_size

        NextChar:
                inc     di                      ;advance a pointer
                call    GetChar
                jne     LookChar
                jmp     ScanDone

        LookChar:
                cmp     al,'?'                  ;check for help
                jne     LookAhead
                jmp     HelpSwitch

        LookAhead:
                cmp     al,'/'                  ;switch prefix?
                je      SwitchFound
                cmp     al,'-'
                je      SwitchFound
                jmp     NextChar

        SwitchFound:
                inc     di                      ;bump a index pointer
                call    GetChar
                jne     LookSwitch
                jmp     ScanDone

        LookSwitch:
                mac@UpperCase   al
                cmp     al,'U'                  ;*remove* command?
                je       TryUninstall
                jmp      Next1

        TryUninstall:
                call    GetInfo                 ;check for resident
                jc      TestResident
                jmp     ErrorSwitch

        TestResident:
                mac@Multiplex   TimeParkID,GetProgInfo
                push    bx                      ;save the resident part seg
                mov     dx,bx
                add     dx,16                   ;Resident Seg = PSP + 10h

                mac@GetIntVec TimerHdwrInt      ;our handler for INT $08
                mov     ax,es
                cmp     ax,dx                   ;match seg?
                jne     NoRemoved
                cmp     bx,OFFSET NewInt08      ;match offset?
                jne     NoRemoved

                mac@GetIntVec   DiskSoftInt     ;our handler for INT $13
                mov     ax,es
                cmp     ax,dx                   ;match seg?
                jne     NoRemoved
                cmp     bx,OFFSET NewInt13      ;match ofs?
                jne     NoRemoved

                mac@GetIntVec   MultiplexInt            ;our handler for INT $2F
                mov     ax,es
                cmp     ax,dx                   ;match seg?
                jne     NoRemoved
                cmp     bx,OFFSET NewInt2F      ;match ofs?
                jne     NoRemoved

                push    ds                      ;save the DS
                mac@Multiplex  TimeParkID,GetProgInfo

                mov     cx,es:[di]              ;CX = # of hooked vectors
                mac@IncVal    di                ;skip this word
                mac@IncVal    di

        AllRestore:
                lds      dx,es:[di+1]           ;get a pointer to routine
                mov     al,es:[di]              ;vector number
                mac@SetIntVec
                mac@IncVal   di,5               ;skip 5 bytes
                loop     AllRestore

                mac@Restore       <ds,es>       ;recover data seg & our old PSP

                mac@FreeBlock                     ;free program seg
                jnc     Remove2
                mac@sJump     NoRemoved

        Remove2:
                mac@LoadOfs   dx,Removed
        LeaveProgram:
                mac@DispStr
                mac@Terminate 00h                       ;set ERRORLEVEL = 0

        NoRemoved:
                mac@LoadOfs   dx,NotUnInstall
                jmp     GoToDos

        Next1:
                cmp     al,'P'                  ;park heads?
                jne     Next1A

                mac@GetIntVec    DiskSoftInt    ;save the old vec $13
                mac@SavePtr   es,bx,VectorArrayPtr[2+5*1]

                call    DiskPark                ;park now

                mac@DispStr  <OFFSET ParkMessage>       ;display the message

                cli                             ;disable interrupts
        Halt_Machine:
                hlt                             ;halt processor
                mac@sJump   Halt_Machine

        Next1A:
                cmp     al,'S'
                jne     Next2                   ;*seconds* parameter?

        SecSwitch:
                inc     di                      ;DI = index pointer
                call    GetChar
                jne     ParseSec2
        ParseSec1:
                mac@sJump     ErrorSwitch
        ParseSec2:
                cmp     al,DeLim
                jne     ParseSec1

                call    GetNumber
                mov     bl,18                   ;18.2 ticks per second
                mul     bl
                add     NewValue,ax
                mac@sJump     Next10

        Next2:
                cmp     al,'M'                  ;*minutes* parameter?
                jne     Next3

                inc     di                      ;DI = index pointer
                call    GetChar
                jne     ParseMin2

        ParseMin1:
                mac@sJump     ErrorSwitch

        ParseMin2:
                cmp     al,DeLim                ;check for delimiter
                jne     ParseMin1

                call    GetNumber
                mov     bx,18*60                ;18.2 * 60 ticks per minute
                mul     bx
                add     NewValue,ax
                mac@sJump     Next10

        Next3:
                cmp     al,'E'                  ;enable program swicth?
                jne     Next4

        Next4:
                cmp     al,'D'                  ;disable program switch?
                jne     Next10A

        HelpSwitch:
                mac@LoadOfs   dx,OnLineHelp
                jmp     LeaveProgram

        Next10:
                jmp     NextChar

        Next10A:
                cmp     al,'?'                  ;on-line help
                jne     ErrorSwitch
                jmp     HelpSwitch

        ErrorSwitch:                            ;parse error occured
                mac@LoadOfs   dx,ErrorMessage
                jmp     GoToDos

; parsing ends here

        ScanDone:
                mov     ax,NewValue
                or      ax,ax                   ;was updated?
                jz      CheckResident
                cmp     ax,MinParkValue         ;test for boundaries
                jb      ErrorSwitch

; check for resident part

        CheckResident:
                mac@LoadOfs   dx,Resident
                call    GetInfo                 ;resident part present?
                jnc     NotInMemory
                mov     bx,NewValue
                or      bx,bx                   ;BX = New Park Time Value
                jz      Quit
                mac@LoadOfs   dx,Passed
                mac@Multiplex  TimeParkID,2       ;subfunction 2
        Quit:
                jmp     LeaveProgram

; init the internal variables

        NotInMemory:
                mov     cx,NewValue
                or      cx,cx
                jz      Initialize
                mov     InitValue,cx
        Initialize:
                call    InitVars

; init the interrupt structure

                push    cs                      ;move CS
                pop     es                      ; to ES
                mac@LoadOfs     di,VectorArrayPtr
                mov     cx,es:[di]
                mac@IncVal     di
                mac@IncVal     di

        AllSave:
                mov     al,es:[di]              ;vector number
                push    es
                mac@GetIntVec                        ;ES:BX -> handler addr
                mac@SavePtr   es,bx,cs:[di+1]
                pop     es
                mac@IncVal   di,5               ;skip 5 bytes
                loop     AllSave

;set the new vec $13

                mac@SetIntVec    DiskSoftInt,<OFFSET  NewInt13>

;set the new vec $08

                mac@SetIntVec    TimerHdwrInt,<OFFSET  NewInt08>

;set the new vec $2F

                mac@SetIntVec    MultiplexInt,<OFFSET  NewInt2F>

; free environment
                mov     es,PSPSeg
                mac@FreeBlock   es:@Environment

; first resident go

                mac@DispStr  <OFFSET GoResident>

;Terminate and Stay Resident

                mac@TSR  <(OFFSET InitMessage + PSP_SIZE)>,0  ;set the ERRORLEVEL = 0

; subroutines

        GetNumber      PROC   NEAR
                inc     di
                call    GetDigit                ;test for getting digit
                jnc     AcceptDigit
                jmp     ErrorSwitch

        AcceptDigit:
                mov     bl,al
                inc     di
                call    GetDigit
                jnc     Multiply
                dec     di
                sub     ah,ah
                mov     al,bl                   ;AL = result
                ret
        Multiply:
                mov     bh,al                   ;BH = 2nd digit
                mov     al,10
                mul     bl                      ;AX = 1st * 10
                add     al,bh                   ;AL = 1st * 10 + 2nd
                cmp     al,59
                jbe     MatchValue
                jmp     ErrorSwitch
        MatchValue:
                sub     ah,ah
                ret
        GetNumber       ENDP

        GetChar         PROC    NEAR
                mov     al,es:[di]
                cmp     al,CR                   ;end of string
                ret
        GetChar         ENDP

        GetDigit        PROC    NEAR
                mov     al,es:[di]
                cmp     al,'0'
                jb      NotDigit
                cmp     al,'9'
                ja      NotDigit
                sub     al,'0'
                clc                             ;CF = 0 no error
                ret
        NotDigit:
                stc                             ;CY = 1 error occurred
                ret
        GetDigit        ENDP

        GetInfo         PROC    NEAR
                mac@LoadZero    bx                 ;BX <- 0
                mac@Multiplex  TimeParkID,Install ;subfunction 0
                mac@ZeroValue?     al              ;if AL = 0 then OK to install
                jnz         Check_Further       ;if =! 0 then go
        No_Resident_Part:
                clc                             ;clear presence flag
                ret
        Check_Further:
                cmp      bx,ExtID               ;out sign?
                jne      No_Resident_Part

                stc                             ;set resident flag
                ret
        GetInfo         ENDP

; variables

        NewValue       DW   0                   ;0 if not init'd

CODE    ENDS

; ************** AREA #2

                        mac@Break       <STACK SEGMENT DEFINTION>

STACK   SEGMENT PARA STACK 'STACK'
        DB      32  DUP  ('STACKxxx')
STACK   ENDS

        END     Start


