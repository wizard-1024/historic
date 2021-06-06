                   PAGE   59,132
                   TITLE  External assembly routines for TpDos Unit

;  Version     2.0
;  Date        01/07/90
;  Programmer  Dima Stefankov

   INCLUDE  TPCOMMON.INC

   DATA   SEGMENT  WORD   PUBLIC
          ASSUME   DS:DATA                       ;info for MASM

;  external references

          EXTRN    InOutRes       :  WORD        ;i/o operation result
          EXTRN    FileMode       :  BYTE        ;file mode to open
          EXTRN    SaveInt00      :  WORD        ;pointer to interrupt vectors
          EXTRN    PrefixSeg      :  WORD        ;segment of PSP
          EXTRN    UpCaseString   :  FAR         ;TpString Unit
          EXTRN    ExecBlock      :  WORD        ;exec parameter block
          EXTRN    OvBlock        :  WORD        ;overlay param block
	  EXTRN	   OldSS	  :  WORD	 ;stack info
	  EXTRN	   OldSP	  :  WORD
          EXTRN    UseTrueDos     :  BYTE
          EXTRN    DosControl     :  NEAR
          EXTRN    DosError       :  NEAR
          EXTRN    DosIO          :  NEAR
          EXTRN    SaveHandle     :  NEAR
          EXTRN    HandleIO       :  NEAR
          EXTRN    MoveString     :  NEAR
          EXTRN    GetEnvCount    :  FAR

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC  EnvStr

;  interface  functions

   StringPtr       EQU          SS:[BX+6]        ;parameters
   Index           EQU          SS:[BX+4]

   EnvStr          PROC         FAR
              StackFrame   bx                    ;set up stack
              push   ds                          ;save environment
              push   bx
              call   GetEnvCount                 ;get count of strings
              pop    bx                          ;recover BX
              mov    cx,Index                    ;get our index
              mov    dx,es                       ;move ES to DS
              mov    ds,dx
              Zero   si                          ;DS:SI = environment string
              les    di,StringPtr                ;ES:DI = destination string
              cmp    cx,0                        ;check the index
              je     L12A                        ;no match index
              cmp    ax,cx                       ;check the index
              jae    L12B                        ;match index
   L12A:
              Zero   cx                          ;clear CX
              jmp    SHORT  L16                  ;exit from function
   L12B:
              push   di                          ;save the pointer to length
              stosb                              ;skip it
              mov    bx,cx                       ;save the string index
              mov    cx,MaxLenOfEnv              ;CX = length for search
   L12:
              mov    dx,si                       ;save pointer to 1st char
   L13:
              lodsb                              ;get a char
              cmp    al,0                        ;zero?
              jne    L13                         ;no, then continue
              dec    bx                          ;decrement the counter
              jne    L12                         ;our string?
              mov    si,dx                       ;get the pointer
              call   MoveString                  ;copy a string
              pop    di                          ;restore the pointer
   L16:
              mov    BYTE PTR es:[di],cl         ;save a length
              pop    ds                          ;restore DS
              ret    2                           ;return and pop parameter
   EnvStr          ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
