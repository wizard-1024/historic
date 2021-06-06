             PAGE    59,132
             TITLE   Screen Window Clipper Utility Program
;
;-------------------------------------------------------------------------
;                  TITLE  OF PROGRAM
;-------------------------------------------------------------------------
;
;         *************************************
;         *                                   *
;         *      The  Utility  Program        *
;         *     A Screen Window Clipper       *
;         *     with the MicroSoft Mouse      *
;         *        by Dima Stefankoff         *
;         *                                   *
;         *         Release  3.0              *
;         *       Monday, 11/21/88            *
;         *                                   *
;         *  This program demonstrates how    *
;         *  to write interrupt handler, and  *
;         *  filter routine, and memory re-   *
;         *  sident program, and use to easy  *
;         *  interface the Microsoft mouse.   *
;         *                                   *
;         *      Copyright  (C)  1988         *
;         *          VideoSoft Inc.           *
;         *                                   *
;         *************************************
;
;
;-------------------------------------------------------------------------
;               DEFINE   VARIABLES
;-------------------------------------------------------------------------
;
false        EQU     0                      ;boolean values
true         EQU     1
null         EQU     0                      ;empty
;
ShortLen     EQU     3                      ;short command line length
ScrnLen      EQU     2100                   ;full screen buffer length
PathLen      EQU     65                     ;file path length (max)
StckLen      EQU     32                     ;stack length (# words/2)
CmdLine      EQU     80h                    ;begin of command line
;
Bell         EQU     7                      ;ASCII bell
LF           EQU     0Ah                    ;ASCII linefeed
CR           EQU     0Dh                    ;ASCII carraige return
SPC          EQU     20h                    ;ASCII space
;
Time         EQU     8                      ;BIOS timer service
Video        EQU     10h                    ;BIOS video service
CurSize      EQU     1                      ;set cursor size
SetCurs      EQU     2                      ;set cursor position
ReadCurs     EQU     3                      ;read cursor size&position
ReadCharAttr EQU     8                      ;read char&attribute
Get_Mode     EQU     15                     ;get current video mode
Mono_Mode    EQU     7                      ;mono text mode
Graph_Mode   EQU     4                      ;graphics modes
Color_Cursor EQU     0607h                  ;cursor size for color adapter
Mono_Cursor  EQU     0B0Ch                  ;cursor size for mono adapters
MinDownLine  EQU     0                      ;min screen line
MaxUpLine    EQU     24                     ;max screen line
MinX         EQU     0                      ;the most left coordinate
;
MouseInfo    EQU     0                      ;return the mouse parameters
Show_Mouse   EQU     1                      ;show the mouse cursor
Hide_Mouse   EQU     2                      ;hide the mouse cursor
Mouse_State  EQU     3                      ;get the mouse information
MouseCursor  EQU     10                     ;set mouse cursor
SoftCursor   EQU     0                      ;select software cursor
ScreenMask   EQU     0FFFFh                 ;the mouse screen mask
CursorMask   EQU     7700h                  ;the mouse cursor mask
;
Kbd          EQU     16h                    ;BIOS keyboard service
Mouse        EQU     33h                    ;mouse driver
MS_DOS       EQU     21h                    ;DOS function dispatcher
DispString   EQU     9                      ;display string function
SetIntVec    EQU     25h                    ;set interrupt vector func.
GetIntVec    EQU     35h                    ;get interrupt vector func.
Keep         EQU     31h                    ;terminate&stay resident func.
End_Process  EQU     4Ch                    ;terminate process function
ErrorCode    EQU     0                      ;value is ErrorCode
Fattr        EQU     0                      ;normal file attribute
Create       EQU     3Ch                    ;create_handle function
Open         EQU     3Dh                    ;open_handle function
Close        EQU     3Eh                    ;close_handle function
Write        EQU     40h                    ;write_to_handle function
Lseek        EQU     42h                    ;move file_ptr function
rw_mode      EQU     2                      ;file r/w enable mode
To_end_file  EQU     2                      ;move ptr from end of file
;
AltA         EQU     1E00h                  ;alt A key
ShiftF3      EQU     5600h                  ;shift F3 key
AltU         EQU     1600h                  ;alt U key
AltL         EQU     2600h                  ;alt L key
AltS         EQU     1F00h                  ;alt S key
AltI         EQU     1700h                  ;alt I key
AltJ         EQU     2400h                  ;alt J key
AltK         EQU     2500h                  ;alt K key
AltM         EQU     3200h                  ;alt M key
ShiftF6      EQU     5900h                  ;shift F6 key
ShiftF7      EQU     5A00h                  ;shift F7 key
ShiftF8      EQU     5B00h                  ;shift F8 key
;
Tics         EQU     6                      ;6 times/second
;
;-------------------------------------------------------------------------
;
CodSeg      SEGMENT  WORD  'CODE'           ;info for assembler
            ASSUME   CS:CodSeg,DS:CodSeg,SS:CodSeg,ES:CodSeg
;
;-------------------------------------------------------------------------
;                INTERRUPT  HANDLER  CODE
;-------------------------------------------------------------------------
;
Timer       PROC  FAR
            sti                             ;enable interrupts
            pushf                           ;save a processor state
            cli                             ;emulate intr
            call  DWORD PTR CS:TimerOldVec  ;call old intr vector
;
            cmp   CS:[MouseYes],false       ;mouse presents?
            je    Exit                      ;no,then exit
            cmp   CS:[Buzy],true            ;now active?
            je    Exit                      ;yes,exit from interrupt
            dec   CS:[Counter]              ;decrement check counter
            jnz   Exit                      ;if not zero, exit
;
            push  ax                        ;preserve registers
            push  bx
            push  cx
            push  dx
            push  bp
            push  si
            push  di
            push  ds
;
            mov   ax,cs                     ;move code segment
            mov   ds,ax                     ;to data segment reg
;
            mov   ax,Mouse_State            ;get mouse info
            int   mouse                     ;call the mouse driver
;
            shl   bx,1                      ;get offset
            add   bx,OFFSET MouseCmd        ;add table beginning
            call  WORD PTR [bx]             ;execute command
            mov   BYTE PTR [Buzy],false     ;no buzy
            mov   BYTE PTR [Counter],Tics   ;init counter
;
            pop   ds                        ;restore a world
            pop   di
            pop   si
            pop   bp
            pop   dx
            pop   cx
            pop   bx
            pop   ax
;
Exit:       iret                            ;return from interrupt
Timer       ENDP
;
;
Keyboard    PROC  FAR
            sti                             ;must be with intrs on
            pushf                           ;emulate interrupt
            cmp   ah,1                      ;function 1?
            je    Filter                    ;yes,then filter it
;
            popf                            ;discard flags
            cli                             ;disable interrupts
            jmp   DWORD PTR CS:KbdOldVec    ;jump to old vector
;
Filter:     cli                             ;turn intrs back off
            call  DWORD PTR CS:KbdOldVec    ;call the old service
            sti                             ;interrupts on
            jz    Quit                      ;no key pressed
;
            pushf                           ;save a registers
            push  ax
            push  bx
            push  cx
            push  dx
            push  bp
            push  si
            push  di
            push  ds
;
            mov   bx,cs                     ;mov code segment to AX
            mov   ds,bx                     ;DS as same code
;
            mov   bx,OFFSET CmdTable        ;put a table beginning
GotoCmd:    cmp   WORD PTR [bx],null        ;no match command?
            je    GotoCmd2                  ;yes, then exit
            cmp   ax,[bx]                   ;find command
            je    GotoCmd1                  ;yes,then exec it
            add   bx,4                      ;=>next table entry
            jmp   SHORT GotoCmd             ;continue look
GotoCmd1:   add   bx,2                      ;PC => command
            call  WORD PTR [bx]             ;execute this command
GotoCmd2:   pop   ds                        ;restore a world
            pop   di
            pop   si
            pop   bp
            pop   dx
            pop   cx
            pop   bx
            pop   ax
            popf
;
Quit:       ret   2                         ;return and pop flags
Keyboard    ENDP
;
;
MouseActive PROC  NEAR
            cmp   [MouseYes],false          ;mouse presents?
            je    Active1                   ;no, then exit
            mov   ax,MouseCursor            ;set mouse cursor
            mov   bx,SoftCursor             ;software mask
            mov   cx,ScreenMask             ;put screen mask
            mov   dx,CursorMask             ;put cursor mask
            int   mouse                     ;call the mouse driver
;
            mov   ax,Show_Mouse             ;show the mouse cursor
            int   mouse                     ;call the mouse driver
;
Active1:    ret                             ;return
MouseActive ENDP
;
;
MouseSleep  PROC  NEAR
            cmp   [MouseYes],false          ;mouse presents?
            je    Sleep1                    ;no, then exit
            mov   ax,Hide_Mouse             ;hide the mouse cursor
            int   mouse                     ;call the mouse driver
Sleep1:     ret                             ;return
MouseSleep  ENDP
;
;
Button0     PROC  NEAR
            call  MouseCoord                ;get mouse coordinates
            mov   [MouseX1],al              ;save X upper corner
            mov   [MouseY1],dl              ;save Y upper corner
            ret                             ;return
Button0     ENDP
;
;
Button1     PROC  NEAR
            call  MouseCoord                ;get mouse coordinates
            mov   [MouseX2],al              ;save X lower corner
            mov   [MouseY2],dl              ;save Y lower corner
            ret                             ;return
Button1     ENDP
;
;
MouseCoord  PROC  NEAR
            mov   ax,cx                     ;save X-coordinate
            shr   ax,1                      ;divide by 8
            shr   ax,1                      ;text X-position
            shr   ax,1
            shr   dx,1                      ;text Y-position
            shr   dx,1
            shr   dx,1
            ret                             ;return
MouseCoord  ENDP
;
;
NoButton    PROC  NEAR
            ret                             ;dummy return
NoButton    ENDP
;
;
SavMouseWin PROC  NEAR
            cmp   [MouseYes],false          ;mouse presents?
            je    SaveMouse                 ;no, then exit
;
            cmp   [FileFound],false         ;filename presents?
            je    SaveMouse                 ;no,then exit
;
            mov   al,[MouseX1]              ;get current (X1,Y1)
            mov   ah,[MouseY1]              ;get current (X1,Y1)
            mov   bl,[MouseX2]              ;get current (X2,Y2)
            mov   bh,[MouseY2]              ;get current (X2,Y2)
            call  Resend                    ;put a window info
            call  SaveWindow                ;call main procedure
SaveMouse:  ret                             ;return
SavMouseWin ENDP
;
;
KbdActive   PROC  NEAR
            cmp   [ActiveFlag],true         ;may be active?
            je    KbdActExit                ;yes, then exit
;
            call  GetVideoMod               ;get current video mode
            cmp   al,Mono_Mode              ;monochrome display?
            je    Save_Mode                 ;yes, then skip next
;
            cmp   al,Graph_Mode             ;may be graphics mode?
            jae   KbdActExit                ;yes, then exit
;
Save_Mode:  mov   [VideoMode],al            ;save current mode
            mov   [VideoPage],bh            ;save current video page
            mov   [CharsInLine],ah          ;save number of chars in line
;
            call  ReadCursor                ;get current cursor info
            mov   [OldKbdState],cx          ;save current cursor state
            mov   [OldCursorXY],dx          ;save current cursor position
;
            mov   cx,Color_Cursor           ;assume CGA, or EGA adapter
            cmp   [VideoMode],Mono_Mode     ;monochrome display?
            jne   SetOurCur                 ;yes, then 8*14 matrix
            mov   cx,Mono_Cursor            ;cursor for mono display
SetOurCur:  call  CursorSize                ;set it's size
;
            mov   dx,MinX                   ;null coordinates
            mov   [CursorX1],dl             ;set X1 -> 0
            mov   [CursorY1],dh             ;set Y1 -> 0
            mov   [CursorX],dl              ;set current X -> 0
            mov   [CursorY],dh              ;set current Y -> 0
            mov   al,[CharsInLine]          ;get # chars in line
            dec   al                        ;make physical coordinate
            mov   [CursorX2],al             ;set X2 -> chars-1
            mov   BYTE PTR [CursorY2],MaxUpLine ;set Y2 -> MaxLine (= 24)
            call  SetCursor                 ;set position to (0,0)
            mov   BYTE PTR ActiveFlag,true  ;set activity flag
KbdActExit: ret                             ;return
KbdActive   ENDP
;
;
KbdSleep    PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    KbdSleep1                 ;no, then exit
;
            mov   BYTE PTR ActiveFlag,false ;put to sleep a process
            mov   cx,[OldKbdState]          ;get old cursor state
            call  CursorSize                ;restore it
            mov   dx,[OldCursorXY]          ;get old cursor position
            call  SetCursor                 ;restore it
KbdSleep1:  ret
KbdSleep    ENDP
;
;
UpperCorner PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    Upper1                    ;no, then exit
            mov   ax,WORD PTR CursorX       ;put current (X,Y) position
            mov   WORD PTR CursorX1,ax      ;to (X1,Y1) window coordinate
Upper1:     ret                             ;and return
UpperCorner ENDP
;
;
LowerCorner PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    Lower1                    ;no, then exit
            mov   ax,WORD PTR CursorX       ;put current (X,Y) position
            mov   WORD PTR CursorX2,ax      ;to (X2,Y2) window coordinate
Lower1:     ret                             ;and return
LowerCorner ENDP
;
;
SaveKbdWin  PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    SaveKbdWin1               ;no, then exit
;
            cmp   [FileFound],false         ;filename presents?
            je    SaveKbdWin1               ;no, then exit
;
            cmp   [WriteFlag],true          ;writing?
            je    SaveKbdWin1               ;yes, then exit
;
            mov   BYTE PTR WriteFlag,true   ;set writing to active
            mov   al,[CursorX1]             ;get current (X1,Y1)
            mov   ah,[CursorY1]             ;get current (X1,Y1)
            mov   bl,[CursorX2]             ;get current (X2,Y2)
            mov   bh,[CursorY2]             ;get current (X2,Y2)
            call  Resend                    ;put a window info
            call  SaveWindow                ;call main procedure
            mov   BYTE PTR WriteFlag,false  ;set writing to passive
            call  KbdSleep                  ;prevent a more write
SaveKbdWin1:ret                             ;return
SaveKbdWin  ENDP
;
;
CursorUp    PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    CursorUp2                 ;no,then exit
;
            mov   dh,[CursorY]              ;get current Y position
            dec   dh                        ;decrement it
            cmp   dh,-1                     ;out range?
            jne   CursorUp1                 ;no, skip next instruction
            mov   dh,MaxUpLine              ;set max Y position
CursorUp1:  mov   [CursorY],dh              ;save Y position
            mov   dl,[CursorX]              ;get current X position
            call  SetCursor                 ;set cursor at given pos.
CursorUp2:  ret                             ;return
CursorUp    ENDP
;
;
CursorDown  PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    CursorDown2               ;no, then exit
;
            mov   dh,[CursorY]              ;get current Y position
            inc   dh                        ;increment it
            cmp   dh,MaxUpLine+1            ;out range?
            jne   CursorDown1               ;no,then skip next code
            mov   dh,MinDownLine            ;set min Y position
CursorDown1:mov   [CursorY],dh              ;save Y position
            mov   dl,[CursorX]              ;get current X position
            call  SetCursor                 ;set cursor at given pos.
CursorDown2:ret                             ;and return
CursorDown  ENDP
;
;
CursorLeft  PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    CursorLeft2               ;no, then exit
;
            mov   dl,[CursorX]              ;get current X position
            dec   dl                        ;decrement it
            cmp   dl,-1                     ;out range?
            jne   CursorLeft1               ;no, skip next code
            mov   dl,[CharsInLine]          ;set max X position
            dec   dl                        ;use the physical coordinate
CursorLeft1:mov   [CursorX],dl              ;save X position now
            mov   dh,[CursorY]              ;get current Y position
            call  SetCursor                 ;set the cursor at given pos.
CursorLeft2:ret                             ;return
CursorLeft  ENDP
;
;
CursorRight PROC  NEAR
            cmp   [ActiveFlag],false        ;active process?
            je    CursorRght2               ;no, then exit
;
            mov   dl,[CursorX]              ;get current X position
            inc   dl                        ;decrement it
            cmp   dl,[CharsInLine]          ;out range?
            jne   CursorRght1               ;no, skip next code
            mov   dl,MinX                   ;set max X position
CursorRght1:mov   [CursorX],dl              ;save X position now
            mov   dh,[CursorY]              ;get current Y position
            call  SetCursor                 ;set the cursor at given pos.
CursorRght2:ret                             ;return
CursorRight ENDP
;
;
CursorSize  PROC  NEAR
            mov   ah,CurSize                ;set cursor size
            mov   bh,[VideoPage]            ;get current video page
            int   Video                     ;call BIOS service
            ret                             ;return
CursorSize  ENDP
;
;
SetCursor   PROC  NEAR
            mov   ah,SetCurs                ;set cursor position
            mov   bh,[VideoPage]            ;get current video page
            int   Video                     ;call BIOS service
            ret                             ;return
SetCursor   ENDP
;
;
ReadCursor  PROC  NEAR
            mov   ah,ReadCurs               ;read cursor info
            mov   bh,[VideoPage]            ;get current video page
            int   Video                     ;call BIOS service
            ret                             ;return
ReadCursor  ENDP
;
;
GetVideoMod PROC  NEAR
            mov   ah,Get_Mode               ;current video mode
            int   Video                     ;call BIOS service
            ret                             ;and return
GetVideoMod ENDP
;
;
Resend      PROC  NEAR
            mov   [TempX1],al               ;save window info
            mov   [TempX2],bl
            mov   [TempY1],ah
            mov   [TempY2],bh
            ret                             ;return
Resend      ENDP
;
;
SaveWindow  PROC  NEAR
            call  GetVideoMod               ;get video mode info
            mov   [VideoMode],al            ;save current video mode
;
            cmp   al,Mono_Mode              ;is monochome display?
            je    TextMode                  ;yes, then go
            cmp   al,Graph_Mode             ;may be graphics mode?
            jb    TextMode                  ;text mode detected
            jmp   SaveWinExit               ;exit from procedure
;
TextMode:   mov   [VideoPage],bh            ;save current video page
;
            call  OpenFile                  ;try open the file
            jnc   FileOpened                ;no setting error flag
            call  CreateFile                ;try to create file
            jnc   FileOpened                ;no error detect
            jmp   SHORT SaveWinExit         ;no opened, then exit
;
FileOpened: mov   [Handle],ax               ;save file handle
;
            call  ReadCursor                ;get current cursor info
            mov   [OldState],cx             ;save current cursor state
            mov   [OldPos],dx               ;save current cursor position
;
            mov   al,[VideoMode]            ;get the video mode
            mov   cx,Color_Cursor           ;assume CGA, or EGA adapter
            cmp   al,Mono_Mode              ;monochrome display?
            jne   Set_Our_Cur               ;yes, then 8*14 matrix
            mov   cx,Mono_Cursor            ;cursor for mono display
Set_Our_Cur:call  CursorSize                ;set it's size
;
            mov   si,OFFSET Buffer          ;set pointer to buffer
            sub   di,di                     ;set byte counter to zero
            mov   dx,WORD PTR TempX1        ;get left corner of window
            mov   cx,WORD PTR TempX2        ;get right corner of window
            inc   cl                        ;use to check
            inc   ch                        ;also for checking
;
ReadChar:   push  si                        ;save buffer pointer
            push  di                        ;save a counter too
;
            call  SetCursor                 ;set cursor at given position
            mov   ah,ReadCharAttr           ;read char/attr at cursor pos.
            mov   bh,[VideoPage]            ;get a display page
            int   Video                     ;call BIOS service
;
            pop   di                        ;restore a counter
            pop   si                        ;restore a pointer
;
            mov   BYTE PTR [si],al          ;write a char to buffer
            inc   si                        ;advance a pointer
            inc   di                        ;increment a byte counter
;
            inc   dl                        ;increment X cursor position
            cmp   cl,dl                     ;over X2 coordinate?
            jne   ReadChar                  ;no, continue loop
            mov   dl,TempX1                 ;restore X1 win coordinate
            mov   BYTE PTR [si],CR          ;write a carriage return
            inc   si                        ;advance a pointer
            inc   di                        ;increment a byte counter
            mov   BYTE PTR [si],LF          ;write a linefeed (use text form)
            inc   si                        ;advance a pointer
            inc   di                        ;increment a byte counter
            inc   dh                        ;increment Y cursor position
            cmp   ch,dh                     ;greater than X2-coordinate?
            jne   ReadChar                  ;no, continue loop
            nop                             ;dummy
;
            push  di                        ;save a counter
            mov   cx,[OldState]             ;get saved cursor state
            call  CursorSize                ;set cursor size
            mov   dx,[OldPos]               ;restore cursor position
Set_Old_1:  call  SetCursor                 ;set a cursor position
            pop   di                        ;restore a register
;
            mov   bx,[Handle]               ;get a file handle
            call  MovePointer               ;move a pointer to file end
            mov   cx,di                     ;number of bytes to write
            call  WriteFile                 ;write to file
            jc    SaveWinExit               ;error detected
            call  CloseFile                 ;close a file
SaveWinExit:ret                             ;return
SaveWindow  ENDP
;
;
CreateFile  PROC  NEAR
            mov   dx,OFFSET FileName        ;DS:DX -> pointer to path
            mov   ax,(Create shl 8)         ;function -> create
            mov   cx,Fattr                  ;an archive file
            int   MS_DOS                    ;call DOS dispatcher
            ret                             ;and return
CreateFile  ENDP
;
;
OpenFile    PROC  NEAR
            mov   dx,OFFSET FileName        ;DS:DX => pointer to path
            mov   ax,(Open shl 8)+rw_mode   ;open in compatibilty mode
            int   MS_DOS                    ;call DOS dispatcher
            ret                             ;return
OpenFile    ENDP
;
;
MovePointer PROC  NEAR
            mov   ax,(Lseek shl 8)+To_end_file ;set current file pos.
            sub   cx,cx                     ;set offset from it
            xor   dx,dx                     ;to zero
            int   MS_DOS                    ;call DOS dispatcher
            ret                             ;return
MovePointer ENDP
;
;
WriteFile   PROC  NEAR
            mov   dx,OFFSET Buffer          ;DS:DX => pointer to buffer
            mov   ah,Write                  ;functuon code=write
            int   MS_DOS                    ;call DOS dispatcher
            ret                             ;return
WriteFile   ENDP
;
;
CloseFile   PROC  NEAR
            mov   ah,Close                  ;function code=close
            int   MS_DOS                    ;call DOS dispatcher
            ret                             ;and return
CloseFile   ENDP
;
;-------------------------------------------------------------------------
;         DATA  and  STACK AREA   FOR  HANDLER
;-------------------------------------------------------------------------
;
MouseCmd    LABEL    WORD                   ;mouse command table
            DW       NoButton               ;no pressed button
            DW       Button0                ;left button
            DW       Button1                ;right button
            DW       SaveWindow             ;save clipped window
;
CmdTable    LABEL    WORD                   ;keystroke table
            DW       ShiftF6,MouseActive    ;wake up mouse
            DW       ShiftF7,MouseSleep     ;sleep mouse
            DW       ShiftF8,SavMouseWin    ;save mouse window
            DW       AltA,KbdActive         ;activate process
            DW       ShiftF3,KbdSleep       ;sleep the process
            DW       AltU,UpperCorner       ;mark the (X1,Y1)-point
            DW       AltL,LowerCorner       ;mark the (X2,Y2)-point
            DW       AltS,SaveKbdWin        ;save the clipped window
            DW       AltI,CursorUp          ;move cursor up
            DW       AltM,CursorDown        ;move cursor down
            DW       AltJ,CursorLeft        ;move cursor left
            DW       AltK,CursorRight       ;move cursor right
            DW       null                   ;end of table
;
TimerOldVec DD       ?                      ;reserved for saved
KbdOldVec   DD       ?                      ;interrupt vectors
CodeSeg     DW       ?                      ;current code segment
MouseYes    DB       false                  ;mouse presents
FileFound   DB       false                  ;boolean flag for filename
            EVEN                            ;align word boundary
MouseX1     DB       ?                      ;mouse window info
MouseY1     DB       ?
MouseX2     DB       ?
MouseY2     DB       ?
Buzy        DB       false                  ;buzy flag
Counter     DB       Tics                   ;calling mouse counter
;
TempX1      DB       ?                      ;temporary locations
TempY1      DB       ?
TempX2      DB       ?
TempY2      DB       ?
;
ActiveFlag  DB       false                  ;state flag for kbd clipper
WriteFlag   DB       false                  ;writing a window for kbd
VideoPage   DB       ?                      ;current active page
VideoMode   DB       ?                      ;current video mode
CharsInLine DB       ?                      ;number of chars in line
OldState    DW       ?                      ;old cursor size
OldPos      DW       ?                      ;old cursor position
OldKbdState DW       ?                      ;old cursor size (kbd calling)
OldCursorXY DW       ?                      ;old cursor position (kbd call)
            EVEN                            ;align word boundary
CursorX     DB       ?                      ;current X cursor position
CursorY     DB       ?                      ;current Y cursor position
CursorX1    DB       ?                      ;X1 window coordinate
CursorY1    DB       ?                      ;Y1 window coordinate
CursorX2    DB       ?                      ;X2 window coordinate
CursorY2    DB       ?                      ;Y2 window coordinate
;
Handle      DW       ?                      ;file handle
FileName    DB       PathLen  dup (?)       ;place there filepath
Buffer      DB       ScrnLen  dup (?)       ;screen window buffer
;
;   STACK  SPACE
;
            DB  StckLen  dup ('S','T','A','C','K',SPC,SPC,SPC)
StckTop     LABEL    WORD                   ;kbd stack pointer
;

;
;-------------------------------------------------------------------------
;                  INITIALIZATION  CODE
;-------------------------------------------------------------------------
;
Start:      mov   CS:[CodeSeg],CS           ;save current code segment
;
            cli                             ;make sure that interrupts off
            mov   SS,CS:[CodeSeg]           ;SS is same that code segment
            mov   SP,OFFSET StckTop         ;use our stack
            sti                             ;enable interrupts
;
            mov   dx,OFFSET Hello           ;welcome!
            call  MessageOut                ;display a message
;
            mov   ax,(GetIntVec shl 8)+Time ;get address of intr. vector
            int   MS_DOS                    ;call DOS dispatcher
;
            mov   CS:[Vector],ES            ;save old handler segment
;
            cmp   BYTE PTR ES:[bx][0],0FBh  ;is this code ==> STI?
            jne   Install                   ;no, then install our handler
            cmp   BYTE PTR ES:[bx][1],09Ch  ;is this code ==> PUSHF?
            jne   Install                   ;no, then install our handler
            cmp   BYTE PTR ES:[bx][2],0FAh  ;is this code ==> CLI?
            je    NoInstall                 ;yes,no install our handler
;
Install:    mov   BYTE PTR CS:[CheckFlag],false ;no installed now
;
            mov   WORD PTR CS:TimerOldVec[0],bx ;save old vector offset
            mov   WORD PTR CS:TimerOldVec[2],es ;save old vector segment
;
            mov   ax,(GetIntVec shl 8)+Kbd  ;get address of intr. vector
            int   MS_DOS                    ;call DOS dispatcher
;
            mov   WORD PTR CS:KbdOldVec[0],bx ;save old vector offset
            mov   WORD PTR CS:KbdOldVec[2],es ;save old vector segment
;
            push  ds                        ;save data segment register
            mov   ds,CS:[CodeSeg]           ;DS is same that code segment
            mov   dx,OFFSET Keyboard        ;offset of our handler
            mov   ax,(SetIntVec shl 8)+Kbd  ;set address of intr. vector
            int   MS_DOS                    ;call DOS dispatcher
;
            mov   dx,OFFSET Timer           ;put offset of handler
            mov   ax,(SetIntVec shl 8)+Time ;set address of intr. vector
            int   MS_DOS                    ;call DOS dispatcher
            pop   ds                        ;restore data segment register
;
            mov   CS:[Vector],CS            ;new interrupt vector segment
;
            mov   ax,MouseInfo              ;mouse request
            int   Mouse                     ;call the mouse driver
;
            cmp   ax,false                  ;mouse presents?
            jne   MouseAct                  ;yes, then skip next code
;
            mov   dx,OFFSET NoMouseFnd      ;mouse not found!
            call  MessageOut                ;display a message
            jmp   SHORT Go1                 ;go
;
MouseAct:   mov   BYTE PTR CS:MouseYes,true ;mouse is active
;
Go1:        mov   dx,OFFSET Installed       ;message about installation
            call  MessageOut                ;display a message
;
NoInstall:  mov   bx,CmdLine                ;beginning of cmd line
;
            mov   cl,DS:[bx]                ;get a line length
            cmp   cl,ShortLen               ;short cmd line?
            ja    ParseLine                 ;no, then check a line
;
            mov   dx,OFFSET NoFileName      ;filename not found
GotoDOS:    call  MessageOut                ;display a message
;
            cmp   CS:[CheckFlag],false      ;now installed?
            jne   Resident                  ;already in memory
;
            mov   ax,(Keep shl 8)+ErrorCode ;stay resident
            mov   cx,4                      ;divisor for adjust
            mov   dx,OFFSET Start           ;size of resident part
            shr   dx,cl                     ;divide by 16
            inc   dx                        ;add paragraph
            int   MS_DOS                    ;call DOS dispatcher
;
Resident:   mov   dx,OFFSET MemResident     ;already installed
            call  MessageOut                ;display a message
;
            mov   ax,(End_Process shl 8)+ErrorCode ;terminate program
            int   MS_DOS                    ;call DOS dispatcher
;
ParseLine:  inc   bx                        ;advance to next position
            dec   cl                        ;decrement char count
            cmp   BYTE PTR [bx],SPC         ;it's space?
            je    ParseLine                 ;yes, then wait nowhite char
;
            inc   cl                        ;first char
            mov   si,OFFSET FileName        ;use for index position
            mov   es,CS:[Vector]            ;segment of buffer
;
NextChar:   mov   al,[bx]                   ;get the char
            mov   BYTE PTR ES:[si],al       ;and save it
            inc   bx                        ;advance pointer to next char
            inc   si                        ;advance buffer pointer
            dec   cl                        ;decrease char counter
            jnz   NextChar                  ;all chars read?
            mov   BYTE PTR [si],0           ;make ASCIIZ string
;
            mov   BYTE PTR ES:[FileFound],true ;filename presents
            mov   dx,OFFSET WriteFuture     ;can be write
            jmp   SHORT GotoDOS             ;back to DOS
;
MessageOut  PROC  NEAR
            push  ds                        ;save data segment
            mov   ds,cs:[CodeSeg]           ;DS is same that code segment
            mov   ah,DispString             ;function = display a string
            int   MS_DOS                    ;call DOS dispatcher
            pop   ds                        ;restore data segment
            ret                             ;return
MessageOut  ENDP
;
;-------------------------------------------------------------------------
;                  DATA   SECTION
;-------------------------------------------------------------------------
;
Vector      DW    (?)                       ;saved hqndler segment
CheckFlag   DB    true                      ;installation flag
;
Hello       DB    "Welcome to VideoSoft Software World!",Bell,CR,LF,"$"
Installed   DB    "The Window Screen Clipper is installed...",CR,LF,"$"
NoMouseFnd  DB    "The MicroSoft Mouse not found...",CR,LF,"$"
NoFileName  DB    "The filename not found...",CR,LF,"$"
MemResident DB    "The Window Screen Clipper already in memory...",CR,LF,"$"
WriteFuture DB    "The filename has been reading from cmd line...",CR,LF,"$"
;
;
CodSeg      ENDS
;
;-------------------------------------------------------------------------
;                   END  OF  PROGRAM
;-------------------------------------------------------------------------
            IF1                             ;talking with user
              %OUT   Ending of pass 1
            ENDIF
;
            IF2
              %OUT   Ending of pass 2
            ENDIF
;
            END      Start
