global processKey:function
global initWorld:function

%include "inc/symbols.asm"
%include "inc/errors.asm"
%include "inc/constants.asm"

section	.text

processKey:
	cmp	rax,	'w'
	je	moveUp
	cmp	rax,	'a'
	je	moveLeft
	cmp	rax,	's'
	je	moveDown
	cmp	rax,	'd'
	je	moveRight
	cmp	rax,	3
	je	.exit
	ret
.exit:
	mov	rax,	0
	call	properExit

moveUp:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	dec	word	[player.y]
	jnz	.notAtTop
	inc	word	[player.y]
.notAtTop:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	call	renderLevel
	ret

moveLeft:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	dec	word	[player.x]
	jnz	.notLeft
	inc	word	[player.x]
.notLeft:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	call	renderLevel
	ret

moveDown:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	inc	word	[player.y]
	mov	ax,	word	[screenDimensions.y]
	cmp	word	[player.y],	ax
	jbe	.notDown
	dec	word	[player.y]
.notDown:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	call	renderLevel
	ret

moveRight:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	inc	word	[player.x]
	mov	dx,	word	[screenDimensions.x]
	cmp	word	[player.x],	dx
	jbe	.notRight
	dec	word	[player.x]
.notRight:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	drawTile
	call	renderLevel
	ret	

initWorld:
	mov	rax,	SYS_OPEN
	mov	rdi,	level0fname
	mov	rsi,	O_RDONLY
	mov	rdx,	0
	syscall
	cmp	rax,	-1
	jg	.openedFine
	mov	rax,	36
	call	properExit
.openedFine:
	mov	r8,	rax
	mov	rax,	SYS_MMAP
	mov	rdi,	0
	mov	rsi,	(1 << 17)
	mov	rdx,	(PROT_READ | PROT_WRITE)
	mov	r10,	MAP_PRIVATE
	mov	r9,	0
	syscall
	mov	qword	[levels],	rax
	mov	rdi,	r8
	mov	rax,	SYS_CLOSE
	syscall
	mov	rax,	qword	[predefEntities]
	mov	qword	[entities + 24],	rax
	ret

renderLevel:
	xor	r15,	r15	; redraw needed
	mov	r15,	1
	movzx	edi,	word	[screenDimensions.x]
	sub	edi,	10
	mov	word	[renderDimensions.x],	di
	movzx	r11,	word	[screenDimensions.y]
	sub	r11,	5
	mov	word	[renderDimensions.y],	r11w
	cmp	word	[screenLeftTop.x],	0
	je	.fine1
	movzx	eax,	word	[player.x]
	sub	ax,	word	[screenLeftTop.x]
	lea	rax,	[3*rax]
	cmp	eax,	edi
	jl	.recenterHorizontal
.fine1:
	movzx	eax,	word	[screenLeftTop.x]
	add	eax,	edi
	cmp	eax,	255
	je	.fine2
	sub	ax,	word	[player.x]
	lea	rax,	[3*rax]
	cmp	eax,	edi
	jnl	.fine2
.recenterHorizontal:
	mov	r15,	1
	mov	eax,	edi
	shr	eax,	1
	movzx	ebx,	word	[player.x]
	sub	ebx,	eax
	jns	.hNotNeg
	mov	ebx,	0
	jmp	.hFine
.hNotNeg:
	cmp	ebx,	255
	jng	.hFine
	mov	ebx,	255
.hFine:
	mov	word	[screenLeftTop.x],	bx
.fine2:
	cmp	word	[screenLeftTop.y],	0
	je	.fine3
	movzx	eax,	word	[player.y]
	sub	ax,	word	[screenLeftTop.y]
	lea	rax,	[3*rax]
	cmp	ax,	word	[renderDimensions.y]
	jl	.recenterVertical
.fine3:
	movzx	eax,	word	[screenLeftTop.y]
	add	ax,	word	[renderDimensions.y]
	cmp	eax,	255
	je	.fine4
	sub	ax,	word	[player.y]
	lea	rax,	[3*rax]
	cmp	ax,	word	[renderDimensions.y]
	jnl	.fine4
.recenterVertical:
	mov	r15,	1
	movzx	eax,	word	[renderDimensions.y]
	shr	eax,	1
	movzx	ebx,	word	[player.y]
	sub	ebx,	eax
	jns	.vNotNeg
	mov	ebx,	0
	jmp	.vFine
.vNotNeg:
	cmp	ebx,	255
	jng	.vFine
	mov	ebx,	255
.vFine:
	mov	word	[screenLeftTop.y],	bx
.fine4:
	cmp	r15,	0
	jne	.redraw
	ret
.redraw:
	lea	rcx,	[r11 + 1]
	mov	r14,	rdi
.lineLoop:
	dec	ecx
	jz	.lineLoopDone
	lea	r13,	[r14 + 1]
.innerLineLoop:
	dec	r13
	jz	.lineLoop
	lea	rax,	[r13 - 1]
	add	ax,	word	[screenLeftTop.x]
	lea	rbx,	[rcx - 1]
	add	bx,	word	[screenLeftTop.y]
	push	rcx
	call	drawTile
	pop	rcx
	jmp	.innerLineLoop
.lineLoopDone:
	ret

;; rax - x
;; rbx - y
drawTile:;TODO ensure tile in window
	push	rax
	push	rbx
	xchg	rax,	rbx
	push	rbx
	mov	rbx,	256
	mul	rbx
	pop	rbx
	add	rax,	rbx
	pop	rbx
	movzx	r11,	byte	[currentLevel]
	mov	r11,	qword	[levels + r11]
	cmp	word	[r11 + 2 * rax],	1
	jb	.wall
	je	.floor
	cmp	word	[r11 + 2 * rax],	2
	je	.door
	cmp	word	[r11 + 2 * rax],	3
	je	.entity
	push	rax
	movzx	eax,	word	[r11 + 2 * rax]
	mov	rdx,	dbgMsg
	call	DWToStr
	mov	rdi,	rdx
	mov	rsi,	rax
	movzx	edx,	word	[screenDimensions.y]
	mov	eax,	1
call	printToPos
	pop	rax
.wall:
	mov	rdi,	charTable.wall
	jmp	.tileDetermined
.floor:
	mov	rdi,	charTable.floor
	jmp	.tileDetermined
.door:
	mov	rdi,	charTable.door
	jmp	.tileDetermined
.entity:
	mov	rdi,	charTable.player	;TODO fix
.tileDetermined:
	pop	rax
	push	rax
	push	rdi
	call	getTileColor
	mov	rdx,	colorMsg.colStart
	call	DWToStr
	mov	[colorMsg.colStart + rax],	byte	'm'
	add	rax,	8
	mov	rdi,	STDOUT
	mov	rdx,	rax
	mov	rsi,	colorMsg
	mov	rax,	SYS_WRITE
	syscall
	pop	rdi
	pop	rax
	sub	ax,	word	[screenLeftTop.x]
	inc	rax	; printToPos is one-indexed
	sub	bx,	word	[screenLeftTop.y]
	lea	rdx,	[rbx + 1]	; one-indexed again
	mov	rsi,	1
	call	printToPos
	ret

;; rax - x
;; rbx - y
;; rax - ret tilecolor (ANSI 8-bit index)
getTileColor:
	mov	rax,	8 ;TODO logic
	ret

section .data

player:
.x:	dw	5
.y:	dw	5

screenLeftTop:
.x:	dw	0
.y:	dw	0

charTable:
.space:	db	' '
.player:	db	'@'
.wall:	db	'#'
.floor:	db	'.'
.door:	db	'D'

currentLevel:	db	0

level0fname:	db	'data/level_0.dat.bac', 0

colorMsg:	db	`\e[38;5;`
.colStart:	db	0,0,0,0,0,0,0,'m'
.msgEnd:

predefEntities:
	dw 1,0,0,0 ;player

section	.bss

;; Pointers to the data structure of each level
;; Each level is 256x256 words
;; 0 is wall
;; 1 is open floor
;; 2 is door
;; 3 is player entity
;; higher is entity index
levels:	resq	LEVEL_AMOUNT

;; Data format of each entity:
;; 0-1	- Entity kind (determines color, symbol etc.)
;; 2-3	- index of next entity on same tile, or 0
;; 4-7	- entity kind specific data (health, stats etc.)
entities:	resq	65536

renderDimensions:
.x:	resw	1
.y:	resw	1

dbgMsg:	resb	10
