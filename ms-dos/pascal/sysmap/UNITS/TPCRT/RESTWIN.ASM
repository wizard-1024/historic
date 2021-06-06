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
          EXTRN     ReadCursorPrim  :    NEAR
          EXTRN     CalcOffset      :    NEAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   RestoreWindow

   BufPtr               EQU          SS:[DI+4]

   RestoreWindow        PROC         FAR
                   StackFrame   di               ;set up stack frame
                   cmp          DirectVideo,false
                   je           ReadBiosWindow
                   push         bp               ;save TP's environment
                   push         ds
                   les          si,BufPtr        ;load a buffer pointer
                   mov          dx,WindMin
                   mov          cx,WindMax
                   sub          cx,dx
                   add          cx,0101h         ;CH = #rows, CL = #cols
                   mov          bx,cx
                   xchg         ch,cl
                   Zero         ch               ;CX = #rows
                   Zero         bh               ;BX = #cols
                   call         CalcOffset       ;AX = video offset
                   add          dx,6             ;DX = video status reg
                   cmp          CheckSnow,true
                   je           NoCheckSnowWrite
                   Zero         dx               ;DX = 0
   NoCheckSnowWrite:
                   mov          di,ax            ;SI = video offset
                   mov          bp,RowsTable.[2] ;BP = length of one row
                   mov          ax,es            ;save ES
                   mov          es,VideoSegment  ;DS = video buffer start
                   mov          ds,ax            ;move old ES into DS
                   cld                           ;go forward
   RestoreOneRow:
                   push         cx               ;save row counter
                   push         di               ;save video offset
                   mov          cx,bx            ;CX = #cols
                   or           dx,dx            ;check for snow?
                   jz           DirectWrite
   Write1:
                   in           al,dx            ;get status
                   test         al,8
                   jnz          Write3
                   shr          al,1
                   jc           Write1
                   cli
   Write2:
                   in           al,dx            ;get the video status
                   shr          al,1
                   jnc          Write2
   Write3:
                   movsw
                   sti
                   loop         Write1
                   jmp          SHORT  WriteDone
   DirectWrite:
                   rep          movsw            ;just copy
   WriteDone:
                   pop          di               ;restore offset
                   add          di,bp            ;DI = offset of new row
                   pop          cx               ;CX
                   loop         RestoreOneRow
                   pop          ds               ;restore TP'environment
                   pop          bp
                   ret          4                ;remove parms and pop
   ReadBiosWindow:
                   call         ReadCursorPrim   ;get cursor info
                   les          si,BufPtr        ;load a buffer pointer
                   push         dx               ;save it
                   mov          dx,WindMin       ;set to (1,1)
                   VideoCall    2                ;video service
                   mov          cx,WindMax       ;get the window right lower corner
                   inc          cl               ;increment for next computations
                   inc          ch
   PutChar:
                   mov          ax,es:[si]       ;get char/attr
                   add          si,2             ;incr buf ptr
                   push         si               ;save SI
                   push         cx               ;save CX
                   push         ax               ;save char/attr
                   mov          ah,2             ;AH = function 2
                   int          Video            ;call video BIOS
                   pop          ax               ;restore char/attr
                   mov          bl,ah            ;load attribute
                   mov          cx,1             ;write 1 char
                   mov          ah,9             ;AH = function 9
                   int          Video            ;call video BIOS
                   pop          cx               ;restore CX
                   pop          si               ;restore SI
                   inc          dl               ;inc X-pos
                   cmp          dl,cl            ;X > XHigh ?
                   jne          PutChar          ;no, then continue
                   mov          dl,WindMin.XLow  ;DL = XLow
                   inc          dh               ;inc Y-pos
                   cmp          dh,ch            ;Y > YHigh ?
                   jne          PutChar          ;no, then continue
                   pop          dx               ;restore the old cursor pos
                   mov          ah,2             ;AH = function 2
                   int          Video            ;call video BIOS
                   ret          4                ;remove parms and pop
   RestoreWindow        ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
