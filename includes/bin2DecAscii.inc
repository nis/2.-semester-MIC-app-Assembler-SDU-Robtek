; Demonstrates floating point conversion
; in Assembler, (C)2003 www.avr-asm-tutorial.net
;
; The task: You read in a 10-bit result of an
;    analogue-digital-converter, number is in the
;    range from hex 0000 to 03FF.
;    You need to convert this into a floating point
;    number in the range from 0.000 to 5.000 Volt
;
; The program scheme:
;    1. Check that the number is smaller than $0400.
;       Prevent illegal overflows during the
;       following multiplication.
;    2. Multiplication by 320,313 (hex 04E338).
;       That step multiplies by 5,000, 65536 and
;       divides by 1023 in one step!
;    3. Round the result and cut the last two bytes
;       of the result.
;       This step divides by 65536 by ignoring the
;       last two bytes of the result. Before doing
;       that, bit 15 is used to round the result.
;    4. Convert the resulting word to ASCII and set
;       the correct decimal point
;       The resulting word in the range from 0 to
;       5.000 is displayed in ASCII-characters
;
; The registers used:
;    The routines use the registers R26..R17 without
;    saving these before. Also required is a multi-
;    purpose register called TEMP1, located in the
;    upper half of the registers. Please take care
;    that this register doesn't conflict with the
;    register use in the rest of your program.
;
;    When entering the routine the 10-bit number is
;    expected in the register pair R18:R17.
;    If the number is greater than $03FF then the
;    check routine returns with the carry flag set,
;    and the resulting string in R21:R22:R23:R24:R25:R26
;    is set to the null-terminated ASCII-string
;    "E.EEEE".
;    The multiplication uses R22:R21:R20:R19 to hold
;    the multiplicator 320.313 (is shifted left
;    max. ten times during multiplication)
;    The result of the multiplication is calculated
;    in the registers R26:R25:R24:R23.
;    The result of the so called division by 65536
;    by just ignoring R24:R23 in the result, is in
;    R26:R25. R26:R25 is rounded, depending on the
;    highest bit of R24, and the result is copied to
;    R18:R17.
;    Conversion to an ASCII-string uses the input
;    in R18:R17, the register pair R20:R19 as a divisor
;    for conversion, and places the ASCII result
;    string to R21:R22:R23:R24:R25:R26 (null-terminated).
;
; Other conventions:
;   The conversion uses subroutines and the stack.
;   The stack must work fine for the use of three
;   levels (six bytes SRAM).
;
; Conversion times:
;   The whole routine requires 326 clock cycles
;   maximum (converting $03FF), and 111 clock cycles
;   minimum (converting $0000). At 4 MHz the times
;   are 81.25 microseconds resp. 27.5 microseconds.
;
; Definitions:
;   Registers
;.DEF TEMP1 = R16 ; used as multi-purpose register
;
;   AVR type
;   Tested for type AT90S8515, only required for
;   stack setting, routines work fine with other
;   AT90S-types also
;.NOLIST
;.INCLUDE "8515def.inc"
;.LIST
;
; Start of test program
;
; Just writes a number to R18:R17 and starts the
; conversion routine, for test purposes only
;
;.CSEG
;.ORG $0000
;	rjmp main
;
;main:
;	ldi TEMP1,HIGH(RAMEND) ; Set the stack
;	out SPH,TEMP1
;	ldi TEMP1,LOW(RAMEND)
;	out SPL,TEMP1
;	ldi TEMP1,$03 ; Convert $03FF
;	mov R18,TEMP1
;	ldi TEMP1,$FF
;	mov R17,TEMP1
;	rcall fpconv10 ; call the conversion routine
;no_end:   ; unlimited loop, when done
;	rjmp no_end
;
; Conversion routine wrapper, calls the different conversion steps
;
fpconv10:
	rcall fpconv10c ; Check the input value in R18:R17
	brcs fpconv10e ; if carry set, set "E.EEE"
        rcall fpconv10m ; multiplicate by 320,313
	rcall fpconv10r ; round and divide by 65536
	rcall fpconv10a ; convert to ASCII string
	rjmp fpconv10f ; set decimal point and null-termination
fpconv10e:
	ldi TEMP1,'E' ; set error condition to result string
	mov R21,TEMP1
	mov R23,TEMP1
	mov R24,TEMP1
	mov R25, TEMP1
fpconv10f:
	ldi TEMP1,',' ; set decimal point
	mov R22,TEMP1
	clr TEMP1 ; null-terminate ASCII string
	mov R26,TEMP1
	ret ; all done
;
; Subroutine inputcheck
;
fpconv10c:
	ldi TEMP1,$03 ; compare MSB with 03
	cp TEMP1,R18 ; if R18>$03, set carry on return
	ret
;
; Subroutine multiplication by 320,313
;
; Starting conditions:
; +---+---+
; | R18+ R17|  Input number
; +---+---+
; +---+---+---+---+
; | R22| R21| R20| R19| Multiplicant 320.313 = $00 04 E3 38
; | 00| 04| E3| 38|
; +---+---+---+---+
; +---+---+---+---+
; |R26| R25| R24| R23| Result
; | 00| 00| 00| 00|
; +---+---+---+---+
;
fpconv10m:
	clr R22 ; set the multiplicant to 320.313
	ldi TEMP1,$04
	mov R21,TEMP1
	ldi TEMP1,$E3
	mov R20,TEMP1
	ldi TEMP1,$38
	mov R19,TEMP1
	clr R26 ; clear the result
	clr R25
	clr R24
	clr R23
fpconv10m1:
	mov TEMP1,R17 ; check if the number is clear
	or TEMP1,R18 ; any bit of the word a one?
	brne fpconv10m2 ; still one's, go on convert
	ret ; ready, return back
fpconv10m2:
	lsr R18 ; shift MSB to the right (div by 2)
	ror R17 ; rotate LSB to the right and set bit 7
	brcc fpconv10m3 ; if the lowest bit was 0, then skip adding
        add R23,R19 ; add the number in R22:R21:R20:R19 to the result
	adc R24,R20
	adc R25,R21
	adc R26,R22
fpconv10m3:
	lsl R19 ; multiply R22:R21:R20:R19 by 2
	rol R20
	rol R21
	rol R22
	rjmp fpconv10m1 ; repeat for next bit
;
; Round the value in R26:R25 with the value in bit 7 of R24
;
fpconv10r:
	clr TEMP1 ; put zero to TEMP1
	lsl R24 ; rotate bit 7 to carry
	adc R25,TEMP1 ; add LSB with carry
	adc R26,TEMP1 ; add MSB with carry
	mov R18,R26 ; copy the value to R18:R17 (divide by 65536)
	mov R17,R25
	ret
;
; Convert the word in R18:R17 to an ASCII string in R21:R22:R23:R24:R25:R26
;
; +---+---+
; + R18| R17| Input value 0..5,000
; +---+---+
; +---+---+
; | R20| R19| Decimal divider value
; +---+---+
; +---+---+---+---+---+---+
; | R21| R22| R23| R24| R25|R26| Resulting ASCII string (for input value 5,000)
; |'5'|'.'|'0'|'0'|'0'|$00| null-terminated
; +---+---+---+---+---+---+
;
fpconv10a:
	ldi TEMP1,HIGH(1000) ; Set the decimal divider value to 1,000
	mov R20,TEMP1
	ldi TEMP1,LOW(1000)
	mov R19,TEMP1
	rcall fpconv10d ; get ASCII digit by repeated subtraction
	mov R21,TEMP1 ; set thousands string char
	clr R20 ; Set the decimal divider value to 100
	ldi TEMP1,100
	mov R19,TEMP1
	rcall fpconv10d ; get the next ASCII digit
	mov R23,TEMP1 ; set hundreds string char
	ldi TEMP1,10 ; Set the decimal divider value to 10
    mov R19,TEMP1
	rcall fpconv10d ; get the next ASCII digit
	mov R24,TEMP1 ; set tens string char
	ldi TEMP1,'0' ; convert the rest to an ASCII char
	add TEMP1,R17
	mov R25,TEMP1 ; set ones string char
	ret
;
; Convert binary word in R18:R17 to a decimal digit by substracting
; the decimal divider value in R20:R19 (1000, 100, 10)
;
fpconv10d:
	ldi TEMP1,'0' ; start with decimal value 0
fpconv10d1:
	cp R17,R19 ; Compare word with decimal divider value
	cpc R18,R20
	brcc fpconv10d2 ; Carry clear, subtract divider value
	ret ; done subtraction
fpconv10d2:
	sub R17,R19 ; subtract divider value
	sbc R18,R20
	inc TEMP1 ; up one digit
	rjmp fpconv10d1 ; once again
;
; End of floating point conversion routines
;
;
; End of conversion test routine
;