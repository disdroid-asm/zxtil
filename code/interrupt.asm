Initialise_Interrupt:   DI                                      ; Disable interrupts
                        LD HL,Interrupt
                        LD IX,0xFFF0                            ; This code is to be written at 0xFF
                        LD (IX+04h),0xC3                        ; Opcode for JP
                        LD (IX+05h),L                           ; Store the address of the interrupt routine in
                        LD (IX+06h),H
                        LD (IX+0Fh),0x18                        ; Opcode for JR; this will do JR to FFF4h
                        LD A,0x39                               ; Interrupt table at page 0x3900 (ROM)
                        LD I,A                                  ; Set the interrupt register to that page
                        IM 2                                    ; Set the interrupt mode
                        EI                                      ; Enable interrupts
                        RET
 
Interrupt:              DI                                      ; Disable interrupts 
                        PUSH AF                                 ; Save all the registers on the stack
                        PUSH BC                                 ; This is probably not necessary unless
                        PUSH DE                                 ; we're looking at returning cleanly
                        PUSH HL                                 ; back to BASIC at some point
                        PUSH IX
                        EXX
                        EX AF,AF'
                        PUSH AF
                        PUSH BC
                        PUSH DE
                        PUSH HL
                        PUSH IY


;
; Your code here...
;
    ;call sound

    ld hl,Input_Custom
    call Read_Controls
    ld (controls),a
        
                        POP IY                                  ; Restore all the registers
                        POP HL
                        POP DE
                        POP BC
                        POP AF
                        EXX
                        EX AF,AF'
                        POP IX
                        POP HL
                        POP DE
                        POP BC
                        POP AF
                        EI                                      ; Enable interrupts
                        RET  

controls:   db 0

