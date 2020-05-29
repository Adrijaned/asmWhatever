global _start
extern strToDW, getCursorPos, setIoctl, resetIoctl, DWToStr

%include "inc/constants.asm"

section .text

_start:
	mov	rax,	0xFFfffFFF
	mov	rdx,	mytest
	call	DWToStr
	mov	rsi,	rdx
	mov	rdx,	rax
	mov	rdi,	STDOUT
	mov	rax,	SYS_WRITE
	syscall
	mov	rax,	SYS_EXIT
	mov	rdi,	0
	syscall

section .bss

mytest: resb 12
