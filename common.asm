global strToDW:function, DWToStr:function

%include "inc/constants.asm"
%include "inc/errors.asm"

section .text

; rax = const char *buf
; rdi = bufLen. Must be greater than 0
; rsi = base (implemented only 10)
; returns double word in rax, zeroes rdi. Only unsigned
strToDW:
	cmp	rsi,	10
	jne	.err1
	cmp	rdi,	0
	jle	.err2
.baseTen:
	push	r10
	push	rdx
	push	r9
	mov	r9,	10
	mov	r10,	rax
	xor	eax,	eax
.baseTen.loop:
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
	jmp	.baseTen.loop
.done:
	xor	edi,	edi
	pop	r9
	pop	rdx
	pop	r10
	ret
.err1:
	mov	rax,	SYS_EXIT
	mov	rdi,	ENOSYS
	syscall
.err2:
	mov	rax,	SYS_EXIT
	mov	rdi,	EINVAL
	syscall
.err3:
	mov	rax,	SYS_EXIT
	mov	rdi,	E_ENOTSUP
	syscall

; eax = in num
; rdx = char* buf of sufficient length
; out
; rax = buflen
DWToStr:
	je	.zero
	push	r11
	push	r12
	push	rdx
	xor	r11d,	r11d
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
