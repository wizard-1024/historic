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

          PUBLIC   FastFillAttr

   CountToWrite          EQU         SS:[BX+2]
   AttributeToWrite      EQU         SS:[BX+4]

   FastFillAttr          PROC         NEAR
                   StackFrame   bx               ;set up stack frame
                   mov     ah,CountToWrite       ;get a count
                   mov     al,AttributeToWrite   ;get a attribute
                   push    ax                    ;save the AX
                   call    ReadCursorPrim        ;DX = where the cursor
                   call    CalcOffset            ;AX = video offset
                   add     dx,6                  ;DX = video status reg
                   cmp     CheckSnow,true
                   je      NoCheckSnowDone
                   Zero    dx                    ;DX = 0
   NoCheckSnowDone:
                   mov          di,ax            ;DI = video offset
                   inc          di               ;adjust to attr field
                   mov          es,VideoSegment  ;ES = video buffer start
                   cld                           ;go forward
                   pop          ax               ;restore the entry parms
                   mov          cl,ah            ;CL = count
                   Zero         ch               ;CX = count
                   or           dx,dx            ;check for snow?
                   jz           DirectAttrWrite
                   mov          bl,al            ;BL = attribute
   AttrWrite1:
                   in           al,dx            ;get status
                   test         al,8
                   jnz          AttrWrite3
                   shr          al,1
                   jc           AttrWrite1
                   cli
   AttrWrite2:
                   in           al,dx            ;get the video status
                   shr          al,1
                   jnc          AttrWrite2
   AttrWrite3:
                   mov          al,bl            ;AL = attribute
                   stosb
                   inc          di               ;next location
                   sti
                   loop         AttrWrite1
                   jmp          SHORT  WriteAttrDone
   DirectAttrWrite:
                   stosb
                   inc          di               ;next location
                   loop         DirectAttrWrite
   WriteAttrDone:
                   ret     4                     ;pop and return
   FastFillAttr          ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
