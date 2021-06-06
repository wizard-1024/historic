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
          EXTRN     GotoXYW         :    FAR
          EXTRN     DelLine         :    FAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   WindowScrollUp

   LinesToScroll        EQU          SS:[SI+4]

   WindowScrollUp       PROC         FAR
                   StackFrame   si              ;set up stack frame
                   call    WhereXY              ;AX = (X,Y)
                   push    ax                   ;save AX
                   mov     ax,0101h             ;(1,1)
                   push    ax                   ;push a parameter
                   call    GotoXYW              ;set cursor pos
                   mov     cx,LinesToScroll     ;CX = # of lines
                   Zero    ch                   ;CH = 0
                   push    cx                   ;save a CX
   Scroll1:
                   push    cx                   ;save a counter
                   call    DelLine              ;delete a line
                   pop     cx                   ;restore a counter
                   loop    Scroll1              ;till done
                   pop     cx                   ;restore CX
                   pop     ax                   ;restore AX
                   sub     ah,cl                ;(Y-Lines)
                   cmp     ah,1                 ;all window?
                   jae     Wrap1                ;if >1 then skip
                   mov     ah,1                 ;Line := 1
   Wrap1:
                   push    ax                   ;AX = parameter
                   call    GotoXYW              ;restore (X,Y)
                   ret     2                    ;pop and return
   WindowScrollUp       ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
