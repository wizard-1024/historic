MASM
COMMENT /
; *************************************************************************

There isn't much left to shave off this routine & stay within the "rules";
however, Richard Ivie had the right idea regarding the filename. If you
execute the program with the filename, i.e., "memdump.dat" as a parameter,
DOS automatically parses an uppercase, space padded ASCIIZ filename into at
FCB1 @ DS:005DH.

RE: reg assumptions

Many beginning (& some not so new) programmers labor under the
misconception that when COM files are loaded, CS=DS=ES=SS, IP=100H, and
SP=0FFFEh, & all other registers are initialized to 0. This last part is
actually a function of the debugger, not DOS. I have noted several
occasions where both DEBUG and Turbo Debugger (and probably others) out &
out lie to you regarding the actual contents of registers & sections of the
PSP, inserting their own values, which acounts for some unusual command
line parsing tricks in batch files, which, because of debugger output, no
one was the wiser to. Just for kicks, I wrote a quick and dirty to dump the
regs to the console before any code is executed. I was surprised to find
they were the same every time, as shown below, however definitely not all
zero!

AX=0000  BX=0000  CX=00FFh  SI=0100h	DI = SP = FFFEh  BP=091Ch (???)

DX = CS = DS = ES = SS # BP	- no idea why the BP value ???


	The best I could do is 25 bytes. I think we've sqeezed this dry! };o)

end comment
/

IDEAL
; *************************************************************************
	MODEL TINY

SEGMENT   TEXT BYTE PUBLIC    'CODE'

	ASSUME CS:TEXT, DS:TEXT, ES:TEXT, SS:TEXT

	ORG 100H
; *************************************************************************

START:
	
	MOV  AH, 3CH
	MOV  DX, 5DH        ; get fname from FCB1
	XOR  CX, CX		; normal attribute
	INT  21H

	XCHG BX, AX         ; handle in BX
	CWD                 ; clear DX,AX
	XOR  SI, SI         ; for Seg math
	MOV  CL, 10H        ; CX still 0 unchanged

NEXT:
	MOV  DS, SI         ; start at Seg 0
	MOV  AH, 40H        ; write a para
	INT 21H
	INC SI			; next Seg
	JNZ NEXT
	RET

ENDS

END   START
