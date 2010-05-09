INITDISPLAY:
	ldi r16,0xFF
	out lcd_dddr,r16	; command er output
	out lcd_cddr,r16	; data er output

	cbi lcd_cprt,lcd_en	; enable = 0
	call delay_2ms
	ldi DISPLAY_DATA,0x38		; lcd 5x7 matrix 2 linier
	call cmdwrt
	call delay_2ms
	ldi DISPLAY_DATA,0x0C		; display tændt, cursor on
	call cmdwrt
	ldi DISPLAY_DATA,0x01		; clear lcd
	call cmdwrt
	call delay_2ms
	ldi DISPLAY_DATA,0x06		; shift cursor right
	call cmdwrt
	ret

display_line_1:
	ldi DISPLAY_DATA,0x80		; Move to line 1
	call cmdwrt
	call delay_2ms
	lds DISPLAY_DATA, C10
	call datawrt
	lds DISPLAY_DATA, C11
	call datawrt
	lds DISPLAY_DATA, C12
	call datawrt
	lds DISPLAY_DATA, C13
	call datawrt
	lds DISPLAY_DATA, C14
	call datawrt
	lds DISPLAY_DATA, C15
	call datawrt
	lds DISPLAY_DATA, C16
	call datawrt
	lds DISPLAY_DATA, C17
	call datawrt
	lds DISPLAY_DATA, C18
	call datawrt
	lds DISPLAY_DATA, C19
	call datawrt
	lds DISPLAY_DATA, C1A
	call datawrt
	lds DISPLAY_DATA, C1B
	call datawrt
	lds DISPLAY_DATA, C1C
	call datawrt
	lds DISPLAY_DATA, C1D
	call datawrt
	lds DISPLAY_DATA, C1E
	call datawrt
	lds DISPLAY_DATA, C1F
	call datawrt
	ret

display_message_at_pos:
	mov DISPLAY_DATA,POS	; Position on LCD. 
	call cmdwrt
	call display_message
	ret
	
display_message:
	LPM DISPLAY_DATA,Z+
	CPI DISPLAY_DATA,0		; Compare DISPLAY_DATA with 0
	BREQ display_finished		; Exit if 0
	CALL datawrt	; Write data
	rjmp display_message
	
display_finished:
	ret
	
cmdwrt:
		out lcd_dprt,DISPLAY_DATA
		cbi lcd_cprt,lcd_rs			;rs=0 for command
		cbi lcd_cprt,lcd_rw			;rw=0 for write

		sbi lcd_cprt,lcd_en			;en=1 
		call sdelay			;
		cbi lcd_cprt,lcd_en	; lang H-to-L puls
		call delay_100us
		ret

datawrt:
		out lcd_dprt,DISPLAY_DATA
		sbi lcd_cprt,lcd_rs
		cbi lcd_cprt,lcd_rw

		sbi lcd_cprt,lcd_en	;
		call sdelay			; lang H-to-L puls
		cbi lcd_cprt,lcd_en	;
		call delay_100us
		ret

sdelay: nop
		nop
		ret

delay_100us:
		push DELAY_COUNTER
		ldi DELAY_COUNTER,60
dr0:	call sdelay
		dec DELAY_COUNTER
		brne dr0
		pop DELAY_COUNTER
		ret

delay_2ms: 
		push DELAY_COUNTER
		ldi DELAY_COUNTER,20
ldr0:	call delay_100us
		dec DELAY_COUNTER
		brne ldr0
		pop DELAY_COUNTER
		ret