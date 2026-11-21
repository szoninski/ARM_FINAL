	AREA	MAIN_CODE, CODE, READONLY
		GET		6_LPC213x.s
		
		ENTRY
__main
__use_two_region_memory
		EXPORT			__main
		EXPORT			__use_two_region_memory


CURRENT_DIGIT RN R12
DIGIT_0 RN R8	
DIGIT_1 RN R9				
DIGIT_2 RN R10
DIGIT_3 RN R11


; Setup IODIR0
    LDR     R4, =IODIR0
    LDR     R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)
    STR     R5, [R4]
; Setup IODIR1
    LDR     R4, =IODIR1
    LDR     R5, =(1<<16)|(1<<17)|(1<<18)|(1<<19)|(1<<20)|(1<<21)|(1<<22)|(1<<23)
    STR     R5, [R4]

	mov CURRENT_DIGIT, #0			
	mov DIGIT_0, #0
	mov DIGIT_1, #0
	mov DIGIT_2, #0
	mov DIGIT_3, #0

MAIN_LOOP
; Clear all digit
	mov 	R5, #0xf0000
	LDR     R4, =IOCLR0
	STR     R5, [R4]

; Clear all segments
	mov 	R5, #0xFF0000
	LDR     R4, =IOCLR1
	STR     R5, [R4]

; Set current digit
	mov 	R6, #0x80000
	mov 	R5, R6, LSR CURRENT_DIGIT
	LDR     R4, =IOSET0
	STR     R5, [R4]
	
; digit to 7 code
	cmp 	CURRENT_DIGIT, #0
	moveq 	R6, DIGIT_0
	cmp 	CURRENT_DIGIT, #1
	moveq 	R6, DIGIT_1
	cmp 	CURRENT_DIGIT, #2
	moveq 	R6, DIGIT_2
	cmp 	CURRENT_DIGIT, #3
	moveq 	R6, DIGIT_3

	ADR     R4, SegmentCode
	LDRB    R6, [R4, R6]
	
; Set segments
	MOV     R6, R6, LSL #16
	LDR     R4, =IOSET1
	STR     R6, [R4]

; Delay 
	ldr 	r0, =40
	bl 		delay_in_ms

	; licznik dekadowy
	add DIGIT_0, #1
	cmp DIGIT_0, #10
	moveq DIGIT_0, #0
	addeq DIGIT_1, #1
	
	cmp DIGIT_1, #10
	moveq DIGIT_1, #0
	addeq DIGIT_2, #1
	
	cmp DIGIT_2, #10
	moveq DIGIT_2, #0
	addeq DIGIT_3, #1
	
	cmp DIGIT_3, #10
	moveq DIGIT_3, #0
	
	; licznik obecnie opracowywanej cyfry
	add CURRENT_DIGIT, #1
	cmp CURRENT_DIGIT, #4
	moveq CURRENT_DIGIT, #0
	
	
	b MAIN_LOOP
	
delay_in_ms
	ldr r1,=2500
	mul r1, r0, r1
	mov r0, r1
Loop
	subs r0,#1
	bne Loop
	
	bx lr

SegmentCode DCB 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

	END