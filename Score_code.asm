#importonce

#import "globals.asm"
#import "Text_code.asm"

*=* "[CODE] Score code"

roundNumber: .byte 0

initScore:
{
    lda bullet
    bne !+
        lda screenRam+(22*40)+6
        sta bullet
    !:
    
    ldx #0 
	!: 
        lda #WHITE
        sta $d800+(22*40)+29,x
        sta $d800+(23*40)+29,x
        inx
        cpx #6
    bne !-

    ldx #0 
	!: 
        lda #GREEN
        sta $d800+(22*40)+12,x 
        inx
        cpx #3
    bne !-
    
    ldx #0 
	!: 
        lda #0
        sta duckHits,x
        lda #WHITE
        sta $d800+(22*40)+16,x   
        lda #BLACK
        sta $d800+(23*40)+16,x   
        inx
        cpx #10
    bne !-

    ldx #0 
	!: 
        lda #GREEN
        sta $d800+(22*40)+1,x
        lda #CYAN+8
        sta $d800+(22*40)+6,x
        lda #PURPLE
        sta $d800+(23*40)+6,x
        inx
        cpx #3
    bne !-

	lda #3
	sta shots
	jsr printShots

    jsr printScore
    jsr printHitsNeeded

    rts
}

resetScore:
{
    lda #0
    sta score1
    sta score2
    sta score3
    jsr printScore
    rts
}

score1: .byte 0
score2: .byte 0
score3: .byte 0
hiScore1: .byte 0
hiScore2: .byte 0
hiScore3: .byte $01
hitScore: .byte $05
scoreSprites:
.byte 53,53,54,55,56,57,58,58,58
hitScoreRound:
.byte $05,$05,$08,$10,$20,$24,$30,$30,$30
addScore:
{
    ldx roundNumber
    dex
    lda hitScoreRound,x
    sta hitScore
    
    sed
    lda #0 
    clc
    adc score1	//ones and tens
    sta score1
    lda score2	//hundreds and thousands
    adc hitScore
    sta score2
    lda score3	//ten-thousands and hundred-thousands
    adc #0
    sta score3
    cld
    rts
}

addPerfectScore:
{
    sed
    lda #0    
    clc
    adc score1	//ones and tens
    sta score1
    lda score2	//hundreds and thousands
    adc #0
    sta score2
    lda score3	//ten-thousands and hundred-thousands
    adc #01
    sta score3
    cld
    rts
}

addFinishedScore:
{
    sed
    lda #0    
    clc
    adc score1	//ones and tens
    sta score1
    lda score2	//hundreds and thousands
    adc #0
    sta score2
    lda score3	//ten-thousands and hundred-thousands
    adc #10
    sta score3
    cld
    rts
}

printScore:
{
    lda score3
    and #$f0	                //hundred-thousands
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+0	//print on screen
    
    lda score3
    and #$0f		            //ten-thousands
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+1	//print on next screen position

    lda score2
    and #$f0	                //thousands
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+2	//print on screen
    
    lda score2
    and #$0f		            //hundreds
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+3	//print on next screen position

    lda score1
    and #$f0	                //tens
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+4	//print on screen

    lda score1
    and #$0f		            //ones
    ora #$30		            // -->ascii
    sta screenRam+(22*40)+29+5	//print on next screen position

    rts
}

printHiScore:
{
    lda hiScore3
    and #$f0	                //hundred-thousands
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+0	//print on screen
    
    lda hiScore3
    and #$0f		            //ten-thousands
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+1	//print on next screen position

    lda hiScore2
    and #$f0	                //thousands
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+2	//print on screen
    
    lda hiScore2
    and #$0f		            //hundreds
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+3	//print on next screen position

    lda hiScore1
    and #$f0	                //tens
    lsr
    lsr
    lsr
    lsr
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+4	//print on screen

    lda hiScore1
    and #$0f		            //ones
    ora #$30		            // -->ascii
    sta screenRamTitleScreen+(20*40)+22+5	//print on next screen position

    rts
}

checkHiScore:
{
    lda score3
    cmp hiScore3
    bcc !lower+
    bne !higher+

    !equal:
        lda score2
        cmp hiScore2
        bcc !lower+
        bne !higher+

        lda score1
        cmp hiScore1
        bcc !lower+
        bne !higher+
        rts

    !higher:
        jmp copyHiScore

    !lower:
        rts

    copyHiScore:
        lda score1
        sta hiScore1
        lda score2
        sta hiScore2
        lda score3
        sta hiScore3

    rts
}

shots: .byte 3
bullet: .byte 0
printShots:
{
	ldx #3
	lda #0
	!:
  		sta screenRam+(22*40)+5,x
		dex
	bne !-		
    
	ldx shots
	bne !+
		rts
	!:
	lda bullet
	!:
       	sta screenRam+(22*40)+5,x
		dex
	bne !-
    rts
}

duckHits:
.fill 10, 0
printDuckHits:
{
    ldx #0 
	!:         
        jsr printDuckHit  
        inx 
        cpx #10
    bne !-
    
    rts
}

printDuckHit:
{    
    lda duckHits,x        
    cmp #0
    bne !+
        lda #WHITE
        sta $d800+(22*40)+16,x
        rts
    !:
    cmp #1
    bne !+
        lda #RED
        sta $d800+(22*40)+16,x
        rts
    !:
    cmp #2
    bne !+
        lda #BLACK
        sta $d800+(22*40)+16,x
        rts
    !:                
       
    rts
}

hitsNeeded: .byte 5
printHitsNeeded:
{
    ldx #0 
	!:         
        lda #CYAN
        sta $d800+(23*40)+16,x  
        inx 
        cpx hitsNeeded
    bne !-
    
    rts
}

flashHitsFlag: .byte 0
flashHitsAnimation: .byte 5
flashHits:
{
    lda flashHitsAnimation
    beq !+
        dec flashHitsAnimation
        rts
    !:

    lda #5
    sta flashHitsAnimation

    lda flashHitsFlag
    bne !clear+
        jsr clearHits
        lda #1
        sta flashHitsFlag
        rts
    !clear:

    jsr markHits

    lda #0
    sta flashHitsFlag
    
    rts
}

clearHits:
{
    ldx #0 
	!:         
        lda #WHITE
        sta $d800+(22*40)+16,x  
        inx 
        cpx #10
    bne !-
    rts
}

markHits:
{
    ldx #0
    ldy #0 
	!:  
        lda duckHits,y
        beq !isHit+            
            lda #RED
            sta $d800+(22*40)+16,x
            inx 
        !isHit:
        iny 
        cpy #10
    bne !-
    rts
}

evalHits:
{   
    jsr clearHits
    jsr markHits    
    cpx hitsNeeded
    bcs !higher+
    bne !lower+
    !lower: 
        jsr checkHiScore
        jsr showGameOverText
        lda #GameOver
        sta gameState
        rts
    !higher:
        cpx #10
        bne !+
            jsr addPerfectScore
            jsr printScore
            jsr showPerfectText
            jmp !endRound+
        !:
        jsr showGoodText
        !endRound:
        
        lda roundNumber
        cmp #9
		bne !+
			jsr addFinishedScore
            jsr printScore
            jsr checkHiScore
            jsr showFinishedText
            lda #GameOver
            sta gameState
            rts
		!:
        lda #EndRound
        sta gameState
    rts
}