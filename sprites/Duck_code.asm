#import "Sprites_common_code.asm"

.var overlay_distance = 6

initDuck1:
{
    // set sprites multicolor1
    lda #WHITE
    sta $d025

    // set sprites multicolor2
    lda #ORANGE
    sta $d026

    // set sprite color sprite1
    lda #GREEN
    sta $d027+2

    // set sprite color sprite2
    lda #BLACK
    sta $d027+1

    rts
}

duck1Sprite: .byte 1
duck1SpriteOverlay: .byte 7
duck1X: .word $0080
duck1Y: .byte 100
duck1IsDead: .byte 0
duck1IsShot: .byte 0
showDuck1:
{
    lda duck1SpriteOverlay    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    lda duck1Sprite
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+2

    lda duck1X
    sta spriteXPositions.lo+1
    sta spriteXPositions.lo+2

    lda duck1X+1
    sta spriteXPositions.hi+1
    sta spriteXPositions.hi+2

    lda duck1Y
    sta spriteYPositions+1
    sta spriteYPositions+2

    :sprite_set_xy_positions(1)
    :sprite_set_xy_positions(2)

    rts
}

duck1AnimSpeed: .byte 0
animateDuck1:
{
    lda duck1AnimSpeed
    cmp #6
    bne !++
        inc duck1Sprite
        inc duck1SpriteOverlay
        lda duck1Sprite
        cmp #4
        bne !+
            lda #1
            sta duck1Sprite
            lda #7
            sta duck1SpriteOverlay
        !:
        lda #0
        sta duck1AnimSpeed
    !:
    inc duck1AnimSpeed
    rts
}