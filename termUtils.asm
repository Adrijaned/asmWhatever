global getCursorPos, getScreenDimensions
global setIoctl, resetIoctl
global printToPos

%include "inc/constants.asm"
%include "inc/errors.asm"
%include "inc/symbols.asm"

section .text
;https://stackoverflow.com/questions/3305005/how-do-i-read-single-character-input-from-keyboard-using-nasm-assembly-under-u
;/include/uapi/asm-generic/termbits.h in kernel
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
	mov	rax,	qword	[Ioctl.termios]
	mov	qword	[Ioctl.orig_flag],	rax
	mov	rax,	qword	[Ioctl.termios + 8]
	mov	qword	[Ioctl.orig_flag + 8],	rax
	; We want UTF8, don't care about anything else
	mov	dword	[Ioctl.termios],	100000000000000b
	mov	dword	[Ioctl.termios + 4],	0
	; eight bits per byte
	or	dword	[Ioctl.termios + 8],	110000b
	mov	dword	[Ioctl.termios + 12],	0
	movzx	eax,	word	[Ioctl.termios + 22]
	mov	word	[Ioctl.orig_Vthings],	ax
	; Always READ at least one character
	mov	byte	[Ioctl.termios + 23], 	1
	; no waiting time for READ
	mov	byte	[Ioctl.termios + 22],	0
	mov	rax,	SYS_IOCTL
	TCSETS	equ	0x5402
	mov	rsi,	TCSETS
	syscall
	mov	rax,	SYS_WRITE
	mov	rdi,	STDOUT
	mov	rsi,	.alternateScreenMsg
	mov	rdx,	(.alternateScreenMsgEnd - .alternateScreenMsg)
	syscall
	ret

section .data
.alternateScreenMsg:
	db `\e[?1049h\e[2J`
.alternateScreenMsgEnd:

section .text
resetIoctl:
	cmp	byte	[Ioctl.isCustomTermMode],	1
	je	.notSetYet
	mov	rax,	SYS_EXIT
	mov	rdi,	E_LOGERROR
	syscall
.notSetYet:
	mov	byte	[Ioctl.isCustomTermMode],	0
	mov	rax,	qword	[Ioctl.orig_flag]
	mov	qword	[Ioctl.termios],	rax
	mov	rax,	qword	[Ioctl.orig_flag + 8]
	mov	qword	[Ioctl.termios + 8],	rax
	movzx	eax,	word	[Ioctl.orig_Vthings]
	mov	word	[Ioctl.termios + 22],	ax
	mov	rax,	SYS_IOCTL
	mov	rdi,	STDIN
	mov	rsi,	TCSETS
	mov	rdx,	Ioctl.termios
	syscall
	mov	rax,	SYS_WRITE
	mov	rdi,	STDOUT
	mov	rsi,	.alternateScreenMsg
	mov	rdx,	(.alternateScreenMsgEnd - .alternateScreenMsg)
	syscall
	ret

section .data

.alternateScreenMsg:
	db `\e[?1049l`
.alternateScreenMsgEnd:

Ioctl:
.isCustomTermMode:	db	0

section .bss

.termios:	resb	36
.orig_flag:	resb	16
.orig_Vthings:	resb	2

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

section .text

printToPos:
	push	rax
	mov	rax,	rdx
	mov	rdx,	.messageMove + 2
	call	DWToStr
	lea	rdx,	[.messageMove + rax + 3]
	mov	[rdx - 1],	byte	';'
	pop	rax
	call	DWToStr
	add	rdx,	rax
	mov	[rdx],	byte	'H'
	mov	rax,	SYS_WRITE
	mov	r8,	rdi
	mov	r9,	rsi
	mov	rdi,	STDOUT
	mov	rsi,	.messageMove
	sub	rdx,	.messageMove - 1
	syscall
	mov	rax,	SYS_WRITE
	mov	rsi,	r8
	mov	rdx,	r9
	syscall
	ret

section .data

.messageMove:
	db `\e[`, 0, 0, 0, 0, 0, 0, 0, 0
