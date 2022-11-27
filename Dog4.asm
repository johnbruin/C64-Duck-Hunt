#importonce 

#import "Dog.asm"
#import "SoundFx.asm"

*=* "[CODE] Dog3 code"

Dog4:
{
    _isVisible: .byte 0
    _moveDown: .byte 0

    _sprite1X: .byte 0
    _sprite1Y: .byte 145
    _sprite2X: .byte 0+24*2
    _sprite2Y: .byte 145

    _sprite3X: .byte 0
    _sprite3Y: .byte 145+21*2
    _sprite4X: .byte 0+24*2
    _sprite4Y: .byte 145+21*2

    _spritesAnimationPointer: .byte 0
    _spritesAnimation: 
    .byte 1*4,2*4,3*4,0*4
    .byte 1*4,2*4,3*4,0*4
    .byte 1*4,2*4,3*4,0*4
    .byte 4*4,5*4,4*4,5*4
    .byte 4*4,5*4
    .byte 1*4,2*4,3*4,0*4
    .byte 1*4,2*4,3*4,0*4
    .byte 1*4,2*4,3*4,0*4
    .byte 4*4,5*4,4*4,5*4
    .byte 4*4,5*4
    .byte 6*4,6*4,6*4
    .byte 7*4,7*4
    .byte 8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4,8*4

    _sprites: 
    .byte 72,73,79,80       //walking1
    .byte 107,108,114,115   //walking2
    .byte 109,110,116,117   //walking3
    .byte 105,106,112,113   //walking4
    .byte 72,73,79,80       //snif1
    .byte 74,75,81,82       //snif2
    .byte 76,77,83,84       //alert
    .byte 140,141,147,148   //jump1
    .byte 142,143,149,150   //jump2

    Init:
    {
        lda #0
        sta _spritesAnimationPointer

        lda #0
        sta _sprite1X
        lda #145
        sta _sprite1Y
        lda #0+2*24
        sta _sprite2X
        lda #145
        sta _sprite2Y

        lda #0
        sta _sprite3X
        lda #145+21*2
        sta _sprite3Y
        lda #0+24*2
        sta _sprite4X
        lda #145+21*2
        sta _sprite4Y

        rts
    }

    Show:
    {
        lda #%00000000
        sta $d010

        ldy _spritesAnimationPointer
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

        // show all sprites
        jsr Sprites.Show

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

        ldy _spritesAnimationPointer
        ldx _spritesAnimation,y    
        lda _sprites,x    
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+4

        inx
        lda _sprites,x    
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+5

        inx
        lda _sprites,x    
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+6

        inx
        lda _sprites,x
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+7

        ldy _spritesAnimationPointer
        ldx _spritesAnimation,y  
        lda _sprites,x      
        clc
        adc #Sprites.overlay_distance
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+0

        inx
        lda _sprites,x  
        clc
        adc #Sprites.overlay_distance
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+1

        inx
        lda _sprites,x  
        clc
        adc #Sprites.overlay_distance
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+2

        inx
        lda _sprites,x  
        clc
        adc #Sprites.overlay_distance
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+3

        // sprite 1
        lda _sprite1X
        sta Sprites.XPositions.lo+0
        sta Sprites.XPositions.lo+4

        lda #0
        sta Sprites.XPositions.hi+0
        sta Sprites.XPositions.hi+4

        lda _sprite1Y
        sta Sprites.YPositions+0
        sta Sprites.YPositions+4

        // sprite 2
        lda _sprite2X
        sta Sprites.XPositions.lo+1
        sta Sprites.XPositions.lo+5

        lda #0
        sta Sprites.XPositions.hi+1
        sta Sprites.XPositions.hi+5

        lda _sprite2Y
        sta Sprites.YPositions+1
        sta Sprites.YPositions+5

        // sprite 3
        lda _sprite3X
        sta Sprites.XPositions.lo+2
        sta Sprites.XPositions.lo+6

        lda #0
        sta Sprites.XPositions.hi+2
        sta Sprites.XPositions.hi+6
        
        lda _sprite3Y
        sta Sprites.YPositions+2
        sta Sprites.YPositions+6

        //sprite 4
        lda _sprite4X
        sta Sprites.XPositions.lo+3
        sta Sprites.XPositions.lo+7

        lda #0
        sta Sprites.XPositions.hi+3
        sta Sprites.XPositions.hi+7

        lda _sprite4Y
        sta Sprites.YPositions+3
        sta Sprites.YPositions+7

        :sprite_set_xy_positions(0)
        :sprite_set_xy_positions(1)
        :sprite_set_xy_positions(2)
        :sprite_set_xy_positions(3)
        :sprite_set_xy_positions(4)
        :sprite_set_xy_positions(5)
        :sprite_set_xy_positions(6)
        :sprite_set_xy_positions(7)

        ldy _spritesAnimationPointer
        cpy #43
        bcc !land+
            lda _sprite3Y
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

    _animSpeed: .byte 0
    Move:
    {
        ldy _spritesAnimationPointer
        cpy #50
        bne !+
            lda #NewRound
            sta Game.State
            rts
        !:

        lda _animSpeed
        cmp animSpeed:#8
        bne !skipAnimation+
            lda #0
            sta _animSpeed  
            lda #8
            sta animSpeed
            inc _spritesAnimationPointer  

            ldy _spritesAnimationPointer
            ldx _spritesAnimation,y
            cpx #4*4
            bne !+
                jmp !skipAnimation+
            !:
            cpx #5*4
            bne !+
                jmp !skipAnimation+
            !:
            cpx #6*4
            bne !+
                jmp !skipAnimation+
            !:
            
            jsr walk
            ldy _spritesAnimationPointer
            cpy #38
            bcc !++
                lda #3
                sta animSpeed
                cpy #41
                bcc !+
                    jsr land               
                    jmp !++
                !:            
                jsr jump
            !:
        !skipAnimation:
        inc _animSpeed

        rts
    }

    walk:
    {
        .for(var i=0;i<4;i++)
        {
            inc _sprite1X
            inc _sprite2X
            inc _sprite3X
            inc _sprite4X
        }
        rts
    }

    land:
    {
        clc
        lda _sprite1Y
        adc #6
        sta _sprite1Y
        sta _sprite2Y

        clc
        lda _sprite3Y
        adc #6
        sta _sprite3Y
        sta _sprite4Y

        rts
    }

    jump:
    {
        sec
        lda _sprite1Y
        sbc #18
        sta _sprite1Y
        sta _sprite2Y

        sec
        lda _sprite3Y
        sbc #18
        sta _sprite3Y
        sta _sprite4Y
        
        rts
    }
}