#importonce

#import "globals.asm"

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
        lda #CYAN
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

    rts
}

score1: .byte 0
score2: .byte 0
score3: .byte 0
addScore:
{
    sed
    lda #0    //50 points scored
    adc score1	//ones and tens
    sta score1
    lda score2	//hundreds and thousands
    adc #05
    sta score2
    lda score3	//ten-thousands and hundred-thousands
    adc #0
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
    .for(var x=0;x<10;x++)
    {
        ldx #x
        jsr printDuckHit   
    }
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