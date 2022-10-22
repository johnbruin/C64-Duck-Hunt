#importonce

#import "globals.asm"
#import "Duck1_code.asm"
#import "Duck2_code.asm"
#import "Dog_code.asm"
#import "Score_code.asm"
#import "Crosshair_code.asm"

initTitleScreen:
{
	lda #%00110000
    sta $d018

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

		inx
		cpx #40
	bne !-

	lda #WHITE
	sta $d800+(15*40)+9

	rts
}

duckNumber:	.byte 0
roundNumber: .byte 0
gameSpeed: .byte 1
initGame:
{
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
	jsr initScore
	jsr init_sprites
	jsr initCrosshair
	jsr show_sprites
	jsr initDuck1
	jsr initDuck2
	rts
}

playGame:
{
	jsr checkCrosshair

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
		
		ldx duck2Number
        lda duckHits,x
        cmp #2
        bne !+
            lda #0
            sta duckHits,x        
        !:
        jsr printDuckHit

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
		inc roundNumber
		jsr showRoundText
		jsr initScore
		jsr initDog4
		lda #Intro
		sta gameState
		rts
	!:

	cmp #NewSet
	bne !++
		lda duckNumber
		cmp #9
		bne !+
			lda #EndRound
			sta gameState
			rts
		!:
		lda #3
		sta shots
		jsr printShots

		inc duckNumber
		lda duckNumber
		sta duck1Number
		
		inc duckNumber
		lda duckNumber
		sta duck2Number

		jsr initDuck1
		jsr initDuck2
		
		lda #Playing
		sta gameState
		rts
	!:
	
	cmp #Playing
	bne !+
		jsr playDucks
		jsr printDuckHits
		jsr areAllDucksOnTheGround
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

		jsr showDuck2
		jsr moveDuck2
		jsr animateDuck2
		lda #1
		sta slowdown
	!:
	dec slowdown
	rts
}

numberMappings:
.byte 48,49,50,51,52,53,54,55,56,57

gameText1:
.text "  ROUND   "
gameText2:
.byte 0,0,0,0,0,0,0,0,0,0,0
gameText3:
.byte 0,0,0,0,0,0,0,0,0,0,0

showRoundText:
{
	ldx roundNumber
	lda numberMappings,x
	sta gameText3+4
	sta screenRam+(22*40)+3
	jsr showText
	rts
}

showText:
{
	ldx #0 
	!:   
		lda #WHITE
		sta $d800+(4*40)+18,x
		sta $d800+(5*40)+18,x
		sta $d800+(6*40)+18,x

		clc
		lda gameText1,x
		adc #(154-'A')
		sta screenRam+(4*40)+16,x		
		cmp #(32+154-'A') // Space
		bne !+
			lda #0
			sta screenRam+(4*40)+16,x
		!:
		lda gameText2,x		
		sta screenRam+(5*40)+16,x
		lda gameText3,x		
		sta screenRam+(6*40)+16,x
		inx
		cpx #10
	bne !--
	rts
}

hideText:
{
	ldx #0 
	!: 
        lda #0
        sta screenRam+(4*40)+16,x
		sta screenRam+(5*40)+16,x
        sta screenRam+(6*40)+16,x
		inx
		cpx #10
	bne !-
	rts
}