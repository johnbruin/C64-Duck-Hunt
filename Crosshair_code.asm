#import "Sprites_code.asm"
#import "Score_code.asm"
#import "SoundFx_code.asm"
#import "Duck1_code.asm"
#import "Duck2_code.asm"

*=* "[CODE] Crosshair code"

//multiplies fac1 and fac2 and put results in x (low-byte) and a (hi-byte)  
.var fac1 = $58
.var fac2 = $59

shots: .byte 3
crosshairXLowBoundary: .word 0
crosshairXHighBoundary: .word 0
crosshairYLowBoundary: .byte 0
crosshairYHighBoundary: .byte 0

initCrosshair:
{
    // Make sure no sprites are x- or y-expanded.
    lda #%11111110 
    sta $d017
    sta $d01d

    //Set sprite pointer
    lda #0
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER

    // set sprite colors
    lda #CYAN
    sta $d027

    rts
}

crosshairX: .word $0080
crosshairY: .byte 100
crosshairTrigger: .byte 0
showCrosshairX: .word $0080
showCrosshairY: .byte 100
isShotFired: .byte 0
showCrosshair:
{  
    jsr initCrosshair 
    :sprite_enable(0)

    lda showCrosshairX
    sta spriteXPositions.lo+0

    lda showCrosshairX+1
    sta spriteXPositions.hi+0

    lda showCrosshairY
    sta spriteYPositions+0

    :sprite_set_xy_positions(0)

    // lda crosshairTrigger
    // bne !+
    //     lda #WHITE
    //     sta $d027
    //     rts
    // !:

    lda #WHITE
    sta $d027

    rts
}

checkCrosshair:
{
	lda $d41a
	sta crosshairTrigger

	lda $d013		//LPX
	sta fac1		//multiply LPX by 2
	lda #2
	sta fac2
	jsr multiply
	stx crosshairX	
	sta crosshairX+1

	sec				//substract 30+12 (half a sprite width)
	lda crosshairX
	sbc #30+12
	sta crosshairX
	lda crosshairX+1
	sbc #0
	sta crosshairX+1
	
	lda $d014		//LPY
	sta crosshairY

	//jsr showCrosshair

	lda isShotFired
	bne !shotwasfired+
		:sprite_disable(0)
				
		lda crosshairTrigger
		bne !trigger+
			lda #10
			sta isShotFired
			
			lda shots
			beq !+
				dec shots
				jsr playShot
			!:
			jsr printShots

			lda duck1IsShot
			bne !+
				jsr isHitDuck1
			!:

			bne !++ // a=1 when duck1 was hit
			lda duck2IsShot
				bne !+
					jsr isHitDuck2
				!:
			!:
		!trigger:
		jmp !skip+
	!shotwasfired:
	dec isShotFired
	!skip:
	rts
}

isHitDuck1:
{
	lda gameState
	cmp #Playing
	beq !+
		rts
	!:

	sec
	lda crosshairY
	sbc #11*2
	sta crosshairYLowBoundary

	clc
	lda crosshairY
	adc #11
	sta crosshairYHighBoundary
	
	sec
	lda crosshairX
	sbc #12*2
	sta crosshairXLowBoundary
	lda crosshairX+1
	sbc #0
	sta crosshairXLowBoundary+1

	clc
	lda crosshairX
	adc #12*2
	sta crosshairXHighBoundary
	lda crosshairX+1
	adc #0
	sta crosshairXHighBoundary+1

	//duck1Y < crosshairYLowBoundary?
	lda duck1Y
	cmp crosshairYLowBoundary
	bcc !nohit+

	//duck1Y >= crosshairYHighBoundary?
	lda duck1Y
	cmp crosshairYHighBoundary
	bcs !nohit+
	
	//duck1X < crosshairXLowBoundary?
	lda duck1X+1
	cmp crosshairXLowBoundary+1
	bne !+
	    lda duck1X
		cmp crosshairXLowBoundary
	!:
    bcc !nohit+ //lower

	//duck1X >= crosshairXHighBoundary?
	lda duck1X+1
	cmp crosshairXHighBoundary+1
	bne !+
	    lda duck1X
		cmp crosshairXHighBoundary
	!:
	bcc !lower+
	bne !nohit+ //higher
	!lower:
	
	!hit:
	    jsr playHit

		lda #0
		sta duck1AnimSpeed
		sta duck1SpritesAnimationCounter
		lda #1
		sta duck1IsShot
		jsr addScore
		jsr printScore
		rts

	!nohit:
		lda crosshairX
		sta showCrosshairX
		lda crosshairX+1
		sta showCrosshairX+1
		lda crosshairY
		sta showCrosshairY
		jsr showCrosshair
		lda shots
		bne !+
			lda #FlyAway
			sta gameState     	
		!:
		lda #0
		rts
}

isHitDuck2:
{
	lda gameState
	cmp #Playing
	beq !+
		rts
	!:

	sec
	lda crosshairY
	sbc #11*2
	sta crosshairYLowBoundary

	clc
	lda crosshairY
	adc #11
	sta crosshairYHighBoundary
	
	sec
	lda crosshairX
	sbc #12*2
	sta crosshairXLowBoundary
	lda crosshairX+1
	sbc #0
	sta crosshairXLowBoundary+1

	clc
	lda crosshairX
	adc #12*2
	sta crosshairXHighBoundary
	lda crosshairX+1
	adc #0
	sta crosshairXHighBoundary+1

	//duck2Y < crosshairYLowBoundary?
	lda duck2Y
	cmp crosshairYLowBoundary
	bcc !nohit+

	//duck2Y >= crosshairYHighBoundary?
	lda duck2Y
	cmp crosshairYHighBoundary
	bcs !nohit+
	
	//duck2X < crosshairXLowBoundary?
	lda duck2X+1
	cmp crosshairXLowBoundary+1
	bne !+
	    lda duck2X
		cmp crosshairXLowBoundary
	!:
    bcc !nohit+ //lower

	//duck2X >= crosshairXHighBoundary?
	lda duck2X+1
	cmp crosshairXHighBoundary+1
	bne !+
	    lda duck2X
		cmp crosshairXHighBoundary
	!:
	bcc !lower+
	bne !nohit+ //higher
	!lower:

	!hit:
		jsr playHit

		lda #0
		sta duck2AnimSpeed
		sta duck2SpritesAnimationCounter
		lda #1
		sta duck2IsShot
		jsr addScore
		jsr printScore
		rts

	!nohit:
		lda crosshairX
		sta showCrosshairX
		lda crosshairX+1
		sta showCrosshairX+1
		lda crosshairY
		sta showCrosshairY
		jsr showCrosshair
		lda shots
		bne !+
			lda #FlyAway
			sta gameState     	
		!:
		rts
}

//multiplies FAC1 and FAC2 and put results in x (low-byte) and a (hi-byte)  
// A*256 + X = FAC1 * FAC2
multiply:
{
	lda #0
	ldx #8
	clc

	m0:
	bcc m1
	clc
	adc fac2

	m1:    
	ror
	ror fac1
	dex
	bpl m0
	ldx fac1
	rts
}