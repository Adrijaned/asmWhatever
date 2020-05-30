global getCursorPos, getScreenDimensions
global setIoctl, resetIoctl

%include "inc/constants.asm"
%include "inc/errors.asm"
%include "inc/symbols.asm"

section .text
;https://stackoverflow.com/questions/3305005/how-do-i-read-single-character-input-from-keyboard-using-nasm-assembly-under-u
setIoctl:
	cmp	byte	[Ioctl.isCustomTermMode],	0
	je	.notSetYet
	call	resetIoctl
	mov	rax,	SYS_EXIT
	mov	rdi,	E_LOGERROR
	syscall
.notSetYet:
	mov	byte	[Ioctl.isCustomTermMode],	1
	mov	rax,	SYS_IOCTL
	mov	rdi,	STDIN
	TCGETS	equ	0x5401
	mov	rsi,	TCGETS
	mov	rdx,	Ioctl.termios
	syscall
	mov	eax,	dword	[Ioctl.termios + 12]
	mov	dword	[Ioctl.orig_c_lflag],	eax
	and	dword	[Ioctl.termios + 12],	!1010b
	mov	rax,	SYS_IOCTL
	TCSETS	equ	0x5402
	mov	rsi,	TCSETS
	syscall
	ret

resetIoctl:
	cmp	byte	[Ioctl.isCustomTermMode],	1
	je	.notSetYet
	mov	rax,	SYS_EXIT
	mov	rdi,	E_LOGERROR
	syscall
.notSetYet:
	mov	byte	[Ioctl.isCustomTermMode],	0
	mov	eax,	dword	[Ioctl.orig_c_lflag]
	mov	dword	[Ioctl.termios + 12],	eax
	mov	rax,	SYS_IOCTL
	mov	rdi,	STDIN
	mov	rsi,	TCSETS
	mov	rdx,	Ioctl.termios
	syscall
	ret

Ioctl:
section .data

.isCustomTermMode:	db	0

section .bss

.termios:	resb	36
.orig_c_lflag:	resb	4

section .text

getCursorPos:
	mov	rax,	SYS_WRITE
	mov	rdi,	STDOUT
	mov	rsi,	.message
	mov	rdx,	(.messageEnd - .message)
	syscall
	;TODO ttyerr error handling
	mov	rax,	SYS_READ
	mov	rdi,	STDIN
	mov	rsi,	.retMsg
	mov	rdx,	10
	syscall
	cmp	rax,	0
	jg	.readOK
	mov	rax,	SYS_EXIT
	mov	rdi,	ENOTTY
	syscall
.readOK:
	mov	word	[.retMsg],	0
	mov	rsi,	rax
	mov	rdx,	.retMsg
	mov	rax,	";"
	call	findChar
	mov	r10,	rax
	lea	rdi,	[rax - 2]
	mov	rax,	.retMsg + 2
	call	strToDW
	mov	rdx,	rax
	lea	rax,	[.retMsg + 1 + r10]
	mov	rdi,	rsi
	sub	rdi,	r10
	sub	rdi,	2
	call	strToDW
	ret

section .data

.message:
	db `\e[8m\e[6n`
.messageEnd:

section .bss

.retMsg:
	resb 10

section .text

getScreenDimensions:
	mov	rax,	SYS_WRITE
	mov	rdi,	STDOUT
	mov	rsi,	.message1
	mov	rdx,	.message1End - .message1
	syscall
	call	getCursorPos
	push	rdx
	push	rax
	mov	rax,	SYS_WRITE
	mov	rdi,	STDOUT
	mov	rsi,	.message2
	mov	rdx,	.message2End - .message2
	syscall
	pop	rax
	pop	rdx
	ret

section .data

.message1:
	db `\e[s\e[999;999H`
.message1End:
.message2:
	db `\e[u`
.message2End:
