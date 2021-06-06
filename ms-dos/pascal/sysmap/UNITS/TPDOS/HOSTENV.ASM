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

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   MasterEnvironment

;  interface  functions

;  modified from MASM 5.0 package

   MasterEnvironment PROC       FAR
              mov    es,PrefixSeg                ;get PSP address
              mov    dx,es:[ShellSeg]            ;load segment of COMMAND.COM
              mov    es,dx                       ;into ES
              mov    ax,es:[EnvPtr]              ;load COMMAND.COM's segment
              or     ax,ax                       ;is it null?
              jnz    Secondary                   ;No? This is a secondary shell
              dec    dx                          ;Yes? This is original shell
              mov    es,dx                       ;so points ES to paragraph before PSP
              add    dx,es:[BlockSize]           ;offset of environment
              add    dx,2                        ;adjust it back to PSP
              mov    ax,dx                       ;put it into AX
   Secondary:
              ret                                ;return far
   MasterEnvironment ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
