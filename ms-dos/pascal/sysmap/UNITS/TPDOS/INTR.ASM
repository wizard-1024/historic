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

          PUBLIC   Intr

   ; this code was stolen from TP 5.0 Dos init!

   IntNo            EQU         [BP+12]
   RegsRecord       EQU         [BP+8]

   Intr             PROC        FAR
                push  bp                          ;save Turbo environment
                push  ds
                mov   bp,sp
                pushf                            ;save flags
                mov   bx,OFFSET ReloadRegs       ;prepare to return
                push  cs                         ;push segment of return address
                push  bx                         ;push offset of return address
                Zero  bx                         ;get vector address from IDT
                mov   ds,bx
                mov   bl,IntNo                   ;calculate offset
                shl   bx,1
                shl   bx,1
                lds   bx,[bx]                    ;load vector address
                push  ds                         ;push address into stack
                push  bx
                lds   si,RegsRecord              ;load values into registers
                cld                              ;forward
                lodsw                            ;get Regs.AX
                push  ax
                lodsw                            ;get Regs.BX
                mov   bx,ax
                lodsw                            ;get Regs.CX                mov   cx,ax
                lodsw                            ;get Regs.DX
                mov   dx,ax
                lodsw                            ;get Regs.BP
                mov   bp,ax
                lodsw                            ;get Regs.SI
                push  ax
                lodsw                            ;get Regs.DI
                mov   di,ax
                lodsw                            ;get Regs.DS
                push  ax
                lodsw                            ;get Regs.ES
                mov   es,ax
                pop   ds                         ;pop last registers
                pop   si
                pop   ax
                cli                              ;disable interrupts
                ret                              ;return far
   ReloadRegs:
                pushf                            ;save regs
                push  es
                push  di
                push  bp
                mov   bp,sp                      ;set up stack frame
                les   di,[bp+16]                 ;load pointer
                cld                              ;forward
                stosw                            ;put Regs.AX
                mov   ax,bx
                stosw                            ;put Regs.BX
                mov   ax,cx
                stosw                            ;put Regs.CX
                mov   ax,dx
                stosw                            ;put Regs.DX
                pop   ax
                stosw                            ;put Regs.BP
                mov   ax,si
                stosw                            ;put Regs.SI
                pop   ax
                stosw                            ;put Regs.DI
                mov   ax,ds
                stosw                            ;put Regs.DS
                pop   ax
                stosw                            ;put Regs.ES
                pop   ax
                stosw                            ;put Regs.Flags
                pop   ds                         ;restore Turbo environment
                pop   bp
                ret   6                          ;remove parms and pop
   Intr             ENDP


   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
