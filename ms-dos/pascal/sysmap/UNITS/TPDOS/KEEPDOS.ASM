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

   DATA   ENDS

   CODE   SEGMENT  BYTE   PUBLIC
          ASSUME   CS:CODE, DS:DATA              ;info for MASM

          PUBLIC   DosControl,DosError,DosIO
          PUBLIC   SaveHandle,HandleIO,MoveString
	  PUBLIC   PutTrueDosEntry

;  internal variables
   
   SaveDosInt     DD         ?

;  internal routines

   DosControl      PROC      NEAR
               push  ax                          ;save regs
               push  ds
               mov   ax,seg  DATA
               mov   ds,ax
               cmp   UseTrueDos,false            ;see flag to call
               je    UseDefault
               pop   ds                          ;recover registers
               pop   ax
	       pushf				 ;emulate the interrupt
               call  cs:SaveDosInt               ;true entry to Dos
               ret
   UseDefault:
              pop    ds                          ;restore registers
              pop    ax
              int    MsDos                       ;what we have
              ret
   DosControl      ENDP

   DosError        PROC      NEAR
   	       jc    Error1                      ;error flag?
               mov   [InOutRes],0                ;clear error code
   	       ret
   Error1:
               mov   [InOutRes],ax               ;save Dos error
               ret
   DosError	   ENDP

   DosIO           PROC      NEAR
               call   DosControl               ;call DOS
               call   DosError                 ;check for errors
               ret                             ;and return
   DosIO           ENDP

   Handle          EQU       DP   SS:[BX+2]

   SaveHandle      PROC      NEAR
                lds     bx,Handle                ;get the pointer
                mov     [bx],ax                  ;save the handle
                ret
   SaveHandle      ENDP

   FileHandle      EQU       WP  SS:[SI+14]      ;parameters
   Buffer	   EQU       DP	 SS:[SI+10]
   Count           EQU       WP  SS:[SI+8]
   Result          EQU       DP  SS:[SI+4]

   HandleIO        PROC      NEAR
                mov     cx,Count                 ;get the counter
                mov     bx,FileHandle            ;load the file handle
                push	ds			 ;save DS
                lds     dx,Buffer                ;load the filename
                call    DosControl               ;call Dos
                lds     bx,Result                ;get the pointer
                mov     [bx],ax                  ;save the result count
                pop	ds			 ;restore DS
                call	DosError		 ;check for errors
                ret
   HandleIO        ENDP

   MoveString      PROC      NEAR
               Zero   cx                          ;clear a counter
   L10:        lodsb                              ;get byte
               or    al,al                        ;zero ?
               jz     L11                         ;if found the exit
               stosb                              ;store a char
               inc    cx                          ;increment a counter
               jmp    SHORT  L10                  ;if no zero then continue
   L11:
               ret                                ;return near
   MoveString      ENDP

   DosPtr	   EQU       SS:[BX+2]

   PutTrueDosEntry PROC      NEAR
               StackFrame    bx                   ;access to parms
	       les   di,DosPtr			  ;ES:DI -> ptr
	       mov   WP cs:SaveDosInt,di	  ;save offset
	       mov   WP cs:SaveDosInt+2,es	  ;save segment
	       ret   4              
   PutTrueDosEntry ENDP

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
