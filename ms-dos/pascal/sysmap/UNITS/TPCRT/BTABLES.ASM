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
          EXTRN     SetCursorPrim   :    NEAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   BuildTables

; Note: video table for rows = 80 words !!!

   BuildTables          PROC        NEAR
                   mov     dx,BiosDataSegment    ;BIOS data segment
                   mov     es,dx
                   mov     ax,es:[063h]          ;AX = CRTC base addr
                   mov     BaseCrtAddr,ax        ;save it
                   mov     ax,es:[04Ch]          ;AX = regen buffer length
                   mov     VideoBufSize,ax       ;save it too
                   mov     si,ax                 ;save it too
                   mov     al,CurrentWidth       ;AL = # of cols - 1
                   inc     ax                    ;AL = # of cols + 1
                   Zero    ah                    ;AX = # of cols
                   shl     ax,1                  ;AX = # of cols * 2
                   Zero    ch                    ;CH = 0
                   mov     cl,CurrentHeight      ;CL = # of rows - 1
                   add     cx,2                  ;CX = # of rows + 1
                   lea     di,RowsTable          ;DI = RowsTable[0]
                   cld                           ;go forward
                   mov     bx,ds                 ;BX = Turbo DS
                   mov     es,bx                 ;ES = Turbo DS
                   mov     dx,ax                 ;DX = offset of one row
                   Zero    ax                    ;AX = 0
   PutElement:
                   stosw                         ;store the offset of row
                   add     ax,dx                 ;AX = offset of next row
                   loop    PutElement            ;repeat till done
; now build the video page table
                   mov     cx,8                  ;CX = # of pages
                   lea     di,PageTable          ;DI = PageTable[0]
                   mov     dx,si                 ;DX = offset of one page
                   Zero    ax                    ;AX = 0
   WriteElement:
                   stosw                         ;store the offset of page
                   add     ax,dx                 ;AX = offset of next page
                   loop    WriteElement          ;repeat till done
                   ret
   BuildTables          ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
