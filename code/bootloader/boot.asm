; boot.s - Minimal bootloader with firmware update over FT230X USB to UART
; 
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

.nolist
.include "m328def.inc"
.list

.equ F_OSC 8000000		; 8 MHz clock

.equ BOOTLOADER_INTERRUPT 0xFF	; Interrupt byte sent to ATMega during reset sequence that starts the bootloader
.equ BOOTLOADER_READY     0x55  ; Byte sent over UART signifying the device has acknowledged the interrupt

.equ BOOTLOADER_INT_WAIT 20	; Wait 20 ms for bootloader interrupt symbol

.org THIRDBOOTSTART		; Bootloader section start at 0x3c00

rjmp boot_main			; Start the bootloader

boot_main:

	; Initialize stack pointer at the end of RAM space
	ldi R24, low(RAMEND)
	ldi R25, high(RAMEND)
	out SPL, R24
	out SPH, R25

	; Turn off unused peripherals to reduce power consumption
	ldi R24, (1<<PRTWI)|(1<<PRTIM2)|(1<<PRADC)
	sts PRR, R24

	; Initialize UART0
	ldi R24, (1<<RXEN0)|(1<<TXEN0)	; Enable RX and TX
	sts UCSR0B, R24

	ldi R24, (1 << UPM01)		; Enable even parity bit check
	sts UCSR0C, R24

	ldi R24, 25			; Set baud rate to 19.2 kbps
	sts UBRR0L, R24

	ldi R23, BOOTLOADER_INT_WAIT

checkl: rcall wait1			; Delay for 1 millisecond

	lds R24, UCSR0A			; Check for UART0 RX Complete flag
	sbrs R24, RXC0			; If UART0 RX Complete not set, go to next loop iteration
	rjmp decl

	lds R24, UDR0			; Load contents of UART0 data register
	cpi R24, BOOTLOADER_INTERRUPT	; Check for interrupt byte
	breq bootloader_start		; If interrupt byte recieved, start the bootloader

decl:	dec R23
	cpi R23, 0			; If wait time is up without recieving bootloader interrupt, start main
	breq FLASHEND+1			; program execution (FLASHEND + 1 = Address 0x0000)

	rjmp checkl			; If wait time is not up yet, go to next loop iteration

boot_start:
	ldi R16, BOOTLOADER_READY	; Send READY byte back on UART0
	rcall uart_tx_single

	rcall uart_rx_single		; Grab single byte from UART0 and repeat it back
	rcall uart_tx_single

	rjmp FLASHEND+1

uart_tx_single:
	lds R24, UCSR0A			; Wait for UART0 transmit buffer to be empty
	sbrs R24, UDRE0
	rjmp uart_tx_single

	sts UDR0, R16			; Store byte to be sent in UART0 data register
	ret

uart_rx_single:
	lds R24, UCSR0A			; Wait for UART0 RX Complete flag
	sbrs R24, RXC0
	rjmp uart_rx_single

	lds R16, UDR0			; Store received byte
	ret

wait1:
	ldi R24, (1<<CS11)		; Set TIMER1 clock source = I/O clock / 8 (1 MHz)
	sts TCCR1B, R24

	ldi R24, 0xE8			; Set TIMER1 compare value to 1000 cycles (1 ms)
	ldi R25, 0x03
	sts OCR1AL, R24
	sts OCR1AH, R25

	ldi R24, 0x00			; Reset timer
	sts TCNT1H, R24
	sts TCNT1L, R24

	ldi R24, (1<<OCF1A)		; Reset output compare flag
	out TIFR1, R24

checkw:	sbis TIFR1, OCF1A		; Loop until output compare flag is set
	rjmp checko

	ret
