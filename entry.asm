global _start

%include "inc/constants.asm"
%include "inc/symbols.asm"

section .text

_start:
	call	setIoctl
	mov	rax,	5
	mov	rdx,	6
	mov	rdi,	anothertest
	mov	rsi,	anotherTest - anothertest
	call	printToPos
	mov	rax,	SYS_NANOSLEEP
	mov	rdi,	sleepTime
	mov	rsi,	0
	syscall
	call	resetIoctl
	mov	rax,	SYS_EXIT
	mov	rdi,	0
	syscall

section .bss

mytest: resb 12

section .data

anothertest:	db "HiHi"
anotherTest:
sleepTime:
	dq 5 ;;seconds
	dq 0 ;;nanos
