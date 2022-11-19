//#define DEBUG

#import "Macros/irq_macros.asm"
#import "Globals.asm"
#import "Game.asm"
#import "Scrolltext.asm"

Main:
{
	.label border_color         = $d020
	.label background_color     = $d021
	.label charmulticolor1		= $d022
	.label charmulticolor2		= $d023

	.pc = $0801 "[CODE] Basic Program Start"
	:BasicUpstart(start)			

	.pc = $2a00 "[CODE] Main Program"
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

		jsr Game.InitTitleScreen
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
		
		jsr disable_restore_key
		jsr Music.play
		jsr Crosshair.CheckTitleScreen
		
		lda Game.StartGame
		beq !+
			jsr Game.Init
			jsr Scrolltext.Init
			lda #StartRound
			sta Game.State
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

		lda Game.State
		cmp #FlyAway
		bne !+
			lda #LIGHT_RED
			sta background_color
			jmp !skip+
		!:
		lda #LIGHT_BLUE     
		sta background_color 
		!skip:

		lda #DARK_GREY
		sta charmulticolor1

		lda #BLACK
		sta charmulticolor2

		jsr disable_restore_key
		jsr Game.Play
		jsr SoundFx.Play

		#if DEBUG
			inc border_color
		#endif

		lda Game.StartGame
		bne !+	
			jsr Game.InitTitleScreen	
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
		irq_next(irqGame3, 50+20*8)	
	}

	.pc =* "[CODE] irqGame3 Screen split"
	irqGame3:
	{
		irq_enter()
		lda #BROWN
		sta charmulticolor1
		lda #BLACK
		sta background_color
		irq_next(irqGame1, 0)	
	}

	disable_restore_key:
	{
		lda #<nmi             //Set NMI vector
		sta $0318
		sta $fffa
		lda #>nmi
		sta $0319
		sta $fffb
		lda #$81
		sta $dd0d             //Use Timer A
		lda #$01              //Timer A count ($0001)
		sta $dd04
		lda #$00
		sta $dd05
		lda #%00011001        //Run Timer A
		sta $dd0e
		rts

		nmi:
		rti
	}
}