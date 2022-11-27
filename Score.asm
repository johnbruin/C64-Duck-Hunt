#importonce

#import "Globals.asm"
#import "Text.asm"
#import "Game.asm"

*=$8100 "[CODE] Score code"

Score:
{
    ScoreSprites:
    .byte 53,54,55,56,57,58
    
    HitScoreRound:
    .byte 0,1,1,2,2,3,3,4,4
    
    _hitScoreRoundValue:
    .byte $05,$08,$10,$20,$24,$30

    _score1: .byte 0
    _score2: .byte 0
    _score3: .byte 0
    
    _hiScore1: .byte 0
    _hiScore2: .byte 0
    _hiScore3: .byte $01
    _hitScore: .byte $05

    _bullet: .byte 0

    Init:
    {
        lda _bullet
        bne !+
            lda ScreenRam+(22*40)+6
            sta _bullet
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
            sta Round.Hits,x
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
        sta Set.Shots
        jsr Score.PrintShots

        jsr PrintScore
        jsr PrintHitsNeeded

        rts
    }

    Reset:
    {
        lda #0
        sta _score1
        sta _score2
        sta _score3
        jsr PrintScore
        rts
    }

    AddScore:
    {
        ldx Round.Number
        dex
        ldy HitScoreRound,x
        lda Set.Hits
        cmp #2
        bne !+
            iny
        !:
        lda _hitScoreRoundValue,y
        sta _hitScore
        
        sed
        lda #0 
        clc
        adc _score1	//ones and tens
        sta _score1
        lda _score2	//hundreds and thousands
        adc _hitScore
        sta _score2
        lda _score3	//ten-thousands and hundred-thousands
        adc #0
        sta _score3
        cld
        rts
    }

    AddPerfectScore:
    {
        sed
        lda #0    
        clc
        adc _score1	//ones and tens
        sta _score1
        lda _score2	//hundreds and thousands
        adc #0
        sta _score2
        lda _score3	//ten-thousands and hundred-thousands
        adc #01
        sta _score3
        cld
        rts
    }

    AddFinishedScore:
    {
        sed
        lda #0    
        clc
        adc _score1	//ones and tens
        sta _score1
        lda _score2	//hundreds and thousands
        adc #0
        sta _score2
        lda _score3	//ten-thousands and hundred-thousands
        adc #10
        sta _score3
        cld
        rts
    }

    PrintScore:
    {
        lda _score3
        and #$f0	                //hundred-thousands
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+0	//print on screen
        
        lda _score3
        and #$0f		            //ten-thousands
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+1	//print on next screen position

        lda _score2
        and #$f0	                //thousands
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+2	//print on screen
        
        lda _score2
        and #$0f		            //hundreds
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+3	//print on next screen position

        lda _score1
        and #$f0	                //tens
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+4	//print on screen

        lda _score1
        and #$0f		            //ones
        ora #$30		            // -->ascii
        sta ScreenRam+(22*40)+29+5	//print on next screen position

        rts
    }

    PrintHiScore:
    {
        lda _hiScore3
        and #$f0	                //hundred-thousands
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+0	//print on screen
        
        lda _hiScore3
        and #$0f		            //ten-thousands
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+1	//print on next screen position

        lda _hiScore2
        and #$f0	                //thousands
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+2	//print on screen
        
        lda _hiScore2
        and #$0f		            //hundreds
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+3	//print on next screen position

        lda _hiScore1
        and #$f0	                //tens
        lsr
        lsr
        lsr
        lsr
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+4	//print on screen

        lda _hiScore1
        and #$0f		            //ones
        ora #$30		            // -->ascii
        sta ScreenRamTitleScreen+(20*40)+22+5	//print on next screen position

        rts
    }

    CheckHiScore:
    {
        lda _score3
        cmp _hiScore3
        bcc !lower+
        bne !higher+

        !equal:
            lda _score2
            cmp _hiScore2
            bcc !lower+
            bne !higher+

            lda _score1
            cmp _hiScore1
            bcc !lower+
            bne !higher+
            rts

        !higher:
            jmp copyHiScore

        !lower:
            rts

        copyHiScore:
            lda _score1
            sta _hiScore1
            lda _score2
            sta _hiScore2
            lda _score3
            sta _hiScore3

        rts
    }

    PrintShots:
    {
        ldx #3
        lda #0
        !:
            sta ScreenRam+(22*40)+5,x
            dex
        bne !-		
        
        ldx Set.Shots
        bne !+
            rts
        !:
        lda _bullet
        !:
            sta ScreenRam+(22*40)+5,x
            dex
        bne !-
        rts
    }

    PrintDuckHits:
    {
        ldx #0 
        !:         
            jsr Score.PrintDuckHit  
            inx 
            cpx #10
        bne !-
        
        rts
    }

    PrintDuckHit:
    {    
        lda Round.Hits,x        
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

    PrintHitsNeeded:
    {
        ldx #0 
        !:         
            lda #CYAN
            sta $d800+(23*40)+16,x  
            inx 
            cpx Round.HitsNeeded
        bne !-
        
        rts
    }

    _flashHitsFlag: .byte 0
    _flashHitsAnimation: .byte 5
    FlashHits:
    {
        lda _flashHitsAnimation
        beq !+
            dec _flashHitsAnimation
            rts
        !:

        lda #5
        sta _flashHitsAnimation

        lda _flashHitsFlag
        bne !clear+
            jsr clearHits
            lda #1
            sta _flashHitsFlag
            rts
        !clear:

        jsr markHits

        lda #0
        sta _flashHitsFlag
        
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
            lda Round.Hits,y
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

    EvalHits:
    {   
        jsr clearHits
        jsr markHits    
        cpx Round.HitsNeeded
        bcs !higher+
        bne !lower+
        !lower: 
            jsr Score.CheckHiScore
            jsr Text.GameOver
            jsr SoundFx.GameOver
            lda #140
            sta Game._wait
            lda #GameOverPause
            sta Game.State            
            rts
        !higher:
            lda #200
            sta Game._wait

            cpx #10
            bne !+
                lda #1
                sta Round.IsPerfect
            !:

        	lda #4
			ldx #4		
			jsr Music.init

            lda #EndRound
            sta Game.State
        rts
    }
}