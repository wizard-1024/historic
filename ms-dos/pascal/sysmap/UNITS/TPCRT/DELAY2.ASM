                   PAGE   59,132
                   TITLE  External assembly routines for TpCrt Unit

;  Version  2.20
;  Date     01/02/91
;  Programmer  Dima Stefankov

   INCLUDE   TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN     DirectVideo     :    BYTE      ;enable/disable access to video memory
          EXTRN     ActivePage      :    BYTE      ;current active video page
          EXTRN     DisplayPage     :    BYTE      ;current display video page
          EXTRN     TextAttr        :    BYTE      ;current text attribute
          EXTRN     NormAttr        :    BYTE      ;normal attribute for char
          EXTRN     CurrentWidth    :    BYTE      ;current screen width
          EXTRN     CurrentHeight   :    BYTE      ;current screen height
          EXTRN     LastMode        :    WORD      ;last text mode after call TEXTMODE
          EXTRN     WindMin         :    WORD      ;upper coordinates of current window
	  EXTRN     WindMax         :    WORD      ;lower coordinates of current window
          EXTRN     VideoSegment    :    WORD      ;current video segment used by adapter
          EXTRN     RowsTable       :    WORD      ;table for row offset on pages
          EXTRN     BaseCrtAddr     :    WORD      ;base address for CRTC
          EXTRN     VideoBufSize    :    WORD      ;current regen buffer size
          EXTRN     PageTable       :    WORD      ;table of page offset
          EXTRN     SaveVideoBuffer :    BYTE      ;boolean value
          EXTRN     CheckSnow       :    BYTE      ;wait for retrace
          EXTRN     CursorX         :    BYTE      ;(X,Y) logical cursor
          EXTRN     CursorY         :    BYTE      ;coordinates (abs. BIOS format)
          EXTRN     LogicalCursor   :    BYTE      ;boolean value

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   DelayTimer2

   MSecs        EQU           SS:[BX+4]

   DelayTimer2          PROC         FAR
                StackFrame    bx                 ;make stack frame
                mov     cx,MSecs		 ;CX = MS
                jcxz	DelayExit		 ;exit if CX = 0
   TinyCycle:
                call    Set_Timer2
                loop    TinyCycle                ;repeat tll done
   DelayExit:
		ret     2
   DelayTimer2          ENDP

   Set_Timer2           PROC          NEAR
		in	al,PPI_B
		and	al,11111100b             ;timer stop
		out	PPI_B,al

		mov	al,10111000b             ;ch.2,LSB/MSB,mode 4,bin
		out	Timer_Ctrl,al
                mov	dx,OneDelayMS            ;initial count
                mov     ax,dx
		out	Timer2,al                ;low byte
		mov	al,ah
		out	Timer2,al                ;high byte

		in	al,PPI_B
		mov	bl,al                    ;save the control value
		or	al,1                     ;enable timer
		out	PPI_B,al
		cli                              ;stop interrupts
   read_timer:
;		mov	al,10000000b             ;latch operation
;		out	Timer_Ctrl,al

		in	al,Timer2                ;read low
		mov	ah,al
		in	al,Timer2                ;read high
		xchg	ah,al                    ;swap bytes
		cmp	dx,ax                    ;check for wraparound
		jb	terminal_count
		or	al,ah                    ;zero count?
		jnz	read_timer
   terminal_count:
		mov	al,bl                    ;restore the control value
		out     PPI_B,al
		sti                              ;enable intrs
                ret
   Set_Timer2           ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END

