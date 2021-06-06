                   PAGE   59,132
                   TITLE  External assembly routines for TpMouse Unit

;  Version  1.00
;  Date     4/10/89
;  Programmer  Dmitri V. Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references
          EXTRN      MouseState    :  BYTE       ;current mouse status

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   MouseInstalled                ;public declarations
          PUBLIC   ShowCursor
          PUBLIC   HideCursor
          PUBLIC   GetMouseStatus
          PUBLIC   SetMousePos
          PUBLIC   GetButtonPressed
          PUBLIC   GetButtonRelease
          PUBLIC   SetMinMaxX
	  PUBLIC   SetMinMaxY
	  PUBLIC   SetGraphCursor
	  PUBLIC   SetTextSoftCursor
	  PUBLIC   SetTextHardCursor
	  PUBLIC   GetMotionCount
	  PUBLIC   SetUserMaskCall
	  PUBLIC   LightPenEmulationOn
	  PUBLIC   LightPenEmulationOff
	  PUBLIC   SetSensitivity
	  PUBLIC   DisableCursorDisplay
	  PUBLIC   SetDoubleSpeedThreshold


;  interface  part

   Buttons         EQU       SS:[SI+4]

   MouseInstalled  PROC      FAR
             StackFrame   si                     ;set stack frame
	     Zero    ax			         ;load function 0
	     int     Mouse			 ;call Mouse service
	     mov     [MouseState],false          ;no display
	     and     ax,1			 ;mask all bits except 0
	     les     di,Buttons		         ;load the pointer
	     mov     es:[di],bx			 ;save a value
	     ret     4		                 ;pop and return
   MouseInstalled  ENDP

   ShowCursor      PROC      FAR
              mov    ax,1                        ;load function
	      int    Mouse			 ;call driver
	      mov    [MouseState],true		 ;save a state
	      ret				 ;return far
   ShowCursor	   ENDP

   HideCursor      PROC      FAR
              mov    ax,2                        ;load function
	      int    Mouse			 ;call driver
	      mov    [MouseState],false	         ;save a state
	      ret				 ;return far
   HideCursor	   ENDP

   ButtonInfo      EQU       SS:[SI+12]
   PositionX	   EQU	     SS:[SI+8]
   PositionY	   EQU	     SS:[SI+4]

   GetMouseStatus  PROC      FAR
             StackFrame   si                     ;set stack frame
             mov     bx,ButtonInfo               ;load a button for info
             mov     ax,3                        ;get a status
	     int     Mouse			 ;call Mouse service
	     les     di,ButtonInfo	         ;load the pointer
	     mov     es:[di],bx			 ;save a value
             les     di,PositionX                ;save a values
             mov     es:[di],cx
             les     di,PositionY
             mov     es:[di],dx
	     ret     12		                 ;pop and return
   GetMouseStatus  ENDP

   SetPosX         EQU       SS:[SI+6]
   SetPosY         EQU       SS:[SI+4]

   SetMousePos     PROC      FAR
             mov     ax,4                        ;set a cursor position
   L0:
             StackFrame   si                     ;set stack frame
             mov     cx,SetPosX                  ;load a parms
             mov     dx,SetPosY
	     int     Mouse			 ;call Mouse service
	     ret     4		                 ;pop and return
   SetMousePos     ENDP

   ButtonToInfo    EQU       SS:[SI+4]
   ButtonState     EQU       SS:[SI+18]
   ButtonCount     EQU       SS:[SI+14]
   LastX	   EQU	     SS:[SI+10]
   LastY	   EQU	     SS:[SI+6]

   GetButtonPressed  PROC    FAR
             mov     ax,5                        ;get a status
   L1:
             StackFrame   si                     ;set stack frame
             mov     bx,ButtonInfo               ;load a button for info
	     int     Mouse			 ;call Mouse service
	     les     di,ButtonState	         ;load the pointer
	     mov     es:[di],ax			 ;save a value
             les     di,ButtonCount
             mov     es:[di],bx
             les     di,LastX                    ;save a values
             mov     es:[di],cx
             les     di,LastY
             mov     es:[di],dx
	     ret     14		                 ;pop and return
   GetButtonPressed  ENDP

   GetButtonRelease  PROC    FAR
             mov     ax,6                        ;load function number
             jmp     SHORT  L1                   ;exit through other function
   GetButtonRelease  ENDP

   SetMinMaxX      PROC      FAR
             mov     ax,7                        ;load function number
             jmp     SHORT  L0                   ;exit through other function
   SetMinMaxX      ENDP

   SetMinMaxY      PROC      FAR
             mov     ax,8                        ;load function number
             jmp     SHORT  L0                   ;exit through other function
   SetMinMaxY      ENDP

   GraphBlock      EQU       SS:[SI+4]
   HotSpotX        EQU       SS:[SI+8]
   HotSpotY        EQU       SS:[SI+10]

   SetGraphCursor  PROC      FAR
             StackFrame   si                     ;set stack frame
             mov     bx,HotSpotX                 ;load a parms
             mov     cx,HotSpotY
             les     dx,GraphBlock
             mov     ax,9
	     int     Mouse			 ;call Mouse service
	     ret     8		                 ;pop and return
   SetGraphCursor  ENDP

   SetTextSoftCursor  PROC   FAR
             mov     ax,10                       ;load a function
             mov     bx,0                        ;soft type
             jmp     SHORT  L0                   ;exit through other function
   SetTextSoftCursor  ENDP

   SetTextHardCursor  PROC   FAR
             mov     ax,10                       ;load a function
             mov     bx,1                        ;hardware type
             jmp     SHORT  L0                   ;exit through other function
   SetTextHardCursor  ENDP

   CountY          EQU       SS:[BX+4]
   CountX          EQU       SS:[BX+8]

   GetMotionCount  PROC      FAR
             StackFrame   bx                     ;set stack frame
             mov     ax,11                       ;get a status
	     int     Mouse			 ;call Mouse service
             les     di,CountX                   ;save a values
             mov     es:[di],cx
             les     di,CountY
             mov     es:[di],dx
	     ret     8		                 ;pop and return
   GetMotionCount  ENDP

   CallMask        EQU       SS:[BX+8]
   UserAddr        EQU       SS:[BX+4]

   SetUserMaskCall PROC      FAR
             StackFrame   bx                     ;set stack frame
             mov     cx,CallMask                 ;load parms
             les     dx,UserAddr
             mov     ax,12
	     int     Mouse			 ;call Mouse service
	     ret     6		                 ;pop and return
   SetUserMaskCall  ENDP

   LightPenEmulationOn PROC  FAR
             mov     ax,13                       ;load a function
   L2:
             int     Mouse                       ;call the driver
             ret                                 ;return far
   LightPenEmulationOn ENDP

   LightPenEmulationOff PROC FAR
             mov     ax,14                       ;load a function
             jmp     SHORT  L2                   ;exit through other function
   LightPenEmulationOff ENDP

   SetSensitivity   PROC     FAR
              mov    ax,15                       ;load a function number
              jmp    L0                   	 ;exit through other function
   SetSensitivity   ENDP

   UpperX           EQU      SS:[BX+10]
   UpperY           EQU      SS:[BX+8]
   LowerX           EQU      SS:[BX+6]
   LowerY           EQU      SS:[BX+4]

   DisableCursorDisplay PROC FAR
              StackFrame   si                     ;set stack frame
              mov     cx,UpperX                   ;load a parms
              mov     dx,UpperY
              mov     si,LowerX
              mov     di,LowerY
              mov     ax,10h
	      int     Mouse			 ;call Mouse service
	      ret     8		                 ;pop and return
   DisableCursorDisplay ENDP

   DoubleSpeed      EQU      SS:[SI+4]

   SetDoubleSpeedThreshold PROC FAR
              StackFrame   si                     ;set stack frame
              mov     bx,DoubleSpeed              ;load a speed
              mov     ax,13h
	      int     Mouse			  ;call Mouse service
	      ret     2		                  ;pop and return
   SetDoubleSpeedThreshold ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
