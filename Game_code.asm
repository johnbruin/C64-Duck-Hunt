#importonce

#import "globals.asm"
#import "Duck1_code.asm"
#import "Duck2_code.asm"
#import "Dog_code.asm"
#import "Score_code.asm"
#import "Crosshair_code.asm"

initTitleScreen:
{
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

		inx
		cpx #40
	bne !-

	lda #WHITE
	sta $d800+(15*40)+9

	jsr printHiScore

	rts
}

duckNumber:	.byte 0
roundNumber: .byte 0
gameSpeed: .byte 1
initGame:
{
	jsr resetSid
	
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
	sta roundNumber
	sta gameSpeed

	lda #1
	sta duckMoveSpeed

	rts
}

initRound:
{
	lda #0
	sta wait

	jsr initScore
	jsr init_sprites
	jsr initCrosshair
	jsr show_sprites
	jsr initDuck1
	jsr initDuck2
	rts
}

wait: .byte 0
playGame:
{
	jsr checkCrosshairGame

	lda gameState
	
	cmp #GameOver
	bne !+
		jsr showGameOverText
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
		jsr hideText

		lda #NewSet
		sta gameState
		rts
	!:

	cmp #EndRound
	bne !+
		lda wait
		bne !wait+
			inc roundNumber
			jsr showRoundText
			jsr initDog4
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
playDucks:
{
	lda slowdown
	cmp gameSpeed
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

		lda #1
		sta slowdown
	!:
	dec slowdown
	jsr areAllDucksOnTheGround
	rts
}

numberMappings:
.byte 48,49,50,51,52,53,54,55,56,57

gameText1:
.byte 0,0,0,0,0,0,0,0,0,0,0
gameText2:
.byte 0,0,0,0,0,0,0,0,0,0,0
gameText3:
.byte 0,0,0,0,0,0,0,0,0,0,0

roundText: .text "  ROUND   "
showRoundText:
{
	ldx #0 
	!:  
		lda roundText,x
		sta gameText1,x
		inx
		cpx #10
	bne !-
	
	ldx roundNumber
	lda numberMappings,x
	sta gameText3+4
	sta screenRam+(22*40)+3
	jsr showText
	rts
}

gameOverText: .text "GAME OVER "
showGameOverText:
{
	ldx #0 
	!:  
		lda gameOverText,x
		sta gameText1,x
		inx
		cpx #10
	bne !-
		
	jsr showText
	
	rts
}

perfectText1: .text "PERFECT!! "
perfectText3: .text "  10000   "
showPerfectText:
{
	ldx #0 
	!:  
		lda perfectText1,x
		sta gameText1,x
		lda perfectText3,x
		sta gameText3,x
		inx
		cpx #10
	bne !-
		
	jsr showText
	
	rts
}

showText:
{
	ldx #0 
	!:   
		lda #WHITE
		sta $d800+(4*40)+16,x
		sta $d800+(5*40)+16,x
		sta $d800+(6*40)+16,x

		lda gameText1,x
		cmp #' '
		bne !replace+
			lda #0
			jmp !print+
		!replace:
		clc
		adc #(154-'A')
		
		!print:
		sta screenRam+(4*40)+16,x		
				
		lda gameText2,x		
		sta screenRam+(5*40)+16,x

		lda gameText3,x		
		sta screenRam+(6*40)+16,x
		
		inx
		cpx #10
	bne !-
	rts
}

hideText:
{
	ldx #0 
	!: 
        lda #0
        sta gameText1,x
		sta gameText2,x
		sta gameText3,x
		sta screenRam+(4*40)+16,x
		sta screenRam+(5*40)+16,x
        sta screenRam+(6*40)+16,x
		inx
		cpx #10
	bne !-
	rts
}