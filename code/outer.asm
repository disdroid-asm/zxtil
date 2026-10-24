
; The outer loop for the interactive interpreter

;OUTER:  
OUTER_INTERACTIVE:
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
