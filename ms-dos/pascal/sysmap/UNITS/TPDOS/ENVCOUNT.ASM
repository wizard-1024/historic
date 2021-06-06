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
          EXTRN    GetEnvPtr      :  FAR

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   GetEnvCount

;  interface  functions

   GetEnvCount     PROC         FAR
              call   GetEnvPtr                   ;get the environment address
              mov    es,dx                       ;ES = Dos enviroment segment
              mov    di,ax                       ;DI = Dos environment offset
              mov    cx,MaxLenOfEnv              ;load the max.length
              cld                                ;forward direction
              Zero   ax                          ;clear AX
              Zero   bx                          ;clear also BX
   L8:
              scasb                              ;check for the zero
              je     L9                          ;zero is found
              repne  scasb                       ;search the zero
              jcxz   L9                          ;end of Dos environment
              inc    bx                          ;increment the counter
              jne     L8                         ;no zero, then continue
   L9:
              mov    ax,bx                       ;function result
              ret                                ;far return
   GetEnvCount     ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
