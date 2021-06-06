
;  Version  2.01
;  Date     08/24/90
;  Programmer  Dima Stefankoff

;  common equates

   false           EQU       0                   ;boolean equates
   true            EQU       1

   BPTR		   EQU       <BYTE PTR>          ;string equates
   WP              EQU       <WORD PTR>          
   DP		   EQU       <DWORD PTR>


;  common macro definitions

    StackFrame     MACRO     reg
                     mov     reg,sp              ;;save SP
   		   ENDM

    StackFrameBP   MACRO
                     push    bp                  ;;emulate 'begin' statement
                     mov     bp,sp
                   ENDM

    ExitCode       MACRO     PopCount
                     mov     sp,bp
                     pop     bp
                     ret     PopCount
                   ENDM

    Zero           MACRO     reg
                     sub     reg,reg             ;;clear register
                   ENDM

    BooleanResult  MACRO     reg
                     or      reg,reg             ;;check for zero
                   ENDM

    PutCylinder    MACRO     Cylinder
                     mov     dx,Cylinder         ;;load a parameter
                     mov     ch,dl               ;;save a low part
                     mov     cl,6                ;;load a shifter
                     shl     dh,cl               ;;bits 0-1 to 6-7
                     mov     cl,dh               ;;CX = track now
                   ENDM

    SeekMode       MACRO     submode
                     mov     ax,(Lseek shl 8) + submode
                   ENDM

    NullJump       MACRO
                     jmp     SHORT  $+2
                   ENDM

    DosCall        MACRO     DosFuncNum
                     mov     ah,DosFuncNum
                     int     MsDos
                   ENDM

    DosCallAX      MACRO     AXvalue
                     mov     ax,AXvalue
                     int     MsDos
                   ENDM

    JmpFar         MACRO     JAddr
                     jmp     DD  JAddr
                   ENDM

    CallFar        MACRO     CAddr
                     call    DD  CAddr
                   ENDM

    VideoPrim      MACRO
                     push    bp
                     push    si
                     push    di
                     int     Video
                     pop     di
                     pop     si
                     pop     bp
                   ENDM

    VideoCall      MACRO     VidService
                     mov     ah,VidService
                     VideoPrim
                   ENDM

    VideoCallAX    MACRO     VidServiceAX
                     mov     ax,VidServiceAX
                     VideoPrim
                   ENDM

    KbdCall        MACRO     func
                     mov     ah,func
                     int     BiosKbd
                   ENDM

    EmsCall        MACRO    EmsFunction
                     mov    ah,EmsFunction
                     int    67h
                   ENDM

    EmsWordResult  MACRO    RegName
                   LOCAL   EWRexit
                     BooleanResult  AH
                     mov    ax,RegName
                     jz     EWRexit
                     mov    ax,ErrorCode
    EWRexit:
                   ENDM

    EmsByteResult  MACRO    RegName
                   LOCAL    EBexit
                   BooleanResult  AH
                   jz       EBexit
                   Zero     ax
    EBexit:
                   ENDM

    EmsBoolean     MACRO    RegName
                   LOCAL    EBexit1
                   cmp      ah,0
                   mov      ax,1
                   jz       EBexit1
                   dec      ax
    EBexit1:
                   BooleanResult al
                   ENDM

;  structure definitions

   Pointer      STRUC
           Ofst    DW    0
           Segm    DW    0
   Pointer      ENDS
