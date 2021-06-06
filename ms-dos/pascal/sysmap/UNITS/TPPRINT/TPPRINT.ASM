                   PAGE   59,132
                   TITLE  External assembly routines for TpPrint Unit

;  Version  1.00
;  Date     4/10/89
;  Programmer  Dmitri V. Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

          EXTRN    PrinterStatus       :  BYTE    ;printer status byte

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   PrintChar                     ;public declarations
          PUBLIC   InitPrinterPort
          PUBLIC   GetPrinterStatus
          PUBLIC   PrintBuffer


;  interface  part

   CharToPrint     EQU       SS:[BX+6]
   Port            EQU       SS:[BX+4]

   PrintChar       PROC      FAR
                StackFrame     bx                ;set up stack frame
                mov      al,CharToPrint          ;get a char
		mov	 ah,OutChar17    	 ;out the char function
                mov      dx,Port                 ;get a port
                int      BiosPrint               ;call BIOS
                mov      PrinterStatus,ah        ;save a status
                ret      4                       ;return
   PrintChar       ENDP

   InitPrinterPort PROC      FAR
                StackFrame     bx                ;set up stack frame
                mov      dx,Port                 ;get a port
		Zero	 ax			 ;function 0
                int      BiosPrint               ;call BIOS
                mov      PrinterStatus,ah        ;save a status
                ret      2                       ;return
   InitPrinterPort ENDP

   GetPrinterStatus PROC      FAR
                StackFrame     bx                ;set up stack frame
                mov      dx,Port                 ;get a port
		mov	 ah,GetStatus17 	 ;load a function
                int      BiosPrint               ;call BIOS
                mov      al,ah                   ;save a status
                ret      2                       ;return
   GetPrinterStatus ENDP

   Result           EQU       SS:[BX+4]
   PrinterPort      EQU       SS:[BX+8]
   Count            EQU       SS:[BX+10]
   Buffer           EQU       SS:[BX+12]

   PrintBuffer      PROC      FAR
                StackFrame     bx                ;set up stack frame
                push     ds                      ;save DS
                mov      cx,Count                ;get a count
                Zero     di                      ;it will be counter
                mov      dx,PrinterPort          ;get a port
                lds      si,Buffer               ;load a pointer
   NotDone:
                lodsb                            ;get a char
                Zero     ah                      ;print it
                int      BiosPrint               ;call BIOS
                test     ah,00101001B            ;are any error bits on?
                jne      L1                      ;error found!
                inc      di                      ;increment a counter
                loop     NotDone                 ;loop until done
   L1:
                mov      dx,di                   ;save a count
                les      di,Result               ;load a pointer
                mov      es:[di],dx              ;save a count
                pop      ds                      ;restore DS
                mov      PrinterStatus,ah        ;save a status
                ret      12                      ;return
   PrintBuffer      ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
