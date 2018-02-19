define posL $00
define posH $01
define prevL $02
define prevH $03
define argA $10
define argB $11
define sysRandom $fe
lda sysRandom
lsr A; aligning pos horizontally
asl A
sta posL
sta argA
lda #$20
sta argB
jsr div
sta argA
lda #$04
sta argB
jsr mod
beq high_byte
cmp #$02
beq high_byte
lda posL
sec
sbc #$20
sta posL
high_byte:
lda sysRandom
cmp #$80 ; code for generating a random starting position
bcc lt ; jump if sysrandom was less than $80
cmp #$c0
bcc gtlt ; jump if sysrandom was less than $c0
lda #$05
sta posH
jmp loop
gtlt:
lda #$04
sta posH
jmp loop
lt:
cmp #$40
bcc ltlt ; jump if sysrandom was less than $40
lda #$03
sta posH
jmp loop
ltlt:
lda #$02
sta posH
jmp loop
loop:
	lda posL
	sta prevL
	lda posH
	sta prevH
	jsr movRand
	jsr checkCollision
	jsr selfCollision
	ldy #0 ;draw to the screen{
	lda #$01
	sta ($00),y ;draw to the screen}
	jmp loop
mod:
	lda argA
	sec
modulo:
	sbc argB
	bcs modulo
	adc argB
	rts
div:
	lda argA
	ldx #$00
	sec
divide:
	inx
	sbc argB
	bcs divide
	txa
	rts
movRand:
	lda sysRandom
	cmp #$80
	bcc rlt
	cmp #$c0
	bcc down
	jmp left
rlt:
	cmp #$40
	bcc up
	jmp right
up:
	sec
	lda posL
	sbc #$40
	sta posL
	lda posH
	sbc #$00
	sta posH
	rts
right:
	clc
	lda posL
	adc #$02
	sta posL
	lda posH
	adc #$00
	sta posH
	rts
down:
	clc
	lda posL
	adc #$40
	sta posL
	lda posH
	adc #$00
	sta posH
	rts
left:
	sec
	lda posL
	sbc #$02
	sta posL
	lda posH
	sbc #$00
	sta posH
	rts
checkCollision:
	lda posH
	cmp #$01
	beq reset
	cmp #$06
	beq reset
	lda posL
	sta argA
	lda #$20
	sta argB
	jsr mod
	sta $20
	lda prevL
	sta argA
	jsr mod
	sec
	sbc $20
	cmp #$1e
	beq reset
	cmp #$e2
	beq reset
	rts
reset:
	lda prevL
	sta posL
	lda prevH
	sta posH
	rts
selfCollision:
	ldy #$00
	lda (posL),y
	bne reset
	rts
