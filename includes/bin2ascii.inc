Bin2ascii:
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
	
;Bin2ascii_dec:
;	ldi TEMP1, 10
;	rcall Divide_dec
;	ori DECIMAL, 0x30
;	sts ASCII_D_1, DECIMAL
;	mov DECIMAL, TEMP2
;	rcall Divide_dec
;	ori DECIMAL, 0x30
;	sts ASCII_D_2, DECIMAL
;	ori TEMP2, 0x30
;	sts ASCII_D_3, TEMP2
;	ret
;
;Divide_dec:
;	ldi TEMP2,0
;L1_dec:	inc	TEMP2
;	sub DECIMAL, TEMP1
;	brcc L1_dec
;	dec TEMP2
;	add DECIMAL, TEMP1
;	ret