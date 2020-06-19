global processKey:function

%include "inc/symbols.asm"

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

hidePlayer:
	movzx	eax,	word	[player.x]
	movzx	edx,	word	[player.y]
	mov	rdi,	charTable.space
	mov	rsi,	1
	call	printToPos
	ret

drawPlayer:
	movzx	eax,	word	[player.x]
	movzx	edx,	word	[player.y]
	mov	rdi,	charTable.player
	mov	rsi,	1
	call	printToPos
	ret

moveUp:
	call	hidePlayer
	dec	word	[player.y]
	jnz	.notAtTop
	inc	word	[player.y]
.notAtTop:
	call	drawPlayer
	ret

moveLeft:
	call	hidePlayer
	dec	word	[player.x]
	jnz	.notLeft
	inc	word	[player.x]
.notLeft:
	call	drawPlayer
	ret

moveDown:
	call	hidePlayer
	inc	word	[player.y]
	mov	ax,	word	[screenDimensions.y]
	cmp	word	[player.y],	ax
	jbe	.notDown
	dec	word	[player.y]
.notDown:
	call	drawPlayer
	ret

moveRight:
	call	hidePlayer
	inc	word	[player.x]
	mov	dx,	word	[screenDimensions.x]
	cmp	word	[player.x],	dx
	jbe	.notRight
	dec	word	[player.x]
.notRight:
	call	drawPlayer
	ret	

section .data

player:
.x:	dw	5
.y:	dw	5

charTable:
.space:	db	' '
.player:	db	'@'
