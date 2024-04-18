			area Lab5, code, readonly
			export __main

__main proc
			; Configure GPIO
			LDR R0, =0x40004C00				; Loads base address of GPIO ports into R0
			ADD R0, #0x21					; Adds an offset to configure Port 4
			MOV R1, #0xF0					; P4.0 - P4.3 input, P4.4 - P4.7 output
			STRB R1, [R0, #0x04]			; Configure P4DIR
			
repeat 		MOV R5, #0x00					; Initialize R5 to hold output bye to control LEDs
			LDRB R3, [R0]					; Loads input status of Port4 into R3
			
check0		AND R4, R3, #0x01				; Masks input to isolate pin P4.0
			CMP R4, #0x00
			BNE check1
			ORR R5, #0x10					; Sets bit 4 of R5 to control LED for sensor P4.0
			
check1      AND R4, R3, #0x02				; Masks input to isolate pin P4.1
			CMP R4, #0x02
			BNE check2
			ORR R5, #0x20					; Sets bit 5 of R5 to control LED for sensor P4.1

check2		AND R4, R3, #0x04				; Masks input to isolate pin P4.2
			CMP R4, #0x04
			BNE check3
			ORR R5, #0x40					; Sets bit 4 of R5 to control LED for sensor P4.2

check3		AND R4, R3, #0x08				; Masks input to isolate pin P4.3
			CMP R4, #0x08
			BNE store
			ORR R5, #0x80					; Sets bit 4 of R5 to control LED for sensor P4.3

store 		STRB R5, [R0, #0x02]
			B repeat
			
			endp
			end