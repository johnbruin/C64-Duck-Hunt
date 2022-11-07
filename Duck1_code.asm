#importonce 

#import "Duck_code.asm"
#import "Joystick_code.asm"

*=$8000 "[CODE] Duck1 code"

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

duck1ScoreX: .word $0000
duck1ScoreY: .byte 0
showScoreDuck1:
{        
    // sprite priority to front    
    lda #%10011110
    sta $d01b

    // Make sure no sprites are x- or y-expanded.    
    sta $d017
    sta $d01d

    lda #WHITE
    sta $d027+5

    ldx roundNumber
    dex
    ldy hitScoreRound,x  
    lda hitsThisSet
    cmp #2
    bne !+
        iny
    !:
    lda scoreSprites,y
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+5
    
    lda duck1ScoreX
    sta spriteXPositions.lo+5

    lda duck1ScoreX+1
    sta spriteXPositions.hi+5

    lda duck1ScoreY
    sta spriteYPositions+5

    :sprite_set_xy_positions(5)
    :sprite_enable(5)
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
        jsr showScoreDuck1
    !:

    lda duck1IsDead
    beq !+
        lda #7*6
        sta duck1SpritesAnimationPointer
        jsr showScoreDuck1
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
            :sprite_disable(1)
            :sprite_disable(2)
            :sprite_disable(5)  
            jmp !duckisdead+
        !:
        inc duck1Y   
        inc duck1Y 
    !duckisdead:
    
    lda duck1AnimSpeed
    cmp #8
    bne !skipAnimation+  

        jsr flashDuckHits

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

moveDuck1:
{
    lda playWith1Duck
    bne !only1Duck+
        jsr getJoystick2Input
        beq !+
            jsr ChangeMovementDuck1
            jmp !skip+
        !:
        lda #15
        sta changeMovementCounterDuck1        
    !only1Duck:    
    jsr ChangeMovementDuck1
    !skip:

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
    cmp #flyDiagonalRightUp
    bne !+
        jsr moveDuck1DiagonalRightUp
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

check:
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
	cmp #5	
    bcc !lower+
    bne !higher+    

    !higher:
        rts
    !lower:
        jsr playLaugh
        jsr hideText
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

check:
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
    
check:
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
        lda #flyRightDown
        sta duck1Direction
        rts
}

moveDuck1LeftDown:
{
    lda #1*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Down
    jsr Duck1Left

check:
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
        lda #flyDiagonalRightUp
        sta duck1Direction
        rts
}

moveDuck1RightUp:
{
    lda #0*6
    sta duck1SpritesAnimationPointer

    jsr Duck1Up
    jsr Duck1Right

check:
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
        lda #flyLeftDown
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

check:
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
        lda #flyLeftUp
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

check:    
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

check:  
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
    sbc duckMoveSpeed
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
    adc duckMoveSpeed
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
    sbc duckMoveSpeed
    sta duck1Y
    rts
}

Duck1Down:
{
    clc
    lda duck1Y
    adc duckMoveSpeed
    sta duck1Y
    rts
}

changeMovementCounterDuck1: .byte 15
ChangeMovementDuck1:
{
    lda changeMovementCounterDuck1
    bne !changeMovement+
        inc rndMovementsPointer
        ldx rndMovementsPointer
        lda rndMovements,x
        cmp #$ff
        beq !+
            sta duck1Direction
        !:
        lda #15
        sta changeMovementCounterDuck1
    !changeMovement:
    dec changeMovementCounterDuck1
    rts
}

isJoystick2Input: .byte 0
getJoystick2Input:
{
    lda #1
    sta isJoystick2Input

	jsr Joystick2.Poll

	ldx #Joystick2.UP
	jsr Joystick2.Held
	bne !+++
        ldx #Joystick2.LEFT
	    jsr Joystick2.Held
	    bne !+
		    lda #flyDiagonalLeftUp
            sta duck1Direction
            jsr moveDuck1DiagonalLeftUp.check
            rts
	    !:
    	ldx #Joystick2.RIGHT
	    jsr Joystick2.Held
	    bne !+
		    lda #flyDiagonalRightUp
            sta duck1Direction
            jsr moveDuck1DiagonalRightUp.check
            rts
	    !:
		lda #flyUp
        sta duck1Direction
        jsr moveDuck1Up.check
        rts
	!:

	ldx #Joystick2.DOWN
	jsr Joystick2.Held
	bne !+++
        ldx #Joystick2.LEFT
	    jsr Joystick2.Held
	    bne !+
		    lda #flyLeftDown
            sta duck1Direction
            jsr moveDuck1LeftDown.check
            rts
	    !:
    	ldx #Joystick2.RIGHT
	    jsr Joystick2.Held
	    bne !+
		    lda #flyRightDown
            sta duck1Direction
            jsr moveDuck1RightDown.check
            rts
	    !:
		lda #flyDown
        sta duck1Direction
        jsr moveDuck1Down.check
        rts
	!:

	ldx #Joystick2.LEFT
	jsr Joystick2.Held
	bne !+
		lda #flyLeftDown
        sta duck1Direction
        jsr moveDuck1LeftDown.check
        rts
	!:

	ldx #Joystick2.RIGHT
	jsr Joystick2.Held
	bne !+
		lda #flyRightDown
        sta duck1Direction
        jsr moveDuck1RightDown.check
        rts
	!:

	ldx #Joystick2.FIRE
	jsr Joystick2.Held
	bne !+
		jsr playQuack
        rts
	!:

    lda #0
    sta isJoystick2Input

	rts
}