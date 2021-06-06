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

          PUBLIC   SwapVectors

;  interface  functions

   SwapVectors     PROC      FAR
                 mov    di,OFFSET SaveInt00      ;pointer to first vector
                 mov    si,OFFSET VectorTable    ;pointer to table
                 mov    cx,VecTableLen           ;load the table length
                 cld                             ;forward direction
   L6:
                 lods   byte ptr cs:[si]         ;get # interrupt
                 mov    ah,GetVector             ;Dos function
                 call    DosControl              ;call Dos
                 push   es                       ;save a segment
                 push   bx                       ;save a offset
                 push   ds                       ;save DS
                 lds    dx,DP [di]               ;load the pointer
                 mov    ah,SetVector             ;set the interrupt vector
                 call    DosControl              ;call Dos
                 pop    ds                       ;restore DS
                 pop    WP [di]                  ;get the offset back
                 pop    WP 2[di]                 ;get the segment back
                 add    di,4                     ;points to next element
                 loop   L6                       ;continue till done
                 ret                             ;return far
   SwapVectors     ENDP

   VectorTable     DB    0,2,1Bh,23h,24h,34h,35h,36h,37h,38h
                   DB    39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,75h
   VecTableLen     =     $ - VectorTable

   IF1
          %OUT  Ending of pass 1
   ENDIF
   IF2
          %OUT  Ending of pass 2
   ENDIF


   CODE   ENDS
          END
