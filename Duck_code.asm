#importonce 

#import "Sprites_code.asm"
#import "SoundFx_code.asm"

*=* "[CODE] Duck common code"

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

.var upperBoundary = 50
.var lowerBoundary = 150
.var leftBoundary = 30
.var rightBoundary = 295

rndDirectionPointer: .byte 0
rndDirection: 
    .for (var i=0; i< 128; i++)
    {
        .var d1 = round(random()*5)
        .var d2 = d1 - 2
        .byte d1, abs(d2)
    }
    

rndXPositionPointer: .byte 0
rndXPositions:
    .for (var i=0; i< 128; i++)
    {
        .var x1 = 44+round(random()*211)
        .var x2 = x1-75
        .if (x2 < 44)
            .eval x2 = 250
        .byte x1, x2
    }

rndQuackPointer: .byte 0
rndQuacks:
    .for (var i=0; i< 255; i++)
    {
        .var q = round(random()*15)        
        .byte q
    }

duck1OnTheGround: .byte 0
duck2OnTheGround: .byte 0
areAllDucksOnTheGround:
{
    lda duck1OnTheGround
	beq !++
		lda duck2OnTheGround
		beq !+
		    jsr playSmile
			lda #ClearWith2Ducks
			sta gameState
		!:
	!:
    rts
}