; Source: https://github.com/breakintoprogram/lib-spectrum/blob/master/lib/keyboard.z80
;
; Title:	ZX Spectrum Keyboard Routines
; Author:	Dean Belfield
; Created:	29/07/2011
; Last Updated:	29/07/2011
;
; Requires:
;
; Modinfo:
;

; Read the in-game controls
; HL: The control map
; Returns:
;  A: Input flags - 000UDLRF (Up, Down, Left, Right, Fire)
; Zero flag set if no key pressed
;
Read_Controls:		;LD D, 5				; Number of controls to check
			ld d,NUMCONTROLS
			LD E, 0				; The output flags
			LD C,0xFE			; Low is always 0xFE for reading keyboard
Read_Controls1:		LD B,(HL)			; Get the keyboard port address
			INC HL
			IN A,(C)			; Read the rows in
			AND (HL)			; And with the mask
			JR NZ, Read_Controls2		; Skip if not pressed (bit is 0)
			SCF				; Set C flag
Read_Controls2:		RL E				; Rotate the carry flag into E
			INC HL
			DEC D
			JR NZ, Read_Controls1		; Loop
			LD A,E				; Fetch the key flags
			AND A				; Check for 0
			RET				


; As Read_Keyboard, but with debounce
;
Read_Keyboard_Debounce:	CALL Read_Keyboard		; A debounced versiion - Read the keyboard
			AND A				; Quick way to do CP 0
			JR NZ, Read_Keyboard_Debounce	; Loop until key released
1:			CALL Read_Keyboard		; And second loop reading the keyboard
			AND A 				; CP 0
			JR Z, 1B			; Loop until key is pressed
			RET 

; Read the keyboard and return an ASCII character code
; Returns:
;  A: The character code, or 0 if no key pressed
; BC: The keyboard port (0x7FFE to 0xFEFE)
;
Read_Keyboard:		
			LD HL,Keyboard_Map		; Point HL at the keyboard list
			ld a,(controls)
			cp 2
			jr nz,NOCAPS
			ld hl,Keyboard_Map_CAP
NOCAPS:
			cp 1
			jr nz,NOSYM
			ld hl,Keyboard_Map_SYM
NOSYM:
			LD D,8				; This is the number of ports (rows) to check
			LD C,0xFE			; Low is always 0xFE for reading keyboard ports
Read_Keyboard_0:	LD B,(HL)			; Get the keyboard port address
			INC HL				; Increment to keyboard list of table
			IN A,(C)			; Read the row of keys in
			AND 0x1F			; We are only interested in the first five bits
			LD E,5				; This is the number of keys in the row
Read_Keyboard_1:	SRL A				; Shift A right; bit 0 sets carry bit
			JR NC,Read_Keyboard_2		; If the bit is 0, we've found our key
RKSKIP:
			INC HL				; Go to next table address
			DEC E				; Decrement key loop counter
			JR NZ,Read_Keyboard_1		; Loop around until this row finished
			DEC D				; Decrement row loop counter
			JR NZ,Read_Keyboard_0		; Loop around until we are done
			;AND A				; Clear A (no key found)
			xor a
			RET
Read_Keyboard_2:       	
			push af
			LD A,(HL)			; We've found a key at this point; fetch the character code!
			or a	; skip shift keys
			jr z,RKSKIP2
			pop de
			RET
RKSKIP2:	pop af
			jr RKSKIP			

Keyboard_Map:		
			DB 0xFE,0,"z","x","c","v"
			DB 0xFD,"a","s","d","f","g"
			DB 0xFB,"q","w","e","r","t"
			DB 0xF7,"1","2","3","4","5"
			DB 0xEF,"0","9","8","7","6"
			DB 0xDF,"p","o","i","u","y"
			DB 0xBF,13,"l","k","j","h"
			DB 0x7F," ",0,"m","n","b"

Keyboard_Map_CAP:		
			DB 0xFE,0,"Z","X","C","V"
			DB 0xFD,"A","S","D","F","G"
			DB 0xFB,"Q","W","E","R","T"
			DB 0xF7,0x07,"2","3","4",0x08
			DB 0xEF,0x0c,"9",0x09,0x0b,0x0a
			DB 0xDF,"P","O","I","U","Y"
			DB 0xBF,13,"L","K","J","H"
			DB 0x7F," ",0,"M","N","B"

Keyboard_Map_SYM:		
			DB 0xFE,0,":","£","?","/"
			DB 0xFD,"~",0x7c,0x5c,"{","}"
			DB 0xFB,0xc7,0xc9,0xc8,"<",">"
			DB 0xF7,"!","@","#","$","%"
			DB 0xEF,"_",")","(","'","&"
			DB 0xDF,'"',";","#","]","["
			DB 0xBF,13,"=","+","-","^"
			DB 0x7F," ",0,".",",","*"

;Input_Custom:		DB 0xFB, %00000001		; Q (Up)
;			DB 0xFD, %00000001		; A (Down)
;			DB 0xDF, %00000010		; O (Left)
;			DB 0xDF, %00000001		; P (Right)
;			DB 0x7F, %00000001		; Space (Fire)

NUMCONTROLS = 2
Input_Custom:
			db 0xFE, %00000001		; Caps shift
			db 0x7f, %00000010		; Sym shift
