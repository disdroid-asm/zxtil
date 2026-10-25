; String handling routines

; ." - read a string from the input buffer up to " and then print it
        db 2,'.','"',0
        dw LINK
LINK = $-6
DOTQUOTE: 
        dw COLON
        dw MODE
        dw CFETCH
        dw _IF
        db DQCOMP-$
; immediate mode
; ...
        dw SEMI

; compile mode
DQCOMP:
        dw DP
        dw FETCH ; the address of the string in the dictionary left on stack for TYPE
        dw STARHASH,QUOTE
        dw COMMA
        dw DP
        dw FETCH
        dw _DUP
        dw _ZERO
        dw CCOMMA ; store the length byte starting at 0
        ; read the string ...
        dw LBP
        dw FETCH

DQLOOP: ; ( strpos strstart ) string post starting from LBP, ptr to length byte
        dw _DUP
        dw CFETCH
        dw _DUP
        dw CHASH
        db '"'
        dw EQUALS
        dw _IF
        db DQDONE - $

        dw CCOMMA ; store the character
        dw ONEPLUS ; increment the pointer

        dw _SWAP
        dw _DUP
        dw _ONE
        dw CPLUSSTORE ; increment the length byte
        dw _SWAP

        dw _WHILE
        db DQLOOP - $

DQDONE:
        dw DROP ; drop the " character

        ; compile TYPE
        dw STARHASH,STARHASH
        dw COMMA
        dw COMMA
        dw STARHASH,TYPE
        dw COMMA
        dw SEMI

; Code field for quoted string. 
; ( -- string )
QUOTE:  dw $+2
_QUOTE: 
        push bc     ; address of the string in the dictionary
        jp _ELSE_   ; advance the instruction pointer by the length of the string
        
