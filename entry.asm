global _start
global screenDimensions.x, screenDimensions.y
global screenDimensions.width, screenDimensions.height

%include "inc/constants.asm"
%include "inc/symbols.asm"

section .text

_start:
	call	setIoctl
	call	getScreenDimensions
;TODO recheck whenever poll is zero in .loop
	mov	word	[screenDimensions.x],	ax
	mov	word	[screenDimensions.y],	dx
.loop:
	mov	rax,	SYS_READ
	mov	rdi,	STDIN
	mov	rsi,	charBuf
	mov	rdx,	1
	syscall
	cmp	rax,	0
	je	.exit	; We have blocking READ, no data to read = EOF
	movzx	eax,	byte	[charBuf]
	cmp	eax,	27
	je	.potentialEscape
	call	processKey
	jmp	.loop
.potentialEscape:
	mov	rax,	SYS_POLL
	mov	rdi,	pollfd
	mov	rsi,	1
	mov	rdx,	0
	syscall
	cmp	word	[pollfd + 6],	1
	je	.potentialEscape2
	mov	eax,	27
	call	processKey
	jmp	.loop
.potentialEscape2:
	mov	rax,	SYS_READ
	mov	rdi,	STDIN
	mov	rsi,	charBuf
	mov	rdx,	1
	syscall
	movzx	eax,	byte	[charBuf]
	cmp	eax,	91
	je	.potentialEscape3
	mov	eax,	27
	call	processKey
	movzx	eax,	byte	[charBuf]
	call	processKey
	jmp	.loop
.potentialEscape3:
	mov	rax,	SYS_POLL
	mov	rdi,	pollfd
	mov	rsi,	1
	mov	rdx,	0
	mov	word	[pollfd + 6],	0
	syscall
	cmp	word	[pollfd + 6],	1
	je	.potentialEscape4
	mov	eax,	27
	call	processKey
	mov	eax,	91
	call	processKey
	jmp	.loop
.potentialEscape4:
	mov	rax,	SYS_READ
	mov	rdi,	STDIN
	mov	rsi,	charBuf + 1
	mov	rdx,	1
	syscall
	movzx	eax,	byte	[charBuf + 1]
	cmp	eax,	65
	jb	.potentialEscape4Issue
	cmp	eax,	68
	ja	.potentialEscape4Issue
	sub	eax,	65
	movzx	eax,	byte	[arrowKeyTranslationTable + eax]
	call	processKey
	jmp	.loop
.potentialEscape4Issue:
	mov	eax,	27
	call	processKey
	mov	eax,	91
	call	processKey
	movzx	eax,	byte	[charBuf + 1]
	call	processKey
	jmp	.loop
.exit:
	call	resetIoctl
	mov	rax,	SYS_EXIT
	mov	rdi,	0
	syscall

section .bss

charBuf:	resb	2	;Two bytes for the really edge case of
				;potentialEscape4

section .data

pollfd:
	dd	STDIN
	dw	1	; POLLIN
	dw	0	; revents (return value goes here)
arrowKeyTranslationTable:
	db	119, 115, 100, 97
screenDimensions:
.x:
.width:	dw	80
.y:
.height:	dw	25
