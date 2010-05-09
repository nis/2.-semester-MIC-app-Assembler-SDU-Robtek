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
;.org 0x14
;	jmp timer_int
;.org ADCCaddr
;	jmp adc_int

.org 0x100
	
Main:	
	;cli
	ldi TEMP,high(RAMEND) ; Init stack
	out SPH,TEMP
	ldi TEMP,low(RAMEND)
	out SPL,TEMP
	
	;SBI PORTD,2		; Init INT0-knap
	;LDI TEMP,1<<INT0
	;OUT GICR,TEMP
	
	;ldi TEMP,0b10001010
	;out adcsra,TEMP		; enable ADC og ck/128
	;ldi TEMP,0b11000000
	;out admux,TEMP		; loader admux
    ;
	;sbi adcsra,adsc	; start konvertering
	;
	;ldi TEMP,(1<<OCIE1A)
  	;out TIMSK,TEMP  ; Enable Timer1 match Interrupt
  	;ldi TEMP,0x0
  	;out TCCR1A,TEMP
  	;ldi TEMP,0xD
  	;out TCCR1B,TEMP ; Prescaler 1:1024, CTC mode
  	;ldi TEMP,HIGH(timer_t) ; High byte
  	;OUT OCR1AH,TEMP
  	;ldi TEMP,LOW(timer_t) ; Low byte
  	;OUT OCR1AL,TEMP
  	;ldi TEMP,0x0
	
	;ldi ASCII_C_1, 0x30		; Init Ascii cifres.
	;ldi ASCII_C_2, 0x30
	;ldi ASCII_C_3, 0x30
	;ldi READINGL, 0
	;ldi READINGH, 0
	;ldi MYSTATE, 0b00000000			; Reset state.
	
	call INITDISPLAY
	
	call show_deflection_header
	
	
	;SEI
	
here:	
	;sbrs MYSTATE, 5		; ADC has been run once, so the zeropoint is set.
	;call set_zeropoint
	
	;sbrc MYSTATE, 6		; Show the current value
	;call display_current_value
	
	jmp here

show_deflection_header:
	ldi TEMP, 'D'
	sts C10, TEMP
	ldi TEMP, 'e'
	sts C11, TEMP
	ldi TEMP, 'f'
	sts C12, TEMP
	ldi TEMP, 'l'
	sts C13, TEMP
	ldi TEMP, 'e'
	sts C14, TEMP
	ldi TEMP, 'c'
	sts C15, TEMP
	ldi TEMP, 't'
	sts C16, TEMP
	ldi TEMP, 'i'
	sts C17, TEMP
	ldi TEMP, 'o'
	sts C18, TEMP
	ldi TEMP, 'n'
	sts C19, TEMP
	ldi TEMP, ':'
	sts C1A, TEMP
	ldi TEMP, ' '
	sts C1B, TEMP
	ldi TEMP, ' '
	sts C1C, TEMP
	ldi TEMP, ' '
	sts C1D, TEMP
	ldi TEMP, ' '
	sts C1E, TEMP
	ldi TEMP, ' '
	sts C1E, TEMP
	call display_line_1
	ret

	
.include "../includes/lcdFunctions.inc" 	; Include LCD functions
.include "../includes/bin2ascii.inc"		; Include Binary to Ascii converter function