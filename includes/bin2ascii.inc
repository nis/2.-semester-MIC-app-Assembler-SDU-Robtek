; bin2ascii registers
;.def NUM = R20				; Number to convert
;.def DENOMINATOR = R21
;.def QUOTIENT = R22
;.equ ASCII_RESULT = 0x210	; Result


Bin2ascii:
	ldi DENOMINATOR, 10
	rcall Divide
	ori NUM, 0x30
	mov ASCII_C_1, NUM
	mov NUM, QUOTIENT
	rcall Divide
	ori NUM, 0x30
	mov ASCII_C_2, NUM
	ori QUOTIENT, 0x30
	mov ASCII_C_3, QUOTIENT
	ret
	
Bin2asciiOLD:
	ldi XL, LOW(ASCII_RESULT)		; Save to here
	ldi XH, HIGH(ASCII_RESULT)
	ldi DENOMINATOR, 10
	rcall Divide
	ori NUM, 0x30
	st X+, NUM
	mov NUM, QUOTIENT
	rcall Divide
	ori NUM, 0x30
	st X+, NUM
	ori QUOTIENT, 0x30
	st X+, QUOTIENT
	ret

Divide:
	ldi QUOTIENT,0
L1:	inc	QUOTIENT
	sub NUM, DENOMINATOR
	brcc L1
	dec QUOTIENT
	add NUM, DENOMINATOR
	ret