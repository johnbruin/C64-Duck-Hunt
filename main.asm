//#define DEBUG

#import "Macros/irq_macros.asm"
#import "Globals.asm"
#import "Scrolltext_code.asm"

//Labels
.label border_color         = $d020
.label background_color     = $d021
.label charmulticolor1		= $d022
.label charmulticolor2		= $d023

.pc = $0801 "Basic Program Start"
:BasicUpstart(start)			

.pc = $3000 "[CODE] Main Program"
start:		
{
	jsr $e544		// Clear screen	
	
	lda #BLACK     
	sta border_color
	sta background_color   

	lda #%00110000
    sta $d018

	lda $DD00
	and #%11111100 
	ora #%00000010 //Change VIC bank to bank1: $4000-$7fff
	sta $DD00

	jsr initTitleScreen
	jsr Scrolltext.Init

	sei
	:irq_init()	
    :irq_setup(irqTitleScreen, 0)
	cli
	
	jmp *
}

.pc =* "[CODE] irqTitleScreen"
irqTitleScreen:   		
{
	:irq_enter()
	
    lda #%000110000
    sta $d016

	lda #%00110000
    sta $d018

	lda #BLACK
	sta background_color 
	
	jsr music.play
	jsr checkCrosshairTitleScreen
	lda startGame
	beq !+
		jsr initGame
		jsr Scrolltext.Init
		lda #EndRound
		sta gameState
		:irq_next(irqGame1, 0)
	!:	
	jsr Scrolltext.Scroll
	:irq_next(irqScroller, 50+24*8)
}

irqScroller:
{
	irq_enter()
	lda #%000100000
    sta $d016
	jsr Scrolltext.Smooth
	:irq_next(irqTitleScreen, 0)
}

.pc =* "[CODE] irqGame1 Game loop"
irqGame1:   		
{
	:irq_enter()
	#if DEBUG
        dec border_color
    #endif

    lda $d016
	ora #%00011000
    sta $d016

    lda #%00100000
    sta $d018

	lda gameState
	cmp #FlyAway
	bne !+
		lda #LIGHT_RED
		sta background_color
		jmp !skip+
	!:
	lda #LIGHT_BLUE     
	sta background_color 
	!skip:

	lda #BLUE
	sta charmulticolor1

	lda #BLACK
	sta charmulticolor2

	jsr playGame
	
	jsr $c237 // play all voices!
	//jsr music.play

    #if DEBUG
        inc border_color
    #endif

	lda startGame
	bne !+		
		:irq_next(irqTitleScreen,0)
	!:		
	:irq_next(irqGame2, 50+16*8)
}

.pc =* "[CODE] irqGame2 Screen split"
irqGame2:
{
	irq_enter()
	lda #LIGHT_GREEN
	sta charmulticolor1
	irq_next(irqGame3,50+20*8)	
}

.pc =* "[CODE] irqGame3 Screen split"
irqGame3:
{
	irq_enter()
	lda #BROWN
	sta charmulticolor1
	lda #BLACK
	sta background_color
	irq_next(irqGame1,0)	
}

#import "Game_code.asm"