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
          EXTRN     DelayMS         :    NEAR
          EXTRN     VideoInfo       :    FAR
          EXTRN     ScanVideoParms  :    NEAR
          EXTRN     ReadCharAttr    :    FAR

;  internal variables
	  OneMS	              DW        ?         ;loop count for 1 ms delay
   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   InitCrt

   InitCrt              PROC         NEAR
                   push    ax                    ;KISS!
                   call    VideoInfo             ;init all variables
                   call    ScanVideoParms        ;check for user settings
		   call    ReadCharAttr          ;get char and attribute
		   and	   ah,01111111b		 ;mask out the blink bit
		   mov	   TextAttr,ah		 ;attribute at cursor is in AH
		   mov	   NormAttr,ah		 ;attribute for NormVideo
		   mov	   OneMS,38		 ;initial value for OneMS
   		   Zero	   BX			 ;BX = 0
                   Zero    AX                    ;timer function = 0
                   int     1Ah                   ;call BIOS service
                   mov     di,dx                 ;save a low word
   InitDelay1:
                   int     1Ah                   ;BIOS timer service
                   cmp     di,dx                 ;repeat
		   je	   InitDelay1		 ; until its value changes
                   mov     di,dx                 ;save it
   InitDelay2:
		   call    DelayMS               ;delay for a count of OneMS (38)
		   inc	   bx			 ;increment loop counter
                   int     1Ah                   ;BIOS timer service
		   cmp	   di,dx                 ;keep looking until the low word
		   je	   InitDelay2		 ; of the timer count changes again
		   mov	   OneMS,bx		 ;BX has new OneMS
		   ret	                         ;return near
   InitCrt		ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF

   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
