global _start

%include "inc/constants.asm"
%include "inc/symbols.asm"

section .text

_start:
	call	setIoctl
	call	getScreenDimensions
	mov	rax,	rdx
	mov	rdx,	mytest
	call	DWToStr
	mov	rdx,	rax
	mov	rsi,	mytest
	mov	rdi,	STDOUT
	mov	rax,	SYS_WRITE
	syscall
	call	resetIoctl
	mov	rax,	SYS_EXIT
	mov	rdi,	0
	syscall

section .bss

mytest: resb 12
