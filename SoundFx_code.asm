#importonce 

*=* "[CODE] SoundFX"

playShot:
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

playDrop:
{
    lda #4    // sfx number
    ldy #0    // voice number
    jsr $c04a // play sound!
    rts
}

playFly:
{
    lda #15
    sta $d418 // set volume to 15

    lda #1    // sfx number
    ldy #0    // voice number
    jsr $c04a // play sound!
    rts
}

playQuack:
{
    lda #2    // sfx number
    ldy #2    // voice number
    jsr $c04a // play sound!
    rts
}
playHit:
{
    lda #3    // sfx number
    ldy #2    // voice number
    jsr $c04a // play sound!
    rts
}

playSmile:
{
    lda #6    // sfx number
   	ldy #1    // voice number
   	jsr $c04a // play sound!
    rts
}

playLaugh:
{
    lda #5    // sfx number
    ldy #1    // voice number
    jsr $c04a // play sound!
    rts
}

playBark:
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