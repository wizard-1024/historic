                PAGE   59,132
                TITLE  External assembly routine  for  MakeROM

;  Version     1.00
;  Date        12/06/90
;  Programmer  Dima Stefankov

;   data  segment
   DATA         SEGMENT  WORD  PUBLIC
                ASSUME   DS:DATA                      ;info for MASM
; no variables

   DATA         ENDS

;  code  segment
   CODE         SEGMENT  BYTE  PUBLIC
                ASSUME   CS:CODE,DS:DATA              ;info for MASM

                PUBLIC   UserCode

;  procedure

  UserCode     PROC     NEAR
  DataStart    =        $
  ECopyright   db       ?                       ;length
               db       80  dup (?)             ;data

  OffsetR      =        $  -  ECopyright

  RCopyright   db       ?                       ;length
               db       80  dup (?)             ;data

  OffsetP      =        $  -  ECopyright
  Password     db       ?                       ;length
               db       16  dup (?)             ;data  (max)

  OffsetU     =        $  -  ECopyright
  Prompt       db       09                     ;length
               db       0Fh,1Eh,0Ch,0Ch,08h,10h,0Dh,1Bh,65h  ;'PASSWORD:'

; format Tmmddyy-dddddddd
;        T - computer type, mmddyy - date, d - decimal digit

  OffsetSN    =        $  -  ECopyright
  SerialNumber db       16                     ;length
               db       16 dup (?)             ;data

  ; code start

  Entry_Here:
               REPT   32
                 nop                           ;reserved for some entries
               ENDM

               cli                             ;intrs switch off
               sub    ax,ax                    ;AX = 0
               mov    ss,ax                    ;SS = ABS0
               mov    sp,7C00h                 ;set up stack before boot sector
                                               ;loading
               sti                             ;re-enable interrupts

               mov      ah,0Fh                 ;get the current video mode
               int      10h

               mov      ah,00h                 ;set this mode with clearing
               int      10h                    ;of screen

               call   Get_Addr                 ;use the PIC (it' not 8259!!!)
  Get_Addr:
  Data_Offset  =      $  - DataStart
               pop    bx                       ;BX = return address
               sub    bx,Data_Offset           ;adjust to beginning of data

               mov      ax,cs                  ;move CS
               mov      ds,ax                  ;to DS

               lea      si,[bx]                ;Ecopyright = English text
               call     Display_Message

               lea      si,[bx+OffsetR]        ;Russian text
               call     Display_Message

               lea      si,[bx+OffsetU]        ;'PASSWORD:'
               call     Display_Message

  Flush_Buf:
               mov      ah,1                   ;char available?
               int      16h
               jz       User_Input
               call     Read_Key               ;yes, then read it
               jmp      SHORT  Flush_Buf

  User_Input:
               cld                             ;go forward
               lea      si,[bx+OffsetP]        ;DS:SI -> password in ROM
               lodsb                           ;AL = length of data
               xor      ah,ah                  ;AX = length of data
               mov      cx,ax                  ;CX = counter of chars
               sub      ax,ax                  ;AX = 0
               mov      es,ax                  ;ES = zero segment
               mov      di,7C00h               ;here later to load
               mov      dx,di                  ;save the start
  Next_Char:
               call     Read_Key               ;only read, don't display
               cmp      al,13                  ;terminate string?
               je       Input_Done
               cmp      al,' '                 ;filter the control chars
               jb       Next_Char
               call     Decode_Byte            ;immediately encoding
               stosb                           ;store a byte
               jmp    SHORT  Next_Char         ;jump always

  Input_Done:
               mov       bx,di                 ;point to past char
               mov       di,dx                 ;ES:DI -> 0:7C00h
               sub       bx,dx                 ;BX = number of inputting chars
               cmp       cx,bx                 ;compare lengths
               je        Match_Length

  Mismatch_Input:
               cli                             ;disable intrs
  Halt_Machine:
               hlt                             ;stop CPU
               jmp       SHORT  Halt_Machine

  Match_Length:                                ;CX = length
               cmpsb                           ;DS:SI -> ROM  password
                                               ;ES:DI -> user password
               jne       Mismatch_Input

  Happy_Boot:
               int     19h                     ;call bootstrap loader
               jmp     SHORT   Happy_Boot

  ;Entry:   AL = byte to decode
  ;Exit:    AL = decoded byte
  Decode_Byte  PROC      NEAR
               xor       al,5Fh                 ;XOR's mask
               ret
  Decode_Byte  ENDP

  ; Entry:  AL = char
  ; Exit:   nothing
  ; Note 1: patch for Multitech & Phoenix PC/XT
  ;         mov bx,7 <- mov bl,82
  ;                     nop
  Output_Char  PROC     NEAR
               push     bx
               mov      ah,0Eh                  ;write TTY
               REPT     4                       ;reserved space
                 nop
               ENDM
               mov      bx,7
               int      10h
               pop      bx
               ret
  Output_Char  ENDP

; output the CR/LF sequence to screen
  CRLF         PROC      NEAR
               mov       al,13                  ;AL = carriage return
               call      Output_Char
               mov       al,10                  ;AL = line feed
               call      Output_Char
               ret
  CRLF         ENDP

  ;Enter:  DS:SI -> text buffer in the following format
  ;     +0  byte  length of text
  ;     +1  var   encrypted text data
  Display_Message   PROC  NEAR
               cld                             ;forward direction
               lodsb                           ;AL = length
               xor      ah,ah                  ;AH = length
               mov      cx,ax                  ;CX = count
               jcxz     Output_Done
  Char_Loop:
               lodsb                           ;get a byte
               call     Decode_Byte            ;decode
               call     Output_Char            ;write to screen
               loop     Char_Loop
  Output_Done:
               ret
  Display_Message   ENDP

; get keystroke
  Read_Key     PROC      NEAR
               xor       ah,ah                  ;read kbd
               int       16h
               ret
  Read_Key     ENDP
  UserCode     ENDP

  CodeLength   =  $  -  UserCode                ;# of code & data bytes

   CODE         ENDS
       		END
