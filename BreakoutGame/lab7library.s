	.text
	.global uart_init
	.global gpio_btn_and_LED_init
	.global keypad_init ; Downloaded from the course website
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
    .global read_from_push_buttns_easy
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_push_button
	.global read_from_keypad
	.global print_newline_carriage_return
	.global string2int
	.global count_digits
	.global int2string_noNullTerm
	.global get_int_at_position
    .global int2string
    .global clock_interrupt_init
    .global uart_interrupt_init
    .global gpio_interrupt_init
    .global Switch_Handler
	.global Timer_Handler
	.global UART0_Handler
    .global clear_terminal
    .global simple_read_character
    .global change_timer_cycles
    .global disable_timer_interrupts
    .global enable_timer_interrupts
    .global disable_all_interrupts
    .global start_timer_no_interrupt

**************************************************************************************************
SYSCTL:			.word	0x400FE000	; Base address for System Control
GPIO_PORT_A:	.word	0x40004000	; Base address for GPIO Port A
GPIO_PORT_D:	.word	0x40007000	; Base address for GPIO Port D
RCGCGPIO:		.equ	0x608		; Offset for GPIO Run Mode Clock Gating Control Register
GPIODIR:		.equ	0x400		; Offset for GPIO Direction Register
GPIODEN:		.equ	0x51C		; Offset for GPIO Digital Enable Register
GPIODATA:		.equ	0x3FC		; Offset for GPIO Data Register
U0FR:   		.equ 	0x18   		; UART0 Flag Register
UART0:          .word 0x4000C000

PORT_DATA_DIR_OFFSET: .equ 0x400
CLOCK_OFFSET: .equ 0x608
DIGITAL_ENABLE_REGISTER: .equ 0x51C
GPIODATA_OFFSET: .equ 0x3FC
GPIOPUR_OFFSET: .equ 0x510


LIGHT_ALL: .equ 0xF
SW5_PRESSED: .equ 0x1
SW4_PRESSED: .equ 0x2
SW3_PRESSED: .equ 0x4
SW2_PRESSED: .equ 0x8

RED: .equ 0x1
BLUE: .equ 0x2
GREEN: .equ 0x4
PURPLE: .equ 0x3
YELLOW: .equ 0x5
WHITE: .equ 0x7

SYSCTL_RCGC_GPIO: .word 0x400FE000 ; Base address of System Run Mode Clock Gating Control Register (SYSCTL_RCGC)
GPIO_PORT_F: .word	0x40025000	; Base address for GPIO Port F
EN0: .word 0xE000E000 ; Base address of ENO (Interrupt 0-31 Set Enable Register)
MAX_PRESSES:    .equ   0x14; this is the maximum number of presses I will allow for keyboard or sw1
NUM_OFFSET_BELOW_MESSAGE: .equ 0xF; want to offset the nub 15 characters


; For Timer_Handler
TIMER0: .word 0x40030000
**************************************************************************************************



print_newline_carriage_return:; This function prints '\r\n' to the console
							  ; Inputs:
							  ; 	None
							  ; Outpus:
							  ; 	'\r\n' printed to console
	PUSH {lr}
	MOV r0, #0xD; store carriage return in r0
	BL output_character
	MOV r0, #0xA; store newline in r0
	BL output_character
	POP {lr}
	MOV pc, lr

; ------------------------------------------------------------------------------------------------ beginning uart_interrupt_init
uart_interrupt_init:;  This function  enables UART0 to interrupt the processor.  uart_init must be run before calling this function
	                ; Input:
                    ;    None
                    ; Output: 
                    ;   None

	;Set the Receive Interrupt Mask (RXIM) bit in the UART Interrupt Mask Register (UARTIM)
	PUSH {lr}

	LDR r1, UART0
	LDRB r0, [r1, #0x038]
	MOV r2, #0x1
	BFI r0, r2, #4, #1; Setting Bit 4 of Receive Interrupt Mask
	STRB r0, [r1, #0x038] 

    ; Set the bit 5 bit in the Interrupt 0-31 Set Enable Register (EN0)
	LDR r1, EN0
	LDRB r0, [r1, #0x100]
	BFI r0, r2, #5, #1 ; Configure Processor to Allow the UART to Interrupt Processor
	STRB r0, [r1, #0x100]

	POP {lr}
	MOV pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending uart_interrupt_init

; ------------------------------------------------------------------------------------------------beginning disable_all_interrupts
disable_all_interrupts:; This function disables gpip port F, Uart0, and timer0 from interrupting the processor
                       ; Inputs:
                       ;        None
                       ; Outputs:
                       ;        Interrupts are disabled from interrupting the processor

    push {lr}

    ;disableing GPIO Port F
    ; disable GPIO Interrupt Mask Register (GPIOIM)
    LDRB r0, [r1, #0x410]
    MOV r2, #0x0
    BFI r0, r2, #4, #1; Enable the Interrupt
    STRB r0, [r1, #0x410]
    ;disable processor interrupts
    LDR r1, EN0
    LDR r0, [r1, #0x100]
    mov r2, #0x0; 0 disables
    BFI r0, r2, #30, #1;  bit 30 (r2 is #0x0)
    STR r0, [r1, #0x100]


    ;disableing UART0
	LDR r1, UART0
	LDRB r0, [r1, #0x038]
	MOV r2, #0x0; 0 to disable
	BFI r0, r2, #4, #1; Setting Bit 4 of Receive Interrupt Mask
	STRB r0, [r1, #0x038] 

    LDR r1, EN0
	LDRB r0, [r1, #0x100]
    mov r2, #0x0; 0 disables
	BFI r0, r2, #5, #1 ;
	STR r0, [r1, #0x100]

    ;disableing timer interrupts
    bl disable_timer_interrupts

    pop {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending disable_all_interrupts

; ------------------------------------------------------------------------------------------------ gpio_interrupt_init
gpio_interrupt_init:; This function initializes Port F pin 4 (SW1) and also enables it to interrupt the processor.  Switch_Handler is the function that gets called on interrupts
                    ; Input: 
                    ;   None
                    ; Output: 
                    ;   None
    PUSH {lr}
    ;--------initalizing port F sw1
    ; Initialize clock for Port F
    LDR r0, SYSCTL_RCGC_GPIO
	LDRB r1, [r0, #0x608]
	ORR r1, r1, #0x20
	STRB r1, [r0, #0x608]
    ADD r0, r0, #0; no op
    ADD r0, r0, #0; no op

    ; Initialize direction register for Port F
    MOV r0, #0xEF
    LDR r1, GPIO_PORT_F
    STRB r0, [r1, #0x400]

    ; Initialize digital register for Port F
    MOV r0, #0xFF
    STRB r0, [r1, #0x51C]
    
    ; Initialize pull up register for Port F
    MOV r0, #0x10
    STRB r0, [r1, #0x510]

    ;------BELOW IS ENABLING THE INTERRUPT

    ; Initialize GPIO Interrupt Sense Register (GPIOSIS)
    LDRB r0, [r1, #0x404]
    MOV r2, #0x0 ; Enable Edge Sensitive
    BFI r0, r2, #4, #1
    STRB r0, [r1, #0x404]

    ; Initialize GPIO Interrupt Both Edges Register (GPIOIBE)
    LDRB r0, [r1, #0x408]
    BFI r0, r2, #4, #1; Allow GPIOEV to determine edge (r2 is #0x0)
    STRB r0, [r1, #0x408]

    ; Initialize GPIO Interrupt Event Register (GPIOIV)
    LDRB r0, [r1, #0x40C]
    BFI r0, r2, #4, #1; Low (Falling Edge) = Button Pressed (r2 is #0x0)
    STRB r0, [r1, #0x40C]

    ; Initialize GPIO Interrupt Mask Register (GPIOIM)
    LDRB r0, [r1, #0x410]
    MOV r2, #0x1
    BFI r0, r2, #4, #1; Enable the Interrupt
    STRB r0, [r1, #0x410]

    ; Initialize Interrupt 0-31 Set Enable Register (EN0)
    LDR r1, EN0
    LDR r0, [r1, #0x100]
    BFI r0, r2, #30, #1; Enable bit 30 (r2 is #0x1)
    STR r0, [r1, #0x100]

    POP {lr}
    MOV pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending gpio_interrupt_init

; ------------------------------------------------------------------------------------------------ beginning clock_interrupt_init
clock_interrupt_init:;  This function initializes the clock and enables it to interrupt the processor once per second.
                     ; Inputs:
                     ;      None
                     ; Outputs:
                     ;      None
	
    PUSH {lr, r4-r11}

    ; Connecting Clock to Timer
    LDR r1, SYSCTL_RCGC_GPIO; Address: #0x400FE000
    LDRB r0, [r1, #0x604]
    MOV r2, #0x1
    BFI r0, r2, #0, #1; Write '1' to bit 0
    STRB r0, [r1, #0x604]

    ; Disable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    MOV r2, #0x0
    BFI r0, r2, #0, #1; Write '0' to TAEN, which is bit 0
    STRB r0, [r1, #0x00C]

    ; Put Timer in 32-Bit Mode
    ; r1 = TIMER0
    LDRB r0, [r1, #0x000]
    ; r2 = #0x0
    BFI r0, r2, #0, #3; GPTMCFG is bits 0-2 (inclusive) 
    STRB r0, [r1, #0x000]

    ; Put Timer in Periodic Mode
    ; r1 = TIMER0
    LDRB r0, [r1, #0x004]
    MOV r2, #0x2
    BFI r0, r2, #0, #2; TAMR is bits 0-1 (inclusive)
    STRB r0, [r1, #0x004]

    ; Setup Interval Period
    ; r1 = TIMER0
    LDR r0, [r1, #0x028]
    MOV r2, #0xD400
    MOVT r2, #0x0030; 3,200,000 cycles
    BFI r0, r2, #0, #32
    STR r0, [r1, #0x028]

    ; Enable Timer to Interrupt Processor
    ; r1 = TIMER0
    LDRB r0, [r1, #0x018]
    MOV r2, #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x018]

    ; Configure Processor to Allow Timer to Interrupt Processor
    LDR r1, EN0
    LDR r0, [r1, #0x100]
    ; r2 = #0x1
    BFI r0, r2, #19, #1; Setting bit 19
    STR r0, [r1, #0x100]

    ; Enable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    ; r2 = #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x00C]

    POP {lr, r4-r11}
	MOV pc, lr       	; Return

start_timer_no_interrupt:
    PUSH {lr, r4-r11}

    ; Connecting Clock to Timer
    LDR r1, SYSCTL_RCGC_GPIO; Address: #0x400FE000
    LDRB r0, [r1, #0x604]
    MOV r2, #0x1
    BFI r0, r2, #0, #1; Write '1' to bit 0
    STRB r0, [r1, #0x604]

    ; Disable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    MOV r2, #0x0
    BFI r0, r2, #0, #1; Write '0' to TAEN, which is bit 0
    STRB r0, [r1, #0x00C]

    ; Put Timer in 32-Bit Mode
    ; r1 = TIMER0
    LDRB r0, [r1, #0x000]
    ; r2 = #0x0
    BFI r0, r2, #0, #3; GPTMCFG is bits 0-2 (inclusive) 
    STRB r0, [r1, #0x000]

    ; Put Timer in Periodic Mode
    ; r1 = TIMER0
    LDRB r0, [r1, #0x004]
    MOV r2, #0x2
    BFI r0, r2, #0, #2; TAMR is bits 0-1 (inclusive)
    STRB r0, [r1, #0x004]

    ; Setup Interval Period
    ; r1 = TIMER0
    LDR r0, [r1, #0x028]
    MOV r2, #0xD400
    MOVT r2, #0x0030; 3,200,000 cycles
    BFI r0, r2, #0, #32
    STR r0, [r1, #0x028]
    
    ; Enable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    MOV r2, #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x00C]

    POP {lr, r4-r11}
	MOV pc, lr       	; Return
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending clock_interrupt_init

; ------------------------------------------------------------------------------------------------
change_timer_cycles:; This function updates the number of cycles before the timer interrupts the processor to the value in r0
                    ; Inputs: 
                    ;   r0 = number of cycles before timer interrupt happens
                    ; Outputs:
                    ;   Timer set to interrupt after r0 many cycles
    push {lr}
    mov r3, r0; storing value of r0 into r3 because r0 is modified
    ; Disable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    MOV r2, #0x0
    BFI r0, r2, #0, #1; Write '0' to TAEN, which is bit 0
    STRB r0, [r1, #0x00C]

    ; Setup Interval Period
    ; r1 = TIMER0
    LDR r0, [r1, #0x028]
    BFI r0, r3, #0, #32 ; move value in r3 to r0
    STR r0, [r1, #0x028]; store new value for timer interrupts


    ; Enable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    mov r2, #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x00C]

    pop {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------------------------------------------------------------------------------
disable_timer_interrupts:; disables timer from interrupting the processor, called whan game paused
                         ; Inputs:
                         ;       None
                         ; Outputs:
                         ;       Timer disabled
    ;leaf function no push or pop needed
    ; Disable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    MOV r2, #0x0
    BFI r0, r2, #0, #1; Write '0' to TAEN, which is bit 0
    STRB r0, [r1, #0x00C]
    ;leaf function no push or pop needed
    mov pc, lr
enable_timer_interrupts:; enables timer to interrupt the processor, called when game unpaused
                        ; Inputs:
                        ;       None
                        ; Outputs:
                        ;       Timer enables
    ;leaf function no push or pop needed
    ; Enable Timer
    LDR r1, TIMER0
    LDRB r0, [r1, #0x00C]
    mov r2, #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x00C]
    ;leaf function no push or pop needed
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


gpio_btn_and_LED_init:
	PUSH {lr} ; Store register lr on stack

	;We only use ports F, D, A so we want to clock to be set to 0x29
	MOV r0, #0xE000
    MOVT r0, #0x400F
	LDRB r1, [r0, #CLOCK_OFFSET]
    MOV r2, #0x2B
	BFI r1, r2, #0, #8; Want 5th bit (indexed at 0) set to 1
	STRB r1, [r0, #CLOCK_OFFSET]

	;The code below initalizes port F. port f is the RGB LED, and tivia board push button
	MOV r0, #0xEF; want all to be 1 except pin 4
	BL set_direction_register_portF; sed pins to be input/output
	MOV r0, #0xFF; want all pins to be set to digital
	BL set_digital_port_F; say pins should be read in as digital
	MOV r0, #0x10; Want to turn on pull up resistor of pin 4
	BL set_pull_up_resistor_port_F

	; Initializing LEDS on daughter board
	MOV r0, #0xF; want all to be 1
	BL set_direction_register_port_B; sed pins to be input/output
	MOV r0, #0xF; want all pins to be set to digital
	BL set_digital_port_B; say pins should be read in as digital
	
	; Initializing buttons on daughter board
	MOV r0, #0x0; what all pins 0-3 to be 0 for input
	BL set_direction_register_port_D
	MOV r0, #0xF; want all pins to be set to digital
	BL set_digital_port_D
	;We don't need to use a pull up resisitor for the daughter board

	; Your code is placed here
	POP {lr}
	MOV pc, lr

read_string: ;reads a string entered in PuTTy and stores it as a NULL-terminated ASCII string in memory. The user terminates the string by hitting Enter.
             ; Inputs
			 ;	   r0: The base address of the string should be passed into the routine in r0
             ;	   r1: must hold the maximum number of characters allowed to be read (so you don't keep accepting characters and overwrite other stuff in memory)
             ;     REMEMBER r1 is the number of characters the user enters, still need 1 more space of memory for the NULL terminator
			 ; Outputs: 
			 ; 	   The string is stored in memory address from r0 input
    PUSH {lr, r4, r5}   ; Store register lr on stack
        ; Your code for your read_string routine is placed here
    MOV r4, r0; moving base address into r4 so it is saved across function calls
    MOV r5, r1; moving max number of characters to be read to r5, so it will be preserved across function calls
loop_read_string:
    BL read_character; reads character and stores in r0
    BL output_character
    CMP r0, #0xD;
    BEQ done_read_string
    STRB r0, [r4]; store character
    ADD r4, r4, #0x1; increment r4 to next position
    SUB r5, r5, #0x1; decrement the number of availble memory slots by 1
    CMP r5, #0x0; have we stored the max number of characters?
    BEQ done_memory_full; break out if we've read in the max number of characters allowed
    B loop_read_string; keep looping for more characters

done_memory_full:
    MOV r0, #0xD; load carriage return in r0
    BL output_character
    B done_read_string
done_read_string:
    MOV r0, #0x0; Storing value of null character in r0
    STRB r0, [r4]; storing null terminator at end of string
    MOV r0, #0xA; Storing newline character in r0
    BL output_character; printing char to console
    POP {lr, r4, r5}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of read_string

; ------------------------------------------------------------------------------------------------beginning of output_string
output_string:; output_string transmits a NULL-terminated ASCII string for display in PuTTy. The base address of the string should be passed into the routine in r0
			  ; Inputs:
			  ; 	r0: base address where string is stored
			  ; Outputs:
			  ; 	None, except what you see in the console
	PUSH {lr, r4}   ; Store register lr on stack

        ; Your code for your output_string routine is placed here
    MOV r4, r0; Moving the address into r4 because output_character needs to use the reg r0 for input
loop_output_string:
    LDRB r0, [r4] ;Load the next character of the string into r0, this is the reg output_character takes as input
    ADD r4, r4, #0x1 ;add 1 to r4 to make it point to the next character
    CMP r0, #0x0; check if character is null
    BEQ done_output_string; done if character is null
    BL output_character
    B loop_output_string

done_output_string:
    POP {lr, r4}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of output_string

; ------------------------------------------------------------------------------------------------beginning of read_character function
read_character:; This function reads a character which is received by the UART from PuTTy, returning the character in r0.
               ; Inputs:
			   ; 	Takes no input parameters
               ; Outputs:
			   ; 	r0: character returned
    PUSH {lr}   ; Store register lr on stack

    ; Your code to receive a character obtained from the keyboard
    ; in PuTTy is placed here.  The character is received in r0.

    ;Keep looping while the flag register for UART0 is 1, continue when it is 0
    BL loop_till_0_FE;

    ;Load the data from the UART0 data register
    MOV r1, #0xC000; lower bits of base address of UART0
    MOVT r1, #0x4000; upper bits
    LDRB r0, [r1]

    POP {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of read_character function


; ------------------------------------------------------------------------------------------------
simple_read_character: ;This function reads a character which is received by the UART from PuTTy, returning the character in r0.
                       ; Inputs: 
                       ;    character pressed on keyboard
                       ; Outputs:
                       ;    r0 holds ascii value of character
    PUSH {lr}

    ; Your code to receive a character obtained from the keyboard
    ; in PuTTy is placed here.  The character is received in r0.


    ;Load the data from the UART0 data register
    LDR r1, UART0
    LDRB r0, [r1]; reading byte from uart

    POP {lr}; restore lr
    MOV pc, lr; return where I came from
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------------------------------------------------------------------------------beginning of output_character
output_character:; transmits a character from the UART to PuTTy. The character is passed in r0.
				 ; Inputs:
				 ; 		r0: character to be printed
				 ; Outputs:
				 ; 		Character printed to console
    PUSH {lr, r0}   ; Store register lr on stack

        ; Your code to output a character to be displayed in PuTTy
        ; is placed here.  The character to be displayed is passed
        ; into the routine in r0.
    BL loop_till_0_FF;

    ;Load the data from the UART0 data register
    MOV r1, #0xC000; lower bits of base address of UART0
    MOVT r1, #0x4000; upper bits

    POP {lr, r0}
    STRB r0, [r1]
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of output_character


; ------------------------------------------------------------------------------------------------beginning of uart_init
uart_init:;  initializes the user UART for use
		  ; Inputs:
		  ; 	None
		  ; Outputs:
		  ; 	None.  UART0 should be initialized though
    PUSH {lr}  ; Store register lr on stack

        ; Your code for your uart_init routine is placed here
        ; r0 will hold the address, r1 will hold the value that gets stored at the address
    MOV r0, #0xE618
    MOVT r0, #0x400F
    MOV r1, #0x1
    STR r1, [r0]

    MOV r0, #0xE608
    MOVT r0, #0x400F
    ;r1 is already 1
    STR r1, [r0]

    MOV r0, #0xC030
    MOVT r0, #0x4000
    MOV r1, #0x0
    STR r1, [r0]

    MOV r0, #0xC024
    MOVT r0, #0x4000
    MOV r1, #0x8
    STR r1, [r0]

    MOV r0, #0xC028
    MOVT r0, #0x4000
    MOV r1, #44 ;I didn't do the hex version of the number here so it matches the values in the c code he provided
    STR r1, [r0]

    MOV r0, #0xCFC8
    MOVT r0, #0x4000
    MOV r1, #0x0
    STR r1, [r0]

    MOV r0, #0xC02C
    MOVT r0, #0x4000
    MOV r1, #0x60
    STR r1, [r0]

    MOV r0, #0xC030
    MOVT r0, #0x4000
    MOV r1, #0x301
    STR r1, [r0]


    ; OR STATEMENTS NEEDED BELOW

    MOV r0, #0x451C
    MOVT r0, #0x4000
    LDR r1, [r0];Load value
    ORR r1, r1, #0x03 ;or value
    STR r1, [r0];store value back


    MOV r0, #0x4420
    MOVT r0, #0x4000
    LDR r1, [r0]
    ORR r1, r1, #0x03 ;or value
    STR r1, [r0];store value back

    MOV r0, #0x452C
    MOVT r0, #0x4000
    LDR r1, [r0]
    ORR r1, r1, #0x11 ;or value
    STR r1, [r0];store value back

    POP {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of uart_init

; ------------------------------------------------------------------------------------------------beginning of loop_till_0_FE function
loop_till_0_FE: ;This function will keep looping until the RxFE flag register for UART0 is 0
				; Inputs:
				; 		None
				; Outpus:
				; 		None
    PUSH {lr}; don't have to do this but it is good practice

    MOV r0, #0xC000; lower bits of base address of UART0
    MOVT r0, #0x4000; upper bits
    MOV r1, #0x10; r1 will be 0 in all places except for the 5th bit.

inner_loop:
    LDRB r2, [r0, #U0FR]; load bits from flag register into r2
    AND r2, r2, r1; r2 = r1&r2, r2 = 0 if bit we want is 0, otherwise not zero
    CMP r2, #0
    BNE inner_loop

    ;If this runs, the 5th bit was set to 0
    ;We can return where we came from
    POP {lr}; restore lr
    MOV pc, lr; return where I came from
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of loop_till_0_FE function


; ------------------------------------------------------------------------------------------------beginning of loop_till_0_FF function
loop_till_0_FF: ;This function will keep looping until the RxFF flag register for UART0 is 0
				; Inputs:
				; 		None
				; Outpus:
				; 		None
    PUSH {lr}; don't have to do this but it is good practice

    MOV r0, #0xC000; lower bits of base address of UART0
    MOVT r0, #0x4000; upper bits
    MOV r1, #0x20; r1 will be 0 in all places except for the 6th bit.

inner_loop_2:
    LDRB r2, [r0, #U0FR]; load bits from flag register into r2
    AND r2, r2, r1; r2 = r1&r2, r2 = 0 if bit we want is 0, otherwise not zero
    CMP r2, #0
    BNE inner_loop_2

    ;If this runs, the 5th bit was set to 0
    ;We can return where we came from
    POP {lr}; restore lr
    MOV pc, lr; return where I came from
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of loop_till_0_FF function

; ------------------------------------------------------------------------------------------------beginning count_digits
count_digits:; This function counts the number of decimal digits in the value stored in r0
            ; Inputs:
            ;   r0: is the integer you want to count the number of digits in
            ; Outputs:
            ;   r0: the number of decimal digits in r0
    PUSH {lr}
    MOV r1, #0; r1 will count iterations of loop (aka number of digits in r0)
    MOV r2, #10; r2 will just hold the value 10 for sdiv
loop_count_digits:
    CMP r0, #0; is r0 == 0?
    BEQ done_count_digits; is r0 == 0?
    SDIV r0, r0, r2; r0 = r0//10 (integer division)
    ADD r1, r1, #1; r1 += 1
    B loop_count_digits

done_count_digits:
    MOV r0, r1
    POP {lr}
    MOV pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending count_digits

; ------------------------------------------------------------------------------------------------beginning get_int_at_position
get_int_at_position:; This function gets the decimal digit stored at index r1 from value stored in r0
                    ; Inputs:
                    ;   r0: integer value
                    ;   r1: index of digit you want from r0
                    ; Outputs:
                    ;   r0: the digit stored at the index desired
    PUSH {lr, r4}
    MOV r2, #0; initialize r2 as 0. This will count the iterations of the loop
    MOV r3, #10; R3 will hold the constant 10 for sdiv

loop_get_int_at_position:
    CMP r1, r2; if r1==r2 we are at the index desired
    BEQ done_get_int_at_position
    UDIV r0, r0, r3; r0 = r0//10
    ADD r2, r2, #1; increment loop counter by 1
    B loop_get_int_at_position

done_get_int_at_position:
    ;compute mod to get the digit
    ;Calculate r5 = r0 % 10
    UDIV r1, r0, r3;
    MUL r1, r1, r3 ;
    SUB r0, r0, r1 ; r0 now equals r0%10
    POP {lr, r4}
    MOV pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending get_int_at_position


; ------------------------------------------------------------------------------------------------
read_from_push_btns:; reads from the momentary push button (SW1) on the Tiva board, and returns a one (1) in r0 if the button is currently being pressed and a zero (0) if it is not.
				   ; Inputs:
				   ; 	SW2-SW5 from daughter board
				   ; Outputs:
				   ; 	r0 first bit set to 1 if SW2 is pressed
				   ; 	r0 second bit set to 1 if SW3 is pressed
				   ; 	r0 third bit set to 1 in SW4 is pressed
				   ; 	r0 fourth bit set to 1 if SW5 is pressed
	PUSH {lr}
	MOV r1, #0x7000
	MOVT r1, #0x4000
	LDRB r2, [r1, #GPIODATA_OFFSET]
	UBFX r0, r2, #0, #4
	POP {lr}
	MOV pc, lr

read_from_push_buttns_easy:; this function takes the value returned by read_from_push_btns and converts it to simpler 1, 2, 3, or 4
                           ; THIS FUNCTION ALSO RETURNS 1 FOR DEFAULT NO BUTTONS PRESSED
                            ; Inputs:
                            ; 	SW2-SW5 from daughter board
                            ; Outputs:
                            ; 	r0 = 1 if SW2 is pressed
                            ; 	r0 = 2 if SW3 is pressed
                            ; 	r0 = 3 if SW4 is pressed
                            ; 	r0 = 4 if SW5 is pressed
                            ;   r0 = 1 for Default case none are pressed
    push {lr}
    bl read_from_push_btns; r0 set to 0001, 0010, 0100, or 1000
    mov r1, r0; store in r1 so I can set r0 for output
    cmp r1, #SW2_PRESSED
    it eq
    moveq r0, #1
    cmp r1, #SW3_PRESSED
    it eq
    moveq r0, #2
    cmp r1, #SW4_PRESSED
    it eq
    moveq r0, #3
    cmp r1, #SW5_PRESSED
    it eq
    moveq r0, #4
    cmp r1, #0; This is default none are pressed
    it eq
    moveq r0, #1; return 1 for default
    ;r0 is set, done
    pop {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


illuminate_LEDs:; illuminates the RBG LED on the Tiva board. The color to be displayed is passed into the routine in r0.  Provides for the RGB LED to be illuminated red, blue, green, purple, yellow, and white.
	;We assume the clock at port F is already enabled
	PUSH {lr}
	;Load
	MOV r1, #0x5000
    MOVT r1, #0x4000
	LDRB r2, [r1, #GPIODATA_OFFSET]
	BFI r2, r0, #0, #4; set the 4 bits we want to to the color
	;ORR r2, r0, r2
	STRB r2, [r1, #GPIODATA_OFFSET]

	POP {lr}
	MOV pc, lr


illuminate_RGB_LED:; illuminates the RBG LED on the Tiva board. The color to be displayed is passed into the routine in r0.  Provides for the RGB LED to be illuminated red, blue, green, purple, yellow, and white.
                   ; Inputs: 
                   ;    r0 = code for color.  RED: .equ 0x1 BLUE: .equ 0x2 GREEN: .equ 0x4 PURPLE: .equ 0x3 YELLOW: .equ 0x5 WHITE: .equ 0x7
                   ; Outputs:
                   ;    RGB on tivia board updated
    ;We assume the clock at port F is already enabled
	PUSH {lr}
	;Load
	MOV r1, #0x5000
    MOVT r1, #0x4002
	LDRB r2, [r1, #GPIODATA_OFFSET]
	BFI r2, r0, #1, #3; set the 3 bits we wanto to the color
	;ORR r2, r0, r2
	STRB r2, [r1, #GPIODATA_OFFSET]

	POP {lr}
	MOV pc, lr

read_tiva_push_button:; reads from the momentary push button (SW1) on the Tiva board, and returns a one (1) in r0 if the button is currently being pressed and a zero (0) if it is not.
				   ; Inputs:
				   ; 	SW1 button on tivia board
				   ; Outputs:
				   ; 	r0 = 1 if the button is being pressed, 0 otherwise
	PUSH {lr}
	MOV r1, #0x5000
	MOVT r1, #0x4002
	LDRB r2, [r1, #GPIODATA_OFFSET]
	UBFX r2, r2, #4, #1
	CMP r2, #0
	BEQ switch_closed
	B switch_open

switch_closed: ; If it's a 1 button is not pressed
	MOV r0, #1; Set r0 to 1 when button is pressed
	B done_read_from_push_btn

switch_open: ; If it's a 0, if the button is pressed
	MOV r0, #0
	B done_read_from_push_btn

done_read_from_push_btn:
	POP {lr}
	MOV pc, lr


initialize_LEDs:
	PUSH {lr}
	;The code below initalizes port F the way it will be used in this lab
    BL initialize_clock_port_B; set clock
	MOV r0, #0xF; want all to be 1
	BL set_direction_register_port_B; sed pins to be input/output
	MOV r0, #0xF; want all pins to be set to digital
	BL set_digital_port_B; say pins should be read in as digital
	
	POP {lr}
	MOV pc, lr

initialize_Buttons:
	PUSH {lr}
	BL initialize_clock_port_D
	MOV r0, #0x0; what all pins 0-3 to be 0 for input
	BL set_direction_register_port_D
	MOV r0, #0xF; want all pins to be set to digital
	BL set_digital_port_D
	;return
	POP {lr}
	MOV pc, lr

; Port B Initialization

initialize_clock_port_B:
	PUSH {lr}
	; Enabling clock
	MOV r0, #0xE000
    MOVT r0, #0x400F
	LDRB r1, [r0, #CLOCK_OFFSET]
	ORR r1, r1, #0x2; Want 2nd bit (indexed at 0) set to 1
	STRB r1, [r0, #CLOCK_OFFSET]
	; Clock enabled
	POP {lr}
	MOV pc, lr

set_direction_register_port_B:; This function sets the port F direction register to be the same as value passed in r0
							 ; Input:
							 ; 		r0: lower 8 bits set to the direction desired for the 8 pins
							 ; Output:
							 ; 		None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x5000
    MOVT r1, #0x4000 ; Address for GPIO Port B is 0x40005000
    STRB r0, [r1, #PORT_DATA_DIR_OFFSET]; setting direction register to be same as lower 8 bits of r0
	POP {lr};
	MOV pc, lr

set_digital_port_B:; This fuction sets the pins for port f to be digital
				  ; Input:
				  ; 	r0: the lower 8 bits hold the values set to the digital enable register
				  ; Outputs:
				  ; 	None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x5000
    MOVT r1, #0x4000 ; Address for GPIO Port B is 0x40005000
    STRB r0, [r1, #DIGITAL_ENABLE_REGISTER]
	POP {lr}
	MOV pc, lr

; Port D Initialization

initialize_clock_port_D:
	PUSH {lr}
	; Enabling clock
	MOV r0, #0xE000
    MOVT r0, #0x400F
	LDRB r1, [r0, #CLOCK_OFFSET]
	ORR r1, r1, #0x8; Want 4th bit (indexed at 0) set to 1
	STRB r1, [r0, #CLOCK_OFFSET]
	; Clock enabled
	POP {lr}
	MOV pc, lr

set_direction_register_port_D:; This function sets the port F direction register to be the same as value passed in r0
							 ; Input:
							 ; 		r0: lower 8 bits set to the direction desired for the 8 pins
							 ; Output:
							 ; 		None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x7000
    MOVT r1, #0x4000 ; Address for GPIO Port B is 0x40005000
	LDRB r2, [r1, #PORT_DATA_DIR_OFFSET]; loading bits so we don't change the ones we arent' setting
	BFI r2, r0, #0, #4; set the bits 0-4 to the same as r0
    STRB r2, [r1, #PORT_DATA_DIR_OFFSET]; setting direction register to be same as lower 8 bits of r0
	POP {lr};
	MOV pc, lr

set_digital_port_D:; This fuction sets the pins for port f to be digital
				  ; Input:
				  ; 	r0: the lower 8 bits hold the values set to the digital enable register
				  ; Outputs:
				  ; 	None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x7000
    MOVT r1, #0x4000 ; Address for GPIO Port B is 0x40005000
	LDRB r2, [r1, #DIGITAL_ENABLE_REGISTER]; loading so we only set the bits we want to
	BFI r2, r0, #0, #4; setting 4 bits of r2 to be same as r0
    STRB r2, [r1, #DIGITAL_ENABLE_REGISTER]
	POP {lr}
	MOV pc, lr

set_pull_up_resistor_port_D:; This function uses the lower 8 bits of r1 to set the pull up resistors in port F
							; Input:
							; 	r0: lower 8 bits.  Set 1 for each pin you want a pull up resistor connected to
							; Outpus:
							; 	None, but pull up resistors for port F are set
	PUSH {lr}
    MOV r1, #0x7000
    MOVT r1, #0x4000
	LDRB r2, [r1, #GPIOPUR_OFFSET]
	BFI r2, r0, #0, #4; setting lower 4 bits of r2 to be same as r0
	STRB r2, [r1, #GPIOPUR_OFFSET]; Set the pull up resistor values as same as lower 8 bits in r1
	POP {lr}
	MOV pc, lr

; Port F Initialization

nitialize_clock_portF:
	PUSH {lr}
	; Enabling clock
	MOV r0, #0xE000
    MOVT r0, #0x400F
	LDRB r1, [r0, #CLOCK_OFFSET]
	ORR r1, r1, #0x20; Want 5th bit (indexed at 0) set to 1
	STRB r1, [r0, #CLOCK_OFFSET]
	; Clock enabled
	POP {lr}
	MOV pc, lr

set_direction_register_portF:; This function sets the port F direction register to be the same as value passed in r0
							 ; Input:
							 ; 		r0: lower 8 bits set to the direction desired for the 8 pins
							 ; Output:
							 ; 		None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x5000
    MOVT r1, #0x4002 ; Address for GPIO Port F is 0x40025000
    STRB r0, [r1, #PORT_DATA_DIR_OFFSET]; setting direction register to be same as lower 8 bits of r0
	POP {lr};
	MOV pc, lr

set_digital_port_F:; This fuction sets the pins for port f to be digital
				  ; Input:
				  ; 	r0: the lower 8 bits hold the values set to the digital enable register
				  ; Outputs:
				  ; 	None
	PUSH {lr}
	; To write to Port F Data Direction Register
    MOV r1, #0x5000
    MOVT r1, #0x4002 ; Address for GPIO Port F is 0x40025000
    STRB r0, [r1, #DIGITAL_ENABLE_REGISTER]
	POP {lr}
	MOV pc, lr

set_pull_up_resistor_port_F:; This function uses the lower 8 bits of r1 to set the pull up resistors in port F
							; Input:
							; 	r0: lower 8 bits.  Set 1 for each pin you want a pull up resistor connected to
							; Outpus:
							; 	None, but pull up resistors for port F are set
	PUSH {lr}
    MOV r1, #0x5000
    MOVT r1, #0x4002 
	STRB r0, [r1, #GPIOPUR_OFFSET]; Set the pull up resistor values as same as lower 8 bits in r1
	POP {lr}
	MOV pc, lr


; ------------------------------------------------------------------------------------------------beginning of string2int
string2int:;  converts the NULL terminated ASCII string pointed to by the address passed into the routine in r0 to an integer. The integer should be returned in r0. The string is not modified by the routine.
           ; Inputs:
           ;    r0: address to the Null terminated ASCII string of decimal digits
           ; Outputs:
           ;    r0: the integer value that was represented by the sequence of decimal digits
    PUSH {lr, r4}   ; Store register lr on stack

    MOV r4, r0 ; Gonna overwrite r0 so copying character pointer address into r4

    MOV r0, #0 ; Storing integer solution here
    MOV r1, #10 ; Constant 10

loop_until_null_string2int:
    LDRB r2, [r4]; Holds the current character
    CMP r2, #0 ; Compare to see if r2 is the NULL terminator
    BEQ done_string2int

    ; NOTE: 48 is the ASCII value of '0'

    ; NOTE: If r2 is '9', the line below does '9' - '0' = 9

    SUB r2, r2, #48; Now we're actually subtracting 48
    MUL r3, r0, r1; r3 = r0 * 10
    ADD r0, r3, r2; Overall Evaluation: r0 = (r0 * 10) + (r2 - 48)

    ADD r4, r4, #1 ; Moving character pointer

    B loop_until_null_string2int

done_string2int:
    POP {lr, r4}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of string2int


; ------------------------------------------------------------------------------------------------
initialize_clock_portF:
	PUSH {lr}
	; Enabling clock
	MOV r0, #0xE000
    MOVT r0, #0x400F
	LDRB r1, [r0, #CLOCK_OFFSET]
	ORR r1, r1, #0x20; Want 5th bit (indexed at 0) set to 1
	STRB r1, [r0, #CLOCK_OFFSET]
	; Clock enabled
	POP {lr}
	MOV pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------------------------------------------------------------------------------beginning of int2string
int2string:;  stores the integer passed into the routine in r0 as a NULL terminated ASCII string in memory at the address passed into the routine in r1.
           ; Inputs:
           ;    r0: Integer value (must be positive/unsigned)
           ;    r1: Memory address you want integer value stored.  Because regs hold 32 bits, r1 must be able to store 11 bytes without messing with other memory
           ; Output:
           ;    String of ASCII digits stored at memory address provided by r1
    PUSH {lr, r4, r5, r6}   ; Store register lr on stack
    MOV r4, r0; store integer in r4 so it is preserved across function calls
    MOV r6, r1; store memory address in r6 so it is preserved across fuction calls
    
    ;First gonna check if int is 0, if it is I only have to store '0' in memory
    CMP r0, #0; compart int with 0
    BEQ number_was_0
    
    ;If this runs the number wasn't 0, so we need to process it normally
    BL count_digits; r0 will now hold the number of digits
    SUB r0, r0, #1; subrtract 1 from r0 because our for us digit indexes start at 0
    MOV r5, r0; r5 now holds the number of digits (minus 1)
loop_int2string:
    CMP r5, #-1; if r5 == -1 we want to break out of loop
    BEQ done_int2string
    MOV r0, r4; move integer back into r0 for function call
    MOV r1, r5
    BL get_int_at_position; r0 now has digit at index r5
    ADD r0, r0, #48 ;add value of '0' to r0 to make it a ASCII character
    STRB r0, [r6]; store digit at memory address
    ADD r6, r6, #1; increment memory address to next position
    SUB r5, r5, #1; decrement r3
    B loop_int2string

    ; Your code for your int2string routine is placed here

number_was_0:
    ADD r0, r0, #48;Place '0' in r0
    STRB r0, [r6]; Store '0' in memory where it's supposed to go
    ADD r6, r6, #1; increment r6 to point to next spot for NULL terminator
    B done_int2string

done_int2string:
    MOV r0, #0; store Null in r0
    STRB r0, [r6]; store Null terminator
    POP {lr, r4, r5, r6}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of int2string
; ------------------------------------------------------------------------------------------------beginning of int2string_noNullTerm:
int2string_noNullTerm:;  stores the integer passed into the routine in r0 as an ASCII string (NOT NULL TERMINATED) in memory at the address passed into the routine in r1.
           ; Inputs:
           ;    r0: Integer value (must be positive/unsigned)
           ;    r1: Memory address you want integer value stored.  Because regs hold 32 bits, r1 must be able to store 11 bytes without messing with other memory
           ; Output:
           ;    String of ASCII digits stored at memory address provided by r1 (NOT NULL TERMINATED!!)
    PUSH {lr, r4, r5, r6}   ; Store register lr on stack
    MOV r4, r0; store integer in r4 so it is preserved across function calls
    MOV r6, r1; store memory address in r6 so it is preserved across fuction calls
    
    ;First gonna check if int is 0, if it is I only have to store '0' in memory
    CMP r0, #0; compart int with 0
    BEQ number_was_0_int2string_noNullTerm
    
    ;If this runs the number wasn't 0, so we need to process it normally
    BL count_digits; r0 will now hold the number of digits
    SUB r0, r0, #1; subrtract 1 from r0 because our for us digit indexes start at 0
    MOV r5, r0; r5 now holds the number of digits (minus 1)
loop_int2string_noNullTerm:
    CMP r5, #-1; if r5 == -1 we want to break out of loop
    BEQ done_int2string_noNullTerm
    MOV r0, r4; move integer back into r0 for function call
    MOV r1, r5
    BL get_int_at_position; r0 now has digit at index r5
    ADD r0, r0, #48 ;add value of '0' to r0 to make it a ASCII character
    STRB r0, [r6]; store digit at memory address
    ADD r6, r6, #1; increment memory address to next position
    SUB r5, r5, #1; decrement r3
    B loop_int2string_noNullTerm

    ; Your code for your int2string routine is placed here

number_was_0_int2string_noNullTerm:
    ADD r0, r0, #48;Place '0' in r0
    STRB r0, [r6]; Store '0' in memory where it's supposed to go
    ADD r6, r6, #1; increment r6
    B done_int2string_noNullTerm

done_int2string_noNullTerm:
    POP {lr, r4, r5, r6}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending of int2string_noNullTerm:


; ------------------------------------------------------------------------------------------------beginning clear_terminal
clear_terminal:; This functions clears the Terminal
               ; Inputs:
               ;    None
               ; Outputs:
               ;    Terminal is cleared
    push {lr}
    mov r0, #0xC; new form feed character
    bl output_character
    pop {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending clear_terminal



; ---------------------------------end------------------------------------------------------------
.end
