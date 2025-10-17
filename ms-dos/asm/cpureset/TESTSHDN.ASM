	.model small
	.code
	org	100h

@Start:
	jmp	@Init

dwSS	dw	?
dwSP	dw	?

szDone	db	13, 10, 'Shutdown done.',13,10,'$'
	
@Init:
	mov	ax, 40h
	mov	es, ax
	mov	word ptr es:[67h], offset @Done
	mov	word ptr es:[69h], cs

	cli
	mov	al,8Fh
	out	70h, al
	jmp	$ + 2
	jmp	$ + 2
	mov	al, 0Ah
	out	71h, al

	sti
	mov	al, 0FEh
	out	64h, al
@Stop:
	hlt
	jmp	@Stop

@Done:
	mov	ax, cs
	mov	ds, ax
	mov	ss, ax
	mov	sp, 08000h

	mov	dx, OFFSET szDone
	mov	ah, 9
	int	21h

	mov	ax, 4c00h
	int	21h

	end	@Start
