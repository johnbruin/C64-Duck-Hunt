#importonce 

#import "Globals.asm"

*=* "[CODE] Sprite common code"

Sprites:
{
    .label SPRITEPOINTER = ScreenRam+$03f8
    .label SPRITEPOINTER_TITLE = ScreenRamTitleScreen+$03f8
    .label overlay_distance = 19

    Init:
    {
        jsr Sprites.Hide
        
        // Make sure no sprites are x- or y-expanded.
        lda #%11111110 
        sta $d017
        sta $d01d

        // turn on multicolour mode for all sprites
        lda #%11111100
        sta $d01c 

        // sprite priority to front
        lda #%11111110
        sta $d01b
        rts
    }

    Hide:
    {
        // turn off all sprites
        lda #%00000000
        sta $d015    
        rts
    }

    Show:
    {
        // turn on all sprites
        lda #%11111111  
        sta $d015
        rts
    }

    XPositions:
        .lohifill 8,0
    YPositions:
        .fill 8,0
}

.macro sprite_enable(i) 
{        
    lda $d015
    ora #(1 << i)
    sta $d015
}

.macro sprite_disable(i) 
{        
    lda $d015
    and #~(1 << i)
    sta $d015
}

.macro sprite_set_xy_positions(i)
{    
    //Set x positions
    lda Sprites.XPositions.lo+i
    sta $d000+(i*2)
    lda Sprites.XPositions.hi+i
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
    lda Sprites.YPositions+i
    sta $d001+(i*2)
}