//#define DEBUG

#import "Macros/irq_macros.asm"
#import "Globals.asm"

//Labels
.label border_color         = $d020
.label background_color     = $d021

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

    lda #%00100000
    sta $d018

    lda $d016
	ora #%00010000
    sta $d016

    lda #music.startSong - 0
    ldx #music.startSong - 0
	jsr music.init

	jsr initTitleScreen

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
	
	lda #BLACK
	sta background_color 
	
	jsr music.play
	jsr checkCrosshairTitleScreen
	lda startGame
	beq !+
		jsr initGame
		jsr initRound
		lda #EndRound
		sta gameState
		:irq_next(irqGame1,0)
	!:	
	:irq_next(irqTitleScreen,0)
}

.pc =* "[CODE] irqGame1 Game loop"
irqGame1:   		
{
	:irq_enter()
	#if DEBUG
        dec border_color
    #endif

    lda #%00100000
    sta $d018

	lda #LIGHT_BLUE     
	sta background_color 

	lda #BLUE
	sta $D022           // Char multi color 1

	lda #BLACK
	sta $D023           // Char multi color 2

	jsr playGame
	
	jsr $c237 // play all voices!
	//jsr music.play

    #if DEBUG
        inc border_color
    #endif
	:irq_next(irqGame2,50+16*8)
}

.pc =* "[CODE] irqGame2 Screen split"
irqGame2:
{
	irq_enter()
	lda #LIGHT_GREEN
	sta $D022           // Char multi color 1
	irq_next(irqGame3,50+20*8)	
}

.pc =* "[CODE] irqGame3 Screen split"
irqGame3:
{
	irq_enter()
	lda #BROWN
	sta $D022           // Char multi color 1

	lda #BLACK
	sta background_color

	irq_next(irqGame1,0)	
}

#import "Game_code.asm"