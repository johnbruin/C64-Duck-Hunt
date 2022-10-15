#import "Sprites_common_code.asm"

*=* "[CODE] Duck code"

initDuck1:
{
    ldx rndYPositionPointer            
    lda rndYPositions,x
    sta duck1Y
    inc rndYPositionPointer

    lda #0
    sta duck1X
    sta duck1X+1

    rts
}

duck1Sprite: .byte 1
duck1SpriteOverlay: .byte 1+overlay_distance
duck1X: .word $0000
duck1Y: .byte 100
duck1IsDead: .byte 0
duck1IsShot: .byte 0
showDuck1:
{
    jsr hide_sprites
    
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

    lda duck1SpriteOverlay    
    clc
    adc #(>spriteMemory<<2)	
    sta SPRITEPOINTER+1

    lda duck1Sprite
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

            lda #0
            sta duck1IsDead
            lda #1
            sta duck1Sprite
            lda #1+overlay_distance
            sta duck1SpriteOverlay            
        !:
        jmp !isDeadOrIsShot+
    !:

    lda duck1IsShot
    bne !isDeadOrIsShot+

    clc
    lda duck1X
    adc #1
    sta duck1X
    lda duck1X+1
    adc #0
    sta duck1X+1
    
    lda duck1X+1
	cmp #$01
	bne !+
	    lda duck1X
	    cmp #$90
	!:
    bcc !lower+
    bne !higher+    

    !higher:
    lda #roundLost
    sta gameState 
    jsr initDuck1
    rts   
    
    !lower:

    !isDeadOrIsShot:
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
            jmp !skip+
        !:
        inc duck1Sprite
        inc duck1SpriteOverlay
        lda duck1IsDead
        beq !+

            lda duck1Sprite        
            cmp #4
            bne !+
                lda #5
                sta duck1Sprite
                lda #5+overlay_distance
                sta duck1SpriteOverlay
                jmp !skip+
            !:  
            
            lda duck1Sprite        
            cmp #5
            bne !+
                lda #6
                sta duck1Sprite
                lda #6+overlay_distance
                sta duck1SpriteOverlay
                jmp !skip+
            !: 
            
            lda duck1Sprite        
            cmp #7
            bne !+
                lda #5
                sta duck1Sprite
                lda #5+overlay_distance
                sta duck1SpriteOverlay
                jmp !skip+
            !: 
        !:
        lda duck1Sprite        
        cmp #4
        bne !+
            lda #1
            sta duck1Sprite
            lda #1+overlay_distance
            sta duck1SpriteOverlay
        !:

        !skip:
        lda #0
        sta duck1AnimSpeed
    !skipAnimation:
    inc duck1AnimSpeed
    rts
}

rndYPositionPointer: .byte 0
rndYPositions:
    .fill $ff, 40+round(random()*110)