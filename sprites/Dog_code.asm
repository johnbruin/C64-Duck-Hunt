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
    lda #New
    sta gameState
    lda #0
    sta dogMoveDown 
    jsr init_sprites

    rts
}

dog2Sprite1X: .byte 160-24*2
dog2Sprite1Y: .byte 120
dog2Sprite2X: .byte 160
dog2Sprite2Y: .byte 120
dog2Sprite3X: .byte 160+24*2
dog2Sprite3Y: .byte 120
dog2Sprite4X: .byte 160
dog2Sprite4Y: .byte 120+21*2
showDog2:
{
    // show sprites
    lda #%11111111  

    // sprite priority to back    
    sta $d01b

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
    lda #PURPLE
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

    lda dog2Sprite1Y
    cmp #120+48
    bcc !+
        :sprite_disable(0)
        :sprite_disable(1)
        :sprite_disable(2)
        :sprite_disable(4)    
        :sprite_disable(5)
        :sprite_disable(6)             
        jmp !skip+
    !:  
    :sprite_enable(0)
    :sprite_enable(1)
    :sprite_enable(2)
    :sprite_enable(4)
    :sprite_enable(5)
    :sprite_enable(6)    
    
    !skip:

    lda dog2Sprite4Y
    cmp #120+48+18
    bcc !+
        :sprite_disable(3)
        :sprite_disable(7)
        jmp !skip+
    !:  
    :sprite_enable(3)
    :sprite_enable(7)
    !skip:

    rts
}

moveDog2:
{
    lda dogMoveDown
    bne !moveDown+
        lda dog2Sprite1Y
        cmp #120
        bcc !+
            dec dog2Sprite1Y
            dec dog2Sprite2Y
            dec dog2Sprite3Y
            dec dog2Sprite4Y
            rts
        !:
        lda #1
        sta dogMoveDown 

    !moveDown:
    lda dog2Sprite1Y
    cmp #120+50
    bcs !+
        inc dog2Sprite1Y
        inc dog2Sprite2Y
        inc dog2Sprite3Y
        inc dog2Sprite4Y
        rts
    !:
    lda #New
    sta gameState
    lda #0
    sta dogMoveDown 
    jsr init_sprites

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
    :sprite_disable(4)
    :sprite_disable(5)
    :sprite_disable(6)
    :sprite_disable(7)
    
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
    lda #New
    sta gameState
    lda #0
    sta dogMoveDown 
    jsr init_sprites

    rts
}

dog4Sprite1X: .byte 0
dog4Sprite1Y: .byte 145
dog4Sprite2X: .byte 0+24*2
dog4Sprite2Y: .byte 145

dog4Sprite3X: .byte 0
dog4Sprite3Y: .byte 145+21*2
dog4Sprite4X: .byte 0+24*2
dog4Sprite4Y: .byte 145+21*2

dog4SpritesAnimationPointer: .byte 0
dog4SpritesAnimation: 
.byte 0*4,1*4,2*4,3*4
.byte 0*4,1*4,2*4,3*4
.byte 0*4,1*4,2*4,3*4
.byte 4*4,5*4,4*4,5*4
.byte 4*4,5*4
.byte 0*4,1*4,2*4,3*4
.byte 0*4,1*4,2*4,3*4
.byte 0*4,1*4,2*4,3*4
.byte 4*4,5*4,4*4,5*4
.byte 4*4,5*4
.byte 6*4,6*4,6*4
.byte 7*4,7*4
.byte 8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4

dog4Sprites: 
.byte 72,73,79,80       //walking1
.byte 107,108,114,115   //walking2
.byte 109,110,116,117   //walking3
.byte 105,106,112,113   //walking4
.byte 72,73,79,80       //snif1
.byte 74,75,81,82       //snif2
.byte 76,77,83,84       //alert
.byte 140,141,147,148   //jump1
.byte 142,143,149,150   //jump2

showDog4:
{
    lda #%00000000
    sta $d010

    ldy dog4SpritesAnimationPointer
    cpy #41
    bcc !+
        // sprite priority to back
        lda #%11111111
        sta $d01b
        jmp !skip+
    !:
    // sprite priority to front
    lda #%00000000
    sta $d01b
    
    !skip:
    // set sprites multicolor1
    lda #WHITE
    sta $d025

    // set sprites multicolor2
    lda #ORANGE
    sta $d026

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
    
    lda #RED   
    sta $d027+4
    sta $d027+6 
    sta $d027+5
    sta $d027+7

    //multicolor
    lda #%11110000
    sta $d01c 

    ldy dog4SpritesAnimationPointer
    ldx dog4SpritesAnimation,y    
    lda dog4Sprites,x    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+4

    inx
    lda dog4Sprites,x    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+5

    inx
    lda dog4Sprites,x    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+6

    inx
    lda dog4Sprites,x
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+7

    ldy dog4SpritesAnimationPointer
    ldx dog4SpritesAnimation,y  
    lda dog4Sprites,x      
    clc
    adc #overlay_distance
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+0

    inx
    lda dog4Sprites,x  
    clc
    adc #overlay_distance
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    inx
    lda dog4Sprites,x  
    clc
    adc #overlay_distance
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+2

    inx
    lda dog4Sprites,x  
    clc
    adc #overlay_distance
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+3

    // sprite 1
    lda dog4Sprite1X
    sta spriteXPositions.lo+0
    sta spriteXPositions.lo+4

    lda #0
    sta spriteXPositions.hi+0
    sta spriteXPositions.hi+4

    lda dog4Sprite1Y
    sta spriteYPositions+0
    sta spriteYPositions+4

    // sprite 2
    lda dog4Sprite2X
    sta spriteXPositions.lo+1
    sta spriteXPositions.lo+5

    lda #0
    sta spriteXPositions.hi+1
    sta spriteXPositions.hi+5

    lda dog4Sprite2Y
    sta spriteYPositions+1
    sta spriteYPositions+5

    // sprite 3
    lda dog4Sprite3X
    sta spriteXPositions.lo+2
    sta spriteXPositions.lo+6

    lda #0
    sta spriteXPositions.hi+2
    sta spriteXPositions.hi+6
    
    lda dog4Sprite3Y
    sta spriteYPositions+2
    sta spriteYPositions+6

    //sprite 4
    lda dog4Sprite4X
    sta spriteXPositions.lo+3
    sta spriteXPositions.lo+7

    lda #0
    sta spriteXPositions.hi+3
    sta spriteXPositions.hi+7

    lda dog4Sprite4Y
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

    ldy dog4SpritesAnimationPointer
    cpy #43
    bcc !land+
        lda dog4Sprite3Y
        cmp #120+48+13
        bcc !+
            :sprite_disable(2)
            :sprite_disable(6)
            :sprite_disable(3)
            :sprite_disable(7)
            jmp !skip+
        !:  
        :sprite_enable(2)
        :sprite_enable(6)
        :sprite_enable(3)
        :sprite_enable(7)        
        !skip:
    !land:
    rts
}

dog4MoveSpeed: .byte 0
dog4AnimSpeed: .byte 0
moveDog4:
{
    ldy dog4SpritesAnimationPointer
    cpy #50
    bne !+
        lda #New
        sta gameState
        rts
    !:

    lda dog4AnimSpeed
    cmp #6
    bne !skipAnimation+
        lda #0
        sta dog4AnimSpeed  
        inc dog4SpritesAnimationPointer  
        
        ldy dog4SpritesAnimationPointer
        cpy #38
        bne !+
            jsr playBark
        !:

        ldy dog4SpritesAnimationPointer
        cpy #41
        bne !+
            jsr playBark
        !:    
    !skipAnimation:

    ldy dog4SpritesAnimationPointer
    ldx dog4SpritesAnimation,y
    cpx #4*4
    bne !+
        inc dog4AnimSpeed
        rts
    !:
    cpx #5*4
    bne !+
        inc dog4AnimSpeed
        rts
    !:
    cpx #6*4
    bne !+
        inc dog4AnimSpeed
        rts
    !:

    lda dog4MoveSpeed
    cmp #2
    bne !skipMove+
        inc dog4Sprite1X
        inc dog4Sprite2X
        inc dog4Sprite3X
        inc dog4Sprite4X

        ldy dog4SpritesAnimationPointer
        cpy #38
        bcc !++
            cpy #41
            bcc !+
                jsr land               
                jmp !++
            !:            
            jsr jump
        !:
        lda #0
        sta dog4MoveSpeed
    !skipMove:
    
    inc dog4MoveSpeed
    inc dog4AnimSpeed

    rts
}

move:
{

    rts
}

land:
{
    clc
    lda dog4Sprite1Y
    adc #2
    sta dog4Sprite1Y
    sta dog4Sprite2Y

    clc
    lda dog4Sprite3Y
    adc #2
    sta dog4Sprite3Y
    sta dog4Sprite4Y

    rts
}

jump:
{
    sec
    lda dog4Sprite1Y
    sbc #6
    sta dog4Sprite1Y
    sta dog4Sprite2Y

    sec
    lda dog4Sprite3Y
    sbc #6
    sta dog4Sprite3Y
    sta dog4Sprite4Y
    
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