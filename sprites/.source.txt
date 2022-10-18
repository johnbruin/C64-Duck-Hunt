#import "Sprites_common_code.asm"

*=* "[CODE] Crosshair code"

initCrosshair:
{
    // Make sure no sprites are x- or y-expanded.
    lda #%11111110 
    sta $d017
    sta $d01d

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
showCrosshairX: .word $0080
showCrosshairY: .byte 100
isShotFired: .byte 0
showCrosshair:
{  
    jsr initCrosshair 
    :sprite_enable(0)

    lda showCrosshairX
    sta spriteXPositions.lo+0

    lda showCrosshairX+1
    sta spriteXPositions.hi+0

    lda showCrosshairY
    sta spriteYPositions+0

    :sprite_set_xy_positions(0)

    // lda crosshairTrigger
    // bne !+
    //     lda #WHITE
    //     sta $d027
    //     rts
    // !:

    lda #WHITE
    sta $d027

    rts
}