CURSORX db 0
CURSORY db 0
CURSORCHR db '>'

; Print the character in a at the cursor position then advance the cursor.
_ECHO:  
        push ix
        push hl
        push de
        push bc
        push af

        push af
        ld a,(CURSORY)
        .3 sla a
        ld h,a
        ld a,(CURSORX)
        .3 sla a
        ld l,a
        pop af
        
        and %01111111
        call PrintChar

        ld a,(CURSORX)
        inc a
        cp 32
        jr z,ECHONL
        ld (CURSORX),a        
ECHODONE:
        pop af
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

; Newline
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

; Move the cursor back one space, stopping at the beginning of the line.
BACKSPACE:
        push af
        call _CURSORBL
        ld a,(CURSORX)
        dec a
        cp 32
        jr c,BACKSPACE1
        inc a
BACKSPACE1:
        ld (CURSORX),a
        ;call _CURSOR
        pop af
        ret

; Display the cursor.
_CURSOR:
        push ix
        push hl
        push de
        push bc
        ld a,(CURSORY)
        .3 sla a
        ld h,a
        ld a,(CURSORX)
        .3 sla a
        ld l,a
        ld a,(CURSORCHR)
        call PrintChar
        pop bc
        pop de
        pop hl
        pop ix
        ret
        ret

; Blank the cursor
_CURSORBL:
        push ix
        push hl
        push de
        push bc
        ld a,(CURSORY)
        .3 sla a
        ld h,a
        ld a,(CURSORX)
        .3 sla a
        ld l,a
        ld a,32
        call PrintChar
        pop bc
        pop de
        pop hl
        pop ix
        ret
        ret

; Read one key, return in a
_KEY:   exx
        call Read_Keyboard_Debounce
        push af
        exx
        pop af
        ret

; Clear the screen
_CLEARSCRN:
        exx
        ld hl,0x4000
        call Clear_Screen_Fast
        ld a,0
        ld (CURSORX),a
        ld (CURSORY),a
        exx
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
