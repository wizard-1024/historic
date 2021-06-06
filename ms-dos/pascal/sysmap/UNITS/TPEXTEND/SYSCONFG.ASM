                   PAGE   59,132
                   TITLE  External assembly routines for TpExtend Unit

;  Version     1.0
;  Date        04/22/90
;  Programmer  Dima Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

;  internal variables

   DATA   ENDS


   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   SystemConfiguration


;  interface  part

   Valid           EQU       SS:[DI+4]
   Table           EQU       SS:[DI+8]

   SystemConfiguration PROC  FAR
                StackFrame  di                   ;set up stack frame
                push    ds                       ;save DS
                mov     ah,0C0h                  ;load function
                int     ATbios                   ;call BIOS
                Zero    al                       ;make a boolean result
                jc      L3
                mov     al,1
   L3:
                lds     si,Valid
                mov     [si],al
                mov     si,bx                    ;ES:BX = ptr to table
                mov     ax,es
                mov     ds,ax                    ;DS:SI = ptr to table now
                mov     cx,10
                les     di,Table                 ;save a table to our var
                rep     movsb
                pop     ds                       ;recover DS
                ret     8                        ;return and pop parms
   SystemConfiguration ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
