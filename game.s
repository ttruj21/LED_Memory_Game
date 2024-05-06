				area test, code, readonly
RS			equ 0x20	; RS connects to P3.5
RW			equ 0x40	; RW connects to P3.6
EN			equ 0x80	; EN connects to P3.7
port2		equ 0x40004C01
port6		equ 0x40004C41
data1		SPACE 255	
				export __main

; button 0: 6.0
; button 1: 6.1
; button 2: 6.6
; button 3: 6.7
; LED 0: 	2.4 
; LED 1:  	2.5
; LED 2:  	2.6
; LED 3:  	2.7

__main proc
					; Configure GPI0 for output LED pins
				LDR r0, =port2 	; Base address
				;ADD r0, #0x01           ; P2
				MOV r1, #0xF0			; set 2.4, 2.5, 2.6, 2.7 as outputs
				STRB r1, [r0, #0x04]
				
				; Configure GPIO for input button pins
				LDR r0, =port6           ; P6
				MOV R1, #0x00
				STRB R1, [R0, #0x04]
				
				
				; ADD CODE TO CONFIGURE P5DIR, P5REN AND P5OUT
				MOV R1, #0x33					; enable resistor for pin
				STRB R1, [R0, #0x06]			; Resistor enabled for the buttons
				MOV R1, #0x00
				STRB R1, [R0, #0x02]			; set pin as pull down
				
				MOV r3, #0x78 ; Seed for pseudo-random number generation
				LDR r6, =0xCE60 ; Multiplier for pseudo-random number generation
				LDR r5, =0xB         ; Additive constant for pseudo-random number generation
				
				MOV r8, #0x0
roundLoop		CMP r8, #0x5
				BGE endGame
				BL DisplayRound
				; flash sequence code starts
				;LDR R0, =0x40004C01 ; move LED output address (Port 2)
                MOV r4, #0x0
loop    		CMP r4, #0x5
                BGE stopFlashing
				
                ; generate random number x5
					MOV r9, #1          ; Clear r9 to store the random number
					; Calculate the random number
					MUL r9, r3, r6      ; Multiply the seed by the multiplier
					ADD r9, r9, r5      ; Add the additive constant
					ADD r3, r9          ; Update the seed for the next iteration
					ADD r6, r6, r4          ; Update the multiplier for the next iteration
					ADD r5, r6, r8         ; Update the additive for the next iteration
					AND r9, r9, #3      ; Mask to keep only the lower 2 bits (random number between 0 and 3)
				;MOV r9, r4
				
				
				LDR r0, =port2
				
				; turn on correspondent LED
LED0			CMP r9, #0
				BNE LED1
				MOV r1, #0x10
				STRB r1, [r0, #0x02]
				B endCheck

LED1			CMP r9, #1
				BNE LED2
				MOV r1, #0x20
				STRB r1, [r0, #0x02]
				B endCheck

LED2			CMP r9, #2
				BNE LED3
				MOV r1, #0x40
				STRB r1, [r0, #0x02]
				B endCheck

LED3			CMP r9, #3
				BNE endCheck
				MOV r1, #0x80
				STRB r1, [r0, #0x02]

				; call delay
endCheck		BL delayLED

				; turn off LED
				MOV r1, #0x00
				STRB r1, [r0, #0x02]
				
	
				; store r9 (whichever LED was selected to 0x40008000)
				LDR r7, =data1
				STR r9, [r7, r4, LSL #2]
				
				BL delayLED

				; increment counter, loop back
                ADD r4, r4, #0x1
                B loop
				
				
				

stopFlashing 	; check user inputs
				BL checkInputs
				
				ADD r8, r8, #0x1
				BL delayLED
				BL delayLED
				BL delayLED
				
				B roundLoop
				
					
endGame			B endGame
				endp
					
checkInputs		function
				PUSH {LR}
				PUSH {R4}
				PUSH {R0}
				PUSH {R5}
				PUSH {R6}
				PUSH {R7}
				PUSH {R2}
				PUSH {R3}
				PUSH {R8}
				
								
				LDR r0, =port6	; buttons
				LDR r3, =port2	; leds
				MOV r4, #0x0	; button input counter
input			CMP r4, #0x5	; we want 5 inputs
				
				BGE	success
				LDRB r5, [r0]	; loads inputs from buttons (port 6)
				BL delay
				
				MOV r8, r4
				BL DisplayCheck

				
Button2			AND r6, r5, #0x40
				CMP r6, #0x40
				BNE Button3
				MOV r8, #0x2
				; turn on led 2
				MOV r6, #0x40
				STRB r6, [r3, #0x02]
				BL delayLED
				; turn off LED
				MOV r6, #0x00
				STRB r6, [r3, #0x02]
				; compare with LEDs
				MOV r6, #2
				LDR r7, =data1
				LDR r2, [r7, r4, LSL #2]
				CMP r6, r2
				BNE	loser

				ADD	r4, #0x1
				B input

Button3			AND r6, r5, #0x80
				CMP r6, #0x80
				BNE Button0
				MOV r8, #0x3
				; turn on led 3
				MOV r6, #0x80
				STRB r6, [r3, #0x02]
				BL delayLED
				; turn off LED
				MOV r6, #0x00
				STRB r6, [r3, #0x02]
				; compare with LEDs
				MOV r6, #3
				LDR r7, =data1
				LDR r2, [r7, r4, LSL #2]
				CMP r6, r2
				BNE	loser

				ADD	r4, #0x1
				B input	
				
Button0			AND r6, r5, #0x01
				CMP r6, #0x01
				BNE Button1
				MOV r8, #0x0
				; turn on led 0
				MOV r6, #0x10
				STRB r6, [r3, #0x02]
				BL delayLED
				; turn off LED
				MOV r6, #0x00
				STRB r6, [r3, #0x02]
				; compare with LEDs
				MOV r6, #0
				LDR r7, =data1
				LDR r2, [r7, r4, LSL #2]
				CMP r6, r2
				BNE	loser

				ADD	r4, #0x1
				B input
				
Button1			AND r6, r5, #0x02
				CMP r6, #0x02
				BNE input
				MOV r8, #0x1
				; turn on led 1
				MOV r6, #0x20
				STRB r6, [r3, #0x02]
				BL delayLED
				; turn off LED
				MOV r6, #0x00
				STRB r6, [r3, #0x02]
				; compare with LEDs
				MOV r6, #1
				LDR r7, =data1
				LDR r2, [r7, r4, LSL #2]
				CMP r6, r2
				BNE	loser

				ADD	r4, #0x1
				B input	
				
success			POP {R8}
				POP	{R3}
				POP {R2}
				POP	{R7}
				POP {R6}
				POP {R5}
				POP {R0}
				POP {R4}
				POP {LR}
				BX LR
				endp
					
loser			function
				PUSH{LR}
				PUSH{R3}
				PUSH{R2}
				PUSH{r8}

again 			BL LCDInit
		
 				MOV R3, #'L'			; Character 'R'	
 				BL LCDData				; Send character in R3 to LCD
				
 				; ADD INSTRUCTIONS TO SEND REMAINING DATA TO THE LCD
 				MOV R3, #'O'			; Character 'O'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'S'			; Character 'U'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'E'			; Character 'N'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'R'			; Character 'D'	
 				BL LCDData				; Send character in R3 to LCD
				
				MOV R3, #'!'			; Character ' '	
 				BL LCDData				; Send character in R3 to LCD
				
				MOV R2, #0x01
				BL LCDCommand
				
				BL delayLED
				BL delayLED
				BL delayLED
				
				B again
				
				POP{R8}
				POP{R2}
				POP{R3}
				POP{LR}
				
				
				endp
					
DisplayCheck	function 
				PUSH{LR}
				PUSH{R3}
				PUSH{R2}
				PUSH{r8}

 				BL LCDInit
		
 				MOV R3, #'C'			; Character 'R'	
 				BL LCDData				; Send character in R3 to LCD
				
 				; ADD INSTRUCTIONS TO SEND REMAINING DATA TO THE LCD
 				MOV R3, #'H'			; Character 'O'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'E'			; Character 'U'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'C'			; Character 'N'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'K'			; Character 'D'	
 				BL LCDData				; Send character in R3 to LCD
				
				MOV R3, #' '			; Character ' '	
 				BL LCDData				; Send character in R3 to LCD
				
				ADD R8, #0x30
 				MOV R3, r8			    ; NUMBER 
 				BL LCDData				; WORK on this later
				
				POP{R8}
				POP{R2}
				POP{R3}
				POP{LR}
				BX LR
				endp
					
DisplayRound	function 
				PUSH{LR}
				PUSH{R3}
				PUSH{R2}
				PUSH{r8}

 				BL LCDInit
		
 				MOV R3, #'R'			; Character 'R'	
 				BL LCDData				; Send character in R3 to LCD
				
 				; ADD INSTRUCTIONS TO SEND REMAINING DATA TO THE LCD
 				MOV R3, #'O'			; Character 'O'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'U'			; Character 'U'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'N'			; Character 'N'	
 				BL LCDData				; Send character in R3 to LCD
				
 				MOV R3, #'D'			; Character 'D'	
 				BL LCDData				; Send character in R3 to LCD
				
				MOV R3, #' '			; Character ' '	
 				BL LCDData				; Send character in R3 to LCD
				
				ADD R8, #0x30
 				MOV R3, r8			    ; NUMBER 
 				BL LCDData				; WORK on this later
				
				POP{R8}
				POP{R2}
				POP{R3}
				POP{LR}
				BX LR
				endp
					
delayLED		function				; Declare new procedure
				PUSH{lr}
				MOV r12, #0x500		; NOTE: tune this constant if needed
continue2		MOV r11, #0x100
continue1		SUB r11, #0x01			
				CMP r11, #0x00
				BNE continue1			; Continue until R12 is positive
				SUB r12, #0x01
				CMP r12, #0x00
				BNE continue2
				POP{lr}
				BX lr					; Return to address in LR
				endp
				
LCDInit		function
			PUSH{R0}
			PUSH{R1}
			PUSH{R2}
			
			LDR R0, =0x40004C20		; P3: control pins
			LDR R1, =0x40004C21		; P4: data or commands 		
			MOV R2, #0xE0			; 1110 0000 
			STRB R2, [R0, #0x04]	; outputs pins for EN, RW, RS
			MOV R2, #0xFF
			STRB R2, [R1, #0x04]	; All of Port 4 as output pins to LCD
			
			PUSH {LR}		
			MOV R2, #0x38			; 2 lines, 7x5 characters, 8-bit mode		 
			BL LCDCommand			; Send command in R2 to LCD

			; ADD INSTRUCTIONS TO TURN ON THE DISPLAY AND THE CURSOR,
			; CLEAR DISPLAY AND MOVE CURSOR RIGHT
			MOV R2, #0x0E
			BL LCDCommand
			
			MOV R2, #0x01
			BL LCDCommand
			
			MOV R2, #0x06
			BL LCDCommand
				
			POP {LR}	
			POP{R2}
			POP{R1}
			POP{R0}
			BX LR
			endp
				
LCDCommand	function				; R2 brings in the command byte
			PUSH{R2}
			PUSH{R1}
			PUSH{R0}
			LDR R0, =0x40004C20		; P3: control pins
			LDR R1, =0x40004C21		; P4: data or commands
			STRB R2, [R1, #0x02]
			MOV R2, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR R2, #EN
			STRB R2, [R0, #0x02]	; EN = 1
			PUSH {LR}
			BL delay
			
			MOV R2, #0x00
			STRB R2, [R0, #0x02]	; EN = 0 and RS = RW = 0	
			POP {LR}
			POP {R0}
			POP {R1}
			POP {R2}
			BX LR
			endp				
				
LCDData		function				; R3 brings in the character byte
			
			; COMPLETE THIS FUNCTION, REFER TO LCDCommand and TABLE 3 on HANDOUT
			PUSH {R1}
			PUSH {R0}
			PUSH {R3}
			LDR R0, =0x40004C20		; P3: control pins
			LDR R1, =0x40004C21		; P4: data or commands
			
			STRB R3, [R1, #0x02]
			MOV R3, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR R3, #EN
			ORR R3, #RS
			STRB R3, [R0, #0x02]	; EN = 1
		
			
			PUSH {LR}
			BL delay
			
			MOV R3, #0x00
			ORR R3, #RS
			STRB R3, [R0, #0x02]	; EN = 0 and RS = RW = 0	
			POP {LR}
			POP {R3}
			POP {R0}
			POP {R1}
			BX LR
			

			endp
		
delay		function
			PUSH {LR}
			PUSH {R5}
			PUSH {R10}
			MOV R5, #50
loop1		MOV R10, #0xFF ; CHANGE BACK LATER
loop2		SUBS R10, #1
			BNE loop2
			SUBS R5, #1
			BNE loop1
			POP {R10}
			POP {R5}
			POP {LR}
			BX LR
			endp
			
			end
