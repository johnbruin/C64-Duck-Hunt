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

    //lda #music.startSong - 0
    //ldx #music.startSong - 0
	//jsr music.init

	jsr initScore
	jsr init_sprites
	jsr initCrosshair
	jsr show_sprites
	jsr initDuck1
	jsr initDuck2

	lda #Intro
	//lda #Playing
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

	jsr checkCrosshair

	jsr playGame
	
	jsr $c237 // play all voices!
	//jsr music.play

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
	
	cmp #Intro
	bne !+
		jsr moveDog4
		jsr showDog4	
		rts
	!:

	cmp #ClearWith1Duck
	bne !+
		jsr showDog1	
		jsr moveDog1
		rts
	!:

	cmp #ClearWith2Ducks
	bne !+
		jsr showDog2	
		jsr moveDog2
		rts
	!:

	cmp #FlyAway
	bne !+
		jsr showDuck1
		jsr moveDuck1
		jsr animateDuck1

		jsr showDuck2
		jsr moveDuck2
		jsr animateDuck2
		rts	
	!:

	cmp #Miss
	bne !+
		jsr showDog3	
		jsr moveDog3		
		rts
	!:

	cmp #New
	bne !+
		lda #3
		sta shots
		jsr printShots

		jsr initDuck1
		jsr initDuck2
		
		lda #Playing
		sta gameState
	!:
	
	cmp #Playing
	bne !+
		jsr showDuck1
		jsr moveDuck1
		jsr animateDuck1	

		jsr showDuck2
		jsr moveDuck2
		jsr animateDuck2

		jsr areAllDucksOnTheGround
	!:

	rts
}

#import "Crosshair_code.asm"
#import "Duck1_code.asm"
#import "Duck2_code.asm"
#import "Dog_code.asm"
#import "Score_code.asm"
#import "SoundFx_code.asm"