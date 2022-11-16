#importonce 

.enum 
{
	 FlyUp   
	,FlyLeftUp
	,FlyRightUp
	,FlyDiagonalLeftUp
	,FlyDiagonalRightUp
	,FlyLeftDown
	,FlyRightDown    
	,FlyDown 
}

#import "Duck1.asm"
#import "Duck2.asm"
#import "Game.asm"
#import "Round.asm"
#import "Sprites.asm"
#import "SoundFx.asm"
#import "Score.asm"
#import "Text.asm"

*=* "[CODE] Duck common code"

Duck:
{
    PlayWith1Duck: .byte 0
    MoveSpeed: .byte 2

    Sprites:
    .byte 1, 3, 2, 1, 3, 2          //0=right
    .byte 40, 42, 41, 40, 42, 41    //1=left
    .byte 47, 49, 48, 47, 49, 48    //2=diagonal left
    .byte 44, 46, 45, 44, 46, 45    //3=diagonal right
    .byte 50, 52, 51, 50, 52, 51    //4=up
    .byte 4, 4, 4, 4, 4, 4          //5=dead right
    .byte 43, 43, 43, 43, 43, 43    //6=dead left
    .byte 5, 6, 5, 6, 5, 6          //7=falling

    .label UpperBoundary = 50
    .label LowerBoundary = 150
    .label LeftBoundary = 30
    .label RightBoundary = 295

    .label UpperBoundary2 = UpperBoundary+21
    .label LowerBoundary2 = LowerBoundary-21
    .label LeftBoundary2 = LeftBoundary+24
    .label RightBoundary2 = RightBoundary-24

    RndDirectionPointer: .byte 0
    RndDirection: 
        .for (var i=0; i<128; i++)
        {
            .var d1 = round(random()*5)
            .var d2 = d1 - 2
            .byte d1, abs(d2)
        }
        

    RndXPositionPointer: .byte 0
    RndXPositions:
        .for (var i=0; i<128; i++)
        {
            .var x1 = 44+round(random()*211)
            .var x2 = x1-75
            .if (x2 < 44)
                .eval x2 = 250
            .byte x1, x2
        }

    RndMovementsPointer: .byte 0
    RndMovements:
        .for (var i=0; i<=255; i++)
        {
            .var m = round(random()*100)        
            .if (m<=6)
            {
                .byte m
            }
            else
            {
                .byte $ff
            }
        }

    AreAllDucksOnTheGround:
    {
        lda PlayWith1Duck
        bne !only1Duck+
            lda Duck1.OnTheGround
            beq !++
                jsr Text.Hide
                jsr SoundFx.Smile
                lda #ClearWith1Duck
                sta Game.State 
                rts
            !:
        !only1Duck:

        lda Duck1.OnTheGround
        beq !++
            lda Duck2.OnTheGround
            beq !+
                jsr Text.Hide
                jsr SoundFx.Smile
                lda #ClearWith2Ducks
                sta Game.State
                rts
            !:
        !:
        rts
    }

    FlashDuckHits:
    {
        ldx Duck1.Number
        lda Round.Hits,x
        cmp #1        
        beq !++
            cmp #0
            bne !+
                lda #2
                sta Round.Hits,x
                jmp !++
            !: 
            lda #0
            sta Round.Hits,x
        !:
        jsr Score.PrintDuckHit

        lda PlayWith1Duck
        beq !only1Duck+
            ldx Duck2.Number
            lda Round.Hits,x
            cmp #1        
            beq !++
                cmp #0
                bne !+
                    lda #2
                    sta Round.Hits,x
                    jmp !++
                !: 
                lda #0
                sta Round.Hits,x
            !:
            jsr Score.PrintDuckHit
        !only1Duck:
        
        rts
    }
}