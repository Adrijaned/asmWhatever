global strToDW:function, DWToStr:function
global findChar:function
global properExit:function

%include "inc/constants.asm"
%include "inc/errors.asm"
%include "inc/symbols.asm"

section .text

strToDW:
	cmp	rdi,	0
	jle	.err2
	push	r10
	push	rdx
	push	r9
	mov	r9,	10
	mov	r10,	rax
	xor	eax,	eax
.loop:
	cmp	rdi,	0
	jle	.done
	dec	rdi
	mul	r9
	cmp	byte	[r10],	0x30
	jl	.err3
	cmp	byte	[r10],	0x39
	jg	.err3
	add	al,	[r10]
	sub	rax,	0x30
	inc	r10
	jmp	.loop
.done:
	xor	edi,	edi
	pop	r9
	pop	rdx
	pop	r10
	ret
.err2:
	mov	rax,	SYS_EXIT
	mov	rdi,	EINVAL
	syscall
.err3:
	mov	rax,	SYS_EXIT
	mov	rdi,	E_ENOTSUP
	syscall

DWToStr:
	cmp	eax,	0
	je	.zero
	push	r11
	push	r12
	push	rdx
	xor	r11,	r11
	mov	r12,	10
.loop:
	xor	edx,	edx
	div	r12d
	add	edx,	0x30
	mov	byte	[.temp + r11],	dl
	inc	r11
	cmp	eax,	0
	jne	.loop
	pop	rdx
.copyloop:
	movzx	r12,	byte	[.temp + r11 - 1]
	mov	byte	[rdx + rax],	r12b
	inc	rax
	dec	r11
	jnz	.copyloop
	pop	r12
	pop	r11
	ret
.zero:
	mov	byte	[rdx],	0x30
	mov	rax,	1
	ret

section .bss

.temp: resb 10

section .text

findChar:
	push	rbx
	xor	ebx,	ebx
.loop:
	cmp	rbx,	rsi
	jge	.notFound
	cmp	al,	byte	[rdx + rbx]
	je	.found
	inc	rbx
	jmp	.loop
.found:
	mov	rax,	rbx
	pop	rbx
	ret
.notFound:
	mov	rax,	-1
	pop	rbx
	ret

properExit:
	push	rax
	call	resetIoctl
	pop	rdi
	mov	rax,	SYS_EXIT
	syscall
