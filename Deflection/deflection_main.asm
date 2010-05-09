.include "../includes/m32def.inc"
.include "../includes/lcdDef.inc"	; Display definitions.
.equ ADCSRA = 0x06	; Kun nødvendig på Mac.

.equ timer_t = 1000

.def TEMP = R16 			; Temp register
.def DELAY_COUNTER = R17  	; Counter used by delays
.def DISPLAY_DATA = R18		; Data to display
.def POS = R19 				; What position on the LCD we want to write to.

; bin2ascii registers
.def NUM = R20				; Number to convert
.def DENOMINATOR = R21
.def QUOTIENT = R22
;.equ ASCII_RESULT = 0x210	; Result
.def ASCII_C_1 = R23
.def ASCII_C_2 = R24
.def ASCII_C_3 = R25

; Other registers
;.def TEMP_COUNT = R26
.def READINGL = R26
.def READINGH = R27
.def ZEROPOINT = R28	; This is where the signal starts. Used in auto-zero-cycle

.def MYSTATE = R29		; State register:
						; | 7 zerocycle set if run | 6 show result if set | 5 ADC has been run | ...

.org 0x00
	jmp Main
.org 0x02
	jmp Main
.org 0x14
	jmp timer_int
.org ADCCaddr
	jmp adc_int

.org 0x100
	
Main:	
	cli
	ldi TEMP,high(RAMEND) ; Init stack
	out SPH,TEMP
	ldi TEMP,low(RAMEND)
	out SPL,TEMP
	
	SBI PORTD,2		; Init INT0-knap
	LDI TEMP,1<<INT0
	OUT GICR,TEMP
	
	ldi TEMP,0b10001010
	out adcsra,TEMP		; enable ADC og ck/128
	ldi TEMP,0b11000000
	out admux,TEMP		; loader admux

	sbi adcsra,adsc	; start konvertering
	
	ldi TEMP,(1<<OCIE1A)
  	out TIMSK,TEMP  ; Enable Timer1 match Interrupt
  	ldi TEMP,0x0
  	out TCCR1A,TEMP
  	ldi TEMP,0xD
  	out TCCR1B,TEMP ; Prescaler 1:1024, CTC mode
  	ldi TEMP,HIGH(timer_t) ; High byte
  	OUT OCR1AH,TEMP
  	ldi TEMP,LOW(timer_t) ; Low byte
  	OUT OCR1AL,TEMP
  	ldi TEMP,0x0
	
	ldi ASCII_C_1, 0x30		; Init Ascii cifres.
	ldi ASCII_C_2, 0x30
	ldi ASCII_C_3, 0x30
	ldi READINGL, 0
	ldi READINGH, 0
	ldi MYSTATE, 0b00000000			; Reset state.
	
	call INITDISPLAY
	
	call display_deflection_header
	
	SEI
	
here:	
	sbrs MYSTATE, 5		; ADC has been run once, so the zeropoint is set.
	call set_zeropoint
	
	sbrc MYSTATE, 6		; Show the current value
	call display_current_value
	
	jmp here

set_zeropoint:
	lsr READINGH	; Divider med 2
	ror READINGL
	lsr READINGH	; Divider med 4
	ror READINGL
	mov ZEROPOINT, READINGL
	cbr MYSTATE, 0b10000000
	ret

adc_int:
	in READINGL,adcl 	; Lower byte of reading
	in READINGH,adch 	; Higher byte of reading
	sbi adcsra,adsc 	; Restart ADC
	sbr MYSTATE, 0b00100000
	reti

timer_int:
	sbr MYSTATE, 0b01000000 		; Time to show the value
	reti

display_current_value:
	lsr READINGH	; Divider med 2
	ror READINGL
	lsr READINGH	; Divider med 4
	ror READINGL
	mov NUM, READINGL
	
	ldi DISPLAY_DATA, 0xC0
	call cmdwrt
	call delay_2ms
	
	;call show_negative_number
	
	cp NUM, ZEROPOINT
	brlo negative_number 		; Branch to display a positive number

positive_number:
	sub NUM, ZEROPOINT
	rjmp display_it
		
negative_number:
	LDI R31,HIGH(MINUS_SIGN<<1)		;
	LDI R30,LOW(MINUS_SIGN<<1)		; Display the minus-sign
	call display_message
	;mov TEMP, ZEROPOINT
	;sub TEMP, NUM
	;mov NUM, TEMP
	rjmp display_it			
	
display_it:
	call display_value
	ret


display_value:
	call Bin2ascii
	mov	DISPLAY_DATA, ASCII_C_3
	call datawrt
	call delay_2ms
	mov	DISPLAY_DATA, ASCII_C_2
	call datawrt
	call delay_2ms
	mov	DISPLAY_DATA, ASCII_C_1
	call datawrt
	call delay_2ms
	LDI R31,HIGH(SPACE<<1)		;
	LDI R30,LOW(SPACE<<1)		; Display the space
	call display_message
	cbr MYSTATE, 0b01000000
	ret

display_deflection_header:
	ldi POS, 0x80
	LDI R31,HIGH(LINE_1<<1)
	LDI R30,LOW(LINE_1<<1)		; Z points to HELLO_WORLD
	call display_message_at_pos
	ret
	
.include "../includes/lcdFunctions.inc" 	; Include LCD functions
.include "../includes/strings.inc"			; Include strings
.include "../includes/bin2ascii.inc"		; Include Binary to Ascii converter function