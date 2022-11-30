.pc = $cf00 "[CODE] Relocator"
#import "Macros/memory_macros.asm"

relocator:
        //Stop and reset IRQ's
        sei
        jsr reset

        memcpy(mainProg, $0801, main.getSize())
        
        lda #$37
        sta $01
        jmp $080d

        cli

reset:
        lda #$7B
        sta $D011

        lda #$00
        sta $d019
        sta $d01A
        sta $d418
        sta $d404
        sta $d40B
        sta $d412
        sta $d015
        rts