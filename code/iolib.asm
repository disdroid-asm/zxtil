CURSORX db 0
CURSORY db 0

_ECHO:  
        push ix
        push hl
        push de
        push bc

        push af
        ld a,(CURSORY)
        .3 sla a
        ld h,a
        ld a,(CURSORX)
        .3 sla a
        ld l,a
        pop af
        
        call PrintChar

        ld a,(CURSORX)
        inc a
        cp 32
        jr z,ECHONL
        ld (CURSORX),a        
ECHODONE:
        pop bc
        pop de
        pop hl
        pop ix
        ret
ECHONL: ld a,0
        ld (CURSORX),a
        ld a,(CURSORY)
        inc a
        cp 22
        jr z,ECHOCLR
        ld (CURSORY),a
        jr ECHODONE
ECHOCLR:
        ld a,0
        ld (CURSORY),a
        ld (CURSORX),a
        jr ECHODONE

_CRLF:  ld a,0
        ld (CURSORX),a
        ld a,(CURSORY)
        inc a
        cp 22
        jr z,CRNL
        ld (CURSORY),a
        ret
CRNL:   ld a,0
        ld (CURSORY),a
        ret

BACKSPACE:
        push af
        ld a,(CURSORX)
        dec a
        jr nc,BACKSPACE1
        inc a
BACKSPACE1:
        ld (CURSORX),a
        pop af
        ret

_KEY:   push bc
        push hl
        push de

        call Read_Keyboard_Debounce

        pop de
        pop hl
        pop bc
        ret


ISIGN:  ld a,d
        xor b
        ex af,af'
        ld a,d
        and a
        jp p,TST2
        ld hl,0
        sbc hl,de
        ex de,hl
TST2:   ld h,b
        ld l,c
        ld a,b
        and a
        ret p
        ld hl,0
        sbc hl,de
        ret

OSIGN:  ex af,af'
        ret p
        ex de,hl
        ld hl,0
        sbc hl,de
        ret

_UD:    ld a,l
        ld bc,0x800
        ld h,c
        ld l,c
DLOOP:  add hl,hl
        adc a
        jr nc,SKADD
        add hl,de
        adc c
SKADD:  djnz DLOOP
        ld c,a
        ret

_US:    ld h,l
        ld l,0
        ld d,l
        ld b,8
SLOOP:  add hl,hl
        jr nc,SKPAD
        add hl,de
SKPAD:  djnz SLOOP
        ret

UDSLASH:
        ld b,0x10
DSLOOP: add hl,hl
        ld a,d
        adc d
        ld d,a
        sub e
        jp m,UDSKIP
        inc l
        ld d,a
UDSKIP: djnz DSLOOP
        ld c,d
        ret

USSLASH:
        ld b,8
USLOOP: add hl,hl
        ld a,h
        sub e
        jp m,USSKIP
        inc l
        ld h,a
USSKIP: djnz USLOOP
        ld c,h
        ld h,b
        ret


; DE - address
; BC - size
SAVEFILE:
        LD HL, DE          ; HL must point to the start
        di
        CALL 1474          ; call ROM SAVE routine (0x05C2)
        ei
        ret

; DE - address
LOADFILE:
        LD BC, 0           ; BC = 0 normally for default loading
        LD HL, 0           ; HL unused
        di
        CALL 1367          ; call ROM LOAD routine (0x0557)
        ei
        ret
