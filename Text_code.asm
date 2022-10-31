#importonce

#import "globals.asm"

*=* "[CODE] Text code"

numberMappings:
.text "0123456789"

gameText1:
.byte 0,0,0,0,0,0,0,0,0,0,0
gameText2:
.byte 0,0,0,0,0,0,0,0,0,0,0
gameText3:
.byte 0,0,0,0,0,0,0,0,0,0,0

replaceChar:
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

roundText: .text "  ROUND   "
roundNumberText: .byte 0
showRoundText:
{
	ldx #0 
	!:  
		lda roundText,x
		sta gameText1,x
		inx
		cpx #10
	bne !-
	
	lda roundNumberText
	sta gameText3+4
	sta screenRam+(22*40)+3
	jsr showText
	rts
}

gameOverText: .text "GAME OVER "
showGameOverText:
{
	ldx #0 
	!:  
		lda gameOverText,x
		sta gameText1,x
		inx
		cpx #10
	bne !-
		
	jsr showText
	
	rts
}

goodText: .text "   GOOD!  "
showGoodText:
{
	ldx #0 
	!:  
		lda goodText,x
		sta gameText1,x
		inx
		cpx #10
	bne !-
		
	jsr showText
	
	rts
}

perfectText1: .text "PERFECT!! "
perfectText3: .text " 10000    "
showPerfectText:
{
	ldx #0 
	!:  
		lda perfectText1,x
		sta gameText1,x
		lda perfectText3,x
		sta gameText3,x
		inx
		cpx #10
	bne !-
		
	jsr showText
	
	rts
}

finishedText1: .text "FINISHED!!"
finishedText3: .text " 100000   "
showFinishedText:
{
	ldx #0 
	!:  
		lda finishedText1,x
		sta gameText1,x
		lda finishedText3,x
		sta gameText3,x
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

		lda gameText1,x
		jsr replaceChar
		sta screenRam+(4*40)+16,x		
				
		lda gameText2,x
		jsr replaceChar	
		sta screenRam+(5*40)+16,x

		lda gameText3,x
		jsr replaceChar		
		sta screenRam+(6*40)+16,x
		
		inx
		cpx #10
	bne !-
	rts
}

hideText:
{
	ldx #0 
	!: 
        lda #0
        sta gameText1,x
		sta gameText2,x
		sta gameText3,x
		sta screenRam+(4*40)+16,x
		sta screenRam+(5*40)+16,x
        sta screenRam+(6*40)+16,x
		inx
		cpx #10
	bne !-
	rts
}