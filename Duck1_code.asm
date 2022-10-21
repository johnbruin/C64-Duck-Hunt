#importonce 

#import "Duck_code.asm"

*=* "[CODE] Duck1 code"

initDuck1:
{
    lda #0
    sta duck1IsDead
    sta duck1IsShot
    sta duck1OnTheGround
    sta duck1SpritesAnimationCounter
    
    ldx rndDirectionPointer
    lda rndDirection,x
    sta duck1Direction

    lda #160
    sta duck1Y
        
    ldx rndXPositionPointer            
    lda rndXPositions,x
    sta duck1X
    lda #0
    sta duck1X+1

    inc rndXPositionPointer
    inc rndDirectionPointer

    rts
}

duck1SpritesAnimationPointer: .byte 0
duck1SpritesAnimationCounter: .byte 0
duck1X: .word $0000
duck1Y: .byte 100
duck1IsDead: .byte 0
duck1IsShot: .byte 0
duck1Direction: .byte flyRightUp
showDuck1:
{
    :sprite_disable(5)
    :sprite_disable(6)
    :sprite_disable(7)    
    
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

    // show sprites
    :sprite_enable(1)
	:sprite_enable(2)

    //multicolor
    lda #%00010100
    sta $d01c 

    lda duck1IsShot
    beq !+
        lda #5*6
        sta duck1SpritesAnimationPointer
    !:

    lda duck1IsDead
    beq !+
        lda #7*6
        sta duck1SpritesAnimationPointer
    !:

    lda duck1SpritesAnimationPointer
    clc
    adc duck1SpritesAnimationCounter
    tax
    lda duckSprites,x
    clc
    adc #(>spriteMemory<<2)	
    adc #overlay_distance
    sta SPRITEPOINTER+1

    lda duckSprites,x  
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
    lda duck1IsDead
    beq !duckisdead+
        lda duck1Y
        cmp #170
        bcc !++
            lda duck1OnTheGround
            bne !+
                jsr playDrop
            !:
            lda #1
            sta duck1OnTheGround
            sprite_disable(1)
            sprite_disable(2)  
            jmp !duckisdead+
        !:
        inc duck1Y   
        inc duck1Y 
    !duckisdead:
    
    lda duck1AnimSpeed
    cmp #8
    bne !skipAnimation+  

        inc rndQuackPointer
        ldx rndQuackPointer
        lda rndQuacks,x
        bne !+
            jsr playQuack
        !:

        jsr playFly

        lda duck1IsShot
        beq !+
            lda #1
            sta duck1IsDead
            lda #0
            sta duck1IsShot
        !:       
        
        inc duck1SpritesAnimationCounter
        lda duck1SpritesAnimationCounter        
        cmp #6
        bne !+
            lda #0
            sta duck1SpritesAnimationCounter
        !:

        lda #0
        sta duck1AnimSpeed
    !skipAnimation:
    inc duck1AnimSpeed
    rts
}

duck1MoveSpeed: .byte 1
moveDuck1:
{
    lda duck1IsShot
    beq !+
        rts
    !:
	
    lda duck1IsDead
	beq !+
        rts
    !:

    lda gameState
    cmp #FlyAway
    bne !+
        jsr moveDuck1FlyAway
        rts
    !:

    lda duck1Direction
    cmp #flyRightUp
    bne !+
        jsr moveDuck1RightUp
    !:

    lda duck1Direction
    cmp #flyRightDown
    bne !+
        jsr moveDuck1RightDown
    !:

    lda duck1Direction
    cmp #flyLeftUp
    bne !+
        jsr moveDuck1LeftUp
    !:

    lda duck1Direction
    cmp #flyLeftDown
    bne !+
        jsr moveDuck1LeftDown
    !:

    lda duck1Direction
    cmp #flyDiagonalLeftUp
    bne !+
        jsr moveDuck1DiagonalLeftUp
    !:

    lda duck1Direction
    cmp #flyDiagonalLeftDown
    bne !+
        jsr moveDuck1DiagonalLeftDown
    !:

    lda duck1Direction
    cmp #flyDiagonalRightUp
    bne !+
        jsr moveDuck1DiagonalRightUp
    !:

    lda duck1Direction
    cmp #flyDiagonalRightDown
    bne !+
        jsr moveDuck1DiagonalRightDown
    !:

    lda duck1Direction
    cmp #flyUp
    bne !+
        jsr moveDuck1Up
    !:

    lda duck1Direction
    cmp #flyDown
    bne !+
        jsr moveDuck1Down
    !:
       
    rts
}

moveDuck1Up:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Up

    lda duck1Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck1Direction
        rts
}

moveDuck1FlyAway:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Up

    lda duck1Y
	cmp #4	
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        jsr playLaugh

        lda #Miss
        sta gameState
        rts
}

moveDuck1Down:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Down

    lda duck1Y
	cmp #lowerBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck1Direction
        rts
    !lower:  
        rts
}

moveDuck1LeftUp:
{
    lda #1*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Left
    
    lda duck1Y
	cmp #upperBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyLeftDown
        sta duck1Direction
        rts

    !skip:

    lda duck1X+1
	cmp #>leftBoundary
	bne !+
	    lda duck1X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyDiagonalRightUp
        sta duck1Direction
         rts
}

moveDuck1LeftDown:
{
    lda #1*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Left
    
    lda duck1Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck1Direction
        rts
    !lower:

    lda duck1X+1
	cmp #>leftBoundary
	bne !+
	    lda duck1X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck1Direction
        rts
}

moveDuck1RightUp:
{
    lda #0*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Right
    
    lda duck1Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyRightDown
        sta duck1Direction
        rts

    !skip:

    lda duck1X+1
	cmp #>rightBoundary
	bne !+
	    lda duck1X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck1Direction
    !lower:
        rts
}

moveDuck1RightDown:
{
    lda #0*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Right
    
    lda duck1Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalRightUp
        sta duck1Direction
        rts
    !lower:

    lda duck1X+1
	cmp #>rightBoundary
	bne !+
	    lda duck1X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftDown
        sta duck1Direction        
    !lower:
        rts    
}

moveDuck1DiagonalLeftUp:
{
    lda #2*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Up
    jsr Duck1Left
    
    lda duck1Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyLeftDown
        sta duck1Direction
        rts

    !skip:
    lda duck1X+1
	cmp #>leftBoundary
	bne !+
	    lda duck1X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyDiagonalRightUp
        sta duck1Direction
        rts    
}

moveDuck1DiagonalLeftDown:
{
    lda #2*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Down
    jsr Duck1Left
    
    lda duck1Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftUp
        sta duck1Direction
        rts
    !lower:

    lda duck1X+1
	cmp #>leftBoundary
	bne !+
	    lda duck1X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck1Direction
        rts    
}

moveDuck1DiagonalRightUp:
{
    lda #3*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Up
    jsr Duck1Right
    
    lda duck1Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyRightDown
        sta duck1Direction
        rts

    !skip:
    lda duck1X+1
	cmp #>rightBoundary
	bne !+
	    lda duck1X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftUp
        sta duck1Direction
        rts
    !lower:
        rts
}

moveDuck1DiagonalRightDown:
{
    lda #3*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Down
    jsr Duck1Right
    
    lda duck1Y
	cmp #lowerBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyRightUp
        sta duck1Direction
        rts
    !lower:
    
    lda duck1X+1
	cmp #>rightBoundary
	bne !+
	    lda duck1X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftDown
        sta duck1Direction
        rts
    !lower:
        rts
}

Duck1Left:
{
    sec
    lda duck1X
    sbc duck1MoveSpeed
    sta duck1X
    lda duck1X+1
    sbc #0
    sta duck1X+1
    rts
}

Duck1Right:
{
    clc
    lda duck1X
    adc duck1MoveSpeed
    sta duck1X
    lda duck1X+1
    adc #0
    sta duck1X+1
    rts
}

Duck1Up:
{
    sec
    lda duck1Y
    sbc duck1MoveSpeed
    sta duck1Y
    rts
}

Duck1Down:
{
    clc
    lda duck1Y
    adc duck1MoveSpeed
    sta duck1Y
    rts
}