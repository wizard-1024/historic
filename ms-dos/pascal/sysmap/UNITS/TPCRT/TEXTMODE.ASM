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
          EXTRN     SetWindowPrim   :    NEAR
          EXTRN     BuildTables     :    NEAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   TextMode                      ;public declarations
          PUBLIC   VideoInfo

   NewMode              EQU         SS:[BX+4]

   TextMode             PROC        FAR
                   StackFrame   bx               ;set up stack frame
                   mov     ax,NewMode            ;load a new mode value
                   mov     dx,BiosDataSegment    ;BIOS data segment
                   mov     es,dx
                   and     BYTE PTR es:[87h],0FEh
                   cmp     al,7                  ;mono mode?
                   je      L1A
                   cmp     al,4                  ;check for text modes 0-3
                   jb      L1A
                   mov     al,3
   L1A:
                   push    ax                    ;save info
                   cmp     [SaveVideoBuffer],false   ;preserve the video buffer
                   je      No_Save
                   or      al,080h               ;use for EGA/VGA,PCjr,PC-Conv
   No_Save:
                   VideoCall  0                  ;set mode
                   pop     ax                    ;restore AX
                   or      ah,ah                 ;check for Font8x8
                   jz      L1B                   ;no, then skip next
                   mov     ax,1112h              ;char generator BIOS routine
                   mov     bl,0                  ;load 8x8 double dot char font
                   VideoPrim                     ;call video BIOS
                   mov     ax,1130h              ;EGA info
                   mov     bh,0
                   mov     dl,0
                   push    es
                   VideoPrim
                   pop     es
                   cmp     dl,2Ah                ;43 lines?
                   jne     EGAexit
                   cmp     dl,31h                ;50 lines?
                   jne     EGAexit
                   or      BYTE PTR es:[087h],1
                   mov     cx,0607h              ;emulate cursor
                   VideoCall    1                ;set cursor size
   EGAexit:
                   mov     bl,20h                ;select alternate print screen routine
                   VideoCallAX  1200h            ;alternate screen routine
   L1B:

   ; external entry

   VideoInfo       PROC     FAR
                   VideoCall  15                 ;call video service
                   push    ax
                   mov     ax,1130h              ;EGA info
                   mov     bh,0
                   mov     dl,0
                   push    es
                   VideoPrim
                   pop    es
                   pop     ax                    ;restore AX
                   mov     bl,false              ;assume that no snow
                   or      dl,dl                 ;EGA active?
                   jnz     L1C                   ;yes, then jump
                   mov     bl,true               ;assume no EGA or higher
                   mov     dl,24                 ;25 lines on screen
   L1C:
                   mov     dh,dl                 ;save rows
                   mov     dl,ah                 ;columns on screen
                   dec     dx                    ;BIOS format
                   mov     ah,0                  ;no EGA/VGA adapter
                   cmp     dh,24                 ;25 lines?
                   jbe     L1D
                   mov     ah,1                  ;EGA/VGA adapter
   L1D:
                   mov     LastMode,ax           ;init all variables
                   mov     cx,0B800h             ;assume the color mode
                   cmp     al,7                  ;monochrome text mode ?
                   jne     SetAllVars
                   mov     bl,false              ;no check for  snow on MDA-like cards
                   mov     ch,0B0h               ;segment $B000
   SetAllVars:
                   mov     CheckSnow,bl
                   mov     VideoSegment,cx       ;current video segment
                   mov     CurrentWidth,dl       ;cols-1
                   mov     CurrentHeight,dh      ;rows-1
                   mov     ActivePage,bh
                   mov     DisplayPage,bh
                   Zero    cx                    ;set full window
                   xchg    dx,cx                 ;swap words
                   call    SetWindowPrim
                   call    BuildTables           ;re-build the table
                   ret     2                     ;pop and return
   VideoInfo            ENDP
   TextMode             ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
