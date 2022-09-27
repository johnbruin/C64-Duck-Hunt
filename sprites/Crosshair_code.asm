#import "Sprites_common_code.asm"

initCrosshair:
{
    //Set sprite pointer
    lda #0
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER

    // set sprite colors
    lda #CYAN
    sta $d027

    rts
}

crosshairX: .word $0080
crosshairY: .byte 100
crosshairTrigger: .byte 0
showCrosshair:
{
    lda crosshairX
    sta spriteXPositions.lo+0

    lda crosshairX+1
    sta spriteXPositions.hi+0

    lda crosshairY
    sta spriteYPositions+0

    :sprite_set_xy_positions(0)

    lda crosshairTrigger
    bne !+
        lda #WHITE
        sta $d027
        rts
    !:

    lda #CYAN
    sta $d027
    rts
}