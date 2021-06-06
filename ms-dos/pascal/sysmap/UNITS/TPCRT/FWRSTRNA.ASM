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

          PUBLIC   FastWriteStrNoAttr

   StrPtr          EQU               SS:[BX+4]

   FastWriteStrNoAttr   PROC         FAR
                   StackFrame   bx               ;set up stack frame
                   les          di,StrPtr        ;DS:SI = pointer to string
                   Zero         cx               ;CX = 0
                   mov          cl,es:[di]       ;CX = length of string
                   jcxz         Fast_Str_No_Out  ;if zero, done
                   push         ds               ;save the Turbo DS
                   push         cx               ;save CX
                   push         es               ;save ES
                   call    ReadCursorPrim        ;DX = where the cursor
                   call    CalcOffset            ;AX = video offset
                   pop     es                    ;restore ES
                   add     dx,6                  ;DX = video status reg
                   cmp     CheckSnow,true
                   je      CheckSnowDone1
                   Zero    dx                    ;DX = 0
   CheckSnowDone1:
                   mov          si,di            ;ES:SI = pointer to string
                   inc          si               ;skip the length byte
                   mov          di,ax            ;DI = video offset
                   mov          ax,es            ;save ES
                   mov          es,VideoSegment  ;ES = video buffer start
                   mov          ds,ax            ;DS = old ES
                   cld                           ;go forward
                   pop          cx               ;restore the string length
                   or           dx,dx            ;check for snow?
                   jz           FastWriteNoAttrChar
   FastWriteNoAttr1:
                   lodsb                         ;AL = char to write
                   mov          bl,al            ;save char into BL
   FastWriteNo1:
                   in           al,dx            ;get status
                   test         al,8
                   jnz          FastWriteNo2
                   shr          al,1
                   jc           FastWriteNo1
                   cli
   FastWriteNoAttr2:
                   in           al,dx            ;get the video status
                   shr          al,1
                   jnc          FastWriteNoAttr2
   FastWriteNo2:
                   mov          al,bl            ;AL = video byte
                   stosb
                   inc          di               ;skip the attribute byte
                   sti
                   loop         FastWriteNoAttr1
                   jmp          SHORT  FastWriteNoAttrDone
   FastWriteNoAttrChar:
                   movsb                         ;AL = char to write
                   inc          di               ;skip the attribute byte
                   loop         FastWriteNoAttrChar
   FastWriteNoAttrDone:
                   pop          ds               ;restore the Turbo DS
   Fast_Str_No_Out:
                   ret          4                ;remove parms and pop
   FastWriteStrNoAttr   ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
