//	inspired by this post 
// 	https://codebase64.org/doku.php?id=base:joystick_input_handling
Joystick:
{
	pressedBit:	.byte 0 

	.label UP = 0
	.label DOWN = 1
	.label LEFT = 2
	.label RIGHT = 3
	.label FIRE = 4

	Reset:
	{
		ldx #$00 
		lda #$ff 
	!:
		sta data,x 
		inx 
		cpx #8 
		bne !-
		rts
	}
	
	Poll:
	{
		//	PORT 2
		ldy $dc01
		tya 
		lsr       
		ror data+UP
		lsr       	
		ror data+DOWN
		lsr
		ror data+LEFT
		lsr
		ror data+RIGHT
		lsr
		ror data+FIRE
		rts	
	}

	//	where X = button type 
	Pressed:
	{
		lda data,x 
		sta pressedBit
		lda #%11111111
		bit pressedBit
		bmi noaction
		bvc noaction

		lda #$00
		rts
	noaction:		
		lda #$01
		rts
	}

	//	where X = button type 
	//	if touched currently
	Held:
	{
		lda data,x 
		and #1
		rts
	}
	data:		.fill 8,0
}