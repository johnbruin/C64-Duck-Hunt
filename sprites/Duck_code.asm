#import "Sprites_common_code.asm"

*=* "[CODE] Duck code"

initDuck1:
{
    lda #0
    sta duck1IsDead
    sta duck1IsShot
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

duckSprites:
.byte 1, 3, 2, 1, 3, 2          //0=right
.byte 40, 42, 41, 40, 42, 41    //1=left
.byte 47, 49, 48, 47, 49, 48    //2=diagonal left
.byte 44, 46, 45, 44, 46, 45    //3=diagonal right
.byte 50, 52, 51, 50, 52, 51    //4=up
.byte 4, 4, 4, 4, 4, 4          //5=dead right
.byte 43, 43, 43, 43, 43, 43    //6=dead left
.byte 5, 6, 5, 6, 5, 6          //7=falling

.enum 
{
     flyUp   
    ,flyLeftUp
    ,flyRightUp
    ,flyDiagonalLeftUp
    ,flyDiagonalRightUp
    ,flyDown    
    ,flyLeftDown
    ,flyRightDown    
    ,flyDiagonalLeftDown
    ,flyDiagonalRightDown
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
    :sprite_disable(3)
    :sprite_disable(4)
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
    lda #%00000100
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
    beq !++
        inc duck1Y   
        inc duck1Y     
        lda duck1Y
        cmp #170
        bcc !+
            jsr initDuck1            
            lda #roundClearWith1Duck
            sta gameState
        !:
    !:

    lda duck1AnimSpeed
    cmp #8
    bne !skipAnimation+        
        :sprite_disable(0)

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

.var upperBoundary = 50
.var lowerBoundary = 150
.var leftBoundary = 30
.var rightBoundary = 295
duck1MoveSpeed: .byte 0
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
    cmp #flyAway
    bne !+
        jsr moveFlyAway
        rts
    !:

    lda duck1Direction
    cmp #flyRightUp
    bne !+
        jsr moveRightUp
    !:

    lda duck1Direction
    cmp #flyRightDown
    bne !+
        jsr moveRightDown
    !:

    lda duck1Direction
    cmp #flyLeftUp
    bne !+
        jsr moveLeftUp
    !:

    lda duck1Direction
    cmp #flyLeftDown
    bne !+
        jsr moveLeftDown
    !:

    lda duck1Direction
    cmp #flyDiagonalLeftUp
    bne !+
        jsr moveDiagonalLeftUp
    !:

    lda duck1Direction
    cmp #flyDiagonalLeftDown
    bne !+
        jsr moveDiagonalLeftDown
    !:

    lda duck1Direction
    cmp #flyDiagonalRightUp
    bne !+
        jsr moveDiagonalRightUp
    !:

    lda duck1Direction
    cmp #flyDiagonalRightDown
    bne !+
        jsr moveDiagonalRightDown
    !:

    lda duck1Direction
    cmp #flyUp
    bne !+
        jsr moveUp
    !:

    lda duck1Direction
    cmp #flyDown
    bne !+
        jsr moveDown
    !:
       
    rts
}

moveUp:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Up
    jsr Up    
    jsr Up  

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

moveFlyAway:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Up
    jsr Up
    jsr Up

    lda duck1Y
	cmp #4	
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        lda #roundLost
        sta gameState
        rts
}

moveDown:
{
    lda #4*6
    sta duck1SpritesAnimationPointer

    jsr Down
    jsr Down
    jsr Down
    jsr Down

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

moveLeftUp:
{
    lda #1*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Left
    
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

moveLeftDown:
{
    lda #1*6
    sta duck1SpritesAnimationPointer

    jsr Down
    jsr Left
    
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

moveRightUp:
{
    lda #0*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Right
    
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

moveRightDown:
{
    lda #0*6
    sta duck1SpritesAnimationPointer

    jsr Down
    jsr Right
    
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

moveDiagonalLeftUp:
{
    lda #2*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Up
    jsr Left
    
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

moveDiagonalLeftDown:
{
    lda #2*6
    sta duck1SpritesAnimationPointer

    jsr Down
    jsr Down
    jsr Left
    
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

moveDiagonalRightUp:
{
    lda #3*6
    sta duck1SpritesAnimationPointer

    jsr Up
    jsr Up
    jsr Right
    
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

moveDiagonalRightDown:
{
    lda #3*6
    sta duck1SpritesAnimationPointer

    jsr Down
    jsr Down
    jsr Right
    
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

Left:
{
    sec
    lda duck1X
    sbc #1
    sta duck1X
    lda duck1X+1
    sbc #0
    sta duck1X+1
    rts
}

Right:
{
    clc
    lda duck1X
    adc #1
    sta duck1X
    lda duck1X+1
    adc #0
    sta duck1X+1
    rts
}

Up:
{
    lda duck1MoveSpeed
    cmp #2
    bne !skipAnimation+ 
        dec duck1Y
        lda #0
        sta duck1MoveSpeed
    !skipAnimation:
    inc duck1MoveSpeed
    rts
}

Down:
{
    lda duck1MoveSpeed
    cmp #2
    bne !skipAnimation+ 
        inc duck1Y
        lda #0
        sta duck1MoveSpeed
    !skipAnimation:
    inc duck1MoveSpeed
    rts
}

rndDirectionPointer: .byte 0
rndDirection: 
    .fill $ff, round(random()*5)

rndXPositionPointer: .byte 0
rndXPositions:
    .fill $ff, 44+round(random()*211)