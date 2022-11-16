#importonce 

#import "Dog.asm"

*=* "[CODE] Dog1 code"

Dog1:
{
    _isVisible: .byte 0
    _moveDown: .byte 0
    _sprite1X: .byte Dog.PosX
    _sprite1Y: .byte Dog.MaxY
    _sprite2X: .byte Dog.PosX+24*2
    _sprite2Y: .byte Dog.MaxY
    _sprite3X: .byte Dog.PosX
    _sprite3Y: .byte Dog.MaxY+21*2
    
    Show:
    {
        lda #%01111110  

        // sprite priority to back    
        sta $d01b

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
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+4

        lda #8
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+5

        lda #14
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+6

        lda #7+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+1

        lda #8+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+2

        lda #14+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+3

        lda _sprite1X
        sta Sprites.XPositions.lo+1
        sta Sprites.XPositions.lo+4

        lda #0
        sta Sprites.XPositions.hi+1
        sta Sprites.XPositions.hi+4

        lda _sprite1Y
        sta Sprites.YPositions+1
        sta Sprites.YPositions+4

        lda _sprite2X
        sta Sprites.XPositions.lo+2
        sta Sprites.XPositions.lo+5

        lda #0
        sta Sprites.XPositions.hi+2
        sta Sprites.XPositions.hi+5

        lda _sprite2Y
        sta Sprites.YPositions+2
        sta Sprites.YPositions+5

        lda _sprite3X
        sta Sprites.XPositions.lo+3
        sta Sprites.XPositions.lo+6

        lda #0
        sta Sprites.XPositions.hi+3
        sta Sprites.XPositions.hi+6

        lda _sprite3Y
        sta Sprites.YPositions+3
        sta Sprites.YPositions+6

        :sprite_set_xy_positions(1)
        :sprite_set_xy_positions(2)
        :sprite_set_xy_positions(3)
        :sprite_set_xy_positions(4)
        :sprite_set_xy_positions(5)
        :sprite_set_xy_positions(6)

        lda _sprite1Y
        cmp #Dog.MaxY
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

        lda _sprite3Y
        cmp #Dog.MaxY+18
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

    Move:
    {
        lda _moveDown
        bne !moveDown+
            lda _sprite1Y
            cmp #Dog.MinY
            bcc !+
                dec _sprite1Y
                dec _sprite2Y
                dec _sprite3Y
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
            inc _sprite3Y
            rts
        !:

        lda #NewSet
        sta Game.State
        
        lda #0
        sta _moveDown 
        
        jsr Sprites.Init

        rts
    }
}