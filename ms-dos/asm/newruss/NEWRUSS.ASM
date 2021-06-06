           PAGE     59,132                  ;set the page length,width
           TITLE    IBM  PC  U.S English / Russian Keyboard
           .8086                            ;set 8086/88 instruction set
;
; Program  NEWRUSS.ASM
; Purpose  switch between national keyboards
; Input    None
; Output   None
; By       Dima Stefankoff
; Date     13 February 1989
;
;    equates
WP         EQU      <WORD  PTR>              ;string equate
false      EQU      0                        ;boolean values
true       EQU      not false
BELL       EQU      07h                      ;ASCII bell ring
LF         EQU      0Ah                      ;ASCII linefeed
CR         EQU      0Dh                      ;ASCII carriage return
EnvPtr     EQU      2Ch                      ;offset in PSP
Kbd        EQU      9                        ;BIOS keyboard interrupt
MsDos      EQU      21h                      ;MSDOS function dispatcher
F11        EQU      57h                      ;F11 key
F12        EQU      58h                      ;F12 key
BufferHead EQU      1Ah                      ;BIOS kbd buffer ptrs
BufferTail EQU      1Ch
BufferStart EQU     80h                      ;BIOS kbd buffer size
BufferEnd  EQU      82h
KbdData    EQU      60h                      ;kbd data port
PPI_Port   EQU      61h                      ;PPI cmd port
Eoi        EQU      20h                      ;8259A controller
PIC_Port   EQU      20h
CapsLock   EQU      40h
BreakCode  EQU      80h                      ;break system scan code
BiosDataSeg     EQU   0040h                  ;BIOS data segment
BiosShiftFlags  EQU   0017h                  ;BIOS kbd flags
CODE       SEGMENT  WORD  PUBLIC  'CODE'
           ASSUME   CS:CODE, DS:CODE, ES:CODE, SS:STACK
;
;*******************************   data   *************************
;    variables  and  code part
OldInt09   DD       ?                        ;old kbd vector
CodSeg     DW       ?                        ;current code segment
SwitchFlag DB       false                    ;init to U.S. Engl. kbd
KbdFlags   DB       ?
CodeTable  DB       03h,06h,07h,08h
           DB       10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,1Ah,1Bh
           DB       1Eh,1Fh,20h,21h,22h,23h,24h,25h,26h,27h,28h
           DB       2Ch,2Dh,2Eh,2Fh,30h,31h,32h,33h,34h
TableLen   EQU      $ - CodeTable
RussTable  DB       '2567'                   ;lowcase chars
           DB       '©Ê„™•≠£ËÈßÂÍ'
           DB       '‰Î¢†Ø‡Æ´§¶Ì'
           DB       'ÔÁ·¨®‚Ï°Ó'
UpRussian  DB       '":,.'                    ;upcase chars
           DB       'âñìäÖçÉòôáïö'
           DB       'îõÇÄèêéãÑÜù'
           DB       'üóëåàíúÅû'
;
; *****************************  code   ****************************
Key        PROC     FAR
           sti                                ;enable interrupts
           push     ds                        ;save regs
           push     ax
;
           mov      ax,BiosDataSeg            ;load to DS
           mov      ds,ax                     ;Bios vars segment
;
           mov      ah,DS:[BiosShiftFlags]    ;get kbd status
           mov      CS:[KbdFlags],ah          ;save it
           and      ah,00001100b              ;shift keys is pressed?
           jnz      PassKbdInt                ;yes, then exit

           mov      ds,CS:[CodSeg]            ;set our DS
;
           in       al,KbdData                ;get data
           cmp      al,F11                    ;is F11 key?
           jne      Key1
           mov      [SwitchFlag],false
Quit:      call     Reset
Quit0:     pop      ax                        ;restore environment
           pop      ds
           iret
;
Key1:      cmp      al,F12                    ;is F12 key?
           jne      Key3
           mov      [SwitchFlag],true
           jmp      SHORT  Quit
;
Quit1:     pop      es                        ;restore registers
           pop      di
           pop      cx
           pop      bx
PassKbdInt:pop      ax
           pop      ds
           jmp      DWORD PTR  CS:OldInt09    ;jump to old routine
;
Key3:      cmp      [SwitchFlag],false        ;check kbd switch
           je       PassKbdInt                ;if U.S. then exit
           test     al,BreakCode              ;is BreakCode?
           jnz      PassKbdInt                ;yes,then exit
;
           push     bx                        ;save world
           push     cx
           push     di
           push     es
;
           cld                                ;set forward scan
           mov      es,[CodSeg]               ;move CS to ES
           mov      di,OFFSET CodeTable       ;set pointer to table
           mov      cx,TableLen               ;init counter
           repne    scasb                     ;find match code
           je       Key4                      ;match found
           jcxz     Quit1                     ;no match, then exit
;
Key4:      dec      di                        ;adjust the pointer
           add      di,RussTable - CodeTable  ;set pointer to russ table
           call     Reset
;
           and      [KbdFlags],01000011b      ;check to upcase chars
           jz       LowCase
           cmp      [KbdFlags],CapsLock       ;both shift keys?
           ja       LowCase
           add      di,UpRussian - RussTable  ;set up ptr
;
LowCase:   xor      ax,ax                     ;make the scan code = 0
           mov      al,[di]                   ;get the ASCII code
           mov      bx,BiosDataSeg            ;load to DS
           mov      ds,bx                     ;Bios vars segment
;
           mov      bx,WP DS:[BufferTail]     ;put into kbd buffer
           mov      di,bx
           inc      bx
           inc      bx
           cmp      bx,WP DS:[BufferEnd]
           jne      Skip
           mov      bx,WP DS:[BufferStart]
Skip:      cmp      bx,WP DS:[BufferHead]     ;full buffer?
           je       Quit2
           mov      [di],ax
           mov      WP DS:[BufferTail],bx
Quit2:     pop      es
           pop      di
           pop      cx
           pop      bx
           jmp      Quit0
Key        ENDP
;
Reset      PROC     NEAR
           in       al,PPI_Port               ;reset kbd
           mov      ah,al
           or       al,80h
           out      PPI_Port,al
           xchg     ah,al
           out      PPI_Port,al
           xchg     ah,al
           mov      al,Eoi                    ;reset intr chip
           out      PIC_Port,al
           ret
Reset      ENDP
;
; *****************************************************************
;  messages
Message    DB   CR,LF
           DB   'The PC Alternate Keyboard Driver V2.00 is installed...'
           DB   CR,LF
           DB   'Default keyboard:  U.S. English',CR,LF
           DB   '<F11> key --> select the U.S. English keyboard.',CR,LF
           DB   '<F12> key --> select the Russian keyboard.',CR,LF
           DB   'Copyright (c) VideoSoft Inc. 1989',CR,LF,CR,LF,'$'
NotFound   DB   CR,LF
           DB   'Unable to install...',BELL,CR,LF,CR,LF,'$'
; data
EnvSeg     DW       ?                        ;environment segment
FarJump    DB       02Eh,0FFh,01Eh           ;CALL FAR CS:
; *****************************************************************
;    initializtion code
Start:     mov     CS:[CodSeg],cs            ;save CS
           mov     ax,WP DS:EnvPtr           ;env. segment
           mov     ds,CS:[CodSeg]            ;DS as same CS
           mov     [EnvSeg],ax               ;save environment segment
;
           mov     ax,35h shl 8 + Kbd        ;get interrupt vector addr
           int     MsDos                     ;call DOS
;
COMMENT !
           cld                               ;forward direction
           mov     cx,0FFFFh                 ;search one segment
           mov     di,bx                     ;set string pointer
           inc     di
Search:    dec     di                        ;adjust ptr
           mov     al,FarJump[0]             ;get 1st byte
Search1:   repne   scasb                     ;find match
           je      Match                     ;found match
           jcxz    ExitToDos                 ;all done, then exit
;
Match:     push    cx                        ;save a register
           mov     si,OFFSET FarJump[1]      ;set string pointer
           mov     cx,2                      ;set counter
           repe    cmpsb                     ;compare strings
           pop     cx                        ;recover a register
           jne     Search                    ;not match string
;
           mov     di,WP es:[di]             ;save a address
           mov     ax,WP es:[di]             ;save a offset
           mov     WP Oldint09[0],ax
           mov     ax,WP es:[2][di]          ;save a segment
           mov     WP OldInt09[2],ax
;
           cli                               ;disable interrupts
           mov     WP es:[di][2],cs          ;put our segment
           mov     WP es:[di],OFFSET Key     ;load our offset
           sti                               ;turn on intrs
;
	
!
	   mov	   word ptr OldInt09+0, bx
	   mov	   word ptr OldInt09+2, es

	   mov	   dx, offset Key
	   mov     ax,2509h
	   int	   MsDos


           mov     es,[EnvSeg]               ;get environment segment
 	   mov     ah,49h                    ;free memory block
           int     MsDos                     ;call DOS
           mov     dx,Offset Message         ;set pointer to string
           mov     ah,9                      ;display installation msg
           int     MsDos                     ;call DOS
           add     dx,100h                   ;add PSP size
           mov     cl,4                      ;shift to 4
           shr     dx,cl                     ;divide by 16
           inc     dx                        ;add one paragraph
           mov     ax,3100h                  ;terminate and stay resident
           int     MsDos                     ;call DOS
;
ExitToDos: mov     dx,OFFSET NotFound        ;set pointer
           int     MsDos                     ;call DOS
           mov     ax,4C01h                  ;function = terminate prog.
           int     MsDos                     ;call DOS
;
CODE       ENDS
;
STACK      SEGMENT  WORD  STACK  'STACK'
           DB   32  DUP ('STACK   ')         ;128 words
STACK      ENDS
;***********************************************************************
           IF1
             %OUT   Ending of Pass 1
           ENDIF
           IF2
             %OUT   Ending of Pass 2
           ENDIF
           END      Start