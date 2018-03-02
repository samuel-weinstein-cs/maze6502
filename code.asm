define posL $00
define posH $01
define prevL $02
define prevH $03
define dir $04
define testPointerL $05
define testPointerH $06
define cpL $07
define cpH $08
define popBool $09
define argA $10
define argB $11
define mazePointerL $50
define mazePointerH $51
define sysRandom $fe
lda #$09; initialize mazepointer
sta mazePointerH
sta testPointerH
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
	ldy #$00
	lda posL
	sta (mazePointerL),y
	ldy #$01
	sta prevL
	lda posH
	sta (mazePointerL),y
	sta prevH
	jsr movRand
	jsr checkCollision
	jsr selfCollision
	lda dir
	beq testSides
	clc
	lda mazePointerL
	adc #$02
	sta mazePointerL
	lda mazePointerH
	adc #$00
	sta mazePointerH
	lda dir
	lsr;draw to the screen
	bcs u
	lsr
	bcs r
	lsr
	bcs d
	lsr
	bcs l
	jmp loop
u:
	lda posL
	clc
	adc #$20
	sta prevL
	lda posH
	adc #0
	sta prevH
	jmp draw
r:
	lda posL
	sec
	sbc #$01
	sta prevL
	jmp draw
d:
	lda posL
	sec
	sbc #$20
	sta prevL
	lda posH
	sbc #0
	sta prevH
	jmp draw
l:
	lda posL
	clc
	adc #$01
	sta prevL
draw:
	ldy #0 
	lda #$01
	sta (posL),y
	sta (prevL),y
	jmp loop
testSides:
	lda #$00
	sta popBool
	sta testPointerL
testLoop:
	sec
	lda posL
	sbc #$20
	sta cpL
	lda posH
	sbc #$00
	sta cpH
	ldy #$01
	cmp (testPointerH),y
	bne endU
	lda cpL
	ldy #$00
	cmp (testPointerL),y
	bne endU
	lda popBool
	ora #$01
	sta popBool
endU:
	clc
	lda posL
	adc #$01
	sta cpL
	lda posH
	adc #$00
	sta cpH
	ldy #$01
	cmp (testPointerH),y
	bne endR
	lda cpL
	ldy #$00
	cmp (testPointerL),y
	bne endR
	lda popBool
	ora #$02
	sta popBool
endR:
	clc
	lda posL
	adc #$20
	sta cpL
	lda posH
	adc #$00
	sta cpH
	ldy #$01
	cmp (testPointerH),y
	bne endD
	lda cpL
	ldy #$00
	cmp (testPointerL),y
	bne endD
	lda popBool
	ora #$04
	sta popBool
endD:
	sec
	lda posL
	sbc #$01
	sta cpL
	lda posH
	sbc #$00
	sta cpH
	ldy #$01
	cmp (testPointerH),y
	bne endDir
	lda cpL
	ldy #$00
	cmp (testPointerL),y
	bne endDir
	lda #$01
	lda popBool
	ora #$08
	sta popBool
endDir:
	lda popBool
	cmp #$0f
	beq pop
	inc testPointerL
	lda testPointerL
	cmp mazePointerL
	beq jumpTestSides
	bcc jumpTestSides
	jmp loop
jumpTestSides:
	jmp testLoop
pop:
	sec
	lda mazePointerL
	sbc #$02
	sta mazePointerL
	lda mazePointerH
	sbc #$00
	sta mazePointerH
	ldy #$00
	lda (mazePointerL),y
	sta posL
	ldy #$01
	lda (mazePointerL),y
	sta posH
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
	lda #$01
	sta dir
	rts
right:
	clc
	lda posL
	adc #$02
	sta posL
	lda posH
	adc #$00
	sta posH
	lda #$02
	sta dir
	rts
down:
	clc
	lda posL
	adc #$40
	sta posL
	lda posH
	adc #$00
	sta posH
	lda #$04
	sta dir
	rts
left:
	sec
	lda posL
	sbc #$02
	sta posL
	lda posH
	sbc #$00
	sta posH
	lda #$08
	sta dir
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
	lda #0
	sta dir
	rts
selfCollision:
	ldy #$00
	lda (posL),y
	bne reset
	rts
