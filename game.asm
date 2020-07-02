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
	call	popEntity
	dec	word	[player.y]
	jnl	.notAtTop
	inc	word	[player.y]
.notAtTop:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	mov	edx,	3
	call	pushEntity
	call	renderLevel
	ret

moveLeft:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	popEntity
	dec	word	[player.x]
	jnl	.notLeft
	inc	word	[player.x]
.notLeft:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	mov	edx,	3
	call	pushEntity
	call	renderLevel
	ret

moveDown:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	popEntity
	inc	word	[player.y]
	cmp	word	[player.y],	255
	jbe	.notDown
	dec	word	[player.y]
.notDown:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	mov	edx,	3
	call	pushEntity
	call	renderLevel
	ret

moveRight:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	call	popEntity
	inc	word	[player.x]
	cmp	word	[player.x],	255
	jbe	.notRight
	dec	word	[player.x]
.notRight:
	movzx	rax,	word	[player.x]
	movzx	rbx,	word	[player.y]
	mov	edx,	3
	call	pushEntity
	call	renderLevel
	ret	

initWorld:
	mov	qword	[levels],	level0
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
	lea	r14,	[rbx + rdi]
	cmp	r14,	256
	jng	.hFine
	mov	ebx,	256
	sub	ebx,	edi
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
	lea	r14,	[rbx + r11]
	cmp	r14,	256
	jng	.vFine
	mov	ebx,	256
	sub	rbx,	r11
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
	call	getTileAddress
	cmp	word	[r11],	1
	jb	.wall
	je	.floor
	cmp	word	[r11],	2
	je	.door
	cmp	word	[r11],	3
	je	.entity
	jmp	.entity
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

;; ax - x
;; bx - y
;; dx - ret entityIdx
;; CLEAN
popEntity:
	call	getTileAddress
	movzx	rdx,	word	[r11]
	push	r12
	movzx	r12,	word	[entities + 8 * rdx + 2]
	mov	word	[entities + 2 + 8 * rdx],	0
	cmp	r12,	0
	jne	.floor
	mov	word	[r11],	1
	jmp	.done
.floor:
	mov	word	[r11],	r12w
.done:
	pop	r12
	ret

;; ax - x
;; bx - y
;; dx - entityIdx
;; CLEAN
pushEntity:
	call	getTileAddress
	movzx	ecx,	word	[r11]
	mov	word	[r11],	dx
	cmp	ecx,	3
	jbe	.floor
	mov	word	[entities + 2 + 8 * rdx],	cx
	jmp	.done
.floor:
	mov	word	[entities + 2 + 8 * rdx],	0
.done:
	ret	

;; ax - x
;; bx - y
;; r11 - tile address
;; CLEAN
getTileAddress:
	push	rax
	push	rbx
	xchg	rax,	rbx
	push	rbx
	mov	rbx,	256
	push	rdx	; push rdx because mul clobbers
	mul	rbx
	pop	rdx
	pop	rbx
	add	rax,	rbx
	pop	rbx
	movzx	r11,	byte	[currentLevel]
	mov	r11,	qword	[levels + r11]
	lea	r11,	[r11 + 2 * rax]
	pop	rax
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

colorMsg:	db	`\e[38;5;`
.colStart:	db	0,0,0,0,0,0,0,'m'
.msgEnd:

predefEntities:
	dw 1,0,0,0 ;player
level0:
	incbin	"data/level_0.dat.bac"

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
