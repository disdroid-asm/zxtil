; String handling routines

; read a string from the input buffer to the dictionary and compile it's literal address

        db 1,'"',0,0
        dw IMLINK
IMLINK = $-6
        dw COLON
        dw STARHASH,QUOTE
        dw COMMA
        dw CHASH
        db '"'
        dw TOKEN
        dw HERE
        dw CFETCH
        dw ONEPLUS
        dw _DP
        dw PLUSSTORE
        dw SEMI        
        

; Primitive to process quoted string in the dictionary. This 
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
