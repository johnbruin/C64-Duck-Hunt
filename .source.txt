.var music = LoadSid("music/Hiraeth_part_1_mockup.sid")

#import "Macros/irq_macros.asm"

//multiplies fac1 and fac2 and put results in x (low-byte) and a (hi-byte)  
.var FAC1 = $58
.var FAC2 = $59

.pc = $0801 "Basic Program Start"
:BasicUpstart(start)			

.pc = $0810 "[CODE] Main Program"
start:		
{
	jsr $e544		// Clear screen	
	
	lda #BLACK     
	sta $d020  
	lda #BLUE     
	sta $d021    

    lda $DD00
	and #%11111100 
	ora #%00000011	//Change VIC bank to bank0: $0000-$3fff
	sta $DD00

    lda #music.startSong - 1
    ldx #music.startSong - 1
	jsr music.init

	jsr init_sprites
	jsr initCrosshair
	jsr initDuck1
	jsr show_sprites

	sei
	:irq_init()	
    :irq_setup(irq1, 50)
	cli
	
	jmp *    
}

.pc =$6000 "[CODE] Irq1"
irq1:   		
{
	:irq_enter()

	lda $d41a
	sta crosshairTrigger

	lda $d013		//LPX
	sta FAC1		//multiply LPX by 2
	lda #2
	sta FAC2
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

	jsr showCrosshair
	lda crosshairTrigger
    bne !+
        jsr isHit
    !:
	
	jsr showDuck1
	
	jsr music.play

	:irq_next(irq1,50)
}

crosshairXLowBoundary: .word 0
crosshairXHighBoundary: .word 0
crosshairYLowBoundary: .byte 0
crosshairYHighBoundary: .byte 0
isHit:
{
	sec
	lda crosshairY
	sbc #30
	sta crosshairYLowBoundary

	sec
	lda crosshairY
	sbc #0
	sta crosshairYHighBoundary
	
	sec
	lda crosshairX
	sbc #28
	sta crosshairXLowBoundary
	lda crosshairX+1
	sbc #0
	sta crosshairXLowBoundary+1

	clc
	lda crosshairX
	adc #16
	sta crosshairXHighBoundary
	lda crosshairX+1
	adc #0
	sta crosshairXHighBoundary+1

	//duck1Y < crosshairYLowBoundary?
	lda duck1Y
	cmp crosshairYLowBoundary
	bcc !end+

	//duck1Y >= crosshairYHighBoundary?
	lda duck1Y
	cmp crosshairYHighBoundary
	bcs !end+
	
	//duck1X < crosshairXLowBoundary?
	lda duck1X+1
	cmp crosshairXLowBoundary+1
	bcc !end+
	lda duck1X
	cmp crosshairXLowBoundary
	bcc !end+

	//duck1X >= crosshairXHighBoundary?
	lda duck1X+1
	cmp crosshairXHighBoundary+1
	bne !end+
	lda duck1X
	cmp crosshairXHighBoundary
	bcs !end+

	lda #4
	sta duck1Sprite
	lda #4+6
	sta duck1SpriteOverlay
	rts

	!end:
	lda #1
	sta duck1Sprite
	lda #1+6
	sta duck1SpriteOverlay

	rts
}

//multiplies FAC1 and FAC2 and put results in x (low-byte) and a (hi-byte)  
// A*256 + X = FAC1 * FAC2
multiply:
{
		lda #$00
		ldx #$08
		clc

	m0:
		bcc m1
		clc
		adc FAC2
	m1:    
		ror
		ror FAC1
		dex
		bpl m0
		ldx FAC1
		rts
}

#import "sprites/Sprites_common_code.asm"
#import "sprites/Crosshair_code.asm"
#import "sprites/Duck_code.asm"

*=music.location "[MUSIC] Hiraeth by Jack-Paw-Judi"
.fill music.size, music.getData(i)