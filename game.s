; P4.0 - 4.3 connected to input (4 input buttons)
; P4.4 and P4.7 connected to two LEDs


				area LEDMemoryGame, code, readonly
				export __main

__main proc

				; Configure GPIO
				LDR R0, =0x40004C00				; Loads base address of GPIO ports into R0
				ADD R0, #0x21					; Adds an offset to configure Port 4
				MOV R1, #0xF0					; P4.0 - P4.3 buttons (input), P4.4 - P4.7 LEDs (output)
				STRB R1, [R0, #0x04]			; Configure P4DIR

				; we may need this idk
				MOV R5, #0x00					; Initialize R5 to hold output byte to control LEDs
				LDRB R3, [R0]					; Loads input status of Port4 into R3
				
				; ADD CODE TO CONFIGURE P5DIR, P5REN AND P5OUT
				MOV R1, #0x10					; enable resistor for pin
				STRB R1, [R0, #0x06]			; Resistor enabled for the buttons
				STRB R1, [R0, #0x02]			; set pin as pull up		


				; checks whether first button is triggered

check0			AND R4, R3, #0x01				; Masks input to isolate pin P4.0
				CMP R4, #0x00
				BNE check0						; if not pressed, keep waiting (endless loop till they start)

				
				; function to match each button to LED		
LED_button_config	function
					

				; auto enter game when pressed. sends into first subroutine for LCD Display

				; SubRoutine: LCD Display: Round X-> X should update as each round is one- increment by 1. if 3 attempts are failed, round does not inc by 1-> new sequence is flashed
LCDisplay		function 
				RS			equ 0x20	; RS connects to P3.5
				RW			equ 0x40	; RW connects to P3.6
				EN			equ 0x80	; EN connects to P3.7

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
				
				MOV R3, ##			    ; NUMBER 	
				BL LCDData				; WORK on this later
				
				MOV R2, #0xC7
				BL LCDCommand
				

				
			
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
							
				
			
				; SubRoutine: Enter a Loop for Sequence Flash


FlashSequence	function

                MOV r1, #0
        loop    CMP r1, #4
                BGE Done
                ; generate random number x5
                ADD r1, r1, #1
                B loop

				; SubRoutine: Enter a Loop for User to input Sequence

				; loop
					; flash counter, increment, break when 5
					; get random value (0 1 2 or 3)
					; flash matching LED (0 = white 1 = blue 2 = green 3 = red)
					; delay (make sure its on for a few seconds)
					; turn off the LED
					; STR r3, [r0, R1, LSL #2] ; (store value to memory)

UserSequence    function   
				; go into checks to see if button pressed
					; if pressed, 
						; light up corresponding LED
						; increment button_counter
						; go to button_match
						; CMP to memory value according to button_counter
						; update match_counter (increment by 1 if match)
				; if match does not equal 5, LOSER

        check0      AND R4, R3, #0x01               ; Masks input to isolate pin P4.0
                    CMP R4, #0x00
                    BNE check1
					CMP R3
                    ORR R5, #0x10                   ; Change, add to stack if pressed
                   
        check1      AND R4, R3, #0x02               ; Masks input to isolate pin P4.1
                    CMP R4, #0x02
                    BNE check2
                    ORR R5, #0x20                   ; Change, add to stack if pressed


        check2      AND R4, R3, #0x04               ; Masks input to isolate pin P4.2
                    CMP R4, #0x04
                    BNE check3
                    ORR R5, #0x40                   ; Change, add to stack if pressed


        check3      AND R4, R3, #0x08               ; Masks input to isolate pin P4.3
                    CMP R4, #0x08
                    BNE store
                    ORR R5, #0x80                   ; Change, add to stack if pressed

				endp
				
				end 