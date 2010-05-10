.include "../includes/m32def.inc"
.include "../includes/lcdDef.inc"	; Display definitions.
.equ ADCSRA = 0x06	; Kun nødvendig på Mac.

.equ timer_t = 200

.def TEMP1 = R16 			; Temp register
.def TEMP2 = R28 			; Temp register
.def DELAY_COUNTER = R29  	; Counter used by delays
.def DISPLAY_DATA = R30		; Data to display
.def MYSTATE = R31			; State register:
							; 	7 zerocycle set if run
							;	6 show result if set
							;	5 ADC has been run

; Bin2DecAscii converter:
.def ConDATAH = R18		; Put the number to be converted in here
.def ConDATAL = R17		;

; Bin2Ascii converter
; Also uses TEMP1 & TEMP2
.def NUM = R22

; Memory
.equ DATAH = 0x210		; Data from the ADC
.equ DATAL = 0x211		;

.equ ZPOINTH = 0x212	; Zeropoint
.equ ZPOINTL = 0x213	;

.equ DATA_SIGN_10_BIT = 0x214	; The sign of the 10-bit data result here. " " for positive, "-" for negative (Ascii)
.equ DATA_SIGN_8_BIT = 0x215	; The sign of the 8-bit data result here. " " for positive, "-" for negative (Ascii)

.equ ASCII_C_1 = 0x216	; Used for the ASCII result for the steps
.equ ASCII_C_2 = 0x217	; Man, my comments rock. You have no idea what the above line means, right?
.equ ASCII_C_3 = 0x218	;

.equ C10	= 0x220		; Line 1 (Ascii)
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

.equ C20	= 0x230		; Line 2 (Ascii)
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
	
	; Initiate some of my data
	ldi MYSTATE, 0b00000000			; Reset state.
	ldi TEMP1, ' '					; Save sign.
	sts DATA_SIGN_10_BIT, TEMP1		;
	sts DATA_SIGN_8_BIT, TEMP1		;
	
	call INITDISPLAY
	
	;call show_deflection_header
	
	SEI
	
here:	
	sbrs MYSTATE, 5		; ADC has been run once, so the zeropoint is set.
	call set_zeropoint
	
	sbrc MYSTATE, 6		; Show the current value
	call rebuild_display
	;call show_deflection_steps_line_2
	
	jmp here

rebuild_display:
	call build_volts			; Build the part of the display that shows the voltage
	
	ldi TEMP1, ' '				; One char for spacing.
	sts C18, TEMP1				;
	
	call build_steps			; Build the part that shows the 8-bit steps

	call display_line_1
	cbr MYSTATE, 0b01000000
	ret

build_steps:
	call offset_data_8_bit		; Offset the data, 8-bit.
	call Bin2ascii				; Build the ASCII result
	ldi TEMP1, ' '				; Load the chars into RAM
	sts C19, TEMP1
	lds TEMP1, DATA_SIGN_8_BIT
	sts C1A, TEMP1
	lds TEMP1, ASCII_C_3
	sts C1B, TEMP1
	lds TEMP1, ASCII_C_2
	sts C1C, TEMP1
	lds TEMP1, ASCII_C_1
	sts C1D, TEMP1
	ldi TEMP1, ' '
	sts C1E, TEMP1
	ldi TEMP1, 'S'
	sts C1F, TEMP1
	ret

build_volts:
	call offset_data_10_bit		; Offset the data with the Zeropoint
	call fpconv10				; Convert the data to ASCII
	
	lds TEMP1, DATA_SIGN_10_BIT	; Load the chars into RAM
	sts C10, TEMP1
	sts C11, R21
	sts C12, R22
	sts C13, R23
	sts C14, R24
	sts C15, R25
	ldi TEMP1, ' '
	sts C16, TEMP1
	ldi TEMP1, 'V'
	sts C17, TEMP1
	ret


adc_int:
	push TEMP1
	push TEMP2
	in TEMP1, adcl 	; Lower byte of reading
	in TEMP2, adch 	; Higher byte of reading
	sts DATAL, TEMP1
	sts DATAH, TEMP2
	sbr MYSTATE, 0b00100000
	pop TEMP2
	pop TEMP1
	sbi adcsra,adsc 	; Restart ADC
	reti

timer_int:
	sbr MYSTATE, 0b01000000 		; Time to show the value
	reti

set_zeropoint:
	lds TEMP1, DATAH
	sts ZPOINTH, TEMP1
	lds TEMP1, DATAL
	sts ZPOINTL, TEMP1
	cbr MYSTATE, 0b10000000
	ret

offset_data_8_bit:
	lds TEMP1, ZPOINTH			; Load the Zeropoint
	lds TEMP2, ZPOINTL			;
	
	lsr TEMP1					; Make Zeropoint 8-bit.
	ror TEMP2					
	lsr TEMP1	
	ror TEMP2
	mov R22, TEMP2				; Zeropoint in R22
	
	lds TEMP1, DATAH			; Load the data
	lds TEMP2, DATAL			;
	
	lsr TEMP1					; Make Data 8-bit.
	ror TEMP2					
	lsr TEMP1	
	ror TEMP2					; Data in TEMP2
	
	cp TEMP2, R22
	brlo negative_number
positive_number:
	sub TEMP2, R22
	ldi TEMP1, ' '
	sts DATA_SIGN_8_BIT, TEMP1
	rjmp done_offsetting
negative_number:
	mov TEMP1, R22
	sub TEMP1, TEMP2
	mov TEMP2, TEMP1
	ldi TEMP1, '-'
	sts DATA_SIGN_8_BIT, TEMP1
done_offsetting:
	mov NUM, TEMP2				; Result in NUM
	ret

offset_data_10_bit:
	lds TEMP1, ZPOINTH			; Load the Zeropoint
	lds TEMP2, ZPOINTL			;
	lds ConDATAH, DATAH			; Load the data
	lds ConDATAL, DATAL			;
	CP ConDATAL, TEMP2 			; Compare two 16-bit words
	CPC ConDATAH, TEMP1 		; If carry-flag is set, ConDATAx is the biggest
	brcs negative_result		; 
positive_result:
	SUB ConDATAL, TEMP2			; I subtract the Zeropoint from the data.
	SBC ConDATAH, TEMP1			; first the low-byte, then the high-byte, result in ConDATAx
	ldi TEMP1, ' '				; Load sign.
	sts DATA_SIGN_10_BIT, TEMP1	; Save sign
	rjmp done_offsetting_10_bit	; Done.
negative_result:
	SUB TEMP2, ConDATAL			; We subtract the data from the zeropoint.
	SBC TEMP1, ConDATAH			; first the low-byte, then the high-byte, result in TEMPx
	mov ConDATAH, TEMP1			; Save the result
	mov ConDATAL, TEMP2			;
	ldi TEMP1, '-'				; Load sign.
	sts DATA_SIGN_10_BIT, TEMP1	; Save sign
	rjmp done_offsetting_10_bit	; Done.
done_offsetting_10_bit:
	ret

.include "../includes/lcdFunctions.inc" 	; Include LCD functions	
;.include "../includes/data_functions.inc" 	; Include LCD functions
.include "../includes/bin2ascii.inc"		; Include Binary to Ascii converter function
.include "../includes/bin2DecAscii.inc" 	; Include LCD functions