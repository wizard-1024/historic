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

          PUBLIC   WriteCharAttr

   CharToWrite          EQU         SS:[BX+6]
   AttrToWrite          EQU         SS:[BX+4]

   WriteCharAttr        PROC        FAR
                   StackFrame   bx               ;set up stack frame
                   cmp     DirectVideo,false
                   je      BiosWrite2
                   mov     al,CharToWrite        ;get a char
                   mov     bl,AttrToWrite        ;get a attribute
                   mov     ah,bl                 ;AX = attr/char
                   push    ax
                   call    ReadCursorPrim        ;get the current pos
                   call    CalcOffset            ;AX = offset into buffer
                   mov     di,ax                 ;DI = offset into buffer
                   mov     es,VideoSegment       ;ES = video buffer start
                   pop     ax                    ;AL = char to write
                   cmp     CheckSnow,false
                   je      WriteVideoWord
                   mov     bx,ax                 ;save it
                   add     dx,6                  ;DX = video status register
   WaitHorizL2:
                   in      al,dx                 ;get a video status
                   test    al,8
                   jnz     WriteVideo1
                   shr     al,1                  ;check for horizontal retrace end
                   jc      WaitHorizL2           ;end
                   cli                           ;no intrs
   WaitHorizH2:
                   in      al,dx                 ;check for horizontal
                   shr     al,1                  ;retrace start
                   jnc     WaitHorizH2
   WriteVideo1:
                   mov     ax,bx                 ;get back a video word
   WriteVideoWord:
                   stosw                         ;write to memory
                   sti                           ;enable interrupts
                   ret     4                     ;pop and return
   BiosWrite2:
                   mov     al,CharToWrite        ;get a char
                   mov     bl,AttrToWrite        ;get a attribute
                   mov     cx,1                  ;write one char
                   mov     bh,ActivePage         ;load video page
                   VideoCall   9                 ;call video service
                   ret     4                     ;pop and return
   WriteCharAttr        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
