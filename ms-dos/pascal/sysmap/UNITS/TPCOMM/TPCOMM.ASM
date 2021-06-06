                   PAGE   59,132
                   TITLE  External assembly routines for TpComm Unit

;  Owner    Video Trends Software
;  Version  1.0
;  Date     4/10/89
;  Programmer  D.Stefankoff

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

          EXTRN    LineStatus       :    BYTE    ;line status info
          EXTRN    ModemStatus      :    BYTE    ;mode status info

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   SendChar                     ;public declarations
          PUBLIC   InitCommPort
          PUBLIC   GetCommPortStatus
          PUBLIC   ReceiveChar

;  interface  part

    WordLen        EQU       SS:[BX+4]
    StopBit        EQU       SS:[BX+6]
    Parity         EQU       SS:[BX+8]
    Bauds          EQU       SS:[BX+10]
    CommPort       EQU       SS:[BX+12]

    InitCommPort   PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov     dx,CommPort              ;load a port
                Zero    ax                       ;clear AX
                mov     al,Bauds                 ;get a baud rate
                or      al,Parity                ;get a parity check
                or      al,StopBit               ;get a stop bits number
                or      al,WordLen               ;get a word length
                int     BiosComm                 ;call BIOS
                mov     LineStatus,ah            ;save a status for device
                mov     ModemStatus,al
                ret     10                       ;return and pop parameters
    InitCommPort   ENDP

    SerialPort     EQU       SS:[BX+6]
    CharToSend     EQU       SS:[BX+4]

    SendChar       PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov     ax,CharToSend            ;load a char
                mov     dx,SerialPort            ;where to send
                mov     ah,OutChar               ;function
                int     BiosComm                 ;call BIOS service
                mov     LineStatus,ah            ;save a status
                ret     4                        ;return and pop parameter
    SendChar       ENDP

    SerPort        EQU       SS:[BX+4]

    ReceiveChar    PROC      FAR
                StackFrame  bx                   ;set up stack frame
                mov     ah,InChar                ;load function
                mov     dx,SerPort               ;where to send
                int     BiosComm                 ;call BIOS service
                mov     LineStatus,ah            ;save a device status
                ret     2                        ;return and pop parameter
    ReceiveChar    ENDP

    GetCommPortStatus PROC   FAR
                StackFrame  bx                   ;set up stack frame
                mov     ah,GetCommStatus         ;load function
                mov     dx,SerPort               ;where to send
                int     BiosComm                 ;call BIOS service
                ret     2                        ;return and pop parameter
    GetCommPortStatus ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
