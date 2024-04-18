; Lab 3 Toggling LED

			area Lab3, code, readonly
			export __main
__main		proc
	
			; configure GPIO
			LDR R0, =0x40004C00		; Port 1 base address
			ADD R0, #0x41			; Port 6 base address
			MOV R1, #0x31			; Byte to configure pins 5, 4, 0 output
			STRB R1, [R0, #0x04]	; Configure pins 6.5, 6.4, 6.0 as output
			
			; Loop and toggle LEDs
repeat		MOV R1, #0x01			; Byte to make only pin 0 HIGH
			STRB R1, [R0, #0x02]	; Make only pin 6.0 HIGH
			BL delay				; remain ON for a while
			
			; ADD CODE TO SEND LOW SIGNAL
			MOV R1, #0x00
			STRB R1, [R0, #0x02]
			BL delay				; Remain OFF for a while
			
			; ADD CODE TO TOGGLE PINS 6.4 and 6.5
			MOV R1, #0x30			; Byte to make pins 6.4 and 6.5 HIGH
			STRB R1, [R0, #0x02]	; Make 6.4 and 6.5
			BL delay
			
			MOV R1, #0x00
			STRB R1, [R0, #0x02]
			BL delay				; Remain OFF for a while
			
			B repeat				; Loop infinitely
			endp
				
			; Single loop delay
			; Complete toggle using below delay routine
			
			; After completing toggling, ADD CODE FOR NESTED DELAY below

delay		function				; Declare new procedure
			MOV R12, #0x500		; NOTE: tune this constant if needed
continue2	MOV R11, #0x100
continue1	SUB R11, #0x01			
			CMP R11, #0x00
			BNE continue1			; Continue until R12 is positive
			SUB R12, #0x01
			CMP R12, #0x00
			BNE continue2
			
			BX LR					; Return to address in LR
			endp
				
			end
			