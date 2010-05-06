.include "../includes/m32def.inc"

.equ lcd_dprt = PORTC
.equ lcd_dddr = DDRC
.equ lcd_dpin = PINC

.equ lcd_cprt = PORTD
.equ lcd_cddr = DDRD
.equ lcd_cpin = PIND

.equ lcd_rs = 5
.equ lcd_rw = 4
.equ lcd_en = 3


		ldi r16,high(RAMEND)	; sæt stakken op
		out sph,r16
		ldi r16,low(RAMEND)
		out spl,r16

		ldi r16,0xFF
		out lcd_dddr,r16	; command er output
		out lcd_cddr,r16	; data er output

		cbi lcd_cprt,lcd_en	; enable = 0
		call delay_2ms
		ldi r18,0x38		; lcd 5x7 matrix 2 linier
		call cmdwrt
		call delay_2ms
		ldi r18,0x0E		; display tændt, cursor on
		call cmdwrt
		ldi r18,0x01		; clear lcd
		call cmdwrt
		call delay_2ms
		ldi r18,0x06		; shift cursor right
		call cmdwrt
		
		LDI R31,HIGH(NIS_STYRER<<1)
		LDI R30,LOW(NIS_STYRER<<1)		; Z points to HELLO_WORLD
		
LOOP:	LPM R18,Z+
		CPI R18,0		; Compare R16 with 0
		BREQ here		; Exit if 0
		CALL datawrt	; Write data
		rjmp LOOP
		
here:	jmp here

.include "../includes/strings.inc"

cmdwrt:
		out lcd_dprt,r18
		cbi lcd_cprt,lcd_rs			;rs=0 for command
		cbi lcd_cprt,lcd_rw			;rw=0 for write
		
		sbi lcd_cprt,lcd_en			;en=1 
		call sdelay			;
		cbi lcd_cprt,lcd_en	; lang H-to-L puls
		call delay_100us
		ret

datawrt:
		out lcd_dprt,r18
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
		push r17
		ldi r17,60
dr0:	call sdelay
		dec r17
		brne dr0
		pop r17
		ret

delay_2ms: 
		push r17
		ldi r17,20
ldr0:	call delay_100us
		dec r17
		brne ldr0
		pop r17
		ret
