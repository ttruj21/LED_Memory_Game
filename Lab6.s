; Lab 6 - 16x2 LCD display

			area Lab6, code, readonly
RS			equ 0x20	; RS connects to P3.5
RW			equ 0x40	; RW connects to P3.6
EN			equ 0x80	; EN connects to P3.7
			export __main

__main		proc	

			BL LCDInit
			
			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			; ADD INSTRUCTIONS TO SEND REMAINING DATA TO THE LCD
			MOV R3, #'U'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'C'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'C'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'E'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'S'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R2, #0xC7
			BL LCDCommand
			
			MOV R3, #'F'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'A'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'I'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'L'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'U'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'R'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
			
			MOV R3, #'E'			; Character 'S'	
			BL LCDData				; Send character in R3 to LCD
				
			
stay		B stay					; Remain here after completion
			endp
				
				
LCDInit		function
					
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
			BX LR
			endp
				
LCDCommand	function				; R2 brings in the command byte
			STRB R2, [R1, #0x02]
			MOV R2, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR R2, #EN
			STRB R2, [R0, #0x02]	; EN = 1
			PUSH {LR}
			BL delay
			
			MOV R2, #0x00
			STRB R2, [R0, #0x02]	; EN = 0 and RS = RW = 0	
			POP {LR}
			BX LR
			endp				
				
LCDData		function				; R3 brings in the character byte
			
			; COMPLETE THIS FUNCTION, REFER TO LCDCommand and TABLE 3 on HANDOUT
			
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
			BX LR
			

			endp
		
delay		function
			MOV R5, #50
loop1		MOV R4, #0xFF
loop2		SUBS R4, #1
			BNE loop2
			SUBS R5, #1
			BNE loop1
			BX LR
			endp
			
			end