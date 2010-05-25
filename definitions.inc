.equ ADCSRA = 0x06					; Only necessary on Mac.

.equ timer_t = 200					; Ticks for TIMER1

.def TEMP1 = R16 					; Temp register
.def TEMP2 = R28 					; Temp register
.def DELAY_COUNTER = R29  			; Counter used by delays
.def DISPLAY_DATA = R30				; Data to display
.def MYSTATE = R31					; State register:
									; 	7 zerocycle set if run
									;	6 show result if set
									;	5 ADC has been run

; Bin2DecAscii converter:
.def ConDATAH = R18					; Put the number to be converted in here
.def ConDATAL = R17					;

; Bin2Ascii converter
; Which also uses TEMP1 & TEMP2
.def NUM = R22

; Memory
.equ DATAH = 0x210					; Data from the ADC
.equ DATAL = 0x211					;
                        			
.equ ZPOINTH = 0x212				; Zeropoint
.equ ZPOINTL = 0x213				;

.equ DATA_SIGN_10_BIT = 0x214		; The sign of the 10-bit data result here. " " for positive, "-" for negative (Ascii)
.equ DATA_SIGN_8_BIT = 0x215		; The sign of the 8-bit data result here. " " for positive, "-" for negative (Ascii)

.equ ASCII_C_1 = 0x216				; Used for the ASCII result for the steps
.equ ASCII_C_2 = 0x217				; Man, my comments rock. You have no idea what the above line means, right?
.equ ASCII_C_3 = 0x218				;

.equ C10	= 0x220					; Line 1 (Ascii)
.equ C11	= 0x221					; 
.equ C12	= 0x222					; 
.equ C13	= 0x223					; 
.equ C14	= 0x224					; 
.equ C15	= 0x225					; 
.equ C16	= 0x226					; 
.equ C17	= 0x227					; 
.equ C18	= 0x228					; 
.equ C19	= 0x229					; 
.equ C1A	= 0x22A					; 
.equ C1B	= 0x22B					; 
.equ C1C	= 0x22C					; 
.equ C1D	= 0x22D					; 
.equ C1E	= 0x22E					; 
.equ C1F	= 0x22F					; 

.equ C20	= 0x230					; Line 2 (Ascii)
.equ C21	= 0x231					; 
.equ C22	= 0x232					; 
.equ C23	= 0x233					; 
.equ C24	= 0x234					; 
.equ C25	= 0x235					; 
.equ C26	= 0x236					; 
.equ C27	= 0x237					; 
.equ C28	= 0x238					; 
.equ C29	= 0x239					; 
.equ C2A	= 0x23A					; 
.equ C2B	= 0x23B					; 
.equ C2C	= 0x23C					; 
.equ C2D	= 0x23D					; 
.equ C2E	= 0x23E					; 
.equ C2F	= 0x23F					;


.equ lcd_dprt = PORTC			; Defenitions for the LCD-display
.equ lcd_dddr = DDRC
.equ lcd_dpin = PINC

.equ lcd_cprt = PORTD
.equ lcd_cddr = DDRD
.equ lcd_cpin = PIND

.equ lcd_rs = 5
.equ lcd_rw = 4
.equ lcd_en = 3