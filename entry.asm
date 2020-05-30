global _start
extern strToDW, getCursorPos, setIoctl, resetIoctl, DWToStr
extern findChar

%include "inc/constants.asm"

section .text

_start:
	call	setIoctl
	call	getCursorPos
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
