//#define DEBUG

.var main = LoadBinary("Main.zip",BF_C64FILE)
.var Music = LoadSid("Music/Duck_Hunt_8580.sid")
.var Title = LoadBinary("Pictures/title.kla", BF_KOALA)

.pc = $8000 "[BIN] Crunched Main"   
	mainProg: 
    .fill main.getSize(), main.get(i)

Main:
{
	.label border_color         = $d020
	.label background_color     = $d021

	.pc = $0801 "[CODE] Basic Program Start"
	:BasicUpstart(start)			

	#import "Macros/irq_macros.asm"
	#import "Joystick.asm"
	#import "Mouse.asm"
	#import "Relocator.asm"

    .pc = $0b00 "[CODE] Main Program"
	_stopIntro:      .byte 0
	start:		
	{
		jsr $e544		// Clear screen	
		
		jsr Joystick1.Reset

		lda #LIGHT_BLUE     
		sta border_color
        lda #BLACK
		sta background_color   

		lda #3
		ldx #3		
		jsr Music.init

        lda #$3b
        sta $d011

        lda #$d8
        sta $d016

        lda #%111000
        sta $d018

		lda $DD00
		and #%11111100 
		ora #%00000010 //Change VIC bank to bank1: $4000-$7fff
		sta $DD00

	    ldx #0
        !:	
            .for (var i=0; i<4; i++) {
                lda colorRam + i*250,x
                sta $d800 + i*250,x
            }
            inx
	    bne !-

		sei
		:irq_init()	
		:irq_setup(irqLoading, 0)
		cli

        !loop:
			:waste_cycles(20)
            inc border_color			
			lda _stopIntro
        	beq !+  
			    lda #BLACK
        		sta border_color
        		sta background_color

				sei
				lda #$36
				sta $01        
				jmp relocator
			!:
			:waste_cycles(63 - 4 - 4 - 3)
			
			lda _isMouse
			bne !ismouse+
				jmp !notismouse+
			!ismouse:
				:waste_cycles(64*7)			
				jmp !loop-
			!notismouse:
				:waste_cycles(66*7)			
		jmp !loop-
	}

	.pc =* "[CODE] irqLoading"
	irqLoading:   		
	{
		:irq_enter()		
		jsr disable_restore_key
		jsr Music.play

		jsr getMouseInput
		lda _isMouse
		bne !ismouse+
			jsr getJoystick1Input
			cpy #$ff
			bne !+
				jsr getLightGunInput
			!:
		!ismouse:
				
		lda _stopIntro
        beq !+ 
			    lda #$ff
    			sta $d019 
    			:irq_exit()
		!:
		:irq_next(irqLoading, 0)
	}

	_isMouse: .byte 0
	getMouseInput:
	{
		lda $d41a		
		bne !+
			rts
		!:

		lda Mouse.potx
		cmp #$ff
		bne !+
			lda Mouse.poty
			cmp #$ff
			bne !+
				lda #0
				sta _isMouse
				rts
			!:		
		!:

		lda #1
		sta _isMouse

		jsr Mouse.cbm1351_poll 

		jsr getJoystick1Input

		rts
	}

	getLightGunInput:
	{
		lda $d41a
		cmp #$ff
		beq !+
			lda #1		
			sta _stopIntro
		!:
		rts
	}

	getJoystick1Input:
	{
		jsr Joystick1.Poll
		ldx #Joystick1.FIRE
		jsr Joystick1.Held
		bne !+
			lda #1
			sta _stopIntro
			ldy #1
		!:
		rts
	}
}

*=$4c00	"[DATA] ScreenRam"; 			.fill Title.getScreenRamSize(), Title.getScreenRam(i)
*=$5c00	"[DATA] ColorRam"; colorRam: 	.fill Title.getColorRamSize(), Title.getColorRam(i)
*=$6000	"[DATA] Bitmap";				.fill Title.getBitmapSize(), Title.getBitmap(i)

*=Music.location "[MUSIC] Duckhunt by Jack-Paw-Judi"
.fill Music.size, Music.getData(i)