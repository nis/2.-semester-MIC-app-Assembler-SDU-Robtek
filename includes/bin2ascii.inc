Bin2ascii:						; Simple converter from 8-bit binary to ASCII
	ldi TEMP1, 10
	rcall Divide
	ori NUM, 0x30
	sts ASCII_C_1, NUM
	mov NUM, TEMP2
	rcall Divide
	ori NUM, 0x30
	sts ASCII_C_2, NUM
	ori TEMP2, 0x30
	sts ASCII_C_3, TEMP2
	ret

Divide:
	ldi TEMP2,0
L1:	inc	TEMP2
	sub NUM, TEMP1
	brcc L1
	dec TEMP2
	add NUM, TEMP1
	ret