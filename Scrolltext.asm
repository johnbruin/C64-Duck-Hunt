#importonce 

#import "Globals.asm"
#import "Text.asm"

*=* "[CODE] Scrolltext"

Scrolltext:
{
        _smooth: .byte 0
        _text: 
        .text "           C64 VERSION BY MAHNA MAHNA IN 2022"
        .text "           TITLE PICTURE BY NYKE"
        .text "           MUSIC BY JACK PAW JUDI"
        .text "           GRAPHICS AND CODE BY STATLER"
        .text "           AIM AND SHOOT WITH LIGHTGUN OR JOYSTICK OR MOUSE IN PORT 1"
        .text "           USE JOYSTICK IN PORT 2 TO CONTROL THE DUCK IN GAME A"
        .byte $ff
        .var text_pointer = $50

        Init:
        {
                lda #0
                sta _smooth          //clear var
                jsr Scroll.reset
                rts
        }

        Smooth:
        {
                 lda _smooth         //smooth it
                 sta $d016
        }       

        Scroll:
        {
                lda _smooth
                sec
                sbc #$01            //$01-$07 Higher is faster scroll
                bcc !+
                        sta _smooth
                        rts
                !:
                and #$07            //only 3 bits needed for smooth
                sta _smooth
                
                ldx #0
                !:
                        lda ScreenRamTitleScreen+1+24*40,x         //move first $28 characters on bottom line
                        sta ScreenRamTitleScreen+24*40,x
                        inx
                        cpx #$28
                bne !-

                ldy #0
                lda (text_pointer),y    //fetch 1 char from scroll text
                cmp #$ff                //if value is $ff reset text
                beq reset
                
                jsr Text.ReplaceChar
                sta ScreenRamTitleScreen+24*40+39

                inc text_pointer        //inc text_pointer to fetch next scrolltext char
                lda text_pointer
                bne !+
                        inc text_pointer+1
                !:
                rts

                reset:
                {
                        lda #<_text
                        sta text_pointer
                        lda #>_text
                        sta text_pointer+1
                        rts
                }
        }
}