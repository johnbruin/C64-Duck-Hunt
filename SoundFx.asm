#importonce 

#import "Globals.asm"

*=* "[CODE] SoundFX"

SoundFx:
{
    GameOver:
    {
        lda #5
		ldx #5		
		jsr Music.init
    }

    Play:
    {
        jsr SoundFx_data+$237 // play all voices
        rts
    }
    
    Shot:
    {
        lda #15
        sta $d418 // set volume to 15

        lda #0    // sfx number
        ldy #0    // voice number
        jsr SoundFx_data+$4a // play sound!
        
        lda #0    // sfx number
        ldy #1    // voice number
        jsr SoundFx_data+$4a // play sound!

        lda #0    // sfx number
        ldy #2    // voice number
        jsr SoundFx_data+$4a // play sound!

        rts
    }

    Drop:
    {
        lda #4    // sfx number
        ldy #0    // voice number
        jsr SoundFx_data+$4a // play sound!

        lda #4    // sfx number
        ldy #1    // voice number
        jsr SoundFx_data+$4a // play sound!

        lda #4    // sfx number
        ldy #2    // voice number
        jsr SoundFx_data+$4a // play sound!

        rts
    }

    Fly:
    {
        lda #15
        sta $d418 // set volume to 15

        lda #1    // sfx number
        ldy #0    // voice number
        jsr SoundFx_data+$4a // play sound!

        rts
    }

    Quack:
    {
        lda #2    // sfx number
        ldy #1    // voice number
        jsr SoundFx_data+$4a // play sound!

        rts
    }

    Hit:
    {
        lda #3    // sfx number
        ldy #1    // voice number
        jsr SoundFx_data+$4a // play sound!

        rts
    }

    Smile:
    {
        lda #1
		ldx #1		
		jsr Music.init
        
        rts
    }

    Laugh:
    {
        lda #6
		ldx #6		
		jsr Music.init
        
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

    Reset:
    {
        lda #$0
        ldx #$17
        !:               
            sta $d400,x
            dex
        bpl !-

        lda #$08
        sta $d404
        sta $d40b
        sta $d412

        lda #$0
        sta $d404
        sta $d40b
        sta $d412

        rts
    }
}