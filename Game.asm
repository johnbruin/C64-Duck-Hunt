#importonce

*=$8000 "[CODE] Game code"

.enum {
	 Intro
	,Playing
	,ClearWith1Duck
	,ClearWith1DuckPause
	,ClearWith2Ducks
	,ClearWith2DucksPause
	,EndRound
	,StartRound
	,GameOver
	,GameOverPause
	,NewRound
	,NewSet
	,FlyAway
	,Miss
	,PerfectRound
	,FinalRound
}

#import "Globals.asm"
#import "Crosshair.asm"
#import "Dog1.asm"
#import "Dog2.asm"
#import "Dog3.asm"
#import "Dog4.asm"
#import "Duck.asm"
#import "Round.asm"
#import "Score.asm"
#import "Set.asm"
#import "SoundFx.asm"
#import "Sprites.asm"
#import "Text.asm"

Game:
{
	State: .byte 0
	Speed: .byte 0
	Shots: .byte 3
	StartGame: .byte 0

	_wait: .byte 0
	_waitFall: .byte 10

	InitTitleScreen:
	{
		lda #2
		ldx #2		
		jsr Music.init

		jsr Sprites.Hide
		
		jsr Crosshair.Init

		jsr Joystick1.Reset
		jsr Joystick2.Reset
		ldx #0 
		!: 
			lda #CYAN
			sta $d800+(1*40),x
			sta $d800+(2*40),x
			sta $d800+(3*40),x
			sta $d800+(4*40),x
			sta $d800+(5*40),x   
			
			lda #RED
			sta $d800+(7*40),x

			lda #CYAN
			sta $d800+(8*40),x
			sta $d800+(9*40),x
			sta $d800+(10*40),x
			sta $d800+(11*40),x
			sta $d800+(12*40),x 
		
			inx
			cpx #40
		bne !-

		ldx #0 
		!:
			lda #RED
			sta $d800+(15*40),x 
			sta $d800+(17*40),x 
			
			lda #GREEN
			sta $d800+(20*40),x 

			lda #WHITE
			sta $d800+(22*40),x

			lda #PURPLE
			sta $d800+(24*40),x

			lda #0
			sta ScreenRamTitleScreen+(24*40),x

			inx
			cpx #40
		bne !-

		lda #WHITE
		sta $d800+(15*40)+9

		jsr Score.PrintHiScore

		lda #0
		sta Game.StartGame

		rts
	}

	Init:
	{
		jsr Joystick1.Reset
		jsr Joystick2.Reset

		// Char primary color
		ldx #0
		!:
			.for (var i=0; i<4; i++) {
				lda #13 	//GREEN
				sta $d800 + i*250,x
			}
			inx
		bne !-

		// Char multi color 1
		lda #BLUE
		sta $D022           

		// Char multi color 2
		lda #BLACK
		sta $D023

		lda #0
		sta Round.DuckNumber
		lda #0	
		sta Round.Number

		jsr Score.Reset

		lda #0
		sta _wait
		jsr Score.Init
		jsr Sprites.Init
		jsr Crosshair.Init
		jsr Sprites.Show
		jsr Duck1.Init
		jsr Duck2.Init

		rts
	}

	Play:
	{	
		jsr Crosshair.CheckGame
				
		lda Game.State
		
		cmp #GameOverPause
		bne !+
			lda _wait
			bne !wait+
				lda #200
				sta _wait
                lda #GameOver
                sta Game.State
				rts
			!wait:
			dec _wait
			jsr Music.play
			rts
		!:

		cmp #GameOver
		bne !+
			lda _wait
			bne !wait+
				lda #0
				sta StartGame
				jsr InitTitleScreen
				rts		
			!wait:
			dec _wait
			jsr Music.play
			jsr Dog3.Show	
			jsr Dog3.MoveUpOnly
			rts
		!:

		cmp #Intro
		bne !+
			jsr Dog4.Move
			jsr Dog4.Show
			jsr Music.play
			rts
		!:

		cmp #ClearWith1DuckPause
		bne !+
			lda _waitFall
			bne !waitFall+
                jsr SoundFx.Smile
                lda #ClearWith1Duck
                sta Game.State
				rts
			!waitFall:
			dec _waitFall
			rts
		!:

		cmp #ClearWith1Duck
		bne !+
			jsr Dog1.Show	
			jsr Dog1.Move
			jsr Music.play
			rts
		!:

		cmp #ClearWith2DucksPause
		bne !+
			lda _waitFall
			bne !waitFall+
                jsr SoundFx.Smile
                lda #ClearWith2Ducks
                sta Game.State
				rts
			!waitFall:
			dec _waitFall
			rts
		!:

		cmp #ClearWith2Ducks
		bne !+
			jsr Dog2.Show	
			jsr Dog2.Move
			jsr Music.play
			rts
		!:

		cmp #FlyAway
		bne !+		
			jsr playDucks		
			rts	
		!:

		cmp #Miss
		bne !miss+
			jsr Text.Hide
			ldx Duck1.Number
			lda Round.Hits,x
			cmp #2
			bne !+
				lda #0
				sta Round.Hits,x        
			!:
			jsr Score.PrintDuckHit
			
			lda Duck.PlayWith1Duck
			beq !only1Duck+
				ldx Duck2.Number
				lda Round.Hits,x
				cmp #2
				bne !+
					lda #0
					sta Round.Hits,x        
				!:
				jsr Score.PrintDuckHit
			!only1Duck:

			jsr Dog3.Show	
			jsr Dog3.Move
			jsr Music.play
			rts
		!miss:

		cmp #NewRound
		bne !+
			lda #$ff
			sta Round.DuckNumber

			jsr SoundFx.Reset
			jsr Score.Init

			lda #NewSet
			sta Game.State
			rts
		!:

		cmp #EndRound
		bne !+
			jsr Score.FlashHits
			jsr Music.play
			lda _wait
			bne !wait+
			    lda Round.Number
				cmp #9
				bne !finalround+
					lda #200
					sta _wait
	                jsr Score.AddFinishedScore
	                jsr Score.PrintScore
    	            jsr Score.CheckHiScore
        	        jsr Text.Finished
					lda #FinalRound
					sta Game.State
					rts
				!finalround:

				lda Round.IsPerfect
				bne !isperfect+
					lda #StartRound
					sta Game.State
					rts
				!isperfect:

				lda #200
				sta _wait
				jsr Score.AddPerfectScore
                jsr Score.PrintScore
                jsr Text.Perfect
				lda #PerfectRound
				sta Game.State
				rts
			!wait:
			dec _wait
			rts
		!:

		cmp #PerfectRound
		bne !+
			jsr Music.play
			lda _wait
			bne !wait+
				lda #StartRound
				sta Game.State
				rts
			!wait:
			dec _wait
			rts
		!:

		cmp #FinalRound
		bne !+
			jsr Music.play
			lda _wait
			bne !wait+
				lda #GameOver
				sta Game.State
				rts
			!wait:
			dec _wait
			rts
		!:


		cmp #StartRound
		bne !+
			lda #0
			sta Round.IsPerfect
			inc Round.Number	
			lda Round.Number
			jsr setDifficulty
			jsr Text.Hide
			jsr Text.RoundNumber
			jsr Dog4.Init
			jsr Score.Init
			lda #0
			ldx #0		
			jsr Music.init
			lda #Intro
			sta Game.State
			rts
		!:

		cmp #NewSet
		bne !++
			lda Round.DuckNumber
			cmp #9
			bne !+
				lda #255
				sta _wait
				jsr Score.EvalHits
				rts
			!:

			lda #10
			sta _waitFall

			lda #3
			sta Set.Shots
			jsr Score.PrintShots

			lda #0
			sta _secondsToFlyAway
			sta Set.Hits

			jsr Text.Hide

			inc Round.DuckNumber
			lda Round.DuckNumber
			sta Duck1.Number
			jsr Duck1.Init

			lda Duck.PlayWith1Duck
			beq !only1Duck+
				inc Round.DuckNumber
				lda Round.DuckNumber
				sta Duck2.Number
				jsr Duck2.Init
			!only1Duck:		
			
			jsr SoundFx.Quack

			lda #Playing
			sta Game.State
			rts
		!:
		
		cmp #Playing
		bne !+
			jsr playDucks
			jsr Score.PrintDuckHits
			rts
		!:

		rts
	}

	_slowdown: .byte 1
	_framesToFlyAway: .byte 0
	_secondsToFlyAway: .byte 0
	playDucks:
	{
		inc _framesToFlyAway
		lda _framesToFlyAway
		cmp #50
		bne !+
			inc _secondsToFlyAway
			lda #0
			sta _framesToFlyAway
		!:

		lda _secondsToFlyAway
		cmp #7
		bne !+		
			jsr Text.FlyAway
			lda #FlyAway
			sta Game.State
		!:

		lda _slowdown
		cmp #0
		bne !+
			jsr Duck1.Show
			jsr Duck1.Move
			jsr Duck1.Animate

			lda Duck.PlayWith1Duck
			beq !only1Duck+
				jsr Duck2.Show
				jsr Duck2.Move
				jsr Duck2.Animate
			!only1Duck:

			lda Game.Speed
			sta _slowdown
		!:
		dec _slowdown
		jsr Duck.AreAllDucksOnTheGround
		rts
	}

	setDifficulty:
	{
		ldx Round.Number
		dex
		lda _hitsNeededRound,x
		sta Round.HitsNeeded

		lda _gameSpeedRound,x
		sta Speed

		lda _duckMoveSpeedRound,x
		sta Duck.MoveSpeed

		rts
	}

	_hitsNeededRound:
	.byte 6,6,7,7,8,8,9,9,10

	_gameSpeedRound:
	.byte 1,1,1,1,1,1,1,1,1

	_duckMoveSpeedRound:
	.byte 1,1,2,2,2,2,3,3,3
}