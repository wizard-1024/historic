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

          PUBLIC   GetEnvSize

;  interface  functions

   EnvBlockSizeVar EQU          SS:[SI+4]
   EnvSizeVar      EQU          SS:[SI+8]

   GetEnvSize      PROC         FAR
              StackFrame   si                    ;set up stack
              push   si                          ;save SI
              call   GetEnvPtr                   ;environment pointer = DX:AX
              mov    ax,dx                       ;save a copy
              mov    si,ax                       ;save a copy
              Zero   dx                          ;clear DX for multiply
              dec    ax                          ;get paragraph before enviroment
              mov    es,ax                       ;load into DS
              mov    ax,es:[BlockSize]           ;size in para
              mov    cx,16                       ;multiply by 16
              mul    cx
              mov    es,si                       ;restore enviroment addr
              Zero   di                          ;point to start
              mov    cx,ax                       ;load maximum count (size of
              mov    bx,ax                       ; enviroment) and save a copy
              Zero   ax                          ;search for double null
   Null2:
              repne  scasb                       ;look for null
              je     NoErr                       ;if not out space, continue
              Zero   ax                          ;else error (return 0)
              jmp    Short  ExitFunc
   NoErr:
              cmp    BYTE PTR es:[di],0          ;is it double null?
              jne    Null2                       ;no? Look again
              mov    ax,di                       ;reload size
   ExitFunc:
              pop    si                          ;restore SI
              les    di,EnvSizeVar               ;load variables with values
              mov    es:[di],ax
              les    di,EnvBlockSizeVar
              mov    es:[di],bx
              ret    8                           ;remove parameters and return
   GetEnvSize      ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
