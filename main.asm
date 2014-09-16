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
cipherText_address:		.byte	0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90
key_address:			.byte	0x73,0xBE
key_length:				.equ	0x0002
plainText_address:		.equ	0x0200
message_length:			.equ	0x0040
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
