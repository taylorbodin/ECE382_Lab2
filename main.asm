;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
cipherText_address:		.byte	0xf8,0xb7,0x46,0x8c,0xb2,0x46,0xdf,0xac,0x42,0xcb,0xba,0x03,0xc7,0xba,0x5a,0x8c,0xb3,0x46,0xc2,0xb8,0x57,0xc4,0xff,0x4a,0xdf,0xff,0x12,0x9a,0xff,0x41,0xc5,0xab,0x50,0x82,0xff,0x03,0xe5,0xab,0x03,0xc3,0xb1,0x4f,0xd5,0xff,0x40,0xc3,0xb1,0x57,0xcd,0xb6,0x4d,0xdf,0xff,0x4f,0xc9,0xab,0x57,0xc9,0xad,0x50,0x80,0xff,0x53,0xc9,0xad,0x4a,0xc3,0xbb,0x50,0x80,0xff,0x42,0xc2,0xbb,0x03,0xdf,0xaf,0x42,0xcf,0xba,0x50,0x8f
key_address:			.byte	0xac,0xdf,0x23
key_length:				.equ	0x0003
plainText_address:		.equ	0x0200
message_length:			.equ	0x0075
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			mov.w   #cipherText_address, R5
			mov.w	#key_address,        R6
			mov.w	#plainText_address,  R7
			mov.w	#message_length,	 R8

			call    #decryptMessage

forever:    jmp     forever   ;traps the cpu

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author:
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: cipherText_address, key_address, plainText_address, message_length
;Outputs: plainText
;Registers destroyed: R8
;-------------------------------------------------------------------------------

decryptMessage:
			tst.w	R8			; Checks to see if we've decrypted the entire message
			jz		return
			dec.b 	R8			; Decrement the loop counter/message length

			mov.w	#key_address, R11	; if(keyPointer(R6)-keyAddress==keyLength) then keyPointer = keyAddress
			mov.w	R6, R12				; Which essentially loops the key
			sub.w	R11, R12
			cmp.b	#key_length, R12
			jeq		resetKeyPointer

			mov.b	@R5+,R9	 	;Loads R9 with the byte to decrypt
			mov.b	@R6+, R10	;Loads R10 with the next byte of the key
			call	#decryptCharacter
			mov.b	R10, 0(R7)	;Stores the decypted byte to memory
			inc.w	R7
			jmp		decryptMessage
resetKeyPointer:
			mov.w	#key_address, R6
			jmp		decryptMessage
return:
            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author:
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs: R9, R10
;Outputs: R10
;Registers destroyed: R10
;-------------------------------------------------------------------------------

decryptCharacter:
			xor.b	R9, R10
            ret


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
