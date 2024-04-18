; P5.4 connected to input
; P5.1 and P5.0 connected to two LEDs


			area Lab4, code, readonly
			export __main

__main proc
	
			; Configure GPIO
			LDR R0, =0x40004C00		; Port 1 base address
			ADD R0, #0x40			; Port 5 base address
			
			; ADD CODE TO CONFIGURE P5DIR, P5REN AND P5OUT
			MOV R1, #0x03			; Byte to configure pins 0 and 1 as output pins
			STRB R1, [R0, #0x04]	; Configure pins
			
			MOV R1, #0x10			; enable resistor for pin
			STRB R1, [R0, #0x06]	; Resistor enabled for the input pins
			STRB R1, [R0, #0x02]	; set pin as pull up
			
			
			; Loop, read input, toggle LEDs
repeat		LDRB R2, [R0, #0x00]	; Load input register value to R2
			AND R2, #0x10			; Mask pin 4
			
			; ADD CODE TO CHECK INPUT, SEND HIGH OR LOW SIGNALS TO 5.0 and 5.1
			CMP R2, #0x10
			BNE input0
			
			; input 1
			MOV R1, #0x02
			STRB R1, [R0, #0x02]
			B repeat
			
input0		MOV R1, #0x01
			STRB R1, [R0, #0x02]
			
			B repeat				; Loop indefinitely
			
			endp
			end