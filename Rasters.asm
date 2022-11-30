//64tass format
//taken from s451-1 intro, stabilized and NTSC support added
//without delay table-values

	.pc = $0801 "[CODE] Basic Program Start"
	:BasicUpstart(start)			

    .pc = $080e "[CODE] Main Program"

start:

	sei		
loop:
	lda #66-32		//must start on a badline. ($x2 or $xA)
    !:	cmp $d012
	bne !-
	cmp ($00),y
	ldx #$00
	ldy #$01
	nop			//NTSC : change this byte to $d1, becomes cmp ($ea),y
br1:
	nop
	cmp ($00,x)
br2:
	lda #$00		//NTSC : change this to lda $00,x
	cmp ($00,x)
		
	inx
	lda col1,x
	sta val1+1
	lda col2,x
	sta val2+1
	dex

	lda col1,x
	sta $d021
	sta $d020
	lda col2,x
	sta $d022
	inx
	dey
	bne br1
val1:
	lda #$00		//badline code. Y=0
	sta $d021		//NTSC : change this to sta$d021,y	
	sta $d020		//NTSC : change this to sta$d020,y
val2:
	lda #$00		
	sta $d022,y
	nop
	nop
	ldy #$07
	inx
	cpx #$22		//this value should be $x2 or $xA
	bne br2
	jmp loop
		
	* = $1100		//test colors - new page = to avoid +1 cycle
		
col1:
	.byte $01,$00,$01,$00,$01,$00,$01,$00
	.byte $01,$00,$01,$00,$01,$00,$01,$00
	.byte $01,$00,$01,$00,$01,$00,$01,$00
	.byte $01,$00,$01,$00,$01,$00,$01,$00
	.byte $01,$00

col2:
	.byte $02,$00,$02,$00,$02,$00,$02,$00
	.byte $02,$00,$02,$00,$02,$00,$02,$00
	.byte $02,$00,$02,$00,$02,$00,$02,$00
	.byte $02,$00,$02,$00,$02,$00,$02,$00
	.byte $02,$00