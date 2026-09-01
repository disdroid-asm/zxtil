; BC - instruction register
; DE - word address register and scratch
; HL - scratch
; IX - return stack pointer
; IY - address of NEXT
; SP - data stack pointer

START:  ld de,RSTMSG
        ld a,(BASE)
        and a
        jr nz,ABORT
        ld a,10
        ld (BASE),a
        ld de,SRTMSG
ABORT:  ld sp,STACK
        push de
        ld hl,0
        ld (MODE),hl
        ld iy,NEXT
        ld ix,RETURN
        ld hl,#8080
        ld (LBEND),hl
        ld bc,OUTER
        jp NEXT

_STACK: dw $+2
        ld hl,STACK
        and a
        sbc hl,sp
        jr nc,STKOK
        add hl,sp
        ld sp,hl
        ld de,STKMSG
        jp PATCH
STKOK:  jp (iy)

PATCH:  ld a,(MODE)
        and a
        jp z,ABORT
        push de
        ld hl,(CURRENT)
        ld e,(hl)
        inc hl
        ld d,(hl)
        ex de,hl
        ld (DP),hl
        ld a,5
        add l
        ld l,a
        jr nc,SKIP
        inc h
SKIP:   ld a,(hl)
        ld (de),a
        dec hl
        dec de
        ld a,(hl)
        ld (de),a
        pop de
        jp ABORT

SEMI:   dw $+2
        ld c,(ix+0)
        inc ix
        ld b,(ix+0)
        inc ix
NEXT:   ld a,(bc)
        ld l,a
        inc bc
        ld a,(bc)
        ld h,a
        inc bc
RUN:    ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ex de,hl
        jp (hl)

COLON:  ;dw $+2
        dec ix
        ld (ix+0),b
        dec ix
        ld (ix+0),c
        ld c,e
        ld b,d
        jp (iy)

LINK = $
        db 7,'E','X','E' ; EXECUTE
        dw 0
EXECUTE: dw $+2
        pop hl
        jr RUN
        


INLINE: dw $+2
        push bc
ISTART: call _CRLF
        ld hl,LBUFFER
        ld (LBP),hl
        ld b,LBLEN
ICLEAR: ld (hl),0x20
        inc hl
        djnz ICLEAR
IZERO:  ld l,0
INKEY:  call _KEY
        cp LINEDEL
        jr nz,TSTBS
        call _ECHO
        jp ISTART
TSTBS:  cp BACKSP
        jr nz,TSTCR
        dec l
        jp m,IZERO
        ld (hl),0x20
ISSUE:  call _ECHO
        jp INKEY
TSTCR:  cp CR
        jr z,LAST1
        bit 7,l
        jr nz,IEND
SAVEIT: ld (hl),a
        cp 0x61
        jr c,NOTLC
        cp 0x7B
        jr nc,NOTLC
        res 5,(hl)
NOTLC:  inc l
        jr ISSUE
IEND:   dec l
        ld c,a
        ld a,BACKSP
        call _ECHO
        ld a,c
        jr SAVEIT
LAST1:  ld a,0x20
        call _ECHO
        ld (hl),0xff
        inc hl
        ld (hl),0xff
        pop bc
        jp (iy)

        db 5,'T','O','K' ; TOKEN
        dw LINK
LINK = $-6
TOKEN:  dw $+2
        exx
        ld hl,(LBP)
        ld de,(DP)
        pop bc
        ld a,0x20
        cp c
        jr nz,TOK
IGNLB  cp (hl)
        jr nz,TOK
        inc l
        jr IGNLB
TOK:    push hl
TCOUNT: inc b
        inc l
        ld a,(hl)
        cp c
        jr z,ENDTOK
        rla
        jr nc,TCOUNT
        dec l
ENDTOK: inc l
        ld (LBP),hl
        ld a,b
        ld (de),a
        inc de
        pop hl
        ld c,b
        ld b,0
        ldir
        exx
        jp (iy)

        db 6,'S','E','A' ; SEARCH
        dw LINK
LINK = $-6
SEARCH: dw $+2
        exx
        pop hl
TESTIT: push hl
        ld de,(DP)
        ld c,0
        ld a,(de)
        cp (hl)
        jr nz,NXTHDR
        cp 4
        jr c,BEL04
        ld a,3
BEL04:  ld b,a
NXTCH:  inc hl
        inc de
        ld a,(de)
        cp (hl)
        jr nz,NXTHDR
        djnz NXTCH
        pop hl
        ld de,6
        add hl,de
        push hl
        jr SFLAG
NXTHDR: pop hl
        ld de,4
        add hl,de
        ld e,(hl)
        inc hl
        ld d,(hl)
        ex de,hl
        ld a,h
        or l
        jr nz,TESTIT
        ld c,1
SFLAG:  push bc
        exx
        jp (iy)

NUMBER: dw $+2
        exx
        ld hl,(DP)
        ld b,(hl)
        inc hl
        ld a,(hl)
        cp 0x2d ; '-'
        jr nz,SKIPSAV
        xor a
        dec a
        dec b
        inc hl
SKIPSAV: 
        xor a
        ex af,af'
        ld de,0
        push de
        push de
NLOOP:  ld a,(hl)
        sub 0x30
        jr c,NOTNO
        cp 0x0a
        jr c,NUMB
        cp 0x11
        jr c,NOTNO
        sub 7
NUMB:   ld e,a
        ld a,(BASE)
        dec a
        cp e
        jr nc,ANUMB
NOTNO:  pop hl
        exx
        jp (iy)
ANUMB:  ex (sp),hl
        ex de,hl
        push bc
        push hl
        ld bc,0x0800
        inc a
        ld l,c
        ld h,c
MLOOP:  add hl,hl
        adc a
        jr nc,SKPADD
        add hl,de
SKPADD: djnz MLOOP
        pop de
        add hl,de
        pop bc
        ex (sp),hl
        inc hl
        djnz NLOOP
        pop de
        pop hl
        ex af,af'
        and a
        jr z,NDONE
        sub hl,de
NDONE:  push de
        scf
        push af
        exx
        jp (iy)

QUESTION: dw $+2
        ld hl,(DP)
        inc hl
        bit 7,(hl)
        jr z,ERROR
        ld de,OKMSG
        push de
        jp (iy)
ERROR:  call _CRLF
        ld iy,QRETURN
        dec hl
        jp _TYPE
QRETURN:
        ld de,QMSG
        jp PATCH

TYPE:   dw $+2
        pop hl
_TYPE:  ld e,(hl)
TLOOP:  inc hl
        ld a,(hl)
        call _ECHO
        dec e
        jr nz,TLOOP
        jp (iy)

        db 1,'!',0,0 ; !
        dw LINK
LINK = $-6
STORE:  dw $+2
        pop hl
        pop de
        ld (hl),e
        inc hl
        ld (hl),d
        jp (iy)

        db 2,'#','>',0 ; #>
        dw LINK
LINK = $-6
HASHGT: dw $+2
        inc ix
        jp _DISPLAY

STARHASH:
        dw $+2
        ld a,(bc)
        ld e,a
        inc bc
        ld a,(bc)
        ld d,a
        inc bc
        push de
        jp (iy)

_PLUSLOOP:
        dw $+2
;_PLUSLOOP:
        push ix
        pop hl
        pop de
        ld a,e
        jp _LOOP_


        db 2,'*','/',0 ; */
        dw LINK
LINK = $-6
STARSLASH: 
        dw $+2
        ld iy,RETTO
        jp _STARSLASHMOD
RETTO:  pop hl
        ld iy,NEXT
        jp (iy)

        db 5,'*','/','M' ; */MOD
        dw LINK
LINK = $-6
STARSLASHMOD: 
        dw $+2
_STARSLASHMOD:
        pop hl
        exx
        pop bc
        pop de
        call ISIGN
        call _UD
        exx 
        ex af,af'
        xor l
        ex af,af'
        ld a,l
        exx 
        and a
        jp p,SKIPN
        neg
SKIPN:  ld d,c
        ld e,a
        call _UD
        call OSIGN
        push hl
        push bc
        exx 
        jp (iy)

CHASH:  dw $+2
        ld a,(bc)
        ld e,a
        inc bc
        ld d,0
        bit 7,e
        jr z,CHOUT
        dec d
CHOUT:  push de
        jp (iy)

_CPLUSLOOP:
        dw $+2
        push ix
        pop hl
        pop de
        ld a,(hl)
        add e
        ld (hl),a
        jp _CLOOP_


_CDO:   dw $+2
        pop hl
        ld (ix-2),l
        pop hl
        ld (ix-1),l
        dec ix
        dec ix
        jp (iy)

_CLEAVE: dw $+2
        ld a,(ix+1)
        ld (ix+0),a
        jp (iy)

_CLOOP: dw $+2
;_CLOOP: 
        push ix
        pop hl
        inc (hl)
_CLOOP_:
        ld a,(hl)
        inc hl
        sub (hl)
        jp c,_WHILE_
        inc ix
        inc ix
        inc bc
        jp (iy)

_DO:    dw $+2
        pop hl
        ld (ix-4),l
        ld (ix-3),h
        pop hl
        ld (ix-2),l
        ld (ix-1),h
        ld de,-4
        add ix,de
        jp (iy)

_ELSE:  dw $+2
_ELSE_: ld a,(bc)
        add c
        ld c,a
        jr nc,ELOUT
        inc b
ELOUT:  jp (iy)

_END:   dw $+2
        pop hl
        ld a,l
        or h
        jp z,_WHILE_
        inc bc
        jp (iy)

_IF:    dw $+2
        pop hl
        ld a,l
        or h
        jp z,_ELSE_
        inc bc
        jp (iy)

_LEAVE: dw $+2
        ld a,(ix+3)
        ld (ix+1),a
        ld a,(ix+2)
        ld (ix+0),a
        jp (iy)

_LOOP:  dw $+2
        push ix
        pop hl
        ld a,1
_LOOP_: add (hl)
        ld (hl),a
        inc hl
        jr nc,LPAGE
        inc hl
LPAGE:  ld d,(hl)
        inc hl
        sub (hl)
        ld d,a
        inc hl
        sbc (hl)
        jp c,_WHILE_
        ld de,4
        add ix,de
        inc bc
        jp (iy)

_SYS:   dw $+2
        ld a,(de)
        ld hl,SYSBLOCK
        add l
        ld l,a
        push hl
        jp (iy)

_WHILE: dw $+2
_WHILE_:
        ld a,(bc)
        add c
        ld c,a
        jr c,WOUT
        dec b
WOUT:   jp (iy)


STRLIT: dw $+2 ; *[
        ld a,(bc)
        ld d,a
SLLOOP: inc bc
        ld a,(bc)
        call _ECHO
        dec d
        jr nz,SLLOOP
        inc bc
        jp (iy)

        db 1,'+',0,0 ; +
        dw LINK
LINK = $-6
PLUS:   dw $+2
        pop hl
        pop de
        add hl,de
        push hl
        jp (iy)

        db 2,'+','!',0 ; +!
        dw LINK
LINK = $-6
PLUSSTORE:
        dw $+2
        pop hl
        pop de
        ld a,(hl)
        add e
        ld (hl),a
        inc hl
        ld a,(hl)
        adc d
        ld (hl),a
        jp (iy)

        db 3,'+','S','P' ; +SP
        dw LINK
LINK = $-6
SPPLUS: dw $+2
        pop hl
        add hl,sp        
        push hl
        jp (iy)

        db 1,',',0,0 ; ,
        dw LINK
LINK = $-6
COMMA:  dw $+2
        pop de
        ld hl,(DP)
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (DP),hl
        jp (iy)

        db 1,'-',0,0 ; -
        dw LINK
LINK = $-6
_SUB:   dw $+2
        pop de
        pop hl
        and a
        sbc hl,de
        push hl
        jp (iy)

        db 3,'-','S','P' ; -SP
        dw LINK
LINK = $-6
SPMINUS:
        dw $+2
        pop hl
        and a
        sbc hl,sp
        push hl
        jp (iy)

        db 1,'/',0,0 ; /
        dw LINK
LINK = $-6
_DIV:   dw $+2
        exx
        pop de
        pop bc
        call ISIGN
        call USSLASH
        call OSIGN
        push hl
        exx
        jp (iy)

        db 4,'/','M','O' ; /MOD
        dw LINK
LINK = $-6
DIVMOD: dw $+2 
        exx
        pop de
        pop bc
        call ISIGN
        call USSLASH
        call OSIGN
        push hl
        push bc
        exx
        jp (iy)

        db 1,'0',0,0 ; 0
        dw LINK
LINK = $-6
_ZERO:  dw $+2 
        ld hl,0
        push hl
        jp(iy)

        db 2,'0','<',0 ; 0<
        dw LINK
LINK = $-6
ZEROLT: dw $+2 
        pop af
        ld de,0
        rla
        jp nc,ZLPUSH
        inc e
ZLPUSH: push de
        jp(iy)

        db 2,'0','=',0 ; 0=
        dw LINK
LINK = $-6
ZEROEQ: dw $+2 
        pop hl
        ld a,l
        or h
        ld de,0
        jr nz,ZEOUT
        inc de
ZEOUT:  push de
        jp (iy)

        db 4,'0','S','E' ; 0SET
        dw LINK
LINK = $-6
ZEROSET:
        dw $+2 
        pop hl
        xor a
        ld (hl),a
        inc hl
        ld (hl),a
        jp (iy)

        db 1,'1',0,0 ; 1
        dw LINK
LINK = $-6
_ONE:   dw $+2 
        ld hl,1
        push hl
        jp(iy)

        db 2,'1','+',0 ; 1+
        dw LINK
LINK = $-6
ONEPLUS:
        dw $+2 
        pop hl
        inc hl
        push hl
        jp (iy)

        db 2,'1','-',0 ; 1-
        dw LINK
LINK = $-6
ONEMINUS:
        dw $+2 
        pop hl
        dec hl
        push hl
        jp (iy)

        db 4,'1','S','E' ; 1SET
        dw LINK
LINK = $-6
ONESET: dw $+2 
        pop hl
        ld (hl),1
        inc hl
        ld (hl),0
        jp (iy)

        db 2,'2','*',0 ; 2*
        dw LINK
LINK = $-6
TWOMUL: dw $+2 
        pop hl
        add hl,hl
        push hl
        jp (iy)

        db 2,'2','+',0 ; 2+
        dw LINK
LINK = $-6
TWOPLUS: 
        dw $+2 
        pop hl
        inc hl
        inc hl
        push hl
        jp (iy)

        db 2,'2','-',0 ; 2-
        dw LINK
LINK = $-6
TWOMINUS: 
        dw $+2 
        pop hl
        dec hl
        dec hl
        push hl
        jp (iy)

        db 2,'2','/',0 ; 2/
        dw LINK
LINK = $-6
TWODIV: dw $+2 
        pop hl
        sra h
        rr l
        push hl
        jp (iy)

        db 4,'2','D','U' ; 2DUP
        dw LINK
LINK = $-6
TWODUP: dw $+2 
        pop hl
        push hl
        push hl
        push hl
        jp (iy)

        db 5,'2','O','V' ; 2OVER
        dw LINK
LINK = $-6
TWOOVER: 
        dw $+2 
        exx
        pop hl
        pop de
        pop bc
        push bc
        push de
        push hl
        push bc
        exx        
        jp (iy)

        db 5,'2','S','W' ; 2SWAP
        dw LINK
LINK = $-6
TWOSWAP: 
        dw $+2 
        pop hl
        pop de
        ex (sp),hl
        push de
        push hl
        jp (iy)

        db 1,'<',0,0 ; <
        dw LINK
LINK = $-6
LESSTHAN: 
        dw $+2 
        pop de
        pop hl
        and a
        sbc de,hl
        ld de,0
        jp p,LTPUSH
        inc e
LTPUSH: push de
        jp (iy)
        
        db 2,'<','#',0 ; <#
        dw LINK
LINK = $-6
LTHASH: dw $+2 
        pop hl
        ld e,0xa0
        push de
        push hl
        dec ix
        ld (ix+0),h
        jp (iy)

        db 2,'<','R',0 ; <R
        dw LINK
LINK = $-6
LTR:    dw $+2 
        pop hl
        dec ix
        ld (ix+0),hl
        dec ix
        ld (ix+0),hl
        jp (iy)

        db 1,'=',0,0 ; =
        dw LINK
LINK = $-6
EQUALS: 
        dw $+2 
        pop hl
        pop de
        and a
        sbc hl,de
        ld de,0
        jr nz,EQPUSH
        inc e
EQPUSH: push de
        jp (iy)

        db 1,'>',0,0 ; >
        dw LINK
LINK = $-6
GREATERTHAN: 
        dw $+2 
        pop de
        pop hl
        and a
        sbc hl,de
        ld de,0
        jp p,GTPUSH
        inc e
GTPUSH: push de
        jp (iy)

        db 3,'?','R','S' ; ?RS
        dw LINK
LINK = $-6
QUESTRS: 
        dw $+2 
        push ix
        jp (iy)

        db 3,'?','S','P' ; ?SP
        dw LINK
LINK = $-6
QUESTSP: 
        dw $+2 
        ld hl,0
        add hl,sp
        ex de,hl
        ld hl,STACK
        and a
        sbc hl,de
        jr nc,QSPSKIP
        ld sp,STACK
QSPSKIP:
        push de
        jp (iy)

        db 1,'@',0,0 ; @
        dw LINK
LINK = $-6
FETCH:  dw $+2 
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        push de
        jp (iy)

        db 5,'A','B','O' ; ABORT
        dw LINK
LINK = $-6
_ABORT: dw $+2 
        jp START

        db 3,'A','B','S' ; ABS
        dw LINK
LINK = $-6
_ABS:   dw $+2 
        pop de
        bit 7,d
        jr z,ABSOUT
        ld hl,0
        and a
        sbc hl,de
        ex de,hl
ABSOUT: push de
        jp (iy)

        db 3,'A','N','D' ; AND
        dw LINK
LINK = $-6
_AND:   dw $+2 
        pop hl
        pop de
        ld a,l
        and e
        ld l,a
        ld a,h
        and d
        ld h,a
        push hl
        jp (iy)

        db 5,'A','S','C' ; ASCII
        dw LINK
LINK = $-6
ASCII:  dw $+2
        pop hl
        ld a,0x30
        and l
        cp 0x3a
        jr c,ASCOUT
        add 7
ASCOUT: ld l,a
        push hl
        jp (iy)
        
        db 6,'A','S','P' ; ASPACE
        dw LINK
LINK = $-6
ASPACE: dw $+2
        ld hl,0x20
        push hl
        jp (iy)

; TODO sys
        db 4,'B','A','S' ; BASE
        dw LINK
LINK = $-6
_BASE:  dw $+2
        ld hl,BASE
        push hl
        jp (iy)

        db 6,'B','I','N' ; BINARY
        dw LINK
LINK = $-6
_BINARY:
        dw $+2
        ld a,2
        ld (BASE),a
        dw $+2
        jp (iy)

        db 2,'C','!',0 ; C!
        dw LINK
LINK = $-6
CSTORE: dw $+2
        pop hl
        pop de
        ld (hl),e
        jp (iy)

        db 3,'C','+','!' ; C+!
        dw LINK
LINK = $-6
CPLUSSTORE: 
        dw $+2
        pop hl
        pop de
        ld a,(hl)
        add e
        ld (hl),a
        jp (iy)

        db 2,'C',',',0 ; C,
        dw LINK
LINK = $-6
CCOMMA: dw $+2
        pop de
        ld hl,(DP)
        ld (hl),e
        inc hl
        ld (DP),hl
        jp (iy)

        db 5,'C','0','S' ; C0SET
        dw LINK
LINK = $-6
C0SET:  dw $+2
        pop hl
        ld (hl),0
        jp (iy)

        db 5,'C','1','S' ; C1SET
        dw LINK
LINK = $-6
C1SET:  dw $+2
        pop hl
        ld (hl),1
        jp (iy)

        db 3,'C','<','R' ; C<R
        dw LINK
LINK = $-6
CLTR:   dw $+2
        pop hl
        dec ix
        ld (ix+0),l
        jp (iy)

        db 2,'C','@',0 ; C@
        dw LINK
LINK = $-6
CFETCH: dw $+2
        pop hl
        ld e,(hl)
        ld d,0
        bit 7,e
        jr z,CFSKIP
        dec d
CFSKIP: push de
        jp (iy)

        db 3,'C','I','>' ; CI>
        dw LINK
LINK = $-6
CIGT:   dw $+2
        ld l,(ix+0)
        ld h,0
        bit 7,l
        jr nz,CINEXT
        dec h
CINEXT: push hl
        jp (iy)

        db 3,'C','J','>' ; CJ>
        dw LINK
LINK = $-6
CJGT:   dw $+2
        ld l,(ix+2)
        ld h,0
        bit 7,l
        jr nz,CJNEXT
        dec h
CJNEXT: push hl
        jp (iy)

        db 5,'C','J','O' ; CJOIN
        dw LINK
LINK = $-6
CJOIN:  dw $+2
        pop hl
        pop de
        ld d,l
        push de
        jp (iy)

        db 3,'C','K','>' ; CK>
        dw LINK
LINK = $-6
CKGT:   dw $+2
        ld l,(ix+4)
        ld h,0
        bit 7,l
        jr nz,CKNEXT
        dec h
CKNEXT: push hl
        jp (iy)
        
        db 5,'C','L','E' ; CLEAR
        dw LINK
LINK = $-6
_CLEAR: dw $+2
    ; TODO cls
        jp (iy)

    ; TODO sys
        db 5,'C','O','M' ; COMPILER
        dw LINK
LINK = $-6
_COMPILER:   
        dw $+2
        ld hl,COMPILER
        push hl
        jp (iy)

; TODO sys
        db 7,'C','O','N' ; CONTEXT
        dw LINK
LINK = $-6
_CONTEXT: 
        dw $+2
        ld hl,CONTEXT
        push hl
        jp (iy)

        db 4,'C','O','R' ; CORE
        dw LINK
LINK = $-6
CORE:   dw COREV
_CORE:  dw CORETOP
COREV:
        ld hl,_CORE
        ld (CONTEXT),hl
        jp (iy)

        db 3,'C','R','>' ; CR>
        dw LINK
LINK = $-6
CRGT:   dw $+2
        ld l,(ix+0)
        inc ix
        ld h,0
        bit 7,l
        jr z,CRGSKIP
        dec h
CRGSKIP:
        push hl
        jp (iy)

        db 4,'C','R','E' ; CRET
        dw LINK
LINK = $-6
CRET:   dw $+2
        call _CRLF
        jp (iy)

        db 6,'C','S','P' ; CSPLIT
        dw LINK
LINK = $-6
CSPLIT: dw $+2
        pop hl
        ld e,h
        ld h,0
        ld d,h
        bit 7,e
        jr z,CSPOUT
        dec d
CSPOUT: push de
        push hl
        jp (iy)

; TODO sys
        db 7,'C','U','R' ; CURRENT
        dw LINK
LINK = $-6
_CURRENT: 
        dw $+2
        ld hl,CURRENT
        push hl
        jp (iy)

        db 2,'D','*',0 ; D*
        dw LINK
LINK = $-6
DMUL:   dw $+2
        exx
        pop bc
        pop de
        call ISIGN
        call _UD
        ex af,af'
        jp p,DMOUT
        ld a,c
        cpl
        ld c,a
        ex de,hl
        ld hl,0
        sbc hl,de
        jr nz,DMOUT
        inc c
DMOUT:  push hl
        push bc
        exx
        jp (iy)

        db 5,'D','/','M' ; D/MOD
        dw LINK
LINK = $-6
DDIVM:  dw $+2
        exx
        pop hl
        pop de
        pop bc
        ld a,h
        xor d
        ex af,af'
        ld a,l
        and a
        jp p,DDMOV1
        neg
DDMOV1: ld d,a
        ld h,b
        ld l,c
        ld a,e
        and a
        jp p,DDMOV2
        cpl
        ld hl,0
        sbc hl,bc
        jp nz,DDMOV2
        inc a
DDMOV2: ld d,a
        call _UD
        call OSIGN
        push hl
        push bc        
        exx
        jp (iy)

        db 7,'D','E','C' ; DECIMAL
        dw LINK
LINK = $-6
DECIMAL:
        dw $+2
        ld a,0x0a
        ld (BASE),a
        jp (iy)

        db 11,'D','E','F' ; DEFINITIONS
        dw LINK
LINK = $-6
DEFINITIONS:
        dw $+2
        ld hl,(CONTEXT)
        ld (CURRENT),hl
        jp (iy)

        db 7,'D','I','S' ; DISPLAY
        dw LINK
LINK = $-6
DISPLAY:
        dw $+2
_DISPLAY:
        exx
DISPLP: pop hl
        ld a,l
        call _ECHO
        and a
        jp p,DISPLP
        exx
        jp (iy)

; TODO sys
        db 2,'D','P',0 ; DP
        dw LINK
LINK = $-6
_DP:    dw $+2
        ld hl,DP
        push hl
        jp (iy)

        db 4,'D','R','O' ; DROP
        dw LINK
LINK = $-6
DROP:   dw $+2
        pop hl
        jp (iy)

        db 3,'D','U','P' ; DUP
        dw LINK
LINK = $-6
_DUP:   dw $+2
        pop hl
        push hl
        push hl
        jp (iy)

        db 4,'E','C','H' ; ECHO
        dw LINK
LINK = $-6
ECHO:   dw $+2
        pop hl
        ld a,l
        call _ECHO
        jp (iy)

        db 4,'H','E','R' ; HERE
        dw LINK
LINK = $-6
HERE:   dw $+2
        ld hl,(DP)
        push hl
        jp (iy)

        db 3,'H','E','X' ; HEX
        dw LINK
LINK = $-6
_HEX:   dw $+2
        ld a,0x0a
        ld (BASE),a
        jp (iy)

        db 2,'I','>',0 ; I>
        dw LINK
LINK = $-6
IGT:    dw $+2
        ld l,(ix+0)
        ld h,(ix+1)
        push hl
        jp (iy)

        db 3,'I','O','R' ; IOR
        dw LINK
LINK = $-6
IOR:    dw $+2
        pop hl
        pop de
        ld a,l
        or e
        ld l,a
        ld a,h
        or d
        ld h,a
        push hl
        jp (iy)

        db 2,'J','>',0 ; J>
        dw LINK
LINK = $-6
JGT:    dw $+2
        ld l,(ix+4)
        ld h,(ix+5)
        push hl
        jp (iy)

        db 2,'K','>',0 ; I>
        dw LINK
LINK = $-6
KGT:    dw $+2
        ld l,(ix+8)
        ld h,(ix+9)
        push hl
        jp (iy)

        db 3,'K','E','Y' ; KEY
        dw LINK
LINK = $-6
KEY:    dw $+2
        call _KEY
        ld l,a
        push hl
        jp (iy)

; TODO sys
        db 3,'L','B','P' ; LBP
        dw LINK
LINK = $-6
_LBP:   dw $+2
        ld hl,LBP
        push hl
        jp (iy)

        db 4,'L','R','O' ; LROT
        dw LINK
LINK = $-6
LROT:   dw $+2
        pop de
        pop hl
        ex (sp),hl
        push de
        push hl
        jp (iy)

        db 3,'M','A','X' ; MAX
        dw LINK
LINK = $-6
MAX:    dw $+2
        pop de
        pop hl
        push hl
        and a
        sbc hl,de
        jp p,MAXOUT
        pop hl
        push de
MAXOUT: jp (iy)

        db 3,'M','I','N' ; MIN
        dw LINK
LINK = $-6
MIN:    dw $+2
        pop de
        pop hl
        push hl
        and a
        sbc hl,de
        jp m,MINOUT
        pop hl
        push de
MINOUT: jp (iy)

        db 5,'M','I','N' ; MINUS
        dw LINK
LINK = $-6
MINUS:  dw $+2
        ld hl,0
        pop de
        and a
        sbc hl,de
        push hl
        jp (iy)

        db 3,'M','O','D' ; MOD
        dw LINK
LINK = $-6
_MOD:   dw $+2
        exx 
        pop de
        pop bc
        call ISIGN
        call _US
        push bc
        exx
        jp (iy)

    ; TODO sys
        db 4,'M','O','D' ; MODE
        dw LINK
LINK = $-6
_MODE:  dw $+2
        ld hl,MODE
        push hl
        jp (iy)

        db 5,'M','O','D' ; MODU/
        dw LINK
LINK = $-6
MODUDIV:  
        dw $+2
        exx 
        pop de
        pop bc
        call ISIGN
        call _US
        call OSIGN
        push bc
        push hl
        exx
        jp (iy)

        db 4,'M','O','V' ; MOVE
        dw LINK
LINK = $-6
_MOVE:  dw $+2
        exx
        pop de
        pop hl
        pop bc
        and a
        sbc hl,bc
        push bc
        ex (sp),hl
        pop bc
        ex de,hl
        push hl
        and a
        sbc hl,de
        pop hl
        jr nc,MVBTM
        ex de,hl
        inc bc
        ldir
MVOUTM: exx
        jp (iy)
MVBTM:  add hl,bc
        ex de,hl
        add hl,bc
        inc bc
        lddr
        jr MVOUTM

        db 3,'N','O','T' ; NOT
        dw LINK
LINK = $-6
_NOT:   dw $+2
        pop hl
        ld a,l
        or h
        ld de,0
        jp nz,NOUT
        inc e
NOUT:   push de
        jp (iy)

        db 5,'O','C','T' ; OCTAL
        dw LINK
LINK = $-6
_OCTAL: dw $+2
        ld a,8
        ld (BASE),a
        jp (iy)

        db 2,'O','R',0 ; OR
        dw LINK
LINK = $-6
_OR:    dw $+2 
        pop hl
        pop de
        ld a,l
        or e
        ld l,a
        ld a,h
        or d
        ld h,a
        push hl
        jp (iy)


        db 4,'O','V','E' ; OVER
        dw LINK
LINK = $-6
OVER:   dw $+2
        pop hl
        pop de
        push de
        push hl
        push de
        jp (iy)

        db 3,'P','A','D' ; PAD
        dw LINK
LINK = $-6
_PAD:  dw $+2
        ; TODO pad
        jp (iy)


        db 2,'R','>',0 ; R>
        dw LINK
LINK = $-6
RGT:    dw $+2
        ld l,(ix+0)
        inc ix
        ld h,(ix+0)
        inc ix
        push hl
        jp (iy)

        db 4,'R','R','O' ; RROT
        dw LINK
LINK = $-6
RROT:   dw $+2
        pop hl
        pop de
        ex (sp),hl
        push hl
        push de
        jp (iy)

        db 2,'S','*',0 ; S*
        dw LINK
LINK = $-6
SMUL:   dw $+2
        exx
        pop bc
        pop de
        call ISIGN
        call _US
        call OSIGN
        push hl
        exx
        jp (iy)

        db 4,'S','I','G' ; SIGN
        dw LINK
LINK = $-6
_SIGN:  dw $+2
        bit 7,(ix+0)
        jr z,SGOUT
        ld l,0x2d
        push hl
SGOUT:  jp (iy)

        db 6,'S','I','N' ; SINGLE
        dw LINK
LINK = $-6
SINGLE: dw $+2
        pop hl
        push hl
        ld l,h
        ld a,h
        and a
        jr z,SINOUT
        inc hl
SINOUT: push hl
        jp (iy)

        db 5,'S','P','A' ; SPACE
        dw LINK
LINK = $-6
_SPACE: dw $+2
        ld a,0x20
        call _ECHO
        jp (iy)

    ; TODO sys
        db 5,'S','T','A' ; STATE
        dw LINK
LINK = $-6
_STATE: dw $+2
        ld hl,STATE
        push hl
        jp (iy)

        db 4,'S','W','A' ; SWAP
        dw LINK
LINK = $-6
_SWAP:  dw $+2
        pop hl
        ex (sp),hl
        push hl
        jp (iy)

        db 4,'W','A','I' ; WAIT
        dw LINK
LINK = $-6
WAIT:   dw $+2
        ; TODO wait
        jp (iy)

        db 3,'X','O','R' ; XOR
        dw LINK
LINK = $-6
_XOR:   dw $+2
        pop hl
        pop de
        ld a,l
        xor e
        ld l,a
        ld a,h
        xor d
        ld h,a
        push hl
        jp (iy)


STACK equ 0xC000
RETURN equ 0xD000
DICT equ 0xE000

LBLEN equ 128
LINEDEL equ 0x0e
BACKSP equ 0x0c
CR equ 0x0d


RSTMSG  db 3,'RST'
SRTMSG  db 3,'SRT'
QMSG    db 1,'?'
OKMSG   db 2,'OK'
STKMSG  db 5,'STACK'

        align 256
;SYSBLOCK .256 db 0
SYSBLOCK:
MODE    dw 0
DP      dw DICT
CONTEXT dw _CORE
CURRENT dw _CORE
LBP     dw 0
COMPILER dw IMMTOP
BASE    db 0
STATE   db 0


        align 256
LBUFFER .128 db 0
LBEND equ $-2
        db 0

