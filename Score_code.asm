#import "globals.asm"

initScore:
{
    .for(var x=0;x<6;x++)
    {
        lda #WHITE+8
        sta $d800+(22*40)+29+x
        sta $d800+(23*40)+29+x
    }

    .for(var x=0;x<10;x++)
    {
        lda #WHITE+8
        sta $d800+(22*40)+16+x   
        lda #PURPLE+8
        sta $d800+(23*40)+16+x   
    }

    .for(var x=0;x<4;x++)
    {
        lda #WHITE+8
        sta $d800+(22*40)+6+x        
    }

    .for(var x=0;x<4;x++)
    {
        lda #CYAN+8
        sta $d800+(22*40)+6+x
        lda #PURPLE+8
        sta $d800+(23*40)+6+x
    }

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