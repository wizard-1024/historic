                PAGE   59,132
                TITLE  External assembly routines for TpString Unit

;  Version     2.00
;  Date        01/03/90
;  Programmer  Dmitri V. Stefankov

   INCLUDE   TPCOMMON.INC                             ;macros and equates

;   data  segment
   DATA         SEGMENT  WORD  PUBLIC
                ASSUME   DS:DATA                      ;info for MASM
; no variables

   DATA         ENDS

;  code  segment
   CODE         SEGMENT  BYTE  PUBLIC
                ASSUME   CS:CODE,DS:DATA              ;info for MASM

                PUBLIC   Search
                PUBLIC   SearchPtr

;  procedures

  ; this function was stoled from Turbo Professional Package!

  MatchLen      EQU      WP   SS:[BP+6]
  Match         EQU      DP   SS:[BP+8]
  BufLen        EQU      WP   SS:[BP+12]
  Buffer        EQU      DP   SS:[BP+14]

  Search        PROC     FAR
  SearchPtr     PROC     FAR
             StackFrameBP                             ;begin
             push      ds                             ;save DS
             cld                                      ;forward direction
             les       di,Buffer                      ;ES:DI => buffer
             mov       bx,di                          ;BX = Ofs(Buffer)
             mov       cx,BufLen                      ;CX = area to search
             mov       dx,MatchLen                    ;DX = len of match string
             test      dx,dx                          ;null length?
             jz        SearchErr                      ;if so, we're done
             lds       si,Match                       ;DS:DI => match buffer
             lodsb                                    ;AL = Match[1],DS:SI => next char
             dec       dx                             ;DX = MatchLen - 1
             sub       cx,dx                          ;CX = BufLen - MatchLen + 1
             jbe       SearchErr                      ;error if BufLen is less
  Next:
             repne     scasb                          ;search for Match[1]
             jne       SearchErr                      ;done if not found
             test      dx,dx                          ;if length = 1 (DX = 0)
             jz        Found                          ;the "string" was found
             push      cx                             ;save CX
             push      di                             ;save DI
             push      si                             ;save SI
             mov       cx,dx                          ;CX = Length(Match) - 1
             repe      cmpsb                          ;does rest string match
             pop       si                             ;recover registers
             pop       di
             pop       cx
             jne       Next                           ;try again if no match
  Found:
             dec       di                             ;DI = offset where end
             mov       ax,di                          ;prepare to subtract
             sub       ax,bx                          ;subtract starting offset
             jmp       SHORT  Done                    ;done
  SearchErr:
             mov       ax,0FFFFh                      ;return -1
  Done:
             pop       ds                             ;restore Turbo enviroment
             ExitCode  12                             ;end
  SearchPtr     ENDP
  Search        ENDP

   CODE         ENDS
       		END
