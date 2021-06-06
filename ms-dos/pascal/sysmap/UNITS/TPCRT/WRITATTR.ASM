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

          PUBLIC   WriteAttr

   Attr                 EQU         SS:[BX+4]

   WriteAttr            PROC        FAR
                   StackFrame   bx               ;set up stack frame
                   cmp     DirectVideo,false
                   je      BiosWrite1
                   mov     al,Attr               ;get a char
                   push    ax
                   call    ReadCursorPrim        ;get the current pos
                   call    CalcOffset            ;AX = offset into buffer
                   mov     di,ax                 ;DI = offset into buffer
                   inc     di                    ;skip a char location
                   mov     es,VideoSegment       ;ES = video buffer start
                   pop     ax                    ;AL = attr to write
                   cmp     CheckSnow,false
                   je      WriteVideoByte1
                   mov     bl,al                 ;BL = attr to write
                   add     dx,6                  ;DX = video status register
   WaitHorizL1:
                   in      al,dx                 ;get video status
                   test    al,8
                   jnz     WriteByte1
                   shr     al,1                  ;check for horizontal retrace end
                   jc      WaitHorizL1           ;end
                   cli                           ;no intrs during critical section
   WaitHorizH1:
                   in      al,dx                 ;check for horizontal
                   shr     al,1                  ;retrace start
                   jnc     WaitHorizH1
   WriteByte1:
                   mov     al,bl                 ;get a video byte back
   WriteVideoByte1:
                   stosb                         ;write to memory
                   sti                           ;enable interrupts
                   ret     2                     ;pop and return
   BiosWrite1:
                   mov     bl,Attr               ;current
                   mov     bh,ActivePage         ;load video page
                   push    bx                    ;save attr
                   VideoCall  8                  ;call video service
                   pop     bx                    ;restore attr
                   mov     cx,1                  ;write one char
                   VideoCall  9                  ;call video service
                   ret     2                     ;pop and return
   WriteAttr            ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
