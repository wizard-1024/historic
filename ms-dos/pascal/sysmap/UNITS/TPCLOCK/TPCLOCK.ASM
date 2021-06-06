                   PAGE   59,132
                   TITLE  External assembly routines for TpClock Unit

;  Version  2.0
;  Date     11/27/89
;  Programmer  Dmitri V. Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

          EXTRN     PrevInt08           :  DWORD ;int $08 handler
          EXTRN     FrequencyTablePtr   :  DWORD ;frequency table
          EXTRN     DurationTablePtr    :  DWORD ;note duration table
          EXTRN     Speaker             :  BYTE  ;speaker toggle
          EXTRN     NoteCounter         :  WORD  ;internal counter

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

; uses  TpCrt unit

          EXTRN    NoSound   :  FAR

; public references

          PUBLIC   ReadSystemTimer               ;public declarations
          PUBLIC   SetSystemTimer
          PUBLIC   ReadRTCtime
          PUBLIC   SetRTCtime
          PUBLIC   ReadRTCdate
          PUBLIC   SetRTCdate
          PUBLIC   SetRTCalarm
          PUBLIC   ResetRTCalarm
          PUBLIC   MusicInt
          PUBLIC   MusicInBackGround
          PUBLIC   PlayOn
          PUBLIC   PlayOff


;  interface  part

   Counter         EQU       SS:[BX+8]
   Rolled          EQU       SS:[BX+4]

   ReadSystemTimer PROC      FAR
               StackFrame   bx                   ;set up stack frame
               Zero       ax                     ;function 0
               int        BiosTimer              ;call BIOS
               les        di,Rolled              ;load a pointer
               mov        es:[di],al             ;save a value
               les        di,Counter             ;load a pointer
               mov        es:0[di],dx            ;save a value
               mov        es:2[di],cx
               ret        8                      ;return and pop parms
   ReadSystemTimer ENDP

   CounterLo       EQU       SS:[BX+4]
   CounterHi       EQU       SS:[BX+6]

   SetSystemTimer  PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        cx,CounterLo           ;load value parameter
               mov        dx,CounterHi
               mov        ah,SetTimer
               int        BiosTimer              ;call BIOS
               ret        4                      ;return and pop 4 bytes
   SetSystemTimer  ENDP

   DayLight        EQU       SS:[BX+4]
   Valid           EQU       SS:[BX+8]
   Second          EQU       SS:[BX+12]
   Minute          EQU       SS:[BX+16]
   Hour            EQU       SS:[BX+20]

   ReadRTCtime     PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        ah,ReadTimeAT          ;load function
               int        BiosTimer              ;call BIOS
               les        di,Valid               ;save a variables
               mov        al,1                   ;assume success
               jnc        L1
               Zero       al
   L1:
               mov        es:[di],al
               les        di,DayLight
               mov        es:[di],dl
               les        di,Second
               mov        es:[di],dh
               les        di,Minute
               mov        es:[di],cl
               les        di,Hour
               mov        es:[di],ch
               ret        20                     ;return
   ReadRTCtime     ENDP

   DayLightToSet   EQU       SS:[BX+4]
   SecToSet        EQU       SS:[BX+6]
   MinToSet        EQU       SS:[BX+8]
   HourToSet       EQU       SS:[BX+10]

   SetRTCtime      PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        ah,SetTimeAT           ;load function
               mov        ch,HourToSet           ;load a parms
               mov        cl,MinToSet
               mov        dh,SecToSet
               mov        dl,DayLightToSet
               int        BiosTimer              ;call BIOS
               ret        8                      ;return and pop parms
   SetRTCtime      ENDP

   Day             EQU       SS:[BX+4]
   Month           EQU       SS:[BX+8]
   Year            EQU       SS:[BX+12]
   Century         EQU       SS:[BX+16]
   Valid           EQU       SS:[BX+20]

   ReadRTCdate     PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        ah,ReadDateAT          ;function
               int        BiosTimer              ;call BIOS
               Zero       al                     ;assume no operating clock
               jc         L2                     ;error flag is set
               mov        al,1                   ;true boolean value
   L2:
               les        di,Valid               ;save a variables
               mov        es:[di],al
               les        di,Century
               mov        es:[di],ch
               les        di,Year
               mov        es:[di],cl
               les        di,Month
               mov        es:[di],dh
               les        di,Day
               mov        es:[di],dl
               ret        20                     ;return and pop
   ReadRTCdate     ENDP

   DayBCD          EQU       SS:[BX+4]
   MonthBCD        EQU       SS:[BX+6]
   YearBCD         EQU       SS:[BX+8]
   CenturyBCD      EQU       SS:[BX+10]

   SetRTCdate      PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        ah,SetDateAT           ;function
               mov        ch,CenturyBCD          ;load the parms
               mov        cl,YearBCD
               mov        dh,MonthBCD
               mov        dl,DayBCD
               int        BiosTimer              ;call BIOS
               ret        8                      ;return and pop
   SetRTCdate      ENDP

   ValidAlarm      EQU       SS:[BX+4]
   SecAlarm        EQU       SS:[BX+8]
   MinAlarm        EQU       SS:[BX+10]
   HourAlarm       EQU       SS:[BX+12]

   SetRTCalarm     PROC      FAR
               StackFrame   bx                   ;set up stack frame
               mov        ah,SetAlarm            ;function
               mov        ch,HourAlarm           ;load the parms
               mov        cl,MinAlarm
               mov        dh,SecAlarm
               int        BiosTimer              ;call BIOS
               Zero       al                     ;assume error occurs
               jc         L3
               mov        al,1
   L3:
               les        di,ValidAlarm          ;save a result
               mov        es:[di],al
               ret        10                     ;return and pop
   SetRTCalarm     ENDP

   ResetRTCalarm   PROC      FAR
               mov        ah,ResetAlarm          ;load function
               int        BiosTimer              ;call Dos
               ret                               ;return far
   ResetRTCalarm   ENDP


   MusicInt        PROC      FAR
               push       ax                     ;save registers
               push       ds
               mov        ax,SEG  DATA
               mov        ds,ax                  ;DS = data segment
               pushf
               call       DP  PrevInt08          ;call old intr handler
               cmp        Speaker,true           ;music playing?
               jne        no_play
               cmp        NoteCounter,0          ;note ended?
               je         next_note
               dec        NoteCounter
               jmp        SHORT  no_play
   next_note:
               push       es                     ;save the registers
               push       di
               push       bx
               les        di,FrequencyTablePtr
               mov        bx,es:[di]             ;get the frequency
               cmp        bx,0FFFFh              ;end of table?
               jne        reprogram_timer
               in         al,61h
               and        al,11111100b           ;PC speaker off
               out        61h,al
               mov        Speaker,false
               jmp        SHORT  music_done
   reprogram_timer:
               mov        al,0B6h                ;load timer 2
               out        43h,al                 ;control word
               mov        ax,bx
               out        42h,al                 ;now load latch regs
               mov        al,ah
               out        42h,al
               in         al,61h
               or         al,00000011b           ;PC speaker on
               out        61h,al
               inc        di                     ;advance pointer
               inc        di
               mov        wp  FrequencyTablePtr[0],di
               les        di,DurationTablePtr     ;get the note length
               mov        ax,es:[di]
               mov        NoteCounter,ax
               inc        di                        ;advance a pointer
               inc        di
               mov        wp  DurationTablePtr[0],di
   music_done:
               pop         bx                     ;restore used regs
               pop         di
               pop         es
   no_play:
               pop        ds                     ;restore registers
               pop        ax
               iret                              ;interrupt return
   MusicInt        ENDP

   MusicInBackGround   PROC      FAR
                mov       al,Speaker             ;return the current state
                ret
   MusicInBackGround   ENDP

   PlayOn          PROC      FAR
                 mov      NoteCounter,0          ;speaker on
                 mov      Speaker,true
                 ret
   PlayOn          ENDP

   PlayOff        PROC      FAR
                mov       Speaker,false          ;speaker off
                call      NoSound
                ret                              ;return far
   PlayOff         ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
