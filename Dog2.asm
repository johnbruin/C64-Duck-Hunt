#importonce 

#import "Dog.asm"

*=* "[CODE] Dog2 code"

Dog2:
{
    _isVisible: .byte 0
    _moveDown: .byte 0
    _sprite1X: .byte Dog.PosX-24*2
    _sprite1Y: .byte Dog.MaxY
    _sprite2X: .byte Dog.PosX
    _sprite2Y: .byte Dog.MaxY
    _sprite3X: .byte Dog.PosX+24*2
    _sprite3Y: .byte Dog.MaxY
    _sprite4X: .byte Dog.PosX
    _sprite4Y: .byte Dog.MaxY+21*2

    Show:
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
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+4

        lda #10
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+5

        lda #11
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+6

        lda #17
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+7

        lda #9+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+0

        lda #10+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+1

        lda #11+Sprites.overlay_distance
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+2

        lda #17+Sprites.overlay_distance
        clc
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

        lda _sprite1Y
        cmp #Dog.MaxY
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

        lda _sprite4Y
        cmp #Dog.MaxY+18
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
                dec _sprite4Y
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
            inc _sprite4Y
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