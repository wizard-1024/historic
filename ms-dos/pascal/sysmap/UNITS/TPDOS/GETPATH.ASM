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

          PUBLIC   GetProgramPath

;  interface  functions

   NamePtr         EQU          SS:[BX+4]        ;parameter

   GetProgramPath  PROC         FAR
              StackFrame   bx                    ;set up stack
              push   ds                          ;save environment
              push   bx
              call   GetEnvCount                 ;ES:[DI] => to Asciiz pathname
              pop    bx                          ;restore BX
              mov    ax,es                       ;move ES to DS
              mov    ds,ax
              mov    si,di                       ;move DI to SI
              lodsw                              ;skip one word
              les    di,NamePtr                  ;the destination string ptr
              push   di                          ;save the pointer
              stosb                              ;first byte = length
              call   MoveString                  ;copy a string
              pop    di                          ;pointer to the length
              mov    BYTE PTR es:[di],cl         ;store the length
              pop    ds                          ;recover DS
              ret                                ;far return
   GetProgramPath  ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
