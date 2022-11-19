#importonce 

#import "Duck.asm"
#import "Game.asm"
#import "Joystick.asm"
#import "Keyboard.asm"
#import "Mouse.asm"
#import "Score.asm"
#import "SoundFx.asm"
#import "Sprites.asm"
#import "Text.asm"

*=* "[CODE] Crosshair code"

Crosshair:
{
	//multiplies fac1 and fac2 and put results in x (low-byte) and a (hi-byte)  
	.var fac1 = $58
	.var fac2 = $59

	_isJoystick: .byte 1
	_isMouse: .byte 0
	_lowBoundaryX: .word 0
	_highBoundaryX: .word 0
	_lowBoundaryY: .byte 0
	_highBoundaryY: .byte 0

	Init:
	{
		lda #366/2
		sta _x
		lda #0
		sta _x+1
		lda #254/2
		sta _y

		lda $d014
		sta _lpyOld

		rts
	}

	_x: .word $0080
	_y: .byte 100
	_trigger: .byte 1
	_showX: .word $0080
	_showY: .byte 100
	_isShotFired: .byte 0
	show:
	{  
		lda _x
		sta _showX
		lda _x+1
		sta _showX+1
		lda _y
		sta _showY

		// set sprite colors
		lda #LIGHT_GRAY
		sta $d027

		// x- and y-expand the right sprites
		lda #%11111110 
		sta $d017
		sta $d01d
		
		lda Game.StartGame
		bne !+
			lda #0
			clc
			adc #(>SpriteMemory<<2)	
			sta Sprites.SPRITEPOINTER_TITLE
			jmp !skip+
		!:
		
		lda #0
		clc
		adc #(>SpriteMemory<<2)	
		sta Sprites.SPRITEPOINTER

		!skip:
		:sprite_enable(0)

		lda _showX
		sta Sprites.XPositions.lo+0

		lda _showX+1
		sta Sprites.XPositions.hi+0

		lda _showY
		sta Sprites.YPositions+0

		:sprite_set_xy_positions(0)

		lda _trigger
		bne !+
			lda #WHITE
			sta $d027
		!:
		rts
	}

	getLightGunInput:
	{
		lda $d41a
		sta _trigger
		cmp #$ff
		beq !+
			lda #0		
			sta _trigger
		!:
		
		lda $d013		//LPX
		sta fac1		//multiply LPX by 2
		lda #2
		sta fac2
		jsr multiply
		stx _x	
		sta _x+1

		sec				//substract 30+12 (half a sprite width)
		lda _x
		sbc #30+12
		sta _x
		lda _x+1
		sbc #0
		sta _x+1
		
		lda $d014		//LPY
		sta _y

		rts
	}

	_lpyOld: .byte 0
	getLightGunInputTitle:
	{
		lda $d41a
		sta _trigger
		cmp #$ff
		beq !+
			lda #0		
			sta _trigger
			sta _isJoystick			
			sta _isMouse
		!:

		lda $d014		//LPY
		cmp _lpyOld
		beq !+
			sta _y
			sta _lpyOld
			lda #0
			sta _isJoystick			
			sta _isMouse
		!:
		rts
	}

	getJoystick1Input:
	{
		jsr Joystick1.Poll

		ldx #Joystick1.UP
		jsr Joystick1.Held
		bne !+
			dec _y
			dec _y
		!:

		ldx #Joystick1.DOWN
		jsr Joystick1.Held
		bne !+
			inc _y
			inc _y
		!:

		ldx #Joystick1.LEFT
		jsr Joystick1.Held
		bne !+
			sec
			lda _x
			sbc #2
			sta _x
			lda _x+1
			sbc #0
			sta _x+1
		!:

		ldx #Joystick1.RIGHT
		jsr Joystick1.Held
		bne !+
			clc
			lda _x
			adc #2
			sta _x
			lda _x+1
			adc #0
			sta _x+1
		!:

		ldx #Joystick1.FIRE
		jsr Joystick1.Held
		bne !+
			lda #0
			sta _trigger
			ldy #1
		!:

		rts
	}

	getMouseInput:
	{
		lda $d41a
		sta _trigger
		bne !+
			rts
		!:

		lda Mouse.potx
		cmp #$ff
		bne !+
			lda Mouse.poty
			cmp #$ff
			bne !+
				lda #0
				sta _isMouse
				rts
			!:		
		!:

		lda #1
		sta _isMouse
		lda #0
		sta _isJoystick

		jsr Mouse.cbm1351_poll 

		jsr Joystick1.Poll
		ldx #Joystick1.FIRE
		jsr Joystick1.Held
		bne !+
			lda #0
			sta _trigger
		!:

		lda Mouse.pos_x_lo
		sta _x
		lda Mouse.pos_x_hi
		sta _x+1
		lda Mouse.pos_y_lo
		sta _y
		rts
	}

	CheckTitleScreen:
	{
		jsr Sprites.Hide
		
		jsr getMouseInput
		lda _isMouse
		bne !ismouse+	
			lda #1
			sta _isJoystick
			jsr getJoystick1Input
			cpy #$ff
			bne !+
				jsr getLightGunInputTitle
			!:
		!ismouse:

		jsr Crosshair.show

		lda _y
		cmp #170	
		bcc !lower+
		bne !higher+
		!lower:
			lda #BLACK
			sta $d800+(17*40)+9
			lda #WHITE
			sta $d800+(15*40)+9
			lda #0
			sta Duck.PlayWith1Duck
			jmp !+    
		!higher:
			lda #BLACK
			sta $d800+(15*40)+9
			lda #WHITE
			sta $d800+(17*40)+9
			lda #1
			sta Duck.PlayWith1Duck
			jmp !+
		!:

		lda _trigger
		bne !+
			lda #1		
			sta Game.StartGame
		!:

		rts
	}

	CheckGame:
	{
		lda _isMouse
		bne !ismouse+
			jsr Keyboard.ReadKeyb
			jsr Keyboard.GetKey
			cmp #03 //runstop
			bne !+
				lda #0	
				sta Game.StartGame
				rts	
			!:
		!ismouse:

		lda Game.State
		cmp #Playing
		beq !+
			:sprite_disable(0)		
			rts
		!:

		lda #1
		sta _trigger
		lda _isJoystick
		beq !+
			jsr getJoystick1Input
			jsr Crosshair.show
			jmp !skip+
		!:

		lda _isMouse
		beq !+
			jsr getMouseInput
			jsr Crosshair.show
			jmp !skip+
		!:

		jsr getLightGunInput
		
		!skip:

		lda _isShotFired
		bne !shotwasfired+	
			
			lda _isJoystick
			bne !isjoystick+
				lda _isMouse
				bne !+
					:sprite_disable(0)	
				!:		
			!isjoystick:

			lda _trigger
			bne !trigger+
				lda #10
				sta _isShotFired
				
				lda Set.Shots
				beq !+
					dec Set.Shots
					jsr SoundFx.Shot
				!:
				jsr Score.PrintShots

				lda Duck1.IsShot
				bne !+
					jsr isHitDuck1
				!:

				bne !trigger+ // a=1 when duck1 was hit
				
				lda Duck.PlayWith1Duck
				beq !only1Duck+
					lda Duck2.IsShot
						bne !+
							jsr isHitDuck2
						!:
					!:
				!only1Duck:
			!trigger:
			jmp !skip+
		!shotwasfired:
		dec _isShotFired
		!skip:
		rts
	}

	isHitDuck1:
	{
		sec
		lda _y
		sbc #11*2
		sta _lowBoundaryY

		clc
		lda _y
		adc #11
		sta _highBoundaryY
		
		sec
		lda _x
		sbc #12*2
		sta _lowBoundaryX
		lda _x+1
		sbc #0
		sta _lowBoundaryX+1

		clc
		lda _x
		adc #12*2
		sta _highBoundaryX
		lda _x+1
		adc #0
		sta _highBoundaryX+1

		//duck1Y < crosshairYLowBoundary?
		lda Duck1.Y
		cmp _lowBoundaryY
		bcc !nohit+

		//duck1Y >= crosshairYHighBoundary?
		lda Duck1.Y
		cmp _highBoundaryY
		bcs !nohit+
		
		//duck1X < crosshairXLowBoundary?
		lda Duck1.X+1
		cmp _lowBoundaryX+1
		bne !+
			lda Duck1.X
			cmp _lowBoundaryX
		!:
		bcc !nohit+ //lower

		//duck1X >= crosshairXHighBoundary?
		lda Duck1.X+1
		cmp _highBoundaryX+1
		bne !+
			lda Duck1.X
			cmp _highBoundaryX
		!:
		bcc !lower+
		bne !nohit+ //higher
		!lower:
		
		!hit:
			jsr SoundFx.Hit

			inc Set.Hits

			jsr Duck1.InitAnimation
			
			lda #1
			sta Duck1.IsShot
			jsr Score.AddScore
			jsr Score.PrintScore

			lda #1
			ldx Duck1.Number
			sta Round.Hits,x
			jsr Score.PrintDuckHits

			lda _x
			sta Duck1.ScoreX
			lda _x+1
			sta Duck1.ScoreX+1
			lda _y
			sta Duck1.ScoreY

			rts

		!nohit:
			jsr Crosshair.show

			jsr areWeOutOfShots

			lda #0
			rts
	}

	isHitDuck2:
	{
		sec
		lda _y
		sbc #11*2
		sta _lowBoundaryY

		clc
		lda _y
		adc #11
		sta _highBoundaryY
		
		sec
		lda _x
		sbc #12*2
		sta _lowBoundaryX
		lda _x+1
		sbc #0
		sta _lowBoundaryX+1

		clc
		lda _x
		adc #12*2
		sta _highBoundaryX
		lda _x+1
		adc #0
		sta _highBoundaryX+1

		//duck2Y < crosshairYLowBoundary?
		lda Duck2.Y
		cmp _lowBoundaryY
		bcc !nohit+

		//duck2Y >= crosshairYHighBoundary?
		lda Duck2.Y
		cmp _highBoundaryY
		bcs !nohit+
		
		//duck2X < crosshairXLowBoundary?
		lda Duck2.X+1
		cmp _lowBoundaryX+1
		bne !+
			lda Duck2.X
			cmp _lowBoundaryX
		!:
		bcc !nohit+ //lower

		//duck2X >= crosshairXHighBoundary?
		lda Duck2.X+1
		cmp _highBoundaryX+1
		bne !+
			lda Duck2.X
			cmp _highBoundaryX
		!:
		bcc !lower+
		bne !nohit+ //higher
		!lower:

		!hit:
			jsr SoundFx.Hit

			inc Set.Hits

			jsr Duck2.InitAnimation

			lda #1
			sta Duck2.IsShot
			jsr Score.AddScore
			jsr Score.PrintScore

			lda #1
			ldx Duck2.Number
			sta Round.Hits,x
			jsr Score.PrintDuckHits

			lda _x
			sta Duck2.ScoreX
			lda _x+1
			sta Duck2.ScoreX+1
			lda _y
			sta Duck2.ScoreY

			rts

		!nohit:
			jsr Crosshair.show

			jsr areWeOutOfShots

			rts
	}

	//multiplies FAC1 and FAC2 and put results in x (low-byte) and a (hi-byte)  
	// A*256 + X = FAC1 * FAC2
	multiply:
	{
		lda #0
		ldx #8
		clc

		m0:
		bcc m1
		clc
		adc fac2

		m1:    
		ror
		ror fac1
		dex
		bpl m0
		ldx fac1
		rts
	}

	areWeOutOfShots:
	{
		lda Duck1.IsShot
		beq !duck1isshot+
			lda Duck.PlayWith1Duck
			beq !only1Duck+
				lda Duck2.IsShot
				beq !duck2isshot+
					rts
				!duck2isshot:
				lda Duck2.IsDead
				beq !duck2isdead+
					rts
				!duck2isdead:
				jmp !skip+
			!only1Duck:
			rts
		!duck1isshot:
		
		!skip:

		lda Duck1.IsDead
		beq !duck1isdead+
			lda Duck.PlayWith1Duck
			beq !only1Duck+
				lda Duck2.IsShot
				beq !duck2isshot+
					rts
				!duck2isshot:
				lda Duck2.IsDead
				beq !duck2isdead+
					rts
				!duck2isdead:
				jmp !skip+
			!only1Duck:
			rts
		!duck1isdead:

		!skip:

		lda Set.Shots
		bne !shots+
			jsr Text.FlyAway
			lda #FlyAway
			sta Game.State     	
		!shots:
		rts
	}
}