; String handling routines

; ." - read a string from the input buffer up to " and then print it
; compile mode only - TODO 
        db 2,'.','"',0
        dw IMLINK
IMLINK = $-6
DOTQUOTE: 
        dw COLON
        dw STRCOMP

        ; compile the string address literal
        dw STARHASH,STARHASH
        dw COMMA
        dw COMMA

        ; compile TYPE
        dw STARHASH,TYPE
        dw COMMA
        dw SEMI

; read a string from the input buffer to the dictionary and compile it's literal address
        db 1,'"',0,0
        dw IMLINK
IMLINK = $-6
QUOTELIT: 
        dw COLON
        dw STRCOMP

        ; compile the string address literal
        dw STARHASH,STARHASH
        dw COMMA
        dw COMMA

        dw SEMI



; copy a string from input buffer to the dictionary up to the " character. Leave the address of the string
; on the stack.
STRCOMP: ; ( -- string )
        dw COLON

        dw _DP
        dw FETCH ; the address of the string in the dictionary left on stack

        dw STARHASH,QUOTE
        dw COMMA
        dw _DP
        dw FETCH
        dw _DUP
        dw _ZERO
        dw CCOMMA ; store the length byte starting at 0
        ; read the string ...
        dw _LBP
        dw FETCH

DQLOOP: ; ( strpos strstart ) string post starting from LBP, ptr to length byte in dictionary
        dw _DUP
        dw CFETCH
        dw _DUP
        dw CHASH
        db '"'
        dw EQUALS
        dw ZEROEQ
        dw _IF
        db DQDONE - $

        dw CCOMMA ; store the character
        dw ONEPLUS ; increment the pointer

        dw _SWAP
        dw _DUP
        dw _ONE
        dw _SWAP
        dw CPLUSSTORE ; increment the length byte
        dw _SWAP

        dw _WHILE
        db DQLOOP - $

DQDONE:
        dw DROP ; drop the " character

        dw ONEPLUS ; increment the source ptr
        dw _LBP
        dw STORE

        dw SEMI

; Primitive to process quoted string in the dictionary. This proceeds the string data and 
; puts the address of the string on the stack then advances the instruction pointer to the 
; address after the string.
; ( -- string )
QUOTE:  dw $+2
_QUOTE: 
        push bc     ; address of the string in the dictionary
        ld a,(bc)   ; advance the instruction pointer by the length of the string
        inc bc
        add c
        ld c,a
        jr nc,QDONE
        inc b
QDONE:  jp (iy)

        