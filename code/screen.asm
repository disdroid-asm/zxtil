; a - ascii
; hl - y,x
; ix - charset
PrintChar:
    ld ix,$3d00
PrintChar_:
; find start of character
    push hl
    ld hl,ix
    sub $20
    ld e,a
    ld d,0
    sla de
    sla de
    sla de
    add hl,de
    ld ix,hl
    pop hl

    ld b,8
.lp:
    push hl
    push af
    call GetScrAdr_Table
    pop af
    ld de,hl

    ld hl,ix
    ldi

    pop hl
    inc h

    inc ix
    djnz .lp

    ret


; Fast clear-screen routine
; Uses the stack to block clear memory
; HL: Address of screen buffer
;
Clear_Screen_Fast:      LD (Clear_Screen_Fast_End+1),SP ; Store the stack (self modding code)
                        LD DE,0x1800
                        ADD HL,DE                       ; Move to end of buffer
                        LD SP,HL                        ; Set stack to pointer
                        LD DE,0                         ; We are clearing, so set DE to 0
                        ;ld de,$0101
                        LD B,128                        ; We loop 128 times - 24 words * 128 = 6144
bytes
1:                      DUP 24
                        PUSH DE
                        EDUP
                        DJNZ 1B
Clear_Screen_Fast_End:  LD SP,0x0000                    ; Restore the stack
                        RET


; Source: https://zxonline.net/zx-spectrum-graphics-magic-the-basics-every-spectrum-fan-should-know/
; Fixed bug in the high byte table.

; Conditions are exactly the same as in the first version - on entry H = Y, L = X,
; On exit, HL will contain the address.
; The procedure corrupts registers DE and A.
GetScrAdr_Table:
    ex de, hl    ; now D = Y, E = X
    ld l, d        ; we write the low byte of the table address - the offset - into L
    ld h, HIGH(.scrtab)  ; and the high byte of the table address into H
    ld a, $f8
    and e
    rrca
    rrca
    rrca
    or (hl)   ; Get the low byte of the address and immediately combine it with the part derived from X
    inc h      ; move to the second half of the table, where the high bytes of the address are stored
    ld h, (hl)  ; get the high byte of the address and immediately write it into place - into register H
    ld l, a    ; Write the calculated offset into L
    ret 

   align 256  ; this guarantees that the table will be placed at an address multiple of 256 - this is important for us
.scrtab
    ; low halves of addresses
    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20
    db $40, $40, $40, $40, $40, $40, $40, $40, $60, $60, $60, $60, $60, $60, $60, $60
    db $80, $80, $80, $80, $80, $80, $80, $80, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
    db $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0

    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20
    db $40, $40, $40, $40, $40, $40, $40, $40, $60, $60, $60, $60, $60, $60, $60, $60
    db $80, $80, $80, $80, $80, $80, $80, $80, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
    db $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0

    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20
    db $40, $40, $40, $40, $40, $40, $40, $40, $60, $60, $60, $60, $60, $60, $60, $60
    db $80, $80, $80, $80, $80, $80, $80, $80, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
    db $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0

   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0     ; fill data for offsets 192 and above with zeros,
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0     ; because nothing should be displayed when Y >= 192
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

   ; now - high halves of addresses
   db $40, $41, $42, $43, $44, $45, $46, $47, $40, $41, $42, $43, $44, $45, $46, $47
   db $40, $41, $42, $43, $44, $45, $46, $47, $40, $41, $42, $43, $44, $45, $46, $47
   db $40, $41, $42, $43, $44, $45, $46, $47, $40, $41, $42, $43, $44, $45, $46, $47
   db $40, $41, $42, $43, $44, $45, $46, $47, $40, $41, $42, $43, $44, $45, $46, $47

   db $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
   db $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
   db $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
   db $48, $49, $4a, $4b, $4c, $4d, $4e, $4f, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f

   db $50, $51, $52, $53, $54, $55, $56, $57, $50, $51, $52, $53, $54, $55, $56, $57
   db $50, $51, $52, $53, $54, $55, $56, $57, $50, $51, $52, $53, $54, $55, $56, $57
   db $50, $51, $52, $53, $54, $55, $56, $57, $50, $51, $52, $53, $54, $55, $56, $57
   db $50, $51, $52, $53, $54, $55, $56, $57, $50, $51, $52, $53, $54, $55, $56, $57

   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0     ; fill data for offsets 192 and above with zeros,
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0     ; because nothing should be displayed when Y >= 192
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

