#importonce 

#import "Dog.asm"

*=* "[CODE] Dog3 code"

Dog3:
{
    _isVisible: .byte 0
    _moveDown: .byte 0
    _sprite1X: .byte Dog.PosX
    _sprite1Y: .byte Dog.MaxY
    _sprite2X: .byte Dog.PosX
    _sprite2Y: .byte Dog.MaxY+21*2
    _animation: .byte 0
    _animSpeed: .byte 4

    Show:
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

        lda _animSpeed
        cmp #4
        bne !skipAnimation+
            lda #0
            sta _animSpeed

            lda _animation
            bne !+
                lda #12    
                clc
                adc #(>SpriteMemory<<2)	
                sta Sprites.SPRITEPOINTER+2
                
                lda #12+Sprites.overlay_distance
                clc
                adc #(>SpriteMemory<<2)	
                sta Sprites.SPRITEPOINTER+0

                lda #1
                sta _animation

                jmp !skipAnimation+
            !:
        
            lda #13    
            clc
            adc #(>SpriteMemory<<2)	
            sta Sprites.SPRITEPOINTER+2
            
            lda #13+Sprites.overlay_distance
            clc
            adc #(>SpriteMemory<<2)	
            sta Sprites.SPRITEPOINTER+0    

            lda #0
            sta _animation
            
        !skipAnimation:
        inc _animSpeed

        lda #19
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+3

        lda #19+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+1

        // sprite 1
        lda _sprite1X
        sta Sprites.XPositions.lo+0
        sta Sprites.XPositions.lo+2

        lda #0
        sta Sprites.XPositions.hi+0
        sta Sprites.XPositions.hi+2

        lda _sprite1Y
        sta Sprites.YPositions+0
        sta Sprites.YPositions+2

        // sprite 2
        lda _sprite2X
        sta Sprites.XPositions.lo+1
        sta Sprites.XPositions.lo+3

        lda #0
        sta Sprites.XPositions.hi+1
        sta Sprites.XPositions.hi+3

        lda _sprite2Y
        sta Sprites.YPositions+1
        sta Sprites.YPositions+3

        :sprite_set_xy_positions(0)
        :sprite_set_xy_positions(1)
        :sprite_set_xy_positions(2)
        :sprite_set_xy_positions(3)

        lda _sprite1Y
        cmp #Dog.MaxY
        bcc !+
            :sprite_disable(0)
            :sprite_disable(2)
            jmp !skip+
        !:  
        :sprite_enable(0)
        :sprite_enable(2)
        !skip:

        lda _sprite2Y
        cmp #Dog.MaxY+18
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

    Move:
    {
        lda _moveDown
        bne !moveDown+
            lda _sprite1Y
            cmp #Dog.MinY
            bcc !+
                dec _sprite1Y
                dec _sprite2Y
                rts
            !:
            lda #1
            sta _moveDown 

        !moveDown:
        lda _sprite1Y
        cmp #Dog.MaxY
        bcs !+
            inc _sprite1Y
            inc _sprite2Y
            rts
        !:
        lda #NewSet
        sta Game.State
        lda #0
        sta _moveDown 
        jsr Sprites.Init

        rts
    }

    MoveUpOnly:
    {
        lda _sprite1Y
        cmp #Dog.MinY
        bcc !+
            dec _sprite1Y
            dec _sprite2Y
            rts
        !:
        rts
    }
}