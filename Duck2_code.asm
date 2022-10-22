#importonce 

#import "Duck_code.asm"

*=* "[CODE] Duck2 code"

initDuck2:
{
    lda #0
    sta duck2IsDead
    sta duck2IsShot
    sta duck2OnTheGround
    sta duck2SpritesAnimationCounter
    
    ldx rndDirectionPointer
    lda rndDirection,x
    sta duck2Direction

    lda #160
    sta duck2Y
        
    ldx rndXPositionPointer            
    lda rndXPositions,x
    sta duck2X
    lda #0
    sta duck2X+1

    inc rndXPositionPointer
    inc rndDirectionPointer

    rts
}

duck2ScoreX: .word $0000
duck2ScoreY: .byte 0
showScoreDuck2:
{        
    // sprite priority to front    
    lda #%10011110
    sta $d01b

    // Make sure no sprites are x- or y-expanded.    
    sta $d017
    sta $d01d

    lda #WHITE
    sta $d027+6

    ldx #0
    lda scoreSprites,x  
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+6
    
    lda duck2ScoreX
    sta spriteXPositions.lo+6

    lda duck2ScoreX+1
    sta spriteXPositions.hi+6

    lda duck2ScoreY
    sta spriteYPositions+6

    :sprite_set_xy_positions(6)
    :sprite_enable(6)
    rts
}

duck2SpritesAnimationPointer: .byte 0
duck2SpritesAnimationCounter: .byte 0
duck2X: .word $0000
duck2Y: .byte 100
duck2IsDead: .byte 0
duck2IsShot: .byte 0
duck2Direction: .byte flyRightUp
showDuck2:
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

    lda duck2IsShot
    beq !+
        lda #5*6
        sta duck2SpritesAnimationPointer
        jsr showScoreDuck2
    !:

    lda duck2IsDead
    beq !+
        lda #7*6
        sta duck2SpritesAnimationPointer
        jsr showScoreDuck2
    !:

    lda duck2SpritesAnimationPointer
    clc
    adc duck2SpritesAnimationCounter
    tax
    lda duckSprites,x
    clc
    adc #(>spriteMemory<<2)	
    adc #overlay_distance
    sta SPRITEPOINTER+3

    lda duckSprites,x  
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+4

    lda duck2X
    sta spriteXPositions.lo+3
    sta spriteXPositions.lo+4

    lda duck2X+1
    sta spriteXPositions.hi+3
    sta spriteXPositions.hi+4

    lda duck2Y
    sta spriteYPositions+3
    sta spriteYPositions+4

    :sprite_set_xy_positions(3)
    :sprite_set_xy_positions(4)

    rts
}

duck2AnimSpeed: .byte 0
animateDuck2:
{
    lda duck2IsDead
    beq !duckisdead+
        lda duck2Y
        cmp #170
        bcc !++
            lda duck2OnTheGround
            bne !+
                jsr playDrop                               
            !:
            lda #1
            sta duck2OnTheGround
            :sprite_disable(3)
            :sprite_disable(4)
            :sprite_disable(6)  
            jmp !duckisdead+
        !:
        inc duck2Y   
        inc duck2Y 
    !duckisdead:

    lda duck2AnimSpeed
    cmp #8
    bne !skipAnimation+  

        lda duck2IsShot
        beq !+
            lda #1
            sta duck2IsDead
            lda #0
            sta duck2IsShot
        !:       

        inc duck2SpritesAnimationCounter
        lda duck2SpritesAnimationCounter
        cmp #6
        bne !+
            lda #0
            sta duck2SpritesAnimationCounter
        !:

        lda #0
        sta duck2AnimSpeed
    !skipAnimation:
    inc duck2AnimSpeed
    rts
}

moveDuck2:
{
    lda duck2IsShot
    beq !+
        rts
    !:
	
    lda duck2IsDead
	beq !+
        rts
    !:

    lda gameState
    cmp #FlyAway
    bne !+
        jsr moveDuck2FlyAway
        rts
    !:

    lda duck2Direction
    cmp #flyRightUp
    bne !+
        jsr moveDuck2RightUp
    !:

    lda duck2Direction
    cmp #flyRightDown
    bne !+
        jsr moveDuck2RightDown
    !:

    lda duck2Direction
    cmp #flyLeftUp
    bne !+
        jsr moveDuck2LeftUp
    !:

    lda duck2Direction
    cmp #flyLeftDown
    bne !+
        jsr moveDuck2LeftDown
    !:

    lda duck2Direction
    cmp #flyDiagonalLeftUp
    bne !+
        jsr moveDuck2DiagonalLeftUp
    !:

    lda duck2Direction
    cmp #flyDiagonalLeftDown
    bne !+
        jsr moveDuck2DiagonalLeftDown
    !:

    lda duck2Direction
    cmp #flyDiagonalRightUp
    bne !+
        jsr moveDuck2DiagonalRightUp
    !:

    lda duck2Direction
    cmp #flyDiagonalRightDown
    bne !+
        jsr moveDuck2DiagonalRightDown
    !:

    lda duck2Direction
    cmp #flyUp
    bne !+
        jsr moveDuck2Up
    !:

    lda duck2Direction
    cmp #flyDown
    bne !+
        jsr moveDuck2Down
    !:
       
    rts
}

moveDuck2Up:
{
    lda #4*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Up

    lda duck2Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck2Direction
        rts
}

moveDuck2FlyAway:
{
    lda #4*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Up

    lda duck2Y
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

moveDuck2Down:
{
    lda #4*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Down
    jsr Duck2Down

    lda duck2Y
	cmp #lowerBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck2Direction
        rts
    !lower:  
        rts
}

moveDuck2LeftUp:
{
    lda #1*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Left
    
    lda duck2Y
	cmp #upperBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyLeftDown
        sta duck2Direction
        rts

    !skip:

    lda duck2X+1
	cmp #>leftBoundary
	bne !+
	    lda duck2X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyDiagonalRightUp
        sta duck2Direction
         rts
}

moveDuck2LeftDown:
{
    lda #1*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Down
    jsr Duck2Left
    
    lda duck2Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck2Direction
        rts
    !lower:

    lda duck2X+1
	cmp #>leftBoundary
	bne !+
	    lda duck2X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck2Direction
        rts
}

moveDuck2RightUp:
{
    lda #0*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Right
    
    lda duck2Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyRightDown
        sta duck2Direction
        rts

    !skip:

    lda duck2X+1
	cmp #>rightBoundary
	bne !+
	    lda duck2X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalLeftUp
        sta duck2Direction
    !lower:
        rts
}

moveDuck2RightDown:
{
    lda #0*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Down
    jsr Duck2Right
    
    lda duck2Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyDiagonalRightUp
        sta duck2Direction
        rts
    !lower:

    lda duck2X+1
	cmp #>rightBoundary
	bne !+
	    lda duck2X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftDown
        sta duck2Direction        
    !lower:
        rts    
}

moveDuck2DiagonalLeftUp:
{
    lda #2*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Up
    jsr Duck2Left
    
    lda duck2Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyLeftDown
        sta duck2Direction
        rts

    !skip:
    lda duck2X+1
	cmp #>leftBoundary
	bne !+
	    lda duck2X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyDiagonalRightUp
        sta duck2Direction
        rts    
}

moveDuck2DiagonalLeftDown:
{
    lda #2*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Down
    jsr Duck2Down
    jsr Duck2Left
    
    lda duck2Y
	cmp #lowerBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftUp
        sta duck2Direction
        rts
    !lower:

    lda duck2X+1
	cmp #>leftBoundary
	bne !+
	    lda duck2X
	    cmp #<leftBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #flyRightDown
        sta duck2Direction
        rts    
}

moveDuck2DiagonalRightUp:
{
    lda #3*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Up
    jsr Duck2Up
    jsr Duck2Right
    
    lda duck2Y
	cmp #upperBoundary
    bcc !lower+
    bne !higher+    

    !higher:
        jmp !skip+
    !lower:
        lda #flyRightDown
        sta duck2Direction
        rts

    !skip:
    lda duck2X+1
	cmp #>rightBoundary
	bne !+
	    lda duck2X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftUp
        sta duck2Direction
        rts
    !lower:
        rts
}

moveDuck2DiagonalRightDown:
{
    lda #3*6
    sta duck2SpritesAnimationPointer

    jsr Duck2Down
    jsr Duck2Down
    jsr Duck2Right
    
    lda duck2Y
	cmp #lowerBoundary	
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyRightUp
        sta duck2Direction
        rts
    !lower:
    
    lda duck2X+1
	cmp #>rightBoundary
	bne !+
	    lda duck2X
	    cmp #<rightBoundary
	!:
    bcc !lower+
    bne !higher+    

    !higher:
        lda #flyLeftDown
        sta duck2Direction
        rts
    !lower:
        rts
}

Duck2Left:
{
    sec
    lda duck2X
    sbc duckMoveSpeed
    sta duck2X
    lda duck2X+1
    sbc #0
    sta duck2X+1
    rts
}

Duck2Right:
{
    clc
    lda duck2X
    adc duckMoveSpeed
    sta duck2X
    lda duck2X+1
    adc #0
    sta duck2X+1
    rts
}

Duck2Up:
{
    sec
    lda duck2Y
    sbc duckMoveSpeed
    sta duck2Y
    rts
}

Duck2Down:
{
    clc
    lda duck2Y
    adc duckMoveSpeed
    sta duck2Y
    rts
}