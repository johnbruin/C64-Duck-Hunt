//#define DEBUG

#import "Macros/irq_macros.asm"
#import "globals.asm"

//Labels
.label border_color         = $d020
.label background_color     = $d021

//multiplies fac1 and fac2 and put results in x (low-byte) and a (hi-byte)  
.var fac1 = $58
.var fac2 = $59

.pc = $0801 "Basic Program Start"
:BasicUpstart(start)			

.pc = $8000 "[CODE] Main Program"
start:		
{
	jsr $e544		// Clear screen	
	
	lda #BLACK     
	sta border_color
	lda #LIGHT_BLUE     
	sta background_color   

	lda $DD00
	and #%11111100 
	ora #%00000010 //Change VIC bank to bank1: $4000-$7fff
	sta $DD00

	ldx #0
	!:
		.for (var i=0; i<4; i++) {
			lda #13 	//GREEN
			sta $d800 + i*250,x
		}
		inx
	bne !-

    lda #%00110000
    sta $d018

    lda $d016
	ora #%00010000
    sta $d016

	lda #BLUE
	sta $D022           // Char multi color 1

	lda #BLACK
	sta $D023           // Char multi color 2

    lda #music.startSong - 0
    ldx #music.startSong - 0
	jsr music.init

	jsr initScore
	jsr init_sprites
	jsr initCrosshair
	jsr initDuck1
	jsr show_sprites

	lda #intro
	sta gameState

	sei
	:irq_init()	
    :irq_setup(irq1, 0)
	cli
	
	jmp *    
}

.pc =* "[CODE] Irq1 Main loop"
irq1:   		
{
	:irq_enter()
	#if DEBUG
        dec border_color
    #endif

	lda #LIGHT_BLUE     
	sta background_color 

	lda #BLUE
	sta $D022           // Char multi color 1

	lda #BLACK
	sta $D023           // Char multi color 2

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
	bne !+++
		lda crosshairTrigger
		bne !++
			lda #10
			sta isShotFired
			lda duck1IsShot
			bne !+
				jsr isHitDuck1
			!:
		!:
		jmp !skip+
	!:
	dec isShotFired
	!skip:
	
	jsr playGame
	
	jsr music.play

    #if DEBUG
        inc border_color
    #endif
	:irq_next(irq2,50+16*8)
}

.pc =* "[CODE] Irq2 Screen split"
irq2:
{
	irq_enter()
	lda #LIGHT_GREEN
	sta $D022           // Char multi color 1
	irq_next(irq3,50+20*8)	
}

.pc =* "[CODE] Irq3 Screen split"
irq3:
{
	irq_enter()
	lda #BROWN
	sta $D022           // Char multi color 1

	lda #BLACK
	sta background_color

	irq_next(irq1,0)	
}

playGame:
{
	lda gameState
	
	cmp #intro
	bne !+
		jsr moveDog4
		jsr showDog4	
		rts
	!:

	cmp #roundClearWith1Duck
	bne !+
		jsr showDog1	
		jsr moveDog1		
		rts
	!:

	cmp #roundLost
	bne !+
		jsr showDog3	
		jsr moveDog3		
		rts
	!:
	
	jsr showDuck1
	jsr animateDuck1	
	
	rts
}

crosshairXLowBoundary: .word 0
crosshairXHighBoundary: .word 0
crosshairYLowBoundary: .byte 0
crosshairYHighBoundary: .byte 0
isHitDuck1:
{
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

	// We have a hit!
	lda #4
	sta duck1Sprite
	lda #4+overlay_distance
	sta duck1SpriteOverlay
	lda #0
    sta duck1AnimSpeed
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

#import "sprites/Crosshair_code.asm"
#import "sprites/Duck_code.asm"
#import "sprites/Dog_code.asm"
#import "Score_code.asm"