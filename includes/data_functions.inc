clean_num:
	lds TEMP1, ASCII_C_3		; See if left-most cifre of the number is zero
	cpi TEMP1, 0x30				; replace with a space if it is
	brne done_num_cleaning		; 
	ldi TEMP1, ' '				;
	sts ASCII_C_3, TEMP1		;

	lds TEMP1, ASCII_C_2		; Same for next cifre
	cpi TEMP1, 0x30				; 
	brne done_num_cleaning		; 
	ldi TEMP1, ' '				;
	sts ASCII_C_2, TEMP1		;

done_num_cleaning:
	ret

clean_decimal:
	lds TEMP1, ASCII_D_1		; See if right-most cifre of the decimal is zero
	cpi TEMP1, 0x30				; replace with a space if it is
	brne done_dec_cleaning		; 
	ldi TEMP1, ' '				;
	sts ASCII_D_1, TEMP1		;
	
	lds TEMP1, ASCII_D_2		; Same for next cifre
	cpi TEMP1, 0x30				; 
	brne done_dec_cleaning		; 
	ldi TEMP1, ' '				;
	sts ASCII_D_2, TEMP1		;
	
done_dec_cleaning:
	ret
	

left_shift_decimal:
	lds TEMP1, ASCII_D_3
	cpi TEMP1, 0x30
	brne done_left_shifting
	lds TEMP1, ASCII_D_2		; Move D2 to D3 as D3 = 0
	sts ASCII_D_3, TEMP1		;
	lds TEMP1, ASCII_D_1		; Move D1 to D2
	sts ASCII_D_2, TEMP1		;
	ldi TEMP1, 0x30				;
	sts ASCII_D_1, TEMP1		; Zero
	;call left_shift_decimal		; Call again to see if we shoudl shift more
done_left_shifting:
	ret
	

divide_binary_decimal_by_256:
	ldi DECIMAL, 0						; Reset decimal to zero
	call divide_binary_decimal_by_two	; 2
	call divide_binary_decimal_by_two	; 4
	call divide_binary_decimal_by_two	; 8
	call divide_binary_decimal_by_two	; 16
	call divide_binary_decimal_by_two	; 32
	call divide_binary_decimal_by_two	; 64
	call divide_binary_decimal_by_two	; 128
	call divide_binary_decimal_by_two	; 256
	ret

divide_binary_decimal_by_two:
	lsr NUM
	BRCC no_carry
	lsr DECIMAL
	ldi TEMP1, 0b0101
	add DECIMAL, TEMP1
	rjmp done_dividing
no_carry:
	lsr DECIMAL
done_dividing:
	ret

offset_data:
	cp NUM, ZEROPOINT
	brlo negative_number
positive_number:
	sub NUM, ZEROPOINT
	ldi TEMP1, ' '
	sts DATA_SIGN, TEMP1
	rjmp done_offsetting
negative_number:
	mov TEMP1, ZEROPOINT
	sub TEMP1, NUM
	mov NUM, TEMP1
	ldi TEMP1, '-'
	sts DATA_SIGN, TEMP1
done_offsetting:
	ret
	
massage_data:	; Makes the data 8-bit instead of 10-bit
	lsr DATAH
	ror DATAL
	lsr DATAH
	ror DATAL
	ret