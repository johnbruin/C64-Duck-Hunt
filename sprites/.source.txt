#importonce 

.const SPRITEPOINTER = $0400+$03f8

init_sprites:
    // Make sure no sprites are x- or y-expanded.
    lda #%00000110
    sta $d017
    sta $d01d

    // turn on multicolour mode for all sprites
    lda #%00000100
    sta $d01c 

    // sprite priority to front
    lda #%00000110
    sta $d01b
rts

hide_sprites:
    // turn off all sprites
	lda #%00000000
	sta $d015    
rts

show_sprites:
    // turn on all sprites
	lda #%11111111    
	sta $d015    
rts

.macro sprite_set_xy_positions(i)
{    
        //Set x positions
        lda spriteXPositions.lo+i
        sta $d000+(i*2)
        lda spriteXPositions.hi+i
        beq msb_zero
            lda $d010
            ora #(1 << i)
            sta $d010
            jmp return
    msb_zero:
        lda $d010
        and #~(1 << i)
        sta $d010
    return:

        //set y positions
        lda spriteYPositions+i
        sta $d001+(i*2)
}

spriteXPositions:
    .lohifill 8,0
spriteYPositions:
    .fill 8,0

.pc = $3000 "[Data] Sprite memory"
spriteMemory:
.var sprites = LoadBinary("DuckHunt - Sprites.bin")
.fill sprites.getSize(), sprites.get(i)