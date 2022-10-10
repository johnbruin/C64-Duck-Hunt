#import "Sprites_common_code.asm"

*=* "[CODE] Dog code"

isDogVisible: .byte 0
dogMoveDown: .byte 0

dog1Sprite1X: .byte 160
dog1Sprite1Y: .byte 120+50
dog1Sprite2X: .byte 160+24*2
dog1Sprite2Y: .byte 120+50
dog1Sprite3X: .byte 160
dog1Sprite3Y: .byte 120+21*2+50

showDog1:
{
    lda #%01111110  

    // x- and y-expanded.
    sta $d017
    sta $d01d

    lda #BLACK
    sta $d027+1
    sta $d027+2
    sta $d027+3

    lda #GREEN
    sta $d027+5

    lda #RED
    sta $d027+4
    sta $d027+6

    //multicolor
    lda #%01110000
    sta $d01c 

    lda #7    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+4

    lda #8
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+5

    lda #14
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+6

    lda #7+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    lda #8+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+2

    lda #14+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+3

    lda dog1Sprite1X
    sta spriteXPositions.lo+1
    sta spriteXPositions.lo+4

    lda #0
    sta spriteXPositions.hi+1
    sta spriteXPositions.hi+4

    lda dog1Sprite1Y
    sta spriteYPositions+1
    sta spriteYPositions+4

    lda dog1Sprite2X
    sta spriteXPositions.lo+2
    sta spriteXPositions.lo+5

    lda #0
    sta spriteXPositions.hi+2
    sta spriteXPositions.hi+5

    lda dog1Sprite2Y
    sta spriteYPositions+2
    sta spriteYPositions+5

    lda dog1Sprite3X
    sta spriteXPositions.lo+3
    sta spriteXPositions.lo+6

    lda #0
    sta spriteXPositions.hi+3
    sta spriteXPositions.hi+6

    lda dog1Sprite3Y
    sta spriteYPositions+3
    sta spriteYPositions+6

    :sprite_set_xy_positions(1)
    :sprite_set_xy_positions(2)
    :sprite_set_xy_positions(3)
    :sprite_set_xy_positions(4)
    :sprite_set_xy_positions(5)
    :sprite_set_xy_positions(6)

    lda dog1Sprite1Y
    cmp #120+48
    bcc !+
        :sprite_disable(1)
        :sprite_disable(4)
        :sprite_disable(2)
        :sprite_disable(5)                
        jmp !skip+
    !:  
    :sprite_enable(1)
    :sprite_enable(4)
    :sprite_enable(2)
    :sprite_enable(5)
    
    !skip:

    lda dog1Sprite3Y
    cmp #120+48+18
    bcc !+
        :sprite_disable(3)
        :sprite_disable(6)
        jmp !skip+
    !:  
    :sprite_enable(3)
    :sprite_enable(6)
    !skip:

    rts
}

moveDog1:
{
    lda dogMoveDown
    bne !moveDown+
        lda dog1Sprite1Y
        cmp #120
        bcc !+
            dec dog1Sprite1Y
            dec dog1Sprite2Y
            dec dog1Sprite3Y
            rts
        !:
        lda #1
        sta dogMoveDown 

    !moveDown:
    lda dog1Sprite1Y
    cmp #120+50
    bcs !+
        inc dog1Sprite1Y
        inc dog1Sprite2Y
        inc dog1Sprite3Y
        rts
    !:
    lda #roundPlaying
    sta gameState
    lda #0
    sta dogMoveDown 
    jsr init_sprites

    rts
}

dog2Sprite1X: .byte 160-24*2
dog2Sprite1Y: .byte 110-21*2+21*2+10
dog2Sprite2X: .byte 160-24*2+24*2
dog2Sprite2Y: .byte 110-21*2+21*2+10
dog2Sprite3X: .byte 160-24*2+24*2*2
dog2Sprite3Y: .byte 110-21*2+21*2+10
dog2Sprite4X: .byte 160-24*2+24*2
dog2Sprite4Y: .byte 110-21*2+21*2+21*2+10
showDog2:
{
    // show sprites
    lda #%11111111  
	sta $d015 

    // x- and y-expanded.
    sta $d017
    sta $d01d

    lda #BLACK
    sta $d027+0
    sta $d027+1
    sta $d027+2
    sta $d027+3

    lda #GREEN
    sta $d027+4
    sta $d027+6

    lda #RED    
    sta $d027+5
    sta $d027+7

    //multicolor
    lda #%11110000
    sta $d01c 

    lda #9    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+4

    lda #10
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+5

    lda #11
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+6

    lda #17
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+7

    lda #9+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+0

    lda #10+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    lda #11+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+2

    lda #17+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+3

    // sprite 1
    lda dog2Sprite1X
    sta spriteXPositions.lo+0
    sta spriteXPositions.lo+4

    lda #0
    sta spriteXPositions.hi+0
    sta spriteXPositions.hi+4

    lda dog2Sprite1Y
    sta spriteYPositions+0
    sta spriteYPositions+4

    // sprite 2
    lda dog2Sprite2X
    sta spriteXPositions.lo+1
    sta spriteXPositions.lo+5

    lda #0
    sta spriteXPositions.hi+1
    sta spriteXPositions.hi+5

    lda dog2Sprite2Y
    sta spriteYPositions+1
    sta spriteYPositions+5

    // sprite 3
    lda dog2Sprite3X
    sta spriteXPositions.lo+2
    sta spriteXPositions.lo+6

    lda #0
    sta spriteXPositions.hi+2
    sta spriteXPositions.hi+6
    
    lda dog2Sprite3Y
    sta spriteYPositions+2
    sta spriteYPositions+6

    //sprite 4
    lda dog2Sprite4X
    sta spriteXPositions.lo+3
    sta spriteXPositions.lo+7

    lda #0
    sta spriteXPositions.hi+3
    sta spriteXPositions.hi+7

    lda dog2Sprite4Y
    sta spriteYPositions+3
    sta spriteYPositions+7

    :sprite_set_xy_positions(0)
    :sprite_set_xy_positions(1)
    :sprite_set_xy_positions(2)
    :sprite_set_xy_positions(3)
    :sprite_set_xy_positions(4)
    :sprite_set_xy_positions(5)
    :sprite_set_xy_positions(6)
    :sprite_set_xy_positions(7)

    rts
}

dog3Sprite1X: .byte 160
dog3Sprite1Y: .byte 120+50
dog3Sprite2X: .byte 160
dog3Sprite2Y: .byte 120+50+21*2
dog3Animation: .byte 0
dog3AnimSpeed: .byte 4
showDog3:
{
    lda #%00001111  

    // sprite priority to front    
    sta $d01b

    // x- and y-expanded.
    sta $d017
    sta $d01d

    lda #BLACK
    sta $d027+0
    sta $d027+1

    //multicolor
    lda #%00001100
    sta $d01c 

    lda dog3AnimSpeed
    cmp #4
    bne !skipAnimation+
        lda #0
        sta dog3AnimSpeed

        lda dog3Animation
        bne !+
            lda #12    
            clc
            adc #(>spriteMemory<<2)	
            sta SPRITEPOINTER+2
            
            lda #12+overlay_distance
            clc
            adc #(>spriteMemory<<2)	
            sta SPRITEPOINTER+0

            lda #1
            sta dog3Animation

            jmp !skipAnimation+
        !:
    
        lda #13    
        clc
        adc #(>spriteMemory<<2)	
        sta SPRITEPOINTER+2
        
        lda #13+overlay_distance
        clc
        adc #(>spriteMemory<<2)	
        sta SPRITEPOINTER+0    

        lda #0
        sta dog3Animation
        
    !skipAnimation:
    inc dog3AnimSpeed

    lda #19
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+3

    lda #19+overlay_distance
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    // sprite 1
    lda dog3Sprite1X
    sta spriteXPositions.lo+0
    sta spriteXPositions.lo+2

    lda #0
    sta spriteXPositions.hi+0
    sta spriteXPositions.hi+2

    lda dog3Sprite1Y
    sta spriteYPositions+0
    sta spriteYPositions+2

    // sprite 2
    lda dog3Sprite2X
    sta spriteXPositions.lo+1
    sta spriteXPositions.lo+3

    lda #0
    sta spriteXPositions.hi+1
    sta spriteXPositions.hi+3

    lda dog3Sprite2Y
    sta spriteYPositions+1
    sta spriteYPositions+3

    :sprite_set_xy_positions(0)
    :sprite_set_xy_positions(1)
    :sprite_set_xy_positions(2)
    :sprite_set_xy_positions(3)

    lda dog3Sprite1Y
    cmp #120+48
    bcc !+
        :sprite_disable(0)
        :sprite_disable(2)
        jmp !skip+
    !:  
    :sprite_enable(0)
    :sprite_enable(2)
    !skip:

    lda dog3Sprite2Y
    cmp #120+48+18
    bcc !+
        :sprite_disable(1)
        :sprite_disable(3)
        jmp !skip+
    !:  
    :sprite_enable(1)
    :sprite_enable(3)
    !skip:

    rts
}

moveDog3:
{
    lda dogMoveDown
    bne !moveDown+
        lda dog3Sprite1Y
        cmp #120
        bcc !+
            dec dog3Sprite1Y
            dec dog3Sprite2Y
            rts
        !:
        lda #1
        sta dogMoveDown 

    !moveDown:
    lda dog3Sprite1Y
    cmp #120+50
    bcs !+
        inc dog3Sprite1Y
        inc dog3Sprite2Y
        rts
    !:
    lda #roundPlaying
    sta gameState
    lda #0
    sta dogMoveDown 
    jsr init_sprites

    rts
}