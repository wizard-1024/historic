        page    60, 132
        title   Force exit to DOS command prompt

; Name:     EXIT2DOS
; Purpose:  Force exit to DOS from hangup program
; Author:   Dmitry Stefankov
; Date:     22-Feb-1998


RIGHT_SHIFT         =   01h                 ;; keyboard state flags
LEFT_SHIFT          =   02h
CTRL_KEY            =   04h
ALT_KEY             =   08h
SCROLL_LOCK         =   10h
CAPS_LOCK           =   40h


bios_data   SEGMENT AT  40h
        ORG 17h
key_flags_1     DB      ?        
bios_data   ENDS


code    SEGMENT  'CODE'
ASSUME cs:code,ds:code,ss:code
        ORG 2Ch
@ProgramEnv     LABEL   word                ;; environment word        
        ORG 54h
@NewCodeStart   label   byte                ;; Move a copy here
        ORG 5Ch                             ;; FCB start
@FCB_1  label   byte        
        ORG 100h                            ;; make command file
        
@Start:
            jmp     SHORT  @Init
new_int_09      PROC    FAR
                pushf
                DB  9Ah                     ;; CALL FAR seg:ofs
dwInt09Ofs      DW   0                
dwInt09Seg      DW   0
                push    ax
                push    es
                mov     ax, SEG bios_data
                mov     es, ax
                mov     al, es:[key_flags_1]
                and     al, CTRL_KEY+ALT_KEY+SCROLL_LOCK+CAPS_LOCK
                cmp     al, CTRL_KEY+ALT_KEY+SCROLL_LOCK+CAPS_LOCK
                jne    SHORT @NotOurHotKey
                mov     ax, 4C03h           ;; Emulate break key
                int     21h
@NotOurHotKey:                
                pop     es
                pop     ax
                iret
new_int_09      ENDP

@Init:            
                mov     ax, 3509h           ;; Get old vector in ES:BX
                int     21h
                mov     dwInt09Seg, es      ;; Save it
                mov     dwInt09Ofs, bx

                mov     ax, ds              ;; Copy interrupt code to PSP
                mov     es, ax
                mov     si, OFFSET new_int_09
                mov     di, OFFSET @NewCodeStart
                mov     dx, di              ;; Save new program offset
                mov     cx, (OFFSET @Init) - (OFFSET new_int_09)
                mov     bx, cx              ;; Save TSR code size
                cld
                rep     movsb

                mov     ax, 2509h           ;; Set our intvec DS:DX
                int     21h

                mov     es, es:[@ProgramEnv];; free up unused memory
                mov     ah, 49h
                int     21h

                add     dx, bx              ;; Start+Offset
                add     dx, 15              ;; Align on paragraph boundary
                REPT    4
                    shr     dx, 1
                ENDM
                mov     ax, 3100h           ;; Keep process in memory
                int     21h
                    
code        ENDS

        END @Start
