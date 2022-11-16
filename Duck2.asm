#importonce 

#import "Duck.asm"

*=* "[CODE] Duck2 code"

Duck2:
{
    X: .word $0000
    Y: .byte 100
    
    ScoreX: .word $0000
    ScoreY: .byte 0
    
    Number: .byte 0
    OnTheGround: .byte 0
    IsShot: .byte 0
    IsDead: .byte 0 

    Init:
    {
        lda #0
        sta IsDead
        sta IsShot
        sta OnTheGround
        sta _spritesAnimationCounter
        
        ldx Duck.RndDirectionPointer
        lda Duck.RndDirection,x
        sta _direction

        lda #Duck.LowerBoundary+10
        sta Y
            
        ldx Duck.RndXPositionPointer            
        lda Duck.RndXPositions,x
        sta X
        lda #0
        sta X+1

        inc Duck.RndXPositionPointer
        inc Duck.RndDirectionPointer

        rts
    }

    showScore:
    {        
        // sprite priority to front    
        lda #%10011110
        sta $d01b

        // Make sure no sprites are x- or y-expanded.    
        sta $d017
        sta $d01d

        lda #WHITE
        sta $d027+6

        ldx Round.Number
        dex
        ldy Score.HitScoreRound,x  
        lda Set.Hits
        cmp #2
        bne !+
            iny
        !:
        lda Score.ScoreSprites,y
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+6
        
        lda ScoreX
        sta Sprites.XPositions.lo+6

        lda ScoreX+1
        sta Sprites.XPositions.hi+6

        lda ScoreY
        sta Sprites.YPositions+6

        :sprite_set_xy_positions(6)
        :sprite_enable(6)
        rts
    }

    _spritesAnimationPointer: .byte 0
    _spritesAnimationCounter: .byte 0
    _direction: .byte FlyRightUp
    Show:
    {
        :sprite_disable(6)
        :sprite_disable(7)    
        
        // set sprites multicolor1
        lda #WHITE
        sta $d025

        // set sprites multicolor2
        lda #ORANGE
        sta $d026

        // set sprite color sprite1
        lda #PURPLE
        sta $d027+4

        // set sprite color sprite2
        lda #BLACK
        sta $d027+3

        // show sprites
        :sprite_enable(3)
        :sprite_enable(4)

        //multicolor
        lda #%00010100
        sta $d01c

        lda IsShot
        beq !+        
            lda #5*6
            sta _spritesAnimationPointer
            jsr showScore
        !:

        lda IsDead
        beq !+
            lda #7*6
            sta _spritesAnimationPointer
            jsr showScore
        !:

        lda _spritesAnimationPointer
        clc
        adc _spritesAnimationCounter
        tax
        lda Duck.Sprites,x
        clc
        adc #(>SpriteMemory<<2)	
        adc #Sprites.overlay_distance
        sta Sprites.SPRITEPOINTER+3

        lda Duck.Sprites,x  
        clc
        adc #(>SpriteMemory<<2)	
        sta Sprites.SPRITEPOINTER+4

        lda X
        sta Sprites.XPositions.lo+3
        sta Sprites.XPositions.lo+4

        lda X+1
        sta Sprites.XPositions.hi+3
        sta Sprites.XPositions.hi+4

        lda Y
        sta Sprites.YPositions+3
        sta Sprites.YPositions+4

        :sprite_set_xy_positions(3)
        :sprite_set_xy_positions(4)

        rts
    }

    _animSpeed: .byte 0
    InitAnimation:
    {
        lda #0
        sta _animSpeed
        sta _spritesAnimationCounter
        rts
    }

    Animate:
    {
        lda IsDead
        beq !duckisdead+
            lda Y
            cmp #170
            bcc !++
                lda OnTheGround
                bne !+                               
                    jsr SoundFx.Drop
                !:
                lda #1
                sta OnTheGround
                :sprite_disable(3)
                :sprite_disable(4)
                :sprite_disable(6)  
                jmp !duckisdead+
            !:
            inc Y   
            inc Y 
        !duckisdead:
        
        lda _animSpeed
        cmp #8
        bne !skipAnimation+  

            lda IsShot
            beq !+
                lda #1
                sta IsDead
                lda #0
                sta IsShot
            !:       
            
            inc _spritesAnimationCounter
            lda _spritesAnimationCounter        
            cmp #6
            bne !+
                lda #0
                sta _spritesAnimationCounter
            !:

            lda #0
            sta _animSpeed
        !skipAnimation:
        inc _animSpeed
        rts
    }

    Move:
    {
        lda Duck.PlayWith1Duck
        jsr changeMovement
        !skip:

        lda IsShot
        beq !+
            rts
        !:
        
        lda IsDead
        beq !+
            rts
        !:

        lda Game.State
        cmp #FlyAway
        bne !+
            jsr moveFlyAway
            rts
        !:

        lda _direction
        cmp #FlyRightUp
        bne !+
            jsr moveRightUp
        !:

        lda _direction
        cmp #FlyRightDown
        bne !+
            jsr moveRightDown
        !:

        lda _direction
        cmp #FlyLeftUp
        bne !+
            jsr moveLeftUp
        !:

        lda _direction
        cmp #FlyLeftDown
        bne !+
            jsr moveLeftDown
        !:

        lda _direction
        cmp #FlyDiagonalLeftUp
        bne !+
            jsr moveDiagonalLeftUp
        !:

        lda _direction
        cmp #FlyDiagonalRightUp
        bne !+
            jsr moveDiagonalRightUp
        !:

        lda _direction
        cmp #FlyUp
        bne !+
            jsr moveUp
        !:

        lda _direction
        cmp #FlyDown
        bne !+
            jsr moveDown
        !:
        
        rts
    }

    moveUp:
    {
        lda #4*6
        sta _spritesAnimationPointer

        jsr up
        jsr up

    check:
        jsr crossUpperBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyRightDown
            sta _direction
        !:
        rts
    }

    moveDown:
    {
        lda #4*6
        sta _spritesAnimationPointer

        jsr down
        jsr down

    check:
        jsr crossLowerBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyDiagonalLeftUp
            sta _direction
        !:
        rts
    }

    moveLeftUp:
    {
        lda #1*6
        sta _spritesAnimationPointer

        jsr up
        jsr left
        
    check:
        jsr crossUpperBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyLeftDown
            sta _direction
            rts
        !:
        jsr crossLeftBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyRightDown
            sta _direction
        !:
        rts
    }

    moveLeftDown:
    {
        lda #1*6
        sta _spritesAnimationPointer

        jsr down
        jsr left

    check:
        jsr crossLowerBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyDiagonalLeftUp
            sta _direction
            rts
        !:
        jsr crossLeftBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyDiagonalRightUp
            sta _direction
        !:
        rts
    }

    moveRightUp:
    {
        lda #0*6
        sta _spritesAnimationPointer

        jsr up
        jsr right

    check:
        jsr crossUpperBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyRightDown
            sta _direction
            rts
        !:
        jsr crossRightBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyLeftDown
            sta _direction
        !:
        rts
    }

    moveRightDown:
    {
        lda #0*6
        sta _spritesAnimationPointer

        jsr down
        jsr right

    check:
        jsr crossLowerBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyDiagonalRightUp
            sta _direction
            rts
        !:
        jsr crossRightBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyLeftUp
            sta _direction 
        !:
        rts
    }

    moveDiagonalLeftUp:
    {
        lda #2*6
        sta _spritesAnimationPointer

        jsr up
        jsr up
        jsr left

    check:
        jsr crossUpperBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyLeftDown
            sta _direction
            rts
        !:
        jsr crossLeftBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyRightDown
            sta _direction
        !:
        rts    
    }

    moveDiagonalRightUp:
    {
        lda #3*6
        sta _spritesAnimationPointer

        jsr up
        jsr up
        jsr right

    check:
        jsr crossUpperBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyRightDown
            sta _direction
            rts
        !:
        jsr crossRightBoundary
        beq !+
            jsr SoundFx.Quack
            lda #FlyLeftDown
            sta _direction        
        !:
        rts
    }

    moveFlyAway:
    {
        lda #4*6
        sta _spritesAnimationPointer

        jsr up
        jsr up

        lda Y
        cmp #5	
        bcc !lower+
        bne !higher+    

        !higher:
            rts
        !lower:
            jsr SoundFx.Laugh
            lda #Miss
            sta Game.State
            rts
    }

    left:
    {
        sec
        lda X
        sbc Duck.MoveSpeed
        sta X
        lda X+1
        sbc #0
        sta X+1
        rts
    }

    right:
    {
        clc
        lda X
        adc Duck.MoveSpeed
        sta X
        lda X+1
        adc #0
        sta X+1
        rts
    }

    up:
    {
        sec
        lda Y
        sbc Duck.MoveSpeed
        sta Y
        rts
    }

    down:
    {
        clc
        lda Y
        adc Duck.MoveSpeed
        sta Y
        rts
    }

    _changeMovementCounter: .byte 15
    changeMovement:
    {
        lda _changeMovementCounter
        bne !changeMovement+
            inc Duck.RndMovementsPointer
            ldx Duck.RndMovementsPointer
            lda Duck.RndMovements,x
            cmp #$ff
            beq !+
                sta _direction
                jsr SoundFx.Quack
            !:
            lda #15
            sta _changeMovementCounter
        !changeMovement:
        dec _changeMovementCounter
        rts
    }

    crossUpperBoundary:
    {
        lda Y
        cmp #Duck.UpperBoundary
        bcc !lower+
        bne !higher+    

        !higher:
            lda #0
            rts
        !lower:
            lda #1
        rts
    }

    crossLowerBoundary:
    {
        lda Y
        cmp #Duck.LowerBoundary
        bcc !lower+
        bne !higher+    

        !higher:
            lda #1
            rts
        !lower:
            lda #0
        rts
    }

    crossLeftBoundary:
    {
        lda X+1
        cmp #>Duck.LeftBoundary
        bne !+
            lda X
            cmp #<Duck.LeftBoundary
        !:
        bcc !lower+
        bne !higher+    

        !higher:
            lda #0
            rts
        !lower:
            lda #1
        rts
    }

    crossRightBoundary:
    {
        lda X+1
        cmp #>Duck.RightBoundary
        bne !+
            lda X
            cmp #<Duck.RightBoundary
        !:
        bcc !lower+
        bne !higher+    

        !higher:
            lda #1
            rts
        !lower:
            lda #0
        rts
    }
}