#importonce 

*=* "[CODE] SoundFX"

SoundFx:
{
    Play:
    {
        jsr $c237 // play all voices
        rts
    }
    
    Shot:
    {
        lda #15
        sta $d418 // set volume to 15

        lda #0    // sfx number
        ldy #0    // voice number
        jsr $c04a // play sound!
        
        lda #0    // sfx number
        ldy #1    // voice number
        jsr $c04a // play sound!

        lda #0    // sfx number
        ldy #2    // voice number
        jsr $c04a // play sound!

        rts
    }

    Drop:
    {
        lda #4    // sfx number
        ldy #1    // voice number
        jsr $c04a // play sound!

        rts
    }

    Fly:
    {
        lda #15
        sta $d418 // set volume to 15

        lda #1    // sfx number
        ldy #0    // voice number
        jsr $c04a // play sound!

        rts
    }

    Quack:
    {
        lda #2    // sfx number
        ldy #1    // voice number
        jsr $c04a // play sound!

        rts
    }

    Hit:
    {
        lda #3    // sfx number
        ldy #1    // voice number
        jsr $c04a // play sound!

        rts
    }

    Smile:
    {
        lda #6    // sfx number
        ldy #2    // voice number
        jsr $c04a // play sound!
        rts
    }

    Laugh:
    {
        lda #5    // sfx number
        ldy #2    // voice number
        jsr $c04a // play sound!
        
        rts
    }

    Bark:
    {
        lda #15
        sta $d418 // set volume to 15

        lda #7    // sfx number
        ldy #0    // voice number
        jsr $c04a // play sound!
        
        lda #7    // sfx number
        ldy #1    // voice number
        jsr $c04a // play sound!

        lda #7    // sfx number
        ldy #2    // voice number
        jsr $c04a // play sound!

        rts
    }

    ResetSid:
    {
        lda #$ff

        !resetSidLoop:
        
        ldx #$17
        !:               
            sta $d400,x
            dex
        bpl !-
        tax
        bpl !+
            lda #$08
        bpl !resetSidLoop-
        !:

        !:
            bit $d011
        bpl !-

        !:
            bit $d011
        bmi !-

        eor #$08
        beq !resetSidLoop-

        lda #$0f
        sta $d418

        rts
    }
}