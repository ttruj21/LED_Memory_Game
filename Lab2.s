			area Lab2code, code, readonly
byteData dcb 0x23, 0xAB, 48, 0x9F, 0xFF
byteDataLen equ 5
wordDataLen equ 5
	
			export __main
__main  	proc

; TASKS 1&2
; moving (dealing) one-byte (8-bit) data
			ldr r0, =0x20002000		; r0 is the pointer to new location
			ldr r1, =byteData		; r1 is the pointer to byteData	
			mov r12, #0				; r12 is used as a counter
moreBytes	ldrb r3, [r1]			; load one value from array in memory
			strb r3, [r0]			; store to new location
			add r12, #1				; moved one, so increase counter
			add r0, #1				; set pointer to new locations for both
			add r1, #1
			cmp r12, #byteDataLen
			bne moreBytes
			
; TASK 3
; moving (dealing) with 4-byte data
			ldr r0, =0x20004000
			ldr r1, =wordData
			mov r12, #0
moreWords	ldr r3, [r1]
			str r3, [r0]
			add r12, #1
			add r0, #4				; pointers added by four for 4-byte data
			add r1, #4
			cmp r12, #wordDataLen
			bne moreWords
			
;TASK 4
; Find the largest value from the word data array
			mov r8, #0			; we start with a small value to find the largest
								; start with a very big value to find the smallest
			ldr r1, =wordData
			mov r12, #0
moreToGo	ldr r3, [r1]
			cmp r3, r8
			blt skip			; bgt for finding the smallest value

			mov r8, r3			; keep the largest value in r8
skip		add r12, #1			; go to the next value
			add	r0, #4
			add r1, #4
			cmp r12, #wordDataLen
			bne moreToGo
			
			endp


			area lab2data, data, readonly
wordData 	dcd 0x12345678, 0x2BCD1234, 0x1234ABCD, 0x4FAABBCC, 8

			end
			
			
		