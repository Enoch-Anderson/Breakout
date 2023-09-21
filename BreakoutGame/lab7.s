	.data
	.global uart_interrupt_init
	.global gpio_interrupt_init	
	.global simple_read_character
	.global output_character
	.global read_string		
	.global output_string		
	.global uart_init		
	.global read_character
    .global change_timer_cycles
    .global gpio_btn_and_LED_init
    .global clock_interrupt_init
    .global Switch_Handler
	.global Timer_Handler
	.global UART0_Handler
	.global int2string_noNullTerm
    .global game
    .global simple_read_character
    .global reset_terminal
    .global change_timer_cycles
    .global disable_timer_interrupts
    .global enable_timer_interrupts
	.global illuminate_RGB_LED
    .global read_from_push_buttns_easy
	.global print_newline_carriage_return
    .global disable_all_interrupts
    .global start_timer_no_interrupt


board:  .string "                       ", 0xA, 0xD
        .string "                       ", 0xA, 0xD
        .string "+---------------------+", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "|                     |", 0xA, 0xD
        .string "+---------------------+", 0xA, 0xD, 0
welcome_prompt: .string "Welcome to Breakout Game!", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "How to Play:             ", 0xA, 0xD
                .string "   -Try to break all the bricks on the board.  When you do ",  0xA, 0xD
                .string "    your level will increase and the game will get harder.", 0xA, 0xD
                .string "    You get more points per brick on harder levels though!"
                .string "                                                            ", 0xA, 0xD
                .string "   -If you break all the bricks at level 4 you win!" , 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "   -Use 'a' key on keyboard to move the paddle left.", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "   -Use 'd' key on keyboard to move the paddle right.", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "   -You begin with 4 lives, if the ball goes below the", 0xA, 0xD
                .string "    paddle you loose a life.", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "   -If you loose all 4 lives you lose", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "   -Press SW1 on the Tivia board to pause and unpause the game.", 0xA, 0xD
                .string "                                                            ", 0xA, 0xD
                .string "Choose how many rows of bricks to generate.", 0xA, 0xD
                .string "   -Press and hold SW2 to generate 1 row of bricks          ", 0xA, 0xD
                .string "   -Press and hold SW3 to generate 2 row of bricks          ", 0xA, 0xD
                .string "   -Press and hold SW4 to generate 3 row of bricks          ", 0xA, 0xD
                .string "   -Press and hold SW5 to generate 4 row of bricks          ", 0xA, 0xD
                .string "   -Default, 1 row of bricks generated                      ", 0xA, 0xD
                .string "While holding button chosen, press any key on the keyboard to", 0xA, 0xD
                .string "begin the game.                                             ", 0xA, 0xD, 0
bricks: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; bricks will be saved in here
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; one brick contains 3 bytes of data [byte1, byte2, byte3, byte4] == [color, x coord, y coord, extra]
        .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; easiest way to reserve a block of 30 words

levelSpeeds: .word 0x30D400; cycles before interrupt level 1
             .word 0x2BF200; cycles before interrupt level 2
             .word 0x271000; cycles before interrupt level 3
             .word 0x222E00; cycles before interrupt level 4


hide_cursor_string:         .string 27, "[?25l", 0; ansi escape sequence to hide the cursor
lives:                      .word 0x4; holds number of lives count
ball:                       .string 27, "[37m*", 0 ;This string makes the ball initially white and then print the ball
cursor:                     .string 27, "[10;10H", 0;This strings moves the cursor where you want it.  initially set to 10,10 and can support from 00;00 to 99;99
padX:                       .word 10; x position of the paddle, initally 10 so paddle is in the middle
padY:                       .word 17; y position of the paddle, never changes but used to calculate colissions
paddle:                     .string 27, "[36;46m-----", 0; This is the paddle, I make it white but kept the '-' characters so ari can see it on her Mac
clear_paddle                .string 27, "[0m     ", 0; convient string to print to remove the paddle
default_terminal_setting:   .string 27, "[0m", 0; string to restore terminal settings to default
ballCurX:                   .word 12; x position of ball, initally will by 12
ballCurY:                   .word 10; y position of ball, initally will be 10
dirX:                       .word 0; x component of direction ball is moving, initally 0
dirY:                       .word 1; y component of direction ball is moving, initally down
erase_ball:                 .string 27, "[0m ", 0; convient string to remove ball from screen
left_wall_position:         .word 1; column number for left wall
right_wall_position:        .word 23; column number for right wall
top_boarder:                .string 27, "[0m+---------------------+", 0; convenient way to reprint top border if ball intersects with one of it's characters
top_boarderX:               .word 1; x coord of top boarder
top_boarderY:               .word 3; y coord of top boarder
need_top_boarder_reprint:   .word 0; This value is set to 1 when the the top boarder needs to be reprinted
paused_game:                .word 0; This value is set to 1 when the game is paused, 0 when unpaused
paused_string:              .string 27, "[41;30m PAUSED ", 27, "[13;2H Press SW1 to Unpause", 0; String that prints when the game is paused
unpaused_string:            .string 27, "[0m        ", 27, "[13;2H                     ", 0; String that prints when the game is unpaused
pausedX:                    .word 8; x position where paused/unpaused are printed
pausedY:                    .word 12; y position where paused/unpaused are printed
level_number:               .word 1; this holds what level the player is on
level_number_string:        .string 27, "[0mLevel:  ", 0 ;This string gets printed to show level number.  Only supports 1 digit level number
level_numberX:              .word 2; x coord of level number on screen
level_numberY:              .word 1; y coord of level number on screen
score:                      .word 0; this holds the score the player has
score_string:               .string 27, "[0mScore:     ", 0;This string gets printed to show/update score on screen.  Only supports 4 digit score
scoreX:                     .word 12; x coord of score on screen
scoreY:                     .word 1;  y coord of score on screen
lives_string:               .string 27, "[0mLives:  ", 0; This string gets printed to show/update lives count on screen. Only supports 1 digit
livesX:                     .word 2; x coord of lives string
livesY:                     .word 2; y coord of lives string
bottom_boarderX:            .word 1; x coord of bottom boarder string (top_boarder string will be used because it's the same sequence of characters)
bottom_boarderY:            .word 18; y coord of bottom boarder string  (top_boarder string will be used because it's the same sequence of characters)
RGB_led_color:              .word 0x7; starting as white for now
number_brick_rows:          .word 1; this will hold how many rows of bricks to compute and print
number_brick_per_row:       .word 7; this is how many bricks per row there are
won_string:                 .string 27, "[46;30m Congradulations you won! ", 0
game_over_string:           .string 27, "[41;30m GAME OVER ", 0
continue_prompt:            .string 27, "[0mPlay again? press 'y' for yes, any other key for exit.", 0; continue prompt string
goodbye_string:             .string 27, "[0mGoodbye :)", 0; this string is printed when the game ends
brickMinX:                  .word 2; min x value allowed for brick
brickMaxX:                  .word 22;max x value allowed for brick
brickMinY:                  .word 6; min y value allowed for brick
curBrickX:                  .word 2; holds x coord where next brick will go
curBrickY:                  .word 6; holds y coord wher next brick will go
brick_string:               .string 27, "[44m   ", 0 ;inject color into this string and print to print bricks
erase_brick_string:         .string 27, "[0m   ", 0 ;print this string overtop of a brick to erase it
random_timer_read:          .word 0; Will fill this with current timer value when user starts the game


    .text
;pointers to all variables in memory below
ptr_levelSpeeds:                .word levelSpeeds
ptr_bricks:                     .word bricks
ptr_hide_cursor_string:         .word hide_cursor_string
ptr_board:                      .word board
ptr_welcome_prompt:             .word welcome_prompt
ptr_lives:                      .word lives
ptr_ball:                       .word ball
ptr_cursor:                     .word cursor
ptr_padX:                       .word padX
ptr_padY:                       .word padY
ptr_paddle:                     .word paddle
ptr_clear_paddle:               .word clear_paddle
ptr_default_terminal_setting:   .word default_terminal_setting
ptr_ballCurX:                   .word ballCurX
ptr_ballCurY:                   .word ballCurY
ptr_dirX:                       .word dirX
ptr_dirY:                       .word dirY
ptr_erase_ball:                 .word erase_ball
ptr_left_wall_position:         .word left_wall_position
ptr_right_wall_position:        .word right_wall_position
ptr_top_boarder:                .word top_boarder
ptr_top_boarderX:               .word top_boarderX
ptr_top_boarderY:               .word top_boarderY
ptr_need_top_boarder_reprint:   .word need_top_boarder_reprint
ptr_paused_game:                .word paused_game
ptr_paused_string:              .word paused_string
ptr_unpaused_string:            .word unpaused_string
ptr_pausedX:                    .word pausedX
ptr_pausedY:                    .word pausedY
ptr_level_number:               .word level_number
ptr_level_number_string:        .word level_number_string
ptr_level_numberX:              .word level_numberX
ptr_level_numberY:              .word level_numberY
ptr_score:                      .word score
ptr_score_string:               .word score_string
ptr_scoreX:                     .word scoreX
ptr_scoreY:                     .word scoreY
ptr_lives_string:               .word lives_string
ptr_livesX:                     .word livesX
ptr_livesY:                     .word livesY
ptr_bottom_boarderX:            .word bottom_boarderX
ptr_bottom_boarderY:            .word bottom_boarderY
ptr_RGB_led_color:              .word RGB_led_color
ptr_number_brick_rows:          .word number_brick_rows
ptr_number_brick_per_row:       .word number_brick_per_row
ptr_won_string:                 .word won_string
ptr_game_over_string:           .word game_over_string
ptr_continue_prompt:            .word continue_prompt
ptr_goodbye_string:             .word goodbye_string
ptr_brickMinX:                  .word brickMinX
ptr_brickMaxX:                  .word brickMaxX
ptr_brickMinY:                  .word brickMinY
ptr_curBrickX:                  .word curBrickX
ptr_curBrickY:                  .word curBrickY
ptr_brick_string:               .word brick_string
ptr_erase_brick_string:         .word erase_brick_string
ptr_random_timer_read:              .word random_timer_read

PORT_DATA_DIR_OFFSET: .equ 0x400
CLOCK_OFFSET: .equ 0x608
DIGITAL_ENABLE_REGISTER: .equ 0x51C
GPIODATA_OFFSET: .equ 0x3FC

;Min and maximum dimensions of the game board.  These numbers are equal to 1 character still inside the board around the border
MIN_X: .equ 2; furthest left
MAX_X: .equ 22; furthest right
MIN_Y: .equ 3; top of board because numbers index at the top left of the board
MAX_Y: .equ 16; bottom of the board

;Codes to set colors of RGB LEDs on Tivia board
RED:    .equ 0x1
BLUE:   .equ 0x2
GREEN:  .equ 0x4
PURPLE: .equ 0x3
YELLOW: .equ 0x5
WHITE:  .equ 0x7

;Handles all ball and brick color stuff
CONVERT_BACKGROUND: .equ 41; Add this number to random number generated to get background color code
; foreground ball color is calculated by subtracting 10 from whatever brick color is



;used to help set interrupt clear register
GPIO_PORT_F: .word	0x40025000	; Base address for GPIO Port F
UART0: .word 0x4000C000
TIMER0: .word 0x40030000; For Timer_Handler



; ------------------------ game ------------------------------------------------------
game:
    push {lr}

    ;initalizing gpio uart, note they are not enabled to interrupt the processor yet
    bl uart_init
    bl gpio_btn_and_LED_init
    bl start_timer_no_interrupt

game_beginning:
    ;clear terminal, makes things look nicer
    bl reset_terminal
    ;print welcoming propts
    ldr r0, ptr_welcome_prompt
    bl output_string

    ;wait and read for keyboard press and update #rows based on SW1-5 pressed
    bl read_character; this will loop until a character is pressed because interrupts aren't enabled
    bl read_from_push_buttns_easy; r0 = number of rows to print 1-4
    ldr r1, ptr_number_brick_rows
    str r0, [r1]; store number in global memory position
    
    ;get random seed to help randomize more
    bl get_timer_value; r0 = current value from timer
    ldr r1, ptr_random_timer_read
    str r0, [r1]; store starting seed here

    ;branch to game infinite loop
    bl restart_game_from_beginning
won_lost:; only returned here if won game or lost all lives. lives >= 1 if won, == 0 if lost
    ;interrupts should have already been disabled
    ;clear terminal
    bl reset_terminal

    ;print you won or game over string
    ldr r0, ptr_won_string; initalize as this
    ldr r1, ptr_lives
    ldr r1, [r1]; r1 = lives remaining
    cmp r1, #0; are there 0 lives?
    it eq
    ldreq r0, ptr_game_over_string; switch to game over string if lost
    bl output_string; print string
    bl print_newline_carriage_return; make things look a little nicer

    ;print continue and accept y or n input
    ldr r0, ptr_continue_prompt
    bl output_string
    bl read_character; r0 = character they pressed

    ;if y pressed loop through game again
    cmp r0, #0x79; is r0 == 'y'?
    beq game_beginning
    b end_game

end_game:
    ;print goodbye
    bl reset_terminal
    ldr r0, ptr_goodbye_string
    bl output_string; print goodbye
    pop {lr}
    mov pc, lr

restart_game_from_beginning:
    PUSH {lr}
    ;clear terminal for testing convenience
    bl reset_terminal

    ;print board
    ldr r0, ptr_board
    bl output_string; print board

    ;hide cursor (makes things look nicer)
    bl hide_cursor

    ;restore lives = 4 and show on board and terminal
    bl restart_lives

    ;restore score to 0 and print
    bl restart_score

    ;retore level number and print
    ldr r1, ptr_level_number
    mov r0, #1; level number initially 1
    str r0, [r1]; set level number 1 in memory
    bl print_level_number

    ;set RGB color to be default color and illuminate it
    ldr r1, ptr_RGB_led_color
    mov r0, #WHITE; white is default for now
    str r0, [r1]; store white at memory address
    bl illuminate_RGB_LED; make tivia board led white
    
    ;restore paddle to initial postion and print it
    bl clear_paddle_from_screen; first clear paddle from screen
    ;restore padX and padY
    ldr r1, ptr_padX
    mov r0, #10; initial x position
    str r0, [r1]; reset padX
    ldr r1, ptr_padY
    mov r0, #17; initial y position, never changed but better safe than sorry
    str r0, [r1]; reset padY
    bl print_paddle; print paddle back in original positoin

    ;restore ball color, dirX, dirY, ballCurX, ballCurY, clear ball, print ball in default location
    bl reset_ball

    ;reset curBrickX and curBrickY
    ldr r1, ptr_curBrickX
    ldr r0, ptr_brickMinX
    ldr r0, [r0]; r0 = value we want to restore 
    str r0, [r1]; curBrickX restored to initial value
    ldr r1, ptr_curBrickY
    ldr r0, ptr_brickMinY
    ldr r0, [r0]; r0 = value we want to restore
    str r0, [r1]; curBrickY restored to initial value

    ;reset bricks in bricks array to be all 0
    bl reset_bricks_all_null

    ;enable all interrupts
    bl uart_interrupt_init
    bl gpio_interrupt_init
    bl clock_interrupt_init

    ;generate bricks, this has to be done after timer initalized because it is used for random number generation
    bl generate_bricks

    ;print all the bricks to terminal
    bl print_bricks


infinite_loop: ;checks if all bricks destroyed, or if lives == 0.  If either it exits the loop
    ;check if all bricks destroyed, break out if so
    ;We know all bricks are destroyed when last brick in bricks == 0
    ldr r0, ptr_bricks
    ldr r0, [r0]; r0 = last brick
    cmp r0, #0; is last brick 0?
    beq increase_level_or_won

    ;check if lives == 0, break out if so
    ldr r0, ptr_lives
    ldr r0, [r0]; r0 = lives count
    cmp r0, #0
    ble end_restart_game_from_beginning
    b infinite_loop; still have some lives left

end_restart_game_from_beginning:
    ;disable all interrupts
    bl disable_all_interrupts
    ;done
    POP {lr}
    MOV pc, lr

increase_level_or_won:; This is called when all the bricks are destoryed.  Either want to increase level jump to end because they won
    ;disable interrupts first
    bl disable_all_interrupts

    ;check if won, easiest first
    ldr r1, ptr_level_number
    ldr r0, [r1]; r0 = level number
    cmp r0, #4; is level = max level?
    beq end_restart_game_from_beginning; leave game loop if so

    ;store next level number now while it's easy
    add r0, r0, #1; incrase level number
    str r0, [r1]; store new level number

    sub r0, r0, #1; subtract so math is easier
    ;set timer to be correct speed now
    lsl r0, r0, #2; easy way to multiply by 4. r0 = offset of levelSpeeds for correct speed
    ldr r1, ptr_levelSpeeds
    ldr r0, [r1, r0]; r0 = desired level speed
    bl change_timer_cycles; note timer is enabled here

    ; print new level number
    bl print_level_number

    ;set RGB color to be default color and illuminate it
    ldr r1, ptr_RGB_led_color
    mov r0, #WHITE; white is default for now
    str r0, [r1]; store white at memory address
    bl illuminate_RGB_LED; make tivia board led white
    
    ;restore paddle to initial postion and print it
    bl clear_paddle_from_screen; first clear paddle from screen
    ;restore padX and padY
    ldr r1, ptr_padX
    mov r0, #10; initial x position
    str r0, [r1]; reset padX
    ldr r1, ptr_padY
    mov r0, #17; initial y position, never changed but better safe than sorry
    str r0, [r1]; reset padY
    bl print_paddle; print paddle back in original positoin

    ;restore ball color, dirX, dirY, ballCurX, ballCurY, clear ball, print ball in default location
    bl reset_ball

    ;reset curBrickX and curBrickY
    ldr r1, ptr_curBrickX
    ldr r0, ptr_brickMinX
    ldr r0, [r0]; r0 = value we want to restore 
    str r0, [r1]; curBrickX restored to initial value
    ldr r1, ptr_curBrickY
    ldr r0, ptr_brickMinY
    ldr r0, [r0]; r0 = value we want to restore
    str r0, [r1]; curBrickY restored to initial value

    ;enable all interrupts, minus clock because that's already going
    bl uart_interrupt_init
    bl gpio_interrupt_init

    ;generate bricks, this has to be done after timer initalized because it is used for random number generation
    bl generate_bricks

    ;print all the bricks to terminal
    bl print_bricks

    ;gonna pause the game because it makes sense to me to do that
    bl pause_game

    b infinite_loop; branch back to game loop
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ generate bricks ------------------------------------------------------
generate_bricks:; This function generates the desired number of bricks and stores them in the bricks memory value
                ; Inputs:
                ;       r0 = desired number of bricks to generate, CANNOT BE BIGGER THAN 28 RIGHT NOW
                ; Outputs:
                ;       bricks are generated and stored in bricks memory address
    push {lr, r4, r5}
    ; calculate the number of bricks to generate
    ldr r0, ptr_number_brick_per_row
    ldr r0, [r0]; r0 = number of bricks per row
    ldr r1, ptr_number_brick_rows
    ldr r1, [r1]; r1 = number of rows
    mul r4, r0, r1; r4 = total number of bricks to generate

    ldr r5, ptr_bricks; r5 = pointer where next brick is stored
    ; while we haven't generated enough bricks, generate and store more another brick
add_another_brick:
    cmp r4, #0; have we made enough bricks yet?
    ble done_generate_bricks; jump out of loop if so
    ;if this runs we need to make another brick
    bl make_one_brick; r0 = new brick
    str r0, [r5], #4; store new brick where it belongs and increment pointer
    sub r4, r4, #1; subtract 1 from total number needed to make
    b add_another_brick; loop
done_generate_bricks:
    ;return
    pop {lr, r4, r5}
    mov pc, lr

make_one_brick:; This function generates one brick and returns it in r0
               ; Inputs: 
               ;    data at brickMinX, brickMaxX, brickMinY, curBrickX, curBrickY
               ; Outputs:
               ;    r0 = data for 1 brick
    push {lr, r4}
    ; calculate brick color
    bl rand_int_from_0_to_4; r0 == color
    ;50% of the time call this function again
    ubfx r1, r0, #0, #1; r2 = first bit of r0
    cmp r1, #0; was r0 even
    it eq
    bleq rand_int_from_0_to_4; get another random number

    add r4, r0, #CONVERT_BACKGROUND; make this an ansii code and save it in r4
    
    ; calculate x and y cord
    bl calc_next_brick_x_y; r0 = x, r1 = y

    ; insert all this data into the brick r0 to return
    ; brick = [byte1, byte2, byte3, byte4] == [color, x coord, y coord, extra]
    lsl r0, r0, #8; x position goes in byte2
    bfi r0, r4, #0, #8; insert color into byte 1
    bfi r0, r1, #16, #8; insert y coord in byte 3
    
    ;return
    pop {lr, r4}
    mov pc, lr

calc_next_brick_x_y:; this funciton generates and returns the x and y coord of where the next brick should go
                    ; Inputs:
                    ;      data at brickMinX, brickMaxX, brickMinY, curBrickX, curBrickY, 
                    ; Outputs:
                    ;      r0 = x coord of brick
                    ;      r1 = y coord of brick
    push {lr, r4, r5, r6}
    ;load in brickCurX and brickCurY
    ldr r4, ptr_curBrickX
    ldr r5, ptr_curBrickY
    ldr r0, [r4]; r0 = curBrickX, we want to return this unmodified
    ldr r1, [r5]; r1 = curBrickY, we want to return this unmodified

    ;add 3 to curBrickX, fix things if it would take a brick outside of the board
    mov r3, r1; store y position in r3 for now
    add r2, r0, #3; bricks are 3 charcters wide
    ldr r6, ptr_brickMaxX
    ldr r6, [r6]; r6 = max x postion possible for a brick
    cmp r2, r6; is new x > max value possible?
    ittt gt
    ldrgt r2, ptr_brickMinX
    ldrgt r2, [r2]; x position reset
    addgt r3, r3, #1; move down one row

    ;store new x and y values to curBrickX and curBrickY
    str r2, [r4]; store next x position 
    str r3, [r5]; store next y position

    pop {lr, r4, r5, r6}
    mov pc, lr

rand_int_from_0_to_4:; generates a random number between 1 and 4.  Must be ran after the timer is initalized
                     ; Inputs:
                     ;      data at GPTMTBV
                     ; Outputs:
                     ;      r0 = random number between 0 and 4
    PUSH {lr}
    ; GPTM Timer B Value Address: 0x40030048
    MOV r0, #0x0048
    MOVT r0, #0x4003
    LDR r0, [r0]

    ;combine this with first random seed generated
    ldr r2, ptr_random_timer_read
    ldr r1, [r2]; r1 = random seed value
    add r0, r0, r1; combine them to be a little more random
    str r0, [r2]; change random seed value


    ;calculate mod
    MOV r1, #5
    UDIV r2, r0, r1
    MUL r2, r2, r1
    SUB r0, r0, r2
    ; r0 - (r0/5) * 5
    POP {lr}
    MOV pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ generate bricks ----------------------------------------------------
reset_bricks_all_null:; this function restores all the bricks in the bricks array to be all null
                      ; Inputs:
                      ;     None
                      ; Outputs:
                      ;     all bricks in bricks set to Null
    push {lr}
    ldr r0, ptr_bricks; r0 points to bricks array
    mov r1, #30; restore all 30 meory spaces to 0
    mov r3, #0; 0 value to store
loop_reset_bricks_all_null:
    cmp r1, #0; have you done this 30 times yet?
    beq done_reset_bricks_all_null; done if so
    ;this only runs if there is more bricks places to reset
    str r3, [r0], #4; store 0 and increment r0
    sub r1, r1, #1; decrement r1
    b loop_reset_bricks_all_null

done_reset_bricks_all_null:
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ get_timer_value ------------------------------------------------------
get_timer_value:;this function gets the current value on the timer and returns it
                ; Inputs: 
                ;    Value on timer
                ; Outputs:
                ;    r0 = that value
    ;leaf no push or pop needed
    MOV r0, #0x0048
    MOVT r0, #0x4003
    LDR r0, [r0]  
    ;leaf no push or pop needed
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ print_bricks ------------------------------------------------------
print_bricks:; This function prints all the bricks stored in the bricks array
             ; Inputs:
             ;      data at bricks array
             ; Outputs:
             ;      bricks are printed to terminal
    push {lr, r4, r5}
    ldr r4, ptr_bricks; r4 = pointer to next brick
    ldr r5, [r4]; r5 = next brick
more_bricks_to_print:
    cmp r5, #0; are we at the end of the bricks array?
    beq done_print_bricks; leave loop if yes
    ;this only runs if r5 == a brick to print
    mov r0, r5; put brick in r0
    bl print_one_brick
    ldr r5, [r4], #4; put next brick in r5, and increment r4
    b more_bricks_to_print

done_print_bricks:
    pop {lr, r4, r5}
    mov pc, lr

print_one_brick:; This function prints 1 brick that's stored in r0
                ; Inputs:
                ;   r0 = brick to print
                ; Outputs:
                ;   brick printed to terminal
    push {lr, r4}
    mov r4, r0; move brick in r4 so it's preserved
    ;extract x and y coord, move cursor there
    ubfx r0, r4, #8, #8; pull out x coord and place in r0
    ubfx r1, r4, #16, #8; pull out y coord and place in r1
    bl move_cursor; move cursor where we want to print brick

    ;extract color and inject it into the brick_string
    ubfx r0, r4, #0, #8; extract color into r0
    bl change_brick_color

    ;print brick_string
    ldr r0, ptr_brick_string
    bl output_string
    ;done
    pop {lr, r4}
    mov pc, lr 
change_brick_color:; this function injects the color passed in from r0 into the brick_string
                   ; Inputs:
                   ;    r0 = color to inject
                   ; Outptus:
                   ;    color is injected into brick string
    push {lr}
    ldr r1, ptr_brick_string
    add r1, r1, #2; shift over 2 so we overwrite ansii characters for foreground
    ;r0 already int we want to inject
    bl int2string_noNullTerm
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ reset_ball ------------------------------------------------------
reset_ball:; this function clears ball from scree, resets ballCurX, ballCurY, dirX, dirY, and then prints ball to screen.
           ; It also restores the ball color to white.
           ; Inputs:
           ;    None
           ; Outputs: 
           ;    clears ball from scree, resets ballCurX, ballCurY, dirX, dirY, and then prints ball to screen.
    push {lr}
    ;clear ball first
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0 = ballCurX
    ldr r1, ptr_ballCurY
    ldr r1, [r1]; r1 = ballCurY
    bl move_cursor
    ldr r0, ptr_erase_ball
    bl output_string

    ;reset ball color
    bl reset_ball_color

    ;reset ballCurX, ballCurY, dirX, dirY
    ldr r1, ptr_ballCurX
    mov r0, #12; initial value
    str r0, [r1]
    ldr r1, ptr_ballCurY
    mov r0, #10; initial value
    str r0, [r1]
    ldr r1, ptr_dirX
    mov r0, #0; initial value
    str r0, [r1]
    ldr r1, ptr_dirY
    mov r0, #1; initial value
    str r0, [r1]

    ;print ball back to screen
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0 = ballCurX
    ldr r1, ptr_ballCurY
    ldr r1, [r1]; r1 = ballCurY
    bl move_cursor
    ldr r0, ptr_ball
    bl output_string

    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ reset_ball_color ------------------------------------------------------
reset_ball_color:; This resets the ball color to be white
                 ; Inputs:
                 ;      None
                 ; Outputs:
                 ;      ball color updated in ball string
    push {lr}
    ldr r1, ptr_ball; r1 = ball string 
    add r1, r1, #2; move r1 over to where we want to inject characters
    mov r0, #37; this is the code for white
    bl int2string_noNullTerm
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ change_ball_color ------------------------------------------------------
change_ball_color:; This changes the ball color to be the foreground color passed in through r0
                 ; Inputs:
                 ;      r0 = foreground color of ansii escape sequence
                 ; Outputs:
                 ;      ball color updated in ball string
    push {lr}
    ;r0 is foreground color
    ldr r1, ptr_ball; r1 = ball string 
    add r1, r1, #2; move r1 over to where we want to inject characters
    bl int2string_noNullTerm
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ restart_score ------------------------------------------------------
restart_score:; This function resets the score back to 0, and also prints the updated score to termainal
              ; Inputs: 
              ;     None
              ; Outputs:
              ;     data at score and score_string updated
    push {lr}
    ;set score int in memory back to 0
    ldr r1, ptr_score
    mov r0, #0; want to restore to 0
    str r0, [r1]; set score to 0

    ;clear out score in score_string with spaces
    ldr r1, ptr_score_string; r1 = score string
    add r1, r1, #11; move 11 characters over to skip over ansii escape sequence and characters of Score:_
    ;need to inject 4 spaces into string
    mov r0, #0x20; r0 = ' '
    strb r0, [r1], #1; store ' ' at memory position and update r1 over 1
    strb r0, [r1], #1; store ' ' at memory position and update r1 over 1
    strb r0, [r1], #1; store ' ' at memory position and update r1 over 1
    strb r0, [r1], #1; store ' ' at memory position and update r1 over 1

    ;print score to terminal
    bl print_score
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ hide_cursor ------------------------------------------------------
hide_cursor:; calling this function prints the ansii escape sequence to hide the cursor
            ; Inputs: 
            ;     data at hide_cursor_string
            ; Outputs: 
            ;     ansii sequence to hide cursor is printed to the screen
    push {lr}
    ldr r0, ptr_hide_cursor_string
    bl output_string
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ print_lives ------------------------------------------------------
print_lives:; This function prints the current score inside score to the screen
            ; Inputs:
            ;     data at memory addresses score, score_string, scoreX, scoreY
            ; Outputs:
            ;     current score is printed to the terminal
    push {lr}
    ;inject ascii characters of score into score_string
    ldr r1, ptr_lives_string
    add r1, r1, #11; move 11 characters over to skip over ansii escape sequence and characters of Lives:_
    ldr r0, ptr_lives
    ldr r0, [r0]; r0 = lives
    bl int2string_noNullTerm; inject characters into string.  If you ever inject more that 1 character things will break

    ;move cursor where it needs to be
    ldr r0, ptr_livesX
    ldr r0, [r0]; r0 = x coord
    ldr r1, ptr_livesY
    ldr r1, [r1]; r1 = y coord
    bl move_cursor; move cursor where we want to print string

    ;print score_string
    ldr r0, ptr_lives_string; r0 = string we want to print
    bl output_string

    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ print_score ------------------------------------------------------
print_score:; This function prints the current score inside score to the screen
            ; Inputs:
            ;     data at memory addresses score, score_string, scoreX, scoreY
            ; Outputs:
            ;     current score is printed to the terminal
    push {lr}
    ;inject ascii characters of score into score_string
    ldr r1, ptr_score_string
    add r1, r1, #11; move 11 characters over to skip over ansii escape sequence and characters of Score:_
    ldr r0, ptr_score
    ldr r0, [r0]; r0 = score
    bl int2string_noNullTerm; inject characters into string.  If you ever inject more that 4 characters things will break

    ;move cursor where it needs to be
    ldr r0, ptr_scoreX
    ldr r0, [r0]; r0 = x coord
    ldr r1, ptr_scoreY
    ldr r1, [r1]; r1 = y coord
    bl move_cursor; move cursor where we want to print string

    ;print score_string
    ldr r0, ptr_score_string; r0 = string we want to print
    bl output_string

    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ print_level_number ------------------------------------------------------
print_level_number:; This function prints the current level inside level_number to screen
            ; Inputs:
            ;     data at memory addresses level_number, level_number_string, level_numberX, level_numberY
            ; Outputs:
            ;     current level number is printed to the terminal
    push {lr}
    ;inject level_number into level_number_string as a sequence of ascii characters
    ldr r0, ptr_level_number
    ldr r0, [r0]; r0 = level_number integer
    ldr r1, ptr_level_number_string
    add r1, r1, #11; move pointer past all asnsii escape sequence and regular characters
    bl int2string_noNullTerm

    ;move cursor where it needs to be
    ldr r0, ptr_level_numberX
    ldr r0, [r0]; r0 = x coord
    ldr r1, ptr_level_numberY
    ldr r1, [r1]; r1 = y coord
    bl move_cursor; move cursor where we want to print string

    ;print level_number to screen
    ldr r0, ptr_level_number_string
    bl output_string

    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ print_paddle ------------------------------------------------------
print_paddle:; This function prints the paddle to the screen
             ; Inputs:
             ;      None, but padX and padY are used know where to print the paddle
             ; Outputs: 
             ;      Paddle is printed to screen
    push {lr}
    
    ;get padX and padY, move the cursor to be there
    ldr r0, ptr_padX
    ldr r0, [r0] ; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; moves curor to desired location

    ;print paddle where the cursor is
    ldr r0, ptr_paddle
    bl output_string

    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ move_cursor ------------------------------------------------------
move_cursor:;This function moves the putty cursor to the position stored in r0 and r1. xpos = r0 ypos = r1.  BOTH NUMBERS MUST BE BETWEEN 00 AND 99
            ; Inputs:
            ;       r0 = desired x position of cursor
            ;       r1 = desired y position of cursor
            ; Outputs:
            ;       Putty cursor is moved to desired location
    push {lr, r4, r5}
    
    ;First preserve values so I don't lose them with function calls
    mov r5, r0; r5 = x position now
    mov r4, r1; r4 = y position now

    ; Handle updating y position of cursor
    ; if y position is < 10, need to print a '0' charcter preceeding it
    ldr r1, ptr_cursor
    add r1, r1, #2; move memory pointer to correct characters to overwrite
    mov r0, #30; r0 = '0'
    cmp r4, #10; check is ypos <10?
    ITT lt
    strblt r0, [r1]; if it is less than 10 store '0' character
    addlt r1, r1, #1; move r1 to point to next byte
    mov r0, r4; moving xposition back to r0 for function call
    bl int2string_noNullTerm; r0 = xposition, r1 = memory address wanting to store at

    ; Handle updating x position of cursor
    ; if x position is < 10, need to print a '0' charcter preceeding it
    ldr r1, ptr_cursor
    add r1, r1, #5; move memory pointer to correct characters to overwrite
    mov r0, #30; r0 = '0'
    cmp r5, #10; check is xpos <10?
    ITT lt
    strblt r0, [r1]; if it is less than 10 store '0' character
    addlt r1, r1, #1; move r1 to point to next byte
    mov r0, r5; moving y position back to r0 for function call
    bl int2string_noNullTerm; r0 = y position, r1 = memory address wanting to store at

    ;Finally print the escape sequence so that the cursor is moved
    ldr r0, ptr_cursor
    bl output_string
    ;done return
    pop {lr, r4, r5}
    mov pc, lr  
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ Game Lives Functions ------------------------

restart_lives: ; We get all 4 lives back (LEDS 3-0 are lit)
    PUSH {lr}

    LDR r0, ptr_lives
    MOV r1, #0x4
    STR r1, [r0]

	MOV r1, #0x5000
    MOVT r1, #0x4000
	LDRB r2, [r1, #GPIODATA_OFFSET]

    MOV r0, #0xF
	BFI r2, r0, #0, #4

	STRB r2, [r1, #GPIODATA_OFFSET]

    ;Added by Enoch, I'm printing the updated lives value back to screen. (for testing without daughter board)
    bl print_lives

	POP {lr}
	MOV pc, lr

lost_life:
    PUSH {lr}

    LDR r0, ptr_lives; ptr_lives is an address. We need to load from the address
    LDR r0, [r0]
    SUB r1, r0, #1
    LDR r0, ptr_lives
    STR r1, [r0]

    MOV r0, #0x5000
    MOVT r0, #0x4000
	LDRB r2, [r0, #GPIODATA_OFFSET]

    CMP r1, #3
    BEQ three_lives_left

    CMP r1, #2
    BEQ two_lives_left

    CMP r1, #1
    BEQ one_life_left

    B no_lives_left

three_lives_left:
    MOV r1, #0x7 ; 0111
    BFI r2, r1, #0, #4; set the 4 bits we want to to the color
    B end_lost_life

two_lives_left:
    MOV r1, #0x3 ; 0011
    BFI r2, r1, #0, #4; set the 4 bits we want to to the color
    B end_lost_life

one_life_left:
    MOV r1, #0x1 ; 0001
    BFI r2, r1, #0, #4; set the 4 bits we want to to the color
    B end_lost_life

no_lives_left:
    MOV r1, #0x0 ; 0000
    BFI r2, r1, #0, #4; set the 4 bits we want to to the color

end_lost_life:
    STRB r2, [r0, #GPIODATA_OFFSET]
    
    ;Added by Enoch, I'm printing the updated lives value back to screen. (for testing without daughter board)
    bl print_lives

    ;restor ball color to original
    mov r0, #37; white foreground color
    bl change_ball_color
    
    POP {lr}
    MOV pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ Switch_Handler -----------------------------------------------------
Switch_Handler:; This function is called when SW1 is pressed to pause and unpause the game
               ; Inputs:
               ;    data at memory addresses pause_game, paused_string, unpaused_string, pausedX, pausedY
               ; Outputs:
               ;    Game is paused or unpaused
    PUSH {lr, r4, r5, r6, r7, r8, r9, r10, r11} ; Remember to preserve registers r4-r11 by pushing then popping 
    LDR r1, GPIO_PORT_F
    LDRB r0, [r1, #0x41C]
    MOV r2, #0x1; Clears Interrupt for Edge Triggered Interrupts
    BFI r0, r2, #4, #1
    STRB r0, [r1, #0x41C]
    ;The interrupt clear register is now set

    ;load paused_game from memory call pause_game if it == 0, unpause_game if it == 1
    ldr r0, ptr_paused_game
    ldr r0, [r0]; r0 = paused_game
    mov r4, r0; storeing here so it'll be preserved across function calls
    cmp r0, #0; if == 0 call pause_game, else call unpause_game
    it eq
    bleq pause_game
    cmp r4, #0
    it ne
    blne unpause_game
    ;done
    POP {lr, r4, r5, r6, r7, r8, r9, r10, r11}
    bx lr

pause_game:; called when we want to pause the game
    push {lr}; unnecessary but gonna leave this for now
    
    ;set paused_game = 1
    ldr r1, ptr_paused_game
    mov r0, #1; want to set data to be a 1
    str r0, [r1]; store 1 at paused_game

    ;disable timer
    bl disable_timer_interrupts

    ;print paused to screen
    ldr r0, ptr_pausedX
    ldr r0, [r0]; r0 = x coord to move cursor
    ldr r1, ptr_pausedY
    ldr r1, [r1]; r1 = y coord to move cursor
    bl move_cursor; move cursor where we want to print
    ldr r0, ptr_paused_string; r0 = paused string
    bl output_string

    ;change RGB color on Tivia board
    mov r0, #BLUE
    bl illuminate_RGB_LED

    ;done return
    pop {lr}; unnecessary but gonna leave this for now
    mov pc, lr

unpause_game:; called when we want to unpause the game
    push {lr}; unnecessary but gonna leave this for now
    ;set paused_game = 0
    ldr r1, ptr_paused_game
    mov r0, #0; want to set data to be a 0
    str r0, [r1]; store 0 at paused_game
    
    ;enable timer
    bl enable_timer_interrupts
    
    ;print unpaused to screen (overwriet paused characaters with spaces)
    ldr r0, ptr_pausedX
    ldr r0, [r0]; r0 = x coord to move cursor
    ldr r1, ptr_pausedY
    ldr r1, [r1]; r1 = y coord to move cursor
    bl move_cursor; move cursor where we want to print
    ldr r0, ptr_unpaused_string; r0 = unpaused string (a bunch of default color spaces)
    bl output_string

    ;change RGB color on Tivia board
    ldr r0, ptr_RGB_led_color
    ldr r0, [r0]; r0 = RGB color
    bl illuminate_RGB_LED

    ;done return
    pop {lr}; unnecessary but gonna leave this for now
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ Timer_Handler ------------------------------------------------------
Timer_Handler:
    PUSH {lr, r4-r11}
    ; Interrupt Servicing in the Handler - Clearing Interrupt
    LDR r1, TIMER0
    LDRB r0, [r1, #0x024]
    MOV r2, #0x1
    BFI r0, r2, #0, #1
    STRB r0, [r1, #0x024]

    ;call function that updated the game a frame
    bl update_game
    
    ;done return
    POP {lr, r4-r11}
    bx lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ UART0_Handler ------------------------------------------------------
UART0_Handler:; called when a key is pressed on the keyboard
    PUSH {lr, r4, r5, r6, r7, r8, r9, r10, r11} 
	;Set the bit 4 (RXIC) in the UART Interrupt Clear Register (UARTICR)
	LDR r1, UART0
	LDRB r0, [r1, #0x044]
	MOV r2, #0x1
	BFI r0, r2, #4, #1
	STRB r0, [r1, #0x044]
    ;The interrupt clear register is now set

    ; read character pressed
	bl simple_read_character; r0 should be 'a' = 0x61, 'd' = 0x64, all other characters are ignored
    mov r4, r0; moving the character to a preserved register now, just because i have to do this eventually and it's safest to do this early

    ;verify if it is valid character that was pressed
    bl verify_character; function only returns from this if it was a valid character

    ;clear current paddle from screen
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here so old paddle can be overwritten
    ldr r0, ptr_clear_paddle
    bl output_string; clear old paddle

    ;update padX
    mov r0, r4; put character pressed back in r0
    bl update_padX

    ;print new paddle to screen
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here to print new paddle
    ldr r0, ptr_paddle
    bl output_string; print new paddle
    b done_UART0_Handler

done_UART0_Handler:; made this here so I can can branch here from verify_character
    ;return from interrupt
    POP {lr, r4, r5, r6, r7, r8, r9, r10, r11}
	BX lr

verify_character:; verifies character in r0 is a 'a' or 'd', if it isn't it branches to to done_UART0_Handler
                 ; Inputs: 
                 ;      r0 character pressed
                 ; Outputs:
                 ;      None, just jumps to the end of the handler if an invalid character was pressed
                 ;      -If the character is 'a' or 'd', it returns to the callee of this function
    cmp r0, #0x61; is r0 == 'a'
    beq verified
    cmp r0, #0x64; is r0 == 'd'
    beq verified
    b done_UART0_Handler; not a valid character, branch to where we exit this handler
verified:
    mov pc, lr; never did any push or pops because this is a leaf function

update_padX:; updates padX in memory
            ; Input:
            ;       r0 = 'a' or 'd' (must be one of these 2 characters)
            ; Output: 
            ;       padX in memory updated
    push {lr}
    cmp r0, #0x61; is r0 == 'a'
    beq a_pressed
    bl d_pressed; can assume this because only valid characters 'a' or 'd' passed into this function

done_update_padX:
    ; Done
    pop {lr}
    mov pc, lr

a_pressed:; updates padX if it won't take the paddle off the board
          ; Inputs:
          ;     None
          ; Outputs:
          ;     padX updated in memory
    ;get value of padX
    ldr r1, ptr_padX
    ldr r0, [r1]; r0 = padX
    cmp r0, #MIN_X
    it gt
    subgt r0, r0, #1; if padX > MIN_X, subtract 1 from it
    ;store updated padX in memory
    str r0, [r1]; padX updated
    ;done
    b done_update_padX

d_pressed:; updates padX if it won't take the paddle off the board
          ; Inputs:
          ;     None
          ; Outputs:
          ;     padX updated in memory
    ;get value of padX
    ldr r1, ptr_padX
    ldr r0, [r1]; r0 = padX
    mov r2, #MAX_X; R2 = MAX_X value
    sub r2, r2, #4; subtract 4 because 4 paddle characters to the right of padX
    cmp r0, r2
    it lt
    addlt r0, r0, #1; if padX < MAX_X, add 1 to it
    ;store updated padX in memory
    str r0, [r1]; padX updated
    ;done
    b done_update_padX

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------------------------------------------------------------------------------beginning reset_terminal
reset_terminal:; This function resets the termainal to all default values, but also clears terminal
               ; Inputs:
               ;    None
               ; Outputs:
               ;    Terminal is cleared
    push {lr}
    ldr r0, ptr_default_terminal_setting
    bl output_string
    mov r0, #0xC; new form feed character
    bl output_character
    pop {lr}
    mov pc, lr
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ending reset_terminal


; ------------------------ UART0_Handler ------------------------------------------------------
check_paddle_collision:; This function checks if the ball is colliding with the paddle, and updates dirX and dirY accordingly if so
                       ; Inputs:
                       ;        memory values at ballCurX, ballCurY
                       ; Outputs:
                       ;    r0 set to 1 if there was a collision 0 otherwise.  This is so you know to reprint the paddle for edge case ball is inside the paddle
    push {lr}
    bl check_paddle_y_range; r0 is set 1 if it is in y range, 0 otherwise
    cmp r0, #1
    it eq
    bleq check_paddle_x_range; branch and link if r0 == 1.  This sets r0 = 1 if in x range (collision happended) and 0 otherwise
    ;r0 is set to what we want already, we can just return
    pop {lr}
    mov pc, lr

check_paddle_y_range:; checks if the ball is in the y range for a collision.
                     ; Inputs:
                     ;        None
                     ; Outputs:
                     ;    r0 set to 1 if there was a collision, 0 otherwise.  This is so you know to reprint the paddle for edge case ball is inside the paddle
    push {lr}
    ;load in padY and ballCurY
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    ldr r2, ptr_ballCurY
    ldr r2, [r2]; r2 = ballCurY

    mov r0, #0; initalize r0 == 0
    
    ;check if in padY == ballCurY, if so set r0 = 1
    cmp r1, r2; are they equal
    it eq
    moveq r0, #1; set r0 = 1

    ;check if padY -1 == ballCurY, if so set r0 = 1
    sub r1, r1, #1; decrement by 1 for comparison
    cmp r1, r2; are they equal
    it eq
    moveq r0, #1; set r0 = 1

    ;r0 is set return
    pop {lr}
    mov pc, lr

check_paddle_x_range:; only run if ball in y range, checks if ball is in x range for collision.  returns 1 in r0 if there is a collision
                     ; Inputs:
                     ;        None
                     ; Outputs:
                     ;    r0 set to 1 if there was a collision 0 otherwise.  This is so you know to reprint the paddle for edge case ball is inside the paddle
    push {lr}
    ;load in padX and ballCurX
    ldr r1, ptr_padX
    ldr r1, [r1]; r1 = padX
    ldr r2, ptr_ballCurX
    ldr r2, [r2]; r2 = ballCurX

    ;Check for LL collision
    cmp r1, r2
    beq collide_LL; can do beq because subroutine handles returing to done_check_paddle_x_range

    ;Check for LM collision
    add r1, r1, #1; want to compare LM position
    cmp r1, r2
    beq collide_LM; can do beq because subroutine handles returing to done_check_paddle_x_range

    ;Check for MM collision
    add r1, r1, #1; want to compare MM position
    cmp r1, r2
    beq collide_MM; can do beq because subroutine handles returing to done_check_paddle_x_range

    ;Check for RM collision
    add r1, r1, #1; want to compare RM position
    cmp r1, r2
    beq collide_RM; can do beq because subroutine handles returing to done_check_paddle_x_range

    ;Check for RR collision
    add r1, r1, #1; want to compare RR position
    cmp r1, r2
    beq collide_RR; can do beq because subroutine handles returing to done_check_paddle_x_range

    ;If none of the above ran, there was no collision
    mov r0, #0; set r0 = 0 to say there was no collision
    b done_check_paddle_x_range; just doing a branch so a little more robust if I move around stuff later

done_check_paddle_x_range:
    pop {lr}
    mov pc, lr

x_collision_happened:
    mov r0, #1
    b done_check_paddle_x_range

collide_LL:; updates dirX, dirY for LL paddle collision
    ;set dirX
    ldr r1, ptr_dirX; r1 points to dirX
    mov r0, #-1
    str r0, [r1]; store new value of dirX

    ;set dirY
    ldr r1, ptr_dirY; r1 points to dirY
    mov r0, #-1
    str r0, [r1]; store new value of dirY
    b x_collision_happened; this sets r0 and returns for us

collide_LM:; updates dirX, dirY for LM paddle collision
    ;set dirX
    ldr r1, ptr_dirX; r1 points to dirX
    mov r0, #-1
    str r0, [r1]; store new value of dirX

    ;set dirY
    ldr r1, ptr_dirY; r1 points to dirY
    mov r0, #0xFFFE
    movt r0, #0xFFFF; r0 = two's complement version of -2
    str r0, [r1]; store new value of dirY
    b x_collision_happened; this sets r0 and returns for us


collide_MM:; updates dirX, dirY for MM paddle collision
    ;set dirX
    ldr r1, ptr_dirX; r1 points to dirX
    mov r0, #0
    str r0, [r1]; store new value of dirX

    ;set dirY
    ldr r1, ptr_dirY; r1 points to dirY
    mov r0, #-1
    str r0, [r1]; store new value of dirY
    b x_collision_happened; this sets r0 and returns for us

collide_RM:; updates dirX, dirY for RM paddle collision
    ;set dirX
    ldr r1, ptr_dirX; r1 points to dirX
    mov r0, #1
    str r0, [r1]; store new value of dirX

    ;set dirY
    ldr r1, ptr_dirY; r1 points to dirY
    mov r0, #0xFFFE
    movt r0, #0xFFFF; r0 = two's complement version of -2
    str r0, [r1]; store new value of dirY
    b x_collision_happened; this sets r0 and returns for us

collide_RR:; updates dirX, dirY for RR paddle collision
    ;set dirX
    ldr r1, ptr_dirX; r1 points to dirX
    mov r0, #1
    str r0, [r1]; store new value of dirX

    ;set dirY
    ldr r1, ptr_dirY; r1 points to dirY
    mov r0, #-1
    str r0, [r1]; store new value of dirY
    b x_collision_happened; this sets r0 and returns for us
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ update_game ------------------------------------------------------
update_game:
    push {lr, r4}

    ;move the ball and update ballCurX and ballCurY
    bl move_ball

    ;if the top boarder needs to be reprinted, to this now
    ldr r0, ptr_need_top_boarder_reprint
    ldr r0, [r0]; r0 = need_top_boarder_reprint
    cmp r0, #1; if need_top_boarder_reprint == 1, need to reprint
    it eq
    bleq reprint_top_boarder; this sets need_top_boarder_reprint back to 0 for us

    ;check for paddle collision
    bl check_paddle_collision; dirX and dirY are updated.  Also r0 = 1 if there was a collision so we know to reprint paddle
    cmp r0, #1         ; if r0 == 1 here want to reprint paddle
    it eq              ; if r0 == 1 here want to reprint paddle
    bleq reprint_paddle; if r0 == 1 here want to reprint paddle

    ;check for inside the brick collision (doing brick collision in 2 steps will get rid of one potential bug)
    bl check_inside_brick_collisions; r0 = 1 if collision happend, skip next step if so
    mov r4, r1; r4 = 1 if ball inside brick and next to wall, 0 otherwise
    cmp r0, #0; is r0 == 1?
    it eq
    bleq check_outside_brick_collisions; only do this if r0 == 0
    ;check for outside the brick collision


    ;check for wall collisions
    cmp r4, #0; only check for wall collisions if r4 == 0
    it eq
    bleq check_wall_collisions; this sets need_top_boarder_reprint if we need to reprint top boarder.  This gets reprinted on the next frame

    ;check for bottom collision
    bl check_bottom_collision

    ;check for dead

    pop {lr, r4}
    mov pc, lr

reprint_paddle:; This function just reprits the paddle to the screen exactly where it is
    push {lr}
    ;code to reprint paddle below
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here to print new paddle
    ldr r0, ptr_paddle
    bl output_string; print new paddle
    ;done
    pop {lr}
    mov pc, lr

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ move_ball ------------------------------------------------------
move_ball:; This calculates the new position of the ball (based off ballCurX ballCurY dirX and dirY in memory) and moves it there
          ; Inputs: 
          ;     values in memory at ballCurX ballCurY dirX and dirY
          ; Output:
          ;     Ball is moved in putty terminal, also ballCurX and ballCurY are updated in memory
    push {lr, r4, r5}
    ;print ' ' to screen where ball is currently
    ldr r4, ptr_ballCurX
    ldr r0, [r4]; r0 = ballCurX
    ldr r5, ptr_ballCurY
    ldr r1, [r5]; r1 = ballCurY
    bl move_cursor; move cursor where the ball is
    ldr r0, ptr_erase_ball; r0 = string to print to erase ball
    bl output_string; ball should be cleared from screen

    ;calcualte new ballCurX ballCurY
    bl update_ballCurX_ballCurY; this updates everything for us

    ;print ball in new location 
    ldr r0, [r4]; r0 = ballCurX
    ldr r1, [r5]; r1 =- ballCurY
    bl move_cursor; move cursor where we want to print
    ldr r0, ptr_ball; r0 = ball string
    bl output_string; print ball in new location
    
    ;done return
    pop {lr, r4, r5}
    mov pc, lr

update_ballCurX_ballCurY:; this function uses dirX and dirY to update the ballCurX and ballCurY values
                         ; Inputs: 
                         ;      dirX and dirY values in memory
                         ; Outputs:
                         ;      ballCurX and ballCurY are updated in memory
    ;leaf function so no pushing and poping needed
    
    ;update ballCurX
    ldr r2, ptr_ballCurX
    ldr r0, [r2]; r0 = ballCurX
    ldr r1, ptr_dirX
    ldr r1, [r1]; r1 = dirX
    add r0, r0, r1; balCurX = balCurX + dirX
    str r0, [r2]; store new value back in memory

    ;update ballCurY
    ldr r2, ptr_ballCurY
    ldr r0, [r2]; r0 = ballCurY
    ldr r1, ptr_dirY
    ldr r1, [r1]; r1 = dirY
    add r0, r0, r1; balCurY = balCurY + dirY
    str r0, [r2]; store new value back in memory

    ;return, leaf function so no pushing and poping needed
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ check_wall_collisions ------------------------------------------------------
check_wall_collisions:; This functions checks if the ball is colliding with a wall, and updates dirX, dirY if so
                      ; Inputs:
                      ;     data at memory locations ballCurX, ballCurY
                      ; Outputs:
                      ;     data at dirX and dirY are updated if the ball does collide with a wall
    push {lr, r4, r5}

    ;Check for left wall collision, update dirX if so
    ldr r0, ptr_left_wall_position
    ldr r0, [r0]; r0 = left wall position
    ldr r1, ptr_ballCurX
    ldr r4, [r1]; r4 = ballCurX, used r4 so it is preserved for checking right wall collision
    add r0, r0, #1; want to see if ballCurX <= left wall position + 1
    cmp r4, r0; compare ballCurX with left wall position +1
    it le ;if ballCurX <= left wall position + 1 flip dirX
    blle flip_dirX; branch and link if so

    ;Check for right wall collision, update dirX if so
    ldr r0, ptr_right_wall_position
    ldr r0, [r0]; r0 = right wall position
    ;r4 already equals ballCurX
    sub r0, r0, #1; want to see if ballCurX >= right wall position +1
    cmp r4, r0
    it ge;  want to see if ballCurX >= right wall position +1
    blge flip_dirX; flip dirX if so (with branch and link)

    ;Check for top collision, update dirY if so
    ;First check if inside or above top boarder
    ldr r0, ptr_top_boarderY
    ldr r5, [r0]; r5 = top_boarderY, putting in r5 so it is preserved across function calls
    ldr r1, ptr_ballCurY
    ldr r4, [r1]; putting in r4 so ballCurY is saved across function calls
    cmp r4, r5; is ballCurY <= top_boarderY?
    it le
    blle inside_top_boarder
    ;Next check for 1 character below top boarder
    add r5, r5, #1; want to check if equal to character below (increase num as you go down)
    cmp r4, r5; is balCurY == top_boarderY +1?
    it eq
    bleq flip_dirY; flip dirY, don't need to set reprint top boarder value in memory

    ;Done return
    pop {lr, r4, r5}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ reprint_top_boarder ------------------------------------------------
inside_top_boarder:; this function sets the value at need_top_boarder_reprint to 1, so other functions know to reprint the top boarder
                   ; It also flips the dirY for us
    push {lr}
    ;set need_top_boarder_reprint to 1
    ldr r1, ptr_need_top_boarder_reprint
    mov r0, #1; want to store a 0
    str r0, [r1]; now memory value is set to 1
    ;flip dirY
    bl flip_dirY
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ reprint_top_boarder ------------------------------------------------------
reprint_top_boarder:; This function reprints the top boarder. Call when ball intersects with one of it's characters
    push {lr}
    ;reprint
    ldr r0, ptr_top_boarderX
    ldr r0, [r0]; r0 = top_boarderX
    ldr r1, ptr_top_boarderY
    ldr r1, [r1]; r1 = top_boarderY
    bl move_cursor; move cursor to this position
    ldr r0, ptr_top_boarder; r0 = string to print
    bl output_string; re-print top boarder

    ;set need_top_boarder_reprint back to 0
    ldr r1, ptr_need_top_boarder_reprint
    mov r0, #0; want to store a 0
    str r0, [r1]; now memory value is set back to 0

    ;done return
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; ------------------------ flip_dirX ------------------------------------------------------
flip_dirX:; This function flips the value stored at dirX
          ; Inputs: 
          ;     data at dirX
          ; Outputs:
          ;     data at dirX is flipped from positive to negative, or negative to positive
    ;leaf function so no push pop needed
    ldr r1, ptr_dirX
    ldr r0, [r1]; r0 = dirX
    mov r2, #-1; r2 = -1
    mul r0, r0, r2; r0 = dirX*-1
    str r0, [r1]; store value back in memory

    ;leaf function so no push pop needed
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


; ------------------------ flip_dirY ------------------------------------------------------
flip_dirY:; This function flips the value stored at dirY
          ; Inputs: 
          ;     data at dirY
          ; Outputs:
          ;     data at dirY is flipped from positive to negative, or negative to positive
    ;leaf function so no push pop needed
    ldr r1, ptr_dirY
    ldr r0, [r1]; r0 = dirY
    mov r2, #-1; r2 = -1
    mul r0, r0, r2; r0 = dirY*-1
    str r0, [r1]; store value back in memory

    ;leaf function so no push pop needed
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ check_bottom_collision ---------------------------------------------
check_bottom_collision:; This function checks if the ball collides with the bottom of the board.  If so it decreases the life count by 1.
                       ; Inputs:
                       ;    Data at bottom_boarderY, ballCurY
                       ; Outputs:
                       ;    lives decreased by 1 if ball collides with bottom
    push {lr}

    ;check if ballCurY >= bottom boarder
    ldr r0, ptr_ballCurY
    ldr r0, [r0]; r0 = ballCurY
    ldr r1, ptr_bottom_boarderY
    ldr r1, [r1]; r1 = bottom_boarderY

    cmp r0, r1; want to see if ballCurY >= bottom boarder
    it ge
    blge bottom_collision_happened; if ballCurY <= bottom boarder there was a collision with bottom

    ;done
    pop {lr}
    mov pc, lr
bottom_collision_happened:; This function only gets called when a bottom collision did occur.  Updates lives, restarts ballCurX, ballCurY, dirX, dirY, and also pauses the game
                          ; I also added reprinting the bottom boarder because it's convenient to do this here.
                          ; I also added resetting the paddle to it's orriginal location.  Lab says to do this
                          ; Input:
                          ;     None
                          ; Output:
                          ;     -lives, ballCurX, ballCurY, dirX, dirY, padX, padY all restored to default
                          ;     -game is also paused
    push {lr}
    ;reprint bottom boarder
    ldr r0, ptr_bottom_boarderX
    ldr r0, [r0]; r0 = bottom_boarderX
    ldr r1, ptr_bottom_boarderY
    ldr r1, [r1]; r1 = bottom_boarderY
    bl move_cursor; move cursor here
    ldr r0, ptr_top_boarder; the top boarder is the same characters as bottom boarder
    bl output_string

    ;decrement lives and update things displaying life count
    bl lost_life

    ;update ballCurX, ballCurY, dirX, dirY
    ldr r1, ptr_ballCurX
    mov r0, #12; want to restore value back to default
    str r0, [r1]; update ballCurX
    ldr r1, ptr_ballCurY
    mov r0, #10; want to restore value back to default
    str r0, [r1]; update ballCurY
    ldr r1, ptr_dirX
    mov r0, #0; default value
    str r0, [r1]; update dirX
    ldr r1, ptr_dirY
    mov r0, #1; default value
    str r0, [r1]; update dirY

    ;clear current paddle from screen
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here so old paddle can be overwritten
    ldr r0, ptr_clear_paddle
    bl output_string; clear old paddle

    ;update padX, padY
    ldr r1, ptr_padX
    mov r0, #10; default value
    str r0, [r1]; update padX
    ldr r1, ptr_padY
    mov r0, #17; default value, this actually never changed but better safe than sorry
    str r0, [r1]; update padY

    ;print new paddle to screen
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here to print new paddle
    ldr r0, ptr_paddle
    bl output_string; print new paddle

    ;pause game
    bl pause_game; this function nicely does everything needed to pause and be ready for unpause
    
    ;done
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ---------------------------------------------------------------------------------------------
clear_paddle_from_screen:; this function clears the paddle from the screen, doesn't update padX or padY
             ; Inputs:
             ;     data at padX and padY
             ; Outputs Paddle cleared from screen
    push {lr}
    ldr r0, ptr_padX
    ldr r0, [r0]; r0 = padX
    ldr r1, ptr_padY
    ldr r1, [r1]; r1 = padY
    bl move_cursor; move cursor here so old paddle can be overwritten
    ldr r0, ptr_clear_paddle
    bl output_string; clear old paddle
    pop {lr}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ----------------------------------------------------------------------------------------
;FINISH THIS
;ADD FUNCTIONALITY FOR R1 IN FUNCTION BELOW
;

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; ---------------------------------------------------------------------------------------------
check_inside_brick_collisions:; checks if ballCurX and ballCurY are inside a brick, updates dirX, dirY, clears brick, and
                             ; removes the brick from bricks if so.
                             ; Inputs:
                             ;      data at ballCurX, ballCurY, bricks
                             ; Outputs:
                             ;      if collision happens, dirX, dirY, brick cleared from terminal, and brick removed from bricks
                             ;      r0 = 1 if a collision happens, 0 otherwise
                             ;      r1 = 1 if a collision happens, and ball is right next to wall
    push {lr, r4, r5}
    ldr r4, ptr_bricks; r4 = pointer to brick in memory
    ldr r5, [r4]; r5 = current brick looking at
loop_check_inside_brick_collisions:
    cmp r5, #0; is r5 end of list?
    beq no_collisions; leave loop if so
    ;this runs if r5 is a brick
    mov r0, r4; r0 = pointer to brick
    bl check_single_inside_brick_collision; r0 = 1 if collision happened 0 otherwise
    cmp r0, #1;
    beq yes_collisions; can leave loop after 1 collision is processed
    ldr r5, [r4, #4] !; update r5 and r4
    b loop_check_inside_brick_collisions
no_collisions:
    mov r0, #0; set r0 = 0
    b done_check_inside_brick_collisions
yes_collisions:
    ;r0 already == 1 if this called
    ;r1 = 1 if next to wall, 0 otherwise
    b done_check_inside_brick_collisions
done_check_inside_brick_collisions:
    ;r0 already set, return
    pop {lr, r4, r5}
    mov pc, lr

check_single_inside_brick_collision:; checks if the ball is inside brick pointed to by r0 pointer. Updates dirX, dirY, clears brick, and
                             ; removes the brick from bricks if so.
                             ; Also changes ball color to the color of the brick it hit
                             ; Inputs: 
                             ;      r0 = pointer to brick in memory
                             ; Outputs:
                             ;      if collision happens, dirX, dirY, brick cleared from terminal, and brick removed from bricks
                             ;      r0 = 1 if a collision happened
                             ;      r1 = 1 if a collision happens, and ball is right next to wall
    push {lr, r4, r5, r6, r7}
    mov r4, r0; preserve pointer to brick in r4
    ldr r5, [r4]; brick data in r5

    ;if y values don't match we know collision didin't happen
    ldr r0, ptr_ballCurY
    ldr r0, [r0]; r0 = ballCurY
    ubfx r1, r5, #16, #8; r1 = brick y position
    cmp r0, r1
    bne done_check_single_inside_brick_collision; exit if y values don't match

    ;This only runs if y values match.  brick = 3 characters [LB, MB, RB]
    ;set r6 = 1 if collision hpapens
    mov r6, #0; initalize to 0
    mov r7, #0; initalize to 0

    ;check if ball is also colliding with the wall
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0 = ballCurX
    ldr r1, ptr_left_wall_position
    ldr r1, [r1]; r1 = left wall position
    add r1, r1, #1; r1 = postion inside board right next to wall
    cmp r0, r1; is ball colliding with wall?
    it eq
    moveq r7, #1; put a 1 in r7 if so
    ldr r1, ptr_right_wall_position
    ldr r1, [r1]; r1 = right wall position
    sub r1, r1, #1; r1 = inside the board right next to wall
    cmp r0, r1; is ball collicing with wall?
    it eq
    moveq r7, #1; store 1 in r7 if so

    
    ;check hitting LB spot
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0  = ballCurX
    ubfx r1, r5, #8, #8; r1 = x position of brick left most character LB
    cmp r0, r1; is ball in LB spot:
    itt eq
    moveq r6, #1; set to 1 if collision happened
    bleq flip_dirX
    
    ;check hitting MB spot
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0  = ballCurX
    ubfx r1, r5, #8, #8; r1 = x position of brick left most character LB
    add r1, r1, #1; r1 = MB spot now
    cmp r0, r1; is ball in MB spot:
    itt eq
    moveq r6, #1; set to 1 if collision happened
    bleq flip_dirY
    
    ;check hitting RB spot
    ldr r0, ptr_ballCurX
    ldr r0, [r0]; r0  = ballCurX
    ubfx r1, r5, #8, #8; r1 = x position of brick left most character RB
    add r1, r1, #2; r1 = RB spot now
    cmp r0, r1; is ball in RB spot:
    itt eq
    moveq r6, #1; set to 1 if collision happened
    bleq flip_dirX
done_check_single_inside_brick_collision:
    ;make r0 pointer to brick and call inside_brick_collision_happended if collision happened
    mov r0, r4; r0 = pointer to brick
    cmp r6, #1; did a collision happen?
    it eq
    bleq inside_brick_collision_happened
    ;set r1 = 1 if collision happended and ball right next to wall
    mov r1, #0; initalize to 0
    cmp r6, #1; did a collision happen?
    it eq
    moveq r1, r7; store what's in r7 in r1 if so (r7 = 1 if next to wall 0 otherwise)
    mov r0 , r6; r0 = 0 if no collision, 1 if collision happened
    pop {lr, r4, r5, r6, r7}
    mov pc, lr

inside_brick_collision_happened:; called when inside brick collision happens
                                ; Inputs:
                                ;       r0 = ptr to brick
                                ; Outpus:
                                ;      ball color updated, brick removed from screen, brick removed from bricks
                                ;      Tivia RGB LED switches color, score incremented
    push {lr, r4}
    mov r4, r0; store pointer in r4 so it's preserved across function calls
    
    ;change ball color to color of brick
    ldr r1, [r4]; r1 == brick
    ubfx r0, r1, #0, #8; r0 = color of brick
    sub r0, r0, #10; convert to foreground color
    bl change_ball_color; this changes the ball color

    ;change Tivia RGB LED color
    mov r3, #WHITE; will make led White by default
    ldr r1, [r4]; r1 == brick
    ubfx r0, r1, #0, #8; r0 = color of brick.  41 = RED, 42 = Green, 43 = YELLOW, 44 = Blue, 45 = Purple
    cmp r0, #41; is color red?
    it eq
    moveq r3, #RED
    cmp r0, #42; is color green?
    it eq
    moveq r3, #GREEN
    cmp r0, #43; is color yellow?
    it eq
    moveq r3, #YELLOW
    cmp r0, #44; is color blue?
    it eq
    moveq r3, #BLUE
    cmp r0, #45; is color purple?
    it eq
    moveq r3, #PURPLE
    mov r0, r3; make r0 color
    ldr r3, ptr_RGB_led_color
    str r0, [r3]; store color in memory before I forget
    bl illuminate_RGB_LED; change RGB color

    ;increment score
    ldr r2, ptr_score
    ldr r0, [r2]; r0 = score
    ldr r1, ptr_level_number
    ldr r1, [r1]; r1 = level number
    add r0, r0, r1; calculate new score
    str r0, [r2]; store new score back where it belongs
    bl print_score

    ;erase brick from display
    ldr r0, [r4]; r0 = brick to erase
    bl erase_one_brick

    ;remove brick from bricks
    mov r0, r4; put pointer to brick back in r0
    bl remove_brick; remove br

    pop {lr, r4}
    mov pc, lr

remove_brick:; removes the brick pointed to by r0 from the bricks array.
             ; Inputs:
             ;      r0 = pointer to a brick
             ; Outputs:
             ;      brick pointed to is removed from bricks array in memory
    push {lr}
    ;r0 = cur Pointer
    ;r1 = next Pointer
    ;r2 = cur brick
    ;r3 = next brick
    add r1, r0, #4; r1 points to next brick in memory
    ldr r2, [r0]; r2 = cur brick
    ldr r3, [r1]; r3 = next brick
    ;while cur brick not 0, loop
loop_remove_brick:
    cmp r2, #0; is current brick 0?
    beq done_remove_brick; leave loop if so
    ;This runs if we are still shifting bricks over
    str r3, [r0], #4; shift brick over and increment r0
    ldr r2, [r1], #4; r2 = next brick and increment r1
    ldr r3, [r1]; r3 = next brick
    b loop_remove_brick
done_remove_brick:
    pop {lr}
    mov pc, lr

erase_one_brick:; This function erases 1 brick that's stored in r0 from the terminal
                ; Inputs:
                ;   r0 = brick to erase (this is not a pointer to the brick it is the brick data)
                ; Outputs:
                ;   brick erased from terminal
    push {lr, r4}
    mov r4, r0; move brick in r4 so it's preserved
    ;extract x and y coord, move cursor there
    ubfx r0, r4, #8, #8; pull out x coord and place in r0
    ubfx r1, r4, #16, #8; pull out y coord and place in r1
    bl move_cursor; move cursor where we want to print brick

    ;print erase_brick_string
    ldr r0, ptr_erase_brick_string
    bl output_string
    ;done
    pop {lr, r4}
    mov pc, lr 
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ---------------------------------------------------------------------------------------------
check_outside_brick_collisions:; ckecks if the ball is colliding above or below a brick in bricks.   Updates dirX, dirY, clears brick, and
                               ; removes the brick from bricks if so.
                               ; Also changes ball color to the color of the brick it hit
                               ; Inputs: 
                               ;      data at bricks and ballCuX and ballCurY
                               ; Outputs:
                               ;      if collision happens, dirX, dirY, brick cleared from terminal, and brick removed from bricks
    push {lr, r4, r5}
    ldr r4, ptr_bricks; r4 = pointer to brick in memory
    ldr r5, [r4]; r5 = current brick looking at
loop_check_outside_brick_collisions:
    cmp r5, #0; is r5 end of list?
    beq done_check_outside_brick_collisions; leave loop if so
    ;this runs if r5 is a brick
    mov r0, r4; r0 = pointer to brick
    bl check_single_brick_above_below_collisoin; r0 = 1 if collision happened 0 otherwise
    cmp r0, #1;
    beq done_check_outside_brick_collisions; can leave loop after 1 collision is processed
    ldr r5, [r4, #4] !; update r5 and r4
    b loop_check_outside_brick_collisions
done_check_outside_brick_collisions:
    pop {lr, r4, r5}
    mov pc, lr

check_single_brick_above_below_collisoin:; checks if the ball colliding above or below a brick pointed to by r0 pointer. Updates dirX, dirY, clears brick, and
                                         ; removes the brick from bricks if so.
                                         ; Also changes ball color to the color of the brick it hit
                                         ; Inputs: 
                                         ;      r0 = pointer to brick in memory
                                         ; Outputs:
                                         ;      if collision happens, dirX, dirY, brick cleared from terminal, and brick removed from bricks
                                         ;      r0 = 1 if a collision happened, 0 otherwise
    push {lr, r4, r5, r6}
    mov r4, r0; save pointer in r4
    ldr r5, [r4]; r5 = brick
    mov r6, #0; initailze to 0, will set to 1 if a collision happens

    ; if ballCurY == brickY - 1 check x direction
    ldr r0, ptr_ballCurY
    ldr r0, [r0]; r0 = ballCurY
    ubfx r1, r5, #16, #8; r1 = brick y position
    sub r1, r1, #1; checking if ball is above the brick first
    cmp r0, r1; if r0 < r1 no collision return
    beq check_x_direction;
    ; now check if ball is below the brick
    add r1, r1, #2; r1 = characters below brick
    cmp r0, r1; if ballCurY == brickY -1 check x directon
    beq check_x_direction;
    b done_check_single_brick_above_below_collisoin; if the ball is not above or below the brick return

check_x_direction:; gets callid if the ball is above the brick.
                 ; r4 = pointer to brick
                 ; r5 = brick data
    ;check if ballCurX is within range of brick x
    ldr r0, ptr_ballCurX
    ldr r0 , [r0]; r0 = ballCurX
    ubfx r1, r5, #8, #8; r1 = brick x position
    cmp r0, r1;
    blt done_check_single_brick_above_below_collisoin; if ballCurX < brick x, no collision happens
    add r1, r1, #2; r1 = right most character of brick
    cmp r0, r1
    bgt done_check_single_brick_above_below_collisoin; if balCurX > brick right character no collision happens
    ;if this runs ball is colliding
    bl flip_dirY; flip y vector
    mov r0, r4; put pointer to brick back into r0
    bl inside_brick_collision_happened; reuse this function, even though the name says inside
    mov r6, #1; set to 1 because collision happened
    b done_check_single_brick_above_below_collisoin

done_check_single_brick_above_below_collisoin:
    mov r0, r6; r0 = return value now
    pop {lr, r4, r5, r6}
    mov pc, lr
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ------------------------ End of File --------------------------------------------------------
    .end
