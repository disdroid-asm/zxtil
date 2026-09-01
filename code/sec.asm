        db 1,'#',0,0
        dw LINK
LINK = $-6
HASH:   dw COLON
        dw _ZERO
        dw _BASE
        dw CFETCH
        dw DIVMOD
        dw ASCII
        dw _SWAP
        dw SEMI

        db 2,'#','S',0
        dw LINK
LINK = $-6
HASHS:  dw COLON
        dw HASH
        dw _DUP
        dw ZEROEQ
        dw _END
        db 0xf8
        dw DROP
        dw SEMI

IMLINK = $
        db 5,'+','L','O'
        dw 0
PLUSLOOP:
        dw COLON
        dw STARHASH,_PLUSLOOP
        dw ENDCOMMA
        dw SEMI

        db 1,'.',0,0
        dw LINK
LINK = $-6
PERIOD: dw COLON
        dw LTHASH
        dw _ABS
        dw HASHS
        dw _SIGN
        dw HASHGT
        dw SEMI

        db 2,'.','R',0
        dw LINK
LINK = $-6
PERIODR:
        dw COLON
        dw TWOMUL
        dw SPMINUS
        dw LTR
        dw LTHASH
        dw _ABS
        dw _SIGN
        dw CRGT
        dw DROP
        dw RGT
        dw SPPLUS
        dw _PAD
        dw _DISPLAY
        dw SEMI


        db 1,'`',0,0
        dw LINK
LINK = $-6
TICK:   dw COLON
        dw ASPACE
        dw TOKEN
        dw _CONTEXT
        dw FETCH
        dw FETCH
        dw SEARCH
        dw _IF
        db 0x0a
        dw ENTRY
        dw SEARCH
        dw _IF
        db 0x03
        dw QUESTION
        dw SEMI

        db 1,':',0,0
        dw LINK
LINK = $-6
_COLON: dw COLON
        dw _CURRENT
        dw FETCH
        dw _CONTEXT
        dw STORE
        dw CREATE
        dw STARHASH,COLON
        dw CASTORE
        dw _MODE
        dw C1SET
        dw SEMI

        db 1,';',0,0
        dw IMLINK
IMLINK = $-6
_SEMI:  dw COLON
        dw STARHASH,SEMI
        dw COMMA
        dw _MODE
        dw C0SET
        dw SEMI

        db 5,';','C','O'
        dw IMLINK
IMLINK = $-6
SEMICODE:  
        dw COLON
        dw STARHASH,SCODE
        dw COMMA
        dw _MODE
        dw C0SET
        dw SEMI

        db 7,'<','B','U'
        dw LINK
LINK = $-6
LTBUILDS: 
        dw COLON
        dw _ZERO
        dw CONSTANT
        dw SEMI

        db 1,'?',0,0
        dw LINK
LINK = $-6
QUESTM: dw COLON
        dw FETCH
        dw PERIOD
        dw SEMI

        db 7,'?','S','E' ; ?SEARCH
        dw LINK
LINK = $-6
QSEARCH: 
        dw COLON
        dw _CONTEXT
        dw FETCH
        dw FETCH
        dw SEARCH
        dw _DUP
        dw _IF
        db 0x20
        dw _MODE
        dw CFETCH
        dw _IF
        db 0x19
        dw DROP
        dw _COMPILER
        dw FETCH
        dw SEARCH
        dw _DUP
        dw _IF
        db 0x06
        dw _ZERO
        dw _ELSE
        db 0x03
        dw _ONE
        dw _STATE
        dw CSTORE
        dw SEMI

        db 7,'?','N','U' ; ?NUMBER
        dw LINK
LINK = $-6
QNUMBER: 
        dw COLON
        dw NUMBER
        dw _IF
        db 0x25
        dw _MODE
        dw CFETCH
        dw _IF
        db 0x19
        dw SINGLE
        dw _IF
        db 0x0c
        dw STARHASH,STARHASH
        dw COMMA
        dw COMMA
        dw _ELSE
        db 0x09
        dw STARHASH,CHASH
        dw COMMA
        dw CCOMMA
        dw _ZERO
        dw _ELSE
        db 0x03
        dw _ONE
        dw SEMI


        db 5,'A','D','U'
        dw LINK
LINK = $-6
ADUMP:  dw COLON
        dw OVER
        dw DO
        dw CRET
        dw _DUP
        dw CHASH
        db 4
        dw APART
        dw APART
        dw WAIT
        dw CHASH
        db 0x10
        dw PLUSLOOP
        dw DROP
        dw SEMI

        db 5,'A','P','A'
        dw LINK
LINK = $-6
APART:  dw COLON
        dw _SPACE
        dw CHASH
        db 8
        dw _ZERO
        dw CDO
        dw _DUP
        dw CFETCH
        dw CHASH
        db 0x80
        dw _OR
        dw _ECHO
        dw _SPACE
        dw ONEPLUS
        dw CLOOP
        dw SEMI

        db 5,'B','E','G'
        dw IMLINK
IMLINK = $-6
_BEGIN: dw COLON
        dw HERE
        dw SEMI

        db 6,'C','+','L'
        dw IMLINK
IMLINK = $-6
CPLUSLOOP: 
        dw COLON
        dw STARHASH,_CPLUSLOOP
        dw ENDCOMMA
        dw SEMI

        db 2,'C','?',0
        dw LINK
LINK = $-6
CQUEST: dw COLON
        dw CFETCH
        dw PERIOD
        dw SEMI

        db 2,'C','A','!'
        dw LINK
LINK = $-6
CASTORE: 
        dw COLON
        dw ENTRY
        dw CHASH
        db 6
        dw PLUS
        dw STORE
        dw SEMI        

        db 9,'C','C','O'
        dw LINK
LINK = $-6
CCONSTANT: 
        dw COLON
        dw CREATE
        dw CCOMMA
        dw SEMICODE
        ld a,(de)
        ld l,a
        ld h,0
        bit 7,l
        jr z,CCSKIP
        dec h
CCSKIP: push hl
        jp (iy)

        db 3,'C','D','O'
        dw IMLINK
IMLINK = $-6
CDO:    dw COLON
        dw STARHASH,_CDO
        dw DOCOMMA
        dw SEMI

        db 6,'C','L','E'
        dw IMLINK
IMLINK = $-6
CLEAVE: dw COLON
        dw STARHASH,_CLEAVE
        dw COMMA
        dw SEMI

        db 5,'C','L','O'
        dw IMLINK
IMLINK = $-6
CLOOP:  dw COLON
        dw STARHASH,_CLOOP
        dw COMMA
        dw SEMI

SCODE:  dw COLON
        dw RGT
        dw CASTORE
        dw SEMI

        db 8,'C','O','N'
        dw LINK
LINK = $-6
CONSTANT: 
        dw COLON
        dw CREATE
        dw COMMA
        dw SEMICODE
        ex de,hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        push de
        jp (iy)

        db 6,'C','R','E'
        dw LINK
LINK = $-6
CREATE: dw COLON
        dw ENTRY
        dw ASPACE
        dw TOKEN
        dw HERE
        dw CURRENT
        dw FETCH
        dw STORE
        dw CHASH
        db 4
        dw _DP
        dw PLUSSTORE
        dw COMMA
        dw HERE
        dw TWOPLUS
        dw COMMA
        dw SEMI
        
        db 9,'C','V','A'
        dw LINK
LINK = $-6
CVARIABLE: 
        dw COLON
        dw CCONSTANT
        dw SEMICODE
        push de
        jp (iy)

        db 2,'D','O',0
        dw IMLINK
IMLINK = $-6
DO:     dw COLON
        dw STARHASH,_DO
        dw DOCOMMA
        dw SEMI

        db 3,'D','O',','
        dw LINK
LINK = $-6
DOCOMMA:
        dw COLON
        dw COMMA
        dw HERE
        dw SEMI

        db 5,'D','O','E' ; DOES>
        dw LINK
LINK = $-6
DOES:   dw COLON
        dw RGT
        dw ENTRY
        dw CHASH
        db 8
        dw PLUS
        dw STORE
        dw SEMICODE
        dec ix
        ld (ix+0),b
        dec ix
        ld (ix+0),c
        ex de,hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        push hl
        jp (iy)

        db 4,'D','U','M' ; DUMP
        dw LINK
LINK = $-6
DUMP:   dw COLON
        dw OVER
        dw _DO
        dw CRET
        dw _DUP
        dw CHASH
        db 4
        dw PERIODR
        dw PART
        dw PART
        dw WAIT
        dw CHASH
        db 10
        dw _PLUSLOOP
        dw DROP
        dw SEMI

        db 4,'E','L','S' ; ELSE
        dw IMLINK
IMLINK = $-6
__ELSE: dw COLON
        dw STARHASH,_ELSE
        dw DOCOMMA
        dw _ZERO
        dw CCOMMA
        dw _SWAP
        dw THEN
        dw SEMI

        db 3,'E','N','D' ; END
        dw IMLINK
IMLINK = $-6
__END:  dw COLON
        dw STARHASH,_END
        dw ENDCOMMA
        dw SEMI

        db 4,'E','N','D' ; END,
        dw LINK
LINK = $-6
ENDCOMMA:
        dw COLON
        dw COMMA
        dw HERE
        dw _SUB
        dw CCOMMA
        dw SEMI

        db 5,'E','N','T' ; ENTRY
        dw LINK
LINK = $-6
ENTRY:  dw COLON
        dw _CURRENT
        dw FETCH
        dw FETCH
        dw SEMI

        db 5,'E','R','A' ; ERASE
        dw LINK
LINK = $-6
ERASE:  dw COLON
        dw ONEPLUS
        dw _SWAP
        dw _DO
        dw ASPACE
        dw IGT
        dw CSTORE
        dw _LOOP
        dw SEMI

        db 4,'F','I','L' ; FILL
        dw LINK
LINK = $-6
FILL:   dw COLON
        dw ONEPLUS
        dw _SWAP
        dw _DO
        dw _DUP
        dw IGT
        dw CSTORE
        dw _LOOP
        dw DROP
        dw SEMI

        db 6,'F','O','R' ; FORGET
        dw LINK
LINK = $-6
FORGET: dw COLON
        dw _CURRENT
        dw FETCH
        dw _CONTEXT
        dw STORE
        dw TICK
        dw _DUP
        dw CHASH
        db 2
        dw _SUB
        dw FETCH
        dw CURRENT
        dw FETCH
        dw STORE
        dw CHASH
        db 6
        dw _SUB
        dw _DP
        dw STORE
        dw SEMI

        db 2,'I','F',0 ; IF
        dw IMLINK
IMLINK = $-6
__IF:   dw COLON
        dw STARHASH,_IF
        dw DOCOMMA
        dw _ZERO
        dw CCOMMA
        dw SEMI

        db 9,'I','M','M' ; IMMEDIATE
        dw LINK
LINK = $-6
IMMEDIATE: 
        dw COLON
        dw ENTRY
        dw _DUP
        dw CHASH
        db 4
        dw PLUS
        dw _DUP
        dw FETCH
        dw _CURRENT
        dw FETCH
        dw STORE
        dw _COMPILER
        dw FETCH
        dw _SWAP
        dw STORE
        dw _COMPILER
        dw STORE
        dw SEMI

        db 5,'L','E','A' ; LEAVE
        dw LINK
LINK = $-6
LEAVE:  dw COLON
        dw STARHASH,_LEAVE
        dw COMMA
        dw SEMI

        db 4,'L','O','O' ; LOOP
        dw LINK
LINK = $-6
LOOP:   dw COLON
        dw STARHASH,_LOOP
        dw ENDCOMMA
        dw SEMI

        db 4,'N','E','X' ; NEXT
        dw LINK
LINK = $-6
_NEXT:  dw COLON
        dw STARHASH,0xe9fd
        dw COMMA
        dw SEMI

        db 4,'P','A','R' ; PART
        dw LINK
LINK = $-6
PART:   dw COLON
        dw _SPACE
        dw CHASH
        db 8
        dw _ZERO
        dw CDO
        dw _DUP
        dw CFETCH
        dw CHASH
        db 3
        dw PERIODR
        dw ONEPLUS
        dw _CLOOP
        dw SEMI

        db 4,'T','H','E' ; THEN
        dw LINK
LINK = $-6
THEN:   dw COLON
        dw HERE
        dw OVER
        dw _SUB
        dw _SWAP
        dw CSTORE
        dw SEMI

        db 8,'V','A','R' ; VARIABLE
        dw LINK
LINK = $-6
VARIABLE:
        dw COLON
        dw CONSTANT
        dw SEMICODE
        push de
        jp (iy)

        db 10,'V','O','C' ; VOCBULARY
        dw LINK
LINK = $-6
VOCABULARY:
        dw COLON
        dw LTBUILDS
        dw ENTRY
        dw COMMA
        dw DOES
        dw _CONTEXT
        dw STORE
        dw SEMI

        db 5,'W','H','I' ; WHILE
        dw IMLINK
IMLINK = $-6
__WHILE: 
        dw COLON
        dw _SWAP
        dw STARHASH,_WHILE
        dw ENDCOMMA
        dw THEN
        dw SEMI

        db 1,'[',0,0 ; [
        dw IMLINK
IMLINK = $-6
LSQBRK: dw COLON
        dw STARHASH,STRLIT
        dw COMMA
        dw CHASH
        db 0x5d
        dw TOKEN
        dw HERE
        dw CFETCH
        dw ONEPLUS
        dw _DP
        dw PLUSSTORE
        dw SEMI


OUTER:  ;dw COLON
OUTERLP:
        dw TYPE
        dw INLINE
        dw ASPACE
        dw TOKEN
        dw QSEARCH
        dw _IF
        db 0x0b
        dw QNUMBER
        dw _END
        db 0xf3
        dw QUESTION
        dw _WHILE
        db 0xea
        dw EXECUTE        
        dw _WHILE
        db 0xe9
        

IMMTOP = IMLINK
CORETOP = LINK
