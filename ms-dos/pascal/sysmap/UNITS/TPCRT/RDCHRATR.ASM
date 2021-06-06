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

          PUBLIC   ReadCharAttr

   ReadCharAttr         PROC         FAR
                   cmp     DirectVideo,false
                   je      BiosRead
                   push    ds                    ;save DS
                   call    ReadCursorPrim        ;get the current pos
                   call    CalcOffset            ;AX = offset into buffer
                   mov     si,ax                 ;SI = offset into buffer
                   cmp     CheckSnow,false       ;ZF = result
                   mov     ds,VideoSegment       ;DS = video buffer start
                   je      ReadVideoWord
                   add     dx,6                  ;DX = video status register
   WaitVert3:
                   in      al,dx                 ;get video status
                   test    al,8
                   jnz     ReadVideoWord
                   shr     al,1                  ;check for horizontal retrace end
                   jc      WaitVert3
                   cli                           ;no interrupts
   WaitHoriz3:
                   in      al,dx                 ;check for horizontal
                   shr     al,1                  ;retrace start
                   jnc     WaitHoriz3
   ReadVideoWord:
                   lodsw                         ;read from memory
                   sti                           ;enable interrupts
                   pop     ds
                   ret                           ;pop and return
   BiosRead:
                   mov     bh,ActivePage         ;load video page
                   VideoCall  8                  ;call video service
                   ret                           ;AH = attribute, AL = char
   ReadCharAttr         ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
