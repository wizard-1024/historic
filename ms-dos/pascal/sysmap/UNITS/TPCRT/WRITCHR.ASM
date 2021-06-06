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

          PUBLIC   WriteChar

   Char                 EQU         SS:[BX+4]

   WriteChar            PROC        FAR
                   StackFrame   bx               ;set up stack frame
                   cmp     DirectVideo,false
                   je      BiosWrite
                   mov     al,Char               ;get a char
                   push    ax
                   call    ReadCursorPrim        ;get the current pos
                   call    CalcOffset            ;AX = offset into buffer
                   mov     di,ax                 ;DI = offset into buffer
                   mov     es,VideoSegment       ;ES = video buffer start
                   pop     ax                    ;AL = char to write
                   cmp     CheckSnow,false
                   je      WriteVideoByte
                   mov     bl,al                 ;BL = char to write

   WaitHorizL:
                   in      al,dx                 ;get a video status
                   test    al,8
                   jnz     VideoByte1
                   shr     al,1                  ;check for horizontal retrace end
                   jc      WaitHorizL            ;mid-retrace?
                   cli                           ;no intrs
   WaitHorizH:
                   in      al,dx                 ;check for horizonatal
                   shr     al,1                  ;retrace start
                   jnc     WaitHorizH
   VideoByte1:
                   mov     al,bl                 ;get a video byte back
   WriteVideoByte:
                   stosb                         ;write to memory
                   sti                           ;enable interrupts
                   ret     2                     ;pop and return
   BiosWrite:
                   mov     al,Char               ;get a char
                   mov     cx,1                  ;write one char
                   mov     bh,ActivePage         ;load video page
                   VideoCall  10                 ;call video service
                   ret     2                     ;pop and return
   WriteChar            ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
