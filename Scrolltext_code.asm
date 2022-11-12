#importonce 

#import "Globals.asm"
#import "Text_code.asm"

*=* "[CODE] Scrolltext"
Scrolltext:
{
        smooth: .byte 0
        text: 
        .text "           C64 VERSION BY MAHNA MAHNA IN 2022"
        .text "           SHOOT WITH LIGHTGUN OR JOYSTICK OR MOUSE IN PORT 1"
        .text "           USE JOYSTICK IN PORT 2 TO CONTROL THE DUCK IN GAME A"
        .byte $ff
        .var text_pointer = $50

        Init:
        {
                lda #0
                sta smooth          //clear var
                jsr Scroll.reset
                rts
        }

        Smooth:
        {
                 lda smooth         //smooth it
                 sta $d016
        }       

        Scroll:
        {
                lda smooth
                sec
                sbc #$01            //$01-$07 Higher is faster scroll
                bcc !+
                        sta smooth
                        rts
                !:
                and #$07            //only 3 bits needed for smooth
                sta smooth
                
                ldx #0
                !:
                        lda screenRamTitleScreen+1+24*40,x         //move first $28 characters on bottom line
                        sta screenRamTitleScreen+24*40,x
                        inx
                        cpx #$28
                bne !-

                ldy #0
                lda (text_pointer),y    //fetch 1 char from scroll text
                cmp #$ff                //if value is $ff reset text
                beq reset
                
                jsr replaceChar
                sta screenRamTitleScreen+24*40+39

                inc text_pointer        //inc text_pointer to fetch next scrolltext char
                lda text_pointer
                bne !+
                        inc text_pointer+1
                !:
                rts

                reset:
                {
                        lda #<text
                        sta text_pointer
                        lda #>text
                        sta text_pointer+1
                        rts
                }
        }
}