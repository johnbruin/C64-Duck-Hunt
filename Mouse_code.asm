#importonce 

#import "Globals.asm"

*=* "[CODE] Mouse code"
Mouse:
{
        // 1351 driver (and compatibles, which might have a middle button)

        .const MIN_COORD_X	= 24
        .const MIN_COORD_Y	= 40
        .const MAX_COORD_X	= 340
        .const MAX_COORD_Y	= 240

        .label BUTTON_NOPRESS	= 0
        .label BUTTON_PRESS_LEFT= 1
        .label BUTTON_PRESS_RIGHT= 2

        .label LEFT_BUTTON = %10000
        .label X_STUFF	= 0
        .label Y_STUFF	= 1

        .label sid      = $d400
        .label potx     = sid+$19
        .label poty     = sid+$1a

        // variables
        // (not really words: first byte is x value, second byte is y value)
        minimum:	.word $ffff	// lowest pot values yet
        limit:		.word 0	// highest pot values yet, plus 1
        previous:	.word 0	// old values
        width:		.word 0	// interval width
        half_width:	.word 0	// (buffered for speed increase)

        cbm1351_poll:
        {
                // mouse x
                ldx #X_STUFF
                jsr pot_delta
                // now YYAA is signed x movement. add to current x value
                clc
                adc pos_x_lo
                sta pos_x_lo
                tya
                adc pos_x_hi
                sta pos_x_hi
                jsr restrict
                
                // mouse y
                ldx #Y_STUFF
                jsr pot_delta
                // now YYAA is signed y movement. subtract from current y
                // value because axis points the other way.
                clc
                sbc pos_y_lo
                eor #$ff
                sta pos_y_lo
                tya
                sbc pos_y_hi
                eor #$ff
                sta pos_y_hi		
                jsr restrict

                rts
        }

        // on entry: X is direction handle (0 = x, 1 = y)
        // on exit: YYAA is signed distance
        // compute signed distance of mouse movement
        pot_delta: 
        {
                // first, get new value and clear "recalculate signal width" flag
                lda potx, x
                ldy #0
                // check whether new value is lower than lowest known
                cmp minimum, x
                bcs !+
                        // store new "lowest" und set "recalculate signal width" flag
                        sta minimum, x
                        dey//ldy#$ff
                !:		// check whether new value is higher than highest known
                cmp limit, x
                bcc !++
                        // set "recalculate signal width" flag and store new "highest"
                        ldy #$ff
                        pha	// remember
                        adc #0	// add one (C set)
                        sta limit, x
                        // value $ff (0 after adding) means that there is no mouse connected,
                        // so reset min/max in that case.
                        bne !+
                                // no mouse, so reset "lowest"
                                // ("highest" will have been reset already)
                                // and return zero.
                                tay		// set Y to zero.
                                pla		// fix stack
                                lda #$ff	// reset "lowest"
                                sta minimum, x
                                tya		// return YYAA = 0
                                rts
                        !:
                        pla	// restore
                !:		// if flag is set, recalculate signal width
                iny	// check flag
                bne !++
                        tay		// remember
                        lda limit,x	// get highest + 1
                        sec		// subtract lowest
                        sbc minimum,x
                        bcc !+
                                sta width,x		// store signal
                                lsr			// width and half signal
                                sta half_width,x	// width
                        !:
                        tya	// restore
                !:	// calculate distance
                tay	// remember
                sec
                sbc previous, x
                pha
                tya
                sta previous, x
                pla
                beq zero	// if not moved, exit
                bcc negative	// negative difference
                
                // positive
                // check whether movement caused a value wrap-around
                cmp half_width, x
                bcc decrease
                beq decrease
                // it did, so calculate "real" distance and jump to exit
                //sec	// C is always set here
                sbc width, x	// fix distance
                // we now know that the (fixed) distance is really negative, so
                // we finally wipe out that annoying bit 0 noise by incrementing
                // the value.
        
                increase:	//clc	// C is always clear here
                adc #1
                beq zero	// if increasing gives zero, jump to zero handler
                ldy #$ff	// set up high byte for negative values
                rts
                
                negative:
                // check whether movement caused a value wrap-around
                eor #$ff	// complement
                cmp half_width, x
                eor #$ff	// restore value
                bcc increase
                // it did, so calculate "real" distance and exit
                clc
                adc width, x	// fix distance
                // we now know that the (fixed) distance is really positive, so
                // we finally wipe out that annoying bit 0 noise by decrementing
                // the value
                
                decrease:
                sec
                sbc #1
                
                // no difference or positive difference// both need zero as the high byte.
                zero:
                ldy #0
                rts
        }

        restrict:
        {
                jsr restrictLeftBoundary
                jsr restrictRightBoundary
                jsr restrictLowerBoundary
                jsr restrictUpperBoundary
                rts
        }

        restrictLeftBoundary:
        {
                lda pos_x_hi
                cmp min_x_hi
                bne !+
                        lda pos_x_lo
                        cmp min_x_lo
                !:
                bcc !lower+
                bne !higher+    

                !higher:
                        rts
                !lower:
                        lda min_x_lo
                        sta pos_x_lo
                        lda min_x_hi
                        sta pos_x_hi 
                        rts
                rts
        }

        restrictRightBoundary:
        {
                lda pos_x_hi
                cmp max_x_hi
                bne !+
                        lda pos_x_lo
                        cmp max_x_lo
                !:
                bcc !lower+
                bne !higher+    

                !higher:
                        lda max_x_lo
                        sta pos_x_lo
                        lda max_x_hi
                        sta pos_x_hi                   
                        rts
                !lower:
                        rts
                rts
        }

        restrictUpperBoundary:
        {
                lda pos_y_hi
                cmp min_y_hi
                bne !+
                        lda pos_y_lo
                        cmp min_y_lo
                !:
                bcc !lower+
                bne !higher+    

                !higher:
                        rts
                !lower:
                        lda min_y_lo
                        sta pos_y_lo
                        lda min_y_hi
                        sta pos_y_hi 
                        rts
                rts
        }

        restrictLowerBoundary:
        {
                lda pos_y_hi
                cmp max_y_hi
                bne !+
                        lda pos_y_lo
                        cmp max_y_lo
                !:
                bcc !lower+
                bne !higher+    

                !higher:
                        lda max_y_lo
                        sta pos_y_lo
                        lda max_y_hi
                        sta pos_y_hi 
                        rts
                !lower:
                        rts
                rts
        }

        min_x_lo:	.byte <MIN_COORD_X
        min_y_lo:	.byte <MIN_COORD_Y
        min_x_hi:	.byte >MIN_COORD_X
        min_y_hi:	.byte >MIN_COORD_Y

        max_x_lo:	.byte <MAX_COORD_X
        max_y_lo:	.byte <MAX_COORD_Y
        max_x_hi:	.byte >MAX_COORD_X
        max_y_hi:	.byte >MAX_COORD_Y

        pos_x_lo:	.byte <MAX_COORD_X/2
        pos_y_lo:	.byte <MAX_COORD_Y/2
        pos_x_hi:	.byte >MAX_COORD_X/2
        pos_y_hi:       .byte >MAX_COORD_Y/2
}