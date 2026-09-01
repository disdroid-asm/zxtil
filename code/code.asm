    device zxspectrum48
    org #8000
main:
    call Initialise_Interrupt
    jp START


    include iolib.asm
    include interrupt.asm
    include keyboard.asm
    include screen.asm
    include til.asm
    include sec.asm

    ifdef TAP
;----------------------------------------------------------------------
program_length = $-main

    include     TapLib.asm
    MakeTape ZXSPECTRUM48, "code.tap", "Code", main, program_length, main
    endif