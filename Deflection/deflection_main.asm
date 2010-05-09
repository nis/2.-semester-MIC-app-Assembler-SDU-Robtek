.include "../includes/m32def.inc"
.include "../includes/lcdDef.inc"	; Display definitions.
.equ ADCSRA = 0x06	; Kun nødvendig på Mac.

.equ timer_t = 200

.def TEMP1 = R16 			; Temp register
.def TEMP2 = R17 			; Temp register
.def DELAY_COUNTER = R18  	; Counter used by delays
.def DISPLAY_DATA = R19		; Data to display
.def MYSTATE = R20			; State register:
							; 	7 zerocycle set if run
							;	6 show result if set
							;	5 ADC has been run

; bin2ascii registers
.def NUM = R21				; Number to convert

; Data registers
.def DATAL = R22
.def DATAH = R23
.def ZEROPOINT = R24	; This is where the signal starts. Used in auto-zero-cycle


; Memory
.equ ASCII_C_1 = 0x210
.equ ASCII_C_2 = 0x211
.equ ASCII_C_3 = 0x212
.equ DATA_SIGN = 0x213

.equ C10	= 0x220		; Line 1
.equ C11	= 0x221		; 
.equ C12	= 0x222		; 
.equ C13	= 0x223		; 
.equ C14	= 0x224		; 
.equ C15	= 0x225		; 
.equ C16	= 0x226		; 
.equ C17	= 0x227		; 
.equ C18	= 0x228		; 
.equ C19	= 0x229		; 
.equ C1A	= 0x22A		; 
.equ C1B	= 0x22B		; 
.equ C1C	= 0x22C		; 
.equ C1D	= 0x22D		; 
.equ C1E	= 0x22E		; 
.equ C1F	= 0x22F		; 

.equ C20	= 0x230		; Line 2
.equ C21	= 0x231		; 
.equ C22	= 0x232		; 
.equ C23	= 0x233		; 
.equ C24	= 0x234		; 
.equ C25	= 0x235		; 
.equ C26	= 0x236		; 
.equ C27	= 0x237		; 
.equ C28	= 0x238		; 
.equ C29	= 0x239		; 
.equ C2A	= 0x23A		; 
.equ C2B	= 0x23B		; 
.equ C2C	= 0x23C		; 
.equ C2D	= 0x23D		; 
.equ C2E	= 0x23E		; 
.equ C2F	= 0x23F		;

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
	ldi TEMP1, high(RAMEND) ; Init stack
	out SPH,TEMP1
	ldi TEMP1, low(RAMEND)
	out SPL,TEMP1
	
	SBI PORTD,2		; Init INT0-knap
	LDI TEMP1, 1<<INT0
	OUT GICR,TEMP1
	
	ldi TEMP1, 0b10001111
	out adcsra,TEMP1	; enable ADC og ck/128
	ldi TEMP1, 0b11000000
	out admux,TEMP1		; loader admux
    
	sbi adcsra,adsc	; start konvertering
	
	ldi TEMP1, (1<<OCIE1A)
  	out TIMSK,TEMP1  ; Enable Timer1 match Interrupt
  	ldi TEMP1, 0x0
  	out TCCR1A,TEMP1
  	ldi TEMP1, 0xD
  	out TCCR1B,TEMP1 ; Prescaler 1:1024, CTC mode
  	ldi TEMP1, HIGH(timer_t) ; High byte
  	OUT OCR1AH,TEMP1
  	ldi TEMP1, LOW(timer_t) ; Low byte
  	OUT OCR1AL,TEMP1
  	ldi TEMP1, 0x0
	
	;ldi ASCII_C_1, 0x30		; Init Ascii cifres.
	;ldi ASCII_C_2, 0x30
	;ldi ASCII_C_3, 0x30
	ldi DATAL, 0
	ldi DATAH, 0
	ldi MYSTATE, 0b00000000			; Reset state.
	
	call INITDISPLAY
	
	call show_deflection_header
	
	
	SEI
	
here:	
	sbrs MYSTATE, 5		; ADC has been run once, so the zeropoint is set.
	call set_zeropoint
	
	sbrc MYSTATE, 6		; Show the current value
	call show_deflection_steps_line_2
	
	jmp here

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

show_deflection_steps_line_2:
	call massage_data
	mov NUM, DATAL
	call offset_data
	call Bin2ascii		; Make current data to ascii
	lds TEMP1, DATA_SIGN
	sts C20, TEMP1
	lds TEMP1, ASCII_C_3
	sts C21, TEMP1
	lds TEMP1, ASCII_C_2
	sts C22, TEMP1
	lds TEMP1, ASCII_C_1
	sts C23, TEMP1
	ldi TEMP1, ' '
	sts C24, TEMP1
	ldi TEMP1, 's'
	sts C25, TEMP1
	ldi TEMP1, 't'
	sts C26, TEMP1
	ldi TEMP1, 'e'
	sts C27, TEMP1
	ldi TEMP1, 'p'
	sts C28, TEMP1
	ldi TEMP1, 's'
	sts C29, TEMP1
	ldi TEMP1, ' '
	sts C2A, TEMP1
	ldi TEMP1, ' '
	sts C2B, TEMP1
	ldi TEMP1, ' '
	sts C2C, TEMP1
	ldi TEMP1, ' '
	sts C2D, TEMP1
	ldi TEMP1, ' '
	sts C2E, TEMP1
	ldi TEMP1, ' '
	sts C2F, TEMP1
	call display_line_2
	cbr MYSTATE, 0b01000000
	ret


adc_int:
	in DATAL,adcl 	; Lower byte of reading
	in DATAH,adch 	; Higher byte of reading
	sbi adcsra,adsc 	; Restart ADC
	sbr MYSTATE, 0b00100000
	reti

timer_int:
	sbr MYSTATE, 0b01000000 		; Time to show the value
	reti

set_zeropoint:
	call massage_data
	mov ZEROPOINT, DATAL
	cbr MYSTATE, 0b10000000
	ret

massage_data:	; Makes the data 8-bit instead of 10-bit
	lsr DATAH
	ror DATAL
	lsr DATAH
	ror DATAL
	ret
	
.include "../includes/lcdFunctions.inc" 	; Include LCD functions
.include "../includes/bin2ascii.inc"		; Include Binary to Ascii converter function