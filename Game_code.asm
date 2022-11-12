#importonce

#import "globals.asm"
#import "SoundFx_code.asm"
#import "Score_code.asm"
#import "Text_code.asm"
#import "Sprites_code.asm"
#import "Keyboard_code.asm"

#import "Crosshair_code.asm"
#import "Duck1_code.asm"
#import "Duck2_code.asm"
#import "Dog_code.asm"

initTitleScreen:
{
	jsr hide_sprites
	
	lda #music.startSong - 0
    ldx #music.startSong - 0
	jsr music.init

	lda $d014
	sta lpyOld

	lda #366/2
	sta crosshairX
	lda #0
	sta crosshairX+1
	lda #22+254/2
	sta crosshairY

	jsr Joystick1.Reset
	jsr Joystick2.Reset
	ldx #0 
	!: 
        lda #CYAN
        sta $d800+(1*40),x
        sta $d800+(2*40),x
		sta $d800+(3*40),x
        sta $d800+(4*40),x
		sta $d800+(5*40),x   
		
		lda #RED
		sta $d800+(7*40),x

		lda #CYAN
		sta $d800+(8*40),x
        sta $d800+(9*40),x
		sta $d800+(10*40),x
        sta $d800+(11*40),x
		sta $d800+(12*40),x 
	
	    inx
        cpx #40
    bne !-

	ldx #0 
	!:
		lda #RED
		sta $d800+(15*40),x 
		sta $d800+(17*40),x 
		
		lda #GREEN
		sta $d800+(20*40),x 

		lda #WHITE
		sta $d800+(22*40),x

		lda #PURPLE
		sta $d800+(24*40),x

		lda #0
		sta screenRamTitleScreen+(24*40),x

		inx
		cpx #40
	bne !-

	lda #WHITE
	sta $d800+(15*40)+9

	jsr printHiScore

	rts
}

duckNumber:	.byte 0
gameSpeed: .byte 0
initGame:
{
	jsr resetSid

	lda #366/2
	sta crosshairX
	lda #0
	sta crosshairX+1
	lda #254/2
	sta crosshairY

	jsr Joystick1.Reset
	jsr Joystick2.Reset

	// Char primary color
	ldx #0
	!:
		.for (var i=0; i<4; i++) {
			lda #13 	//GREEN
			sta $d800 + i*250,x
		}
		inx
	bne !-

	// Char multi color 1
	lda #BLUE
	sta $D022           

    // Char multi color 2
	lda #BLACK
	sta $D023

	lda #0
	sta duckNumber
	lda #0
	sta roundNumber

    jsr resetScore

	lda #0
	sta wait
	jsr initScore
	jsr init_sprites
	jsr initCrosshair
	jsr show_sprites
	jsr initDuck1
	jsr initDuck2

	jsr playShot

	rts
}

wait: .byte 0
playGame:
{
	lda isMouse
	bne !ismouse+
		jsr ReadKeyb
		jsr GetKey
		cmp #03 //runstop
		bne !+
			lda #0
			sta startGame
			jsr initTitleScreen
			rts	
		!:
	!ismouse:
	
	jsr checkCrosshairGame

	lda gameState
	
	cmp #GameOver
	bne !+
		lda wait
		bne !wait+
			lda #0
			sta startGame
			jsr initTitleScreen			
		!wait:
		dec wait
		rts
	!:

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
		jsr playDucks		
		rts	
	!:

	cmp #Miss
	bne !+++
	    ldx duck1Number
        lda duckHits,x
        cmp #2
        bne !+
            lda #0
            sta duckHits,x        
        !:
        jsr printDuckHit
		
		lda playWith1Duck
		beq !only1Duck+
			ldx duck2Number
			lda duckHits,x
			cmp #2
			bne !+
				lda #0
				sta duckHits,x        
			!:
			jsr printDuckHit
		!only1Duck:

		jsr showDog3	
		jsr moveDog3		
		rts
	!:

	cmp #NewRound
	bne !+
		lda #$ff
		sta duckNumber

		jsr initScore

		lda #NewSet
		sta gameState
		rts
	!:

	cmp #EndRound
	bne !+
		jsr flashHits
		lda wait
		bne !wait+
			inc roundNumber			
			ldx roundNumber
			lda numberMappings,x
			sta roundNumberText
			jsr setDifficulty
			jsr hideText
			jsr showRoundText
			jsr initDog4
			jsr initScore
			lda #Intro
			sta gameState
		!wait:
		dec wait			
		rts
	!:

	cmp #NewSet
	bne !++
		lda duckNumber
		cmp #9
		bne !+
			lda #255
			sta wait
			jsr evalHits
			rts
		!:

		lda #3
		sta shots
		jsr printShots

		lda #0
		sta secondsToFlyAway
		sta hitsThisSet

		jsr hideText

		inc duckNumber
		lda duckNumber
		sta duck1Number
		jsr initDuck1

		lda playWith1Duck
		beq !only1Duck+
			inc duckNumber
			lda duckNumber
			sta duck2Number
			jsr initDuck2
		!only1Duck:		
		
		lda #Playing
		sta gameState
		rts
	!:
	
	cmp #Playing
	bne !+
		jsr playDucks
		jsr printDuckHits
		rts
	!:

	rts
}

slowdown: .byte 1
framesToFlyAway: .byte 0
secondsToFlyAway: .byte 0
playDucks:
{
	inc framesToFlyAway
	lda framesToFlyAway
	cmp #50
	bne !+
		inc secondsToFlyAway
		lda #0
		sta framesToFlyAway
	!:

	lda secondsToFlyAway
	cmp #7
	bne !+		
		jsr showflyAwayText
		lda #FlyAway
		sta gameState
	!:

	lda slowdown
	cmp #0
	bne !+
		jsr showDuck1
		jsr moveDuck1
		jsr animateDuck1	

		lda playWith1Duck
		beq !only1Duck+
			jsr showDuck2
			jsr moveDuck2
			jsr animateDuck2
		!only1Duck:

		lda gameSpeed
		sta slowdown
	!:
	dec slowdown
	jsr areAllDucksOnTheGround
	rts
}

setDifficulty:
{
	ldx roundNumber
	dex
	lda hitsNeededRound,x
	sta hitsNeeded

	lda gameSpeedRound,x
	sta gameSpeed

	lda duckMoveSpeedRound,x
	sta duckMoveSpeed

	rts
}

hitsNeededRound:
.byte 6,6,7,7,8,8,9,9,10
gameSpeedRound:
.byte 1,1,1,1,1,1,1,1,1
duckMoveSpeedRound:
.byte 1,1,2,2,2,2,3,3,3