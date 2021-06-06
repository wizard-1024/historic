				PAGE	59,132
				TITLE	NEW BOOT LOADER FOR HARD DISK

; Purpose	Protect the machine from user attack
; Input		Modify some variables by BOOTINST.EXE
; Output	CMOS storage overwritten by this module
; Version	1.01
; Date		11/30/89
; Programmer	D.Sfefankoff

				.8086			;MASM directive

; bios data segment

        bios_data	segment  at  40h
			org  072h
	warm_boot_flag	label	word
	bios_data       ends

; bios code segment

        bios_code	segment  at  0F000h
			org  0FFF0h
	power_on	label	far
	bios_code       ends

; main code segment

	cseg	segment	  word  public  'code'
                assume   cs:cseg,ds:cseg

; equates

	false		=	0
	sec_size	=	512
	boot_ofs	=	07C00h

;  start point where loaded by bootstrap loader
;
			ORG   0
	boot_loc	label	byte

;  setup segment regitsers

	start:
		cli
		xor	ax,ax
		mov	ds,ax
		mov	es,ax
		mov	ss,ax
                mov     sp,offset boot_loc + boot_ofs
		sti

;  display the message

		cld					;go forward
		mov	si,offset  message + boot_ofs

	next_char:
		lodsb
		or	al,al				;end of string?
		jz	unlock
		mov	ah,0Eh				;TTY output
		mov	bx,7
		int	10h
		jmp	short	next_char

	unlock:
		mov	si,offset password + boot_ofs
		push	si
		lodsw
		mov	cx,ax				;CX = length of string

	decode:
		ror	byte ptr [si],1
		ror	byte ptr [si],1
		inc	si
		loop	decode

		pop	si
		mov	di,offset user_input + boot_ofs
		push	di

	get_char:
		xor	ah,ah				;read char
		int	16h
		stosb
		cmp	al,13				;carrage return?
		pushf
		mov	ax,0Eh shl 8 + 'X'		;TTY output
		mov	bx,7
		int	10h
		popf
		jne	get_char

		pop	di
		lodsw
		mov	cx,ax
		repe	cmpsb				;compare passwords
		je	go_on
		jmp	halt

; write original boot sector back

	go_on:
		mov	bx,offset boot_loc + sec_size + boot_ofs
		mov	cx,[sector].boot_ofs
		mov	ah,2				;read
		call	disk_io

		mov	si,bx				;now unlock the old boot code
		mov	cx,sec_size
	decode1:
		ror	byte ptr [si],1
		ror	byte ptr [si],1
		inc	si
		loop	decode1

		mov	ah,3				;write
		mov	cx,1				;sector 1 back
		call	disk_io

		mov	di,bx				;fill with zeroes
		mov	cx,sec_size shr 1
		xor	ax,ax
		rep	stosw

		mov	ah,3				;write
		mov	cx,[sector].boot_ofs
		call	disk_io

		cmp	[hard_dsk_2].boot_ofs,false
		je	no_present

		mov	ax,201h				;read 1st sector
		mov	cx,1
		mov	dx,81h
		int	13h
		jc	no_present

		mov	si,bx				;now unlock the old boot code
		mov	cx,sec_size
	decode2:
		ror	byte ptr [si],1
		ror	byte ptr [si],1
		inc	si
		loop	decode2

		mov	ax,301				;write
		mov	cx,1				;sector 1 back
		mov	dx,81h
		int	13h

	no_present:
		cmp	[cmos_flag].boot_ofs,false	;cmos update
		jne	cmos_update
		
; call the bootstrap loader

		int	19h

; write CMOS information back
		
	cmos_update:
		mov	ah,diskette_type.boot_ofs
                mov	al,10h
		call	write_cmos

; equipment byte

		mov	al,94h
		call	read_cmos
		or	al,1
		mov	ah,al
		mov	al,94h
		call	write_cmos

; calculate checksum

		mov	cl,90h
                mov     ch,0AEh
		sub	bx,bx
                cli

	summa:
		mov	al,cl
		call	read_cmos
		sub	ah,ah
		add	bx,ax
		inc	cl
		cmp	ch,cl
		jne	summa

; write checksum

                mov     ah,bh
                mov     al,0AEh
                call    write_cmos
                mov     ah,bl
                mov     al,0AFh
                call    write_cmos
                sti

; now soft reset

		mov	ax,40h
		mov	ds,ax
                assume  ds:bios_data
                mov     warm_boot_flag,01234h
		jmp	power_on

	halt:
		cli
		jmp	short  $+0

; routines

	disk_io		proc	near
                mov	dx,80h
		mov	al,1
		int	13h
		jc	halt
		ret
	disk_io		endp

	write_cmos	proc	near
		out	70h,al
		jmp	short	$+2
		jmp	short	$+2
		jmp	short	$+2
		xchg	ah,al
		out	71h,al
		ret
	write_cmos	endp

	read_cmos	proc	near
		out	70h,al
		jmp	short	$+2
		jmp	short	$+2
		jmp	short	$+2
		in	al,71h
		ret
	read_cmos	endp

	message		db	'PASSWORD:',0
	user_input	=	$

                        org  (boot_loc + sec_size - 17)
	
	sector		dw	?
	cmos_flag	db	false
	hard_dsk_2	db	false
	diskette_type	db	?
	password	db	10  dup (0);
        		dw	0AA55h                        ;boot ID

	cseg	ends
		end	start
