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

          PUBLIC   ReadCursorPrim

   ReadCursorPrim       PROC        NEAR
                  cmp     DirectVideo,false      ;direct video r/w?
                  je      Read_Cursor_Bios

                  mov     bl,ActivePage          ;BL = video page
                  mov     ax,40h                 ;AX = $40
                  mov     es,ax                  ;DS = $40
                  mov     cx,es:[60h]            ;CX = cursor size
                  cmp     LogicalCursor,false
                  je      Read_Physical_Cursor
                  mov     dx,WP CursorX          ;current Turbo pos
                  ret                            ;near return
   Read_Physical_Cursor:
                  Zero    bh                     ;BH = 0
                  shl     bx,1                   ;BX = page * 2
                  mov     dx,es:[bx+50h]         ;DX = cursor position
                  ret                            ;return to caller
   Read_Cursor_Bios:
                  mov     bh,ActivePage          ;current active vide page
                  VideoCall   3                  ;read cursor function
                  ret                            ;near return
   ReadCursorPrim       ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END

