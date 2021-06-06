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

          PUBLIC   Sound

   Hertz                EQU         SS:[BX+4]

   Sound                PROC        FAR
                   StackFrame   bx               ;set up stack frame
                   mov     bx,Hertz              ;BX = Hz
                   mov     ax,34DDh
                   mov     dx,0012h              ;DX:AX = $1234DC = 1,193,180
                   cmp     dx,bx                 ;make sure the division won't
                   jae     L3                    ;produce a divide by zero error
                   div     bx                    ;Count (AX) = $1234DC div Hz
                   mov     bx,ax                 ;save Count in BX
                   in      al,61h                ;check the value in port
                   test    al,00000011b          ;bits 0-1 set if speaker on
                   jnz     L2                    ;if they're already on, continue
                   or      al,00000011b          ;set bits 0-1
                   out     61h,al                ;change the value
                   mov     al,182                ;set up timer 2
                   out     43h,al
   L2:
                   mov     al,bl                 ;low byte into AL
                   out     42h,al
                   mov     al,bh                 ;high byte in AL
                   out     42h,al
   L3:
                   ret     2                     ;pop and return
   Sound                ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
