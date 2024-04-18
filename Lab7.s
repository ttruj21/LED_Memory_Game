		; perform binary search
		; result indicated by R12 (0: fail, other: 1-index of target)
		
		area lab7, code, readonly
words 	DCD 0x01, 0x02, 0x04, 0x06, 0x08, 0x10, 0x11
len		equ 0x07
target	equ 0x05
		export __main
			
__main proc
		
		; Perform binary search
		LDR r0, =words 	; load starting address of list
		MOV r1, #0x0 	; define left index
		MOV r2, #len
		SUB r2, #1		; define right index
		MOV r10, #target	; define target
		B Test
		
loop	ADD r3, r1, r2
		MOV r3, r3, LSR #1			; define middle index
		LDR r4, [r0, r3, LSL #2] 	; load words[middle]
		CMP r4, r10					; words[middle] - target = 0?
		BLT right					; words[middle] < target look right
		BGT left					; words[middle] > target look left
		ADD r3, r3, #1				; else words[middle] = target
		MOV r12, r3
		B stay
		
left	SUB r3, r3, #1
		MOV r2, r3 			; right = middle - 1
		B Test
		
right	ADD r3, r3, #1
		MOV r1, r3			; left = middle + 1
		B Test
			
		
Test	CMP r1, r2
		BLE loop
		MOV r12, #0
		
		
stay	B stay

		endp
		end