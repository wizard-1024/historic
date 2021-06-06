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
          EXTRN     CalcOffset      :    NEAR      ;calculate the offset

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   SetCursorPrim

   SetCursorPrim        PROC        NEAR
                  cmp     DirectVideo,false      ;use BIOS call?
                  je      Set_Pos_Bios
                  cmp     LogicalCursor,false    ;use emulation?
                  je      Set_Physical_Cursor
                  mov     WP CursorX,dx
                  ret
   Set_Physical_Cursor:
                  mov     bl,ActivePage          ;BL = video page
                  mov     ax,40h                 ;AX = $40
                  mov     es,ax                  ;DS = $40
                  Zero    bh                     ;BH = 0
                  shl     bx,1                   ;BX= page * 2
                  mov     es:[bx+50h],dx         ;cursor position
                  shr     bx,1                   ;BX = video page
                  cmp     DisplayPage,bl         ;program the 6845 now?
                  jne     Cursor_Done            ;no, then exit
                  call    CalcOffset             ;AX = offset
                  shr     ax,1                   ;adjust to byte count
                  mov     bx,ax                  ;save to BX
                  mov     al,14                  ;cursor high address
                  out     dx,al                  ;write the byte
                  NullJump                       ;wait
                  mov     al,bh                  ;get a high byte of word
                  inc     dx                     ;data register
                  out     dx,al                  ;write the byte
                  NullJump                       ;wait
                  dec     dx                     ;DX = index CRT register
                  mov     al,15                  ;cursor low address
                  out     dx,al                  ;write the byte
                  NullJump                       ;wait
                  mov     al,bl                  ;get a low byte of word
                  inc     dx                     ;data register
                  out     dx,al                  ;write the byte
   Cursor_Done:
                  ret
   Set_Pos_Bios:
                  mov     bh,ActivePage          ;current active vide page
                  VideoCall   2                  ;set the cursor position
                  ret                            ;near return
   SetCursorPrim        ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END

