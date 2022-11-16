#importonce

#import "Globals.asm"
#import "Round.asm"

*=* "[CODE] Text code"

Text:
{
	_numberMappings:
	.text "0123456789"

	_gameText1:
	.byte 0,0,0,0,0,0,0,0,0,0,0
	_gameText2:
	.byte 0,0,0,0,0,0,0,0,0,0,0
	_gameText3:
	.byte 0,0,0,0,0,0,0,0,0,0,0

	ReplaceChar:
	{
		cmp #'0'
		bne !replace+
			lda #48
			rts
		!replace:

		cmp #'1'
		bne !replace+
			lda #49
			rts
		!replace:

		cmp #'2'
		bne !replace+
			lda #50
			rts
		!replace:

		cmp #'3'
		bne !replace+
			lda #51
			rts
		!replace:

		cmp #'4'
		bne !replace+
			lda #52
			rts
		!replace:

		cmp #'5'
		bne !replace+
			lda #53
			rts
		!replace:

		cmp #'6'
		bne !replace+
			lda #54
			rts
		!replace:

		cmp #'7'
		bne !replace+
			lda #55
			rts
		!replace:

		cmp #'8'
		bne !replace+
			lda #56
			rts
		!replace:

		cmp #'9'
		bne !replace+
			lda #57
			rts
		!replace:

		cmp #' '
		bne !replace+
			lda #0
			rts
		!replace:

		cmp #'!'
		bne !replace+
			lda #180
			rts
		!replace:

		cmp #0
		bne !replace+
			rts
		!replace:

		clc
		adc #(154-'A')

		rts
	}

	_roundText: .text "  ROUND   "	
	RoundNumber:
	{
		ldx #0 
		!:  
			lda _roundText,x
			sta _gameText1,x
			inx
			cpx #10
		bne !-
		
		ldx Round.Number
		lda _numberMappings,x
		sta _gameText3+4
		sta ScreenRam+(22*40)+3
		jsr showText
		rts
	}

	_gameOverText: .text "GAME OVER "
	GameOver:
	{
		ldx #0 
		!:  
			lda _gameOverText,x
			sta _gameText1,x
			inx
			cpx #10
		bne !-
			
		jsr showText
		
		rts
	}

	_goodText: .text "  GOOD!   "
	Good:
	{
		ldx #0 
		!:  
			lda _goodText,x
			sta _gameText2,x
			inx
			cpx #10
		bne !-
			
		jsr showText
		
		rts
	}

	_flyAwayText: .text " FLY AWAY "
	FlyAway:
	{
		ldx #0 
		!:  
			lda _flyAwayText,x
			sta _gameText1,x
			inx
			cpx #10
		bne !-
			
		jsr showText
		
		rts
	}

	_perfectText1: .text "PERFECT!! "
	_perfectText3: .text " 10000    "
	Perfect:
	{
		ldx #0 
		!:  
			lda _perfectText1,x
			sta _gameText1,x
			lda _perfectText3,x
			sta _gameText3,x
			inx
			cpx #10
		bne !-
			
		jsr showText
		
		rts
	}

	_finishedText1: .text "FINISHED!!"
	_finishedText3: .text " 100000   "
	Finished:
	{
		ldx #0 
		!:  
			lda _finishedText1,x
			sta _gameText1,x
			lda _finishedText3,x
			sta _gameText3,x
			inx
			cpx #10
		bne !-
			
		jsr showText
		
		rts
	}

	showText:
	{
		ldx #0 
		!:   
			lda #WHITE
			sta $d800+(4*40)+16,x
			sta $d800+(5*40)+16,x
			sta $d800+(6*40)+16,x

			lda _gameText1,x
			jsr ReplaceChar
			sta ScreenRam+(4*40)+16,x		
					
			lda _gameText2,x
			jsr ReplaceChar	
			sta ScreenRam+(5*40)+16,x

			lda _gameText3,x
			jsr ReplaceChar		
			sta ScreenRam+(6*40)+16,x
			
			inx
			cpx #10
		bne !-
		rts
	}

	Hide:
	{
		ldx #0 
		!: 
			lda #0
			sta _gameText1,x
			sta _gameText2,x
			sta _gameText3,x
			sta ScreenRam+(4*40)+16,x
			sta ScreenRam+(5*40)+16,x
			sta ScreenRam+(6*40)+16,x
			inx
			cpx #10
		bne !-
		rts
	}
}