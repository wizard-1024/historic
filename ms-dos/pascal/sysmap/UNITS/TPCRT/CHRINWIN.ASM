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
          EXTRN     WhereXY         :    FAR
          EXTRN     WindowSizeX     :    FAR
          EXTRN     WindowSizeY     :    FAR
          EXTRN     WriteTTY        :    FAR
          EXTRN     WriteCharAttr   :    FAR
          EXTRN     WindowScrollUp  :    FAR
          EXTRN     GotoXYW         :    FAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   WriteCharInWindow

   WindowChar           EQU          SS:[SI+4]

   WriteCharInWindow    PROC         FAR
                   StackFrame   si               ;set up stack frame
                   call         WhereXY          ;AX = (X,Y)
                   mov          dx,ax            ;save DH = Y, DL = X
                   call         WindowSizeX      ;AL = function result
                   mov          cl,al            ;save it
                   call         WindowSizeY      ;AL = function result
                   mov          ch,al            ;save it
                   mov          al,WindowChar    ;AL = char to output
                   cmp          al,10            ;line feed?
                   je           CheckScroll2     ;check for next ctrl char
   Check1:
                   cmp          al,13            ;carriage return?
                   jne          Check2           ;next cntrl char
                   mov          dl,1             ;X-coordinate = 1
                   jmp          SHORT CheckScroll
   Check2:
                   cmp          al,8             ;back space?
                   jne          Check3           ;try the next cntrl char
                   dec          dl               ;decrement horiz. pos
                   or           dl,dl            ;at left bound?
                   jnz          CheckScroll      ;no, then OK!
                   mov          dl,1             ;reset to 1
                   jmp          SHORT CheckScroll
   Check3:
                   cmp          al,7             ;bell?
                   jne          Check4           ;try another ctrl char
                   push         dx               ;save a DX
                   call         WriteTTY         ;nice bell
                   pop          dx               ;restore a DX
                   jmp          SHORT  Set_New_Pos
   Check4:
                   cmp          al,9             ;tab?
                   jne          NoCheck5         ;no more
                   mov          bl,al            ;BL = divisor
                   mov          al,dl            ;AL = X
                   Zero         ah               ;AX = X
                   div          bl               ;div 9
                   inc          al               ;AL = result
                   mul          bl               ;AX = AL * BL
                   mov          dl,al            ;DL = new position
                   jmp          SHORT  CheckScroll
   NoCheck5:
                   push         cx               ;save a registers
                   push         dx
                   push         ax               ;push a parameter
                   mov          al,TextAttr      ;AL = current attr
                   push         ax               ;push a parameter
                   call         WriteCharAttr    ;output a char & attr
                   pop          dx               ;restore a regs
                   pop          cx
                   inc          dl               ;inc X-coordinate
   CheckScroll:
                   cmp          dl,cl            ;X > WindowSizeX?
                   jbe          Set_New_Pos      ;no,then skip
                   mov          dl,1             ;X = 1
   CheckScroll2:
                   inc          dh               ;Y = Y + 1
                   cmp          dh,ch            ;Y > WindowSizeY?
                   jbe          Set_New_Pos      ;no, then no scroll
                   push         dx               ;save a registers
                   push         cx
                   mov          al,1             ;scroll one line
                   push         ax               ;push a parameter
                   call         WindowScrollUp   ;current window
                   pop          cx
                   pop          dx
                   mov          dh,ch            ;Y = WindowSizeY
   Set_New_Pos:
                   push        dx                ;push a parameter
                   call        GotoXYW           ;set a cursor position
                   ret         2                 ;pop & return
   WriteCharInWindow    ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
