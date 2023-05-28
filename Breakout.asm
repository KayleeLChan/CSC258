################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Kaylee Chan, 1008109011
# Student 2: Lonely :( sadge, 18002672001 alarm force
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

WHITE:
	.word 0xffffff

GREY:
	.word 0xcccccc
	
BLACK:
	.word 0x000000
	
PINK:
	.word 0x015bc0068
	
LIGHT_PURPLE:
	.word 0xb4a7d6
	
LEFT_EDGE:
	.word 0x10009d84
	
RIGHT_EDGE:
	.word 0x10009dd8
	
TOP_LEFT_CORNER:
	.word 0x10008000
	
TOP_RIGHT_CORNER:
	.word 0x1000807c
	
BOT_LEFT_CORNER:
	.word 0x10009f80
		
BOT_RIGHT_CORNER:
	.word 0x10009ffc
	
INIT_BALL:
	.word 0x10009c40
	
INIT_PAD:
	.word 0x10009db0
	
PAUSE_POS:
	.word 0x10008d30
	
MID_C:
	.byte 60

E_4:
	.byte 64
	
GB_4:
	.byte 66
	
EB_4:
	.byte 63
	
LENGTH:
	.byte 500
	
VOLUME:
	.byte 127
	
VOICE_OOH:
	.byte 54
	
LAUNCH_HIT:
	.byte 97
	
SYNTH_HIT:
	.byte 96

BRICK_BEGIN:
	.word 0x1000820c

BRICK_POSITIONS:
	.space 140
##############################################################################
# Mutable Data
##############################################################################
# Number of lives left
LIVES:
	.word	3:4			# Initialize space for one integer (4 bytes) initialized to 3

# Current position of the ball
BALL_POS:
	.word 0x10009c40	# Initialize 8 units up, 15 right

# Current position of the paddle	
PAD_POS:
	.word 0x10009db0	# Beginning of paddle (left-most pixel)
	
BRICK_COLOURS:
	.space 140
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
	lw $t9, TOP_LEFT_CORNER		# set $t9 in the top left corner
	lw $t8, BOT_RIGHT_CORNER	# set $t8 to be after the last pixel onscreen
	lw $t4, BLACK				# set colour as black for erasing
	addi $t8, $t8, 4
	jal wipe_clean
	
	lw $t2, INIT_BALL
	lw $t3, INIT_PAD
	sw $t2, BALL_POS
	sw $t3, PAD_POS
	
start_bricks:
	addi $t9, $zero, 0			# int j = 0
	addi $t8, $zero, 7			# j < 7
	addi $t1, $zero, -1			# index i
	la $t7, BRICK_POSITIONS
	la $t6, BRICK_COLOURS
	lw $t0, BRICK_BEGIN
	lw $t4, PINK
	
	set_bricks:
		beq $t9, $t8, render
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# 4i = offset
		add $t3, $t6, $t2		# addr(BRICK_COLOURS[i])
		addi $t4, $t4, 4		# change colour
		sw $t4, 0($t3)			# BRICK_COLOURS[i] = colour
		add $t3, $t7, $t2		# addr(BRICK_POSITIONS[i])
		sw $t0, 0($t3)			# BRICK_POSITIONS[i] = position
		addi $t0, $t0, 24		# shift to next brick
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# 4i = offset
		add $t3, $t6, $t2		# addr(BRICK_COLOURS[i])
		addi $t4, $t4, 4		# change colour
		sw $t4, 0($t3)			# BRICK_COLOURS[i] = colour
		add $t3, $t7, $t2		# addr(BRICK_POSITIONS[i])
		sw $t0, 0($t3)			# BRICK_POSITIONS[i] = position
		addi $t0, $t0, 20		# shift to next brick
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# 4i = offset
		add $t3, $t6, $t2		# addr(BRICK_COLOURS[i])
		addi $t4, $t4, 4		# change colour
		sw $t4, 0($t3)			# BRICK_COLOURS[i] = colour
		add $t3, $t7, $t2		# addr(BRICK_POSITIONS[i])
		sw $t0, 0($t3)			# BRICK_POSITIONS[i] = position
		addi $t0, $t0, 24		# shift to next brick
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# 4i = offset
		add $t3, $t6, $t2		# addr(BRICK_COLOURS[i])
		addi $t4, $t4, 4		# change colour
		sw $t4, 0($t3)			# BRICK_COLOURS[i] = colour
		add $t3, $t7, $t2		# addr(BRICK_POSITIONS[i])
		sw $t0, 0($t3)			# BRICK_POSITIONS[i] = position
		addi $t0, $t0, 20		# shift to next brick
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# 4i = offset
		add $t3, $t6, $t2		# addr(BRICK_COLOURS[i])
		addi $t4, $t4, 4		# change colour
		sw $t4, 0($t3)			# BRICK_COLOURS[i] = colour
		add $t3, $t7, $t2		# addr(BRICK_POSITIONS[i])
		sw $t0, 0($t3)			# BRICK_POSITIONS[i] = position
		
		addi $t0, $t0, 424		# shift to next brick layer
		addi $t9, $t9, 1		# increment loop counter
		j set_bricks
		
draw_brick_four:
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 4		# increment to next column
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 4		# increment to next column
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 4		# increment to next column
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 12		# increment to next brick
	j jump_back

draw_brick_three:
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 4		# increment to next column
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 4		# increment to next column
	sw $t4, 0($t0)			# paint in top half of column
	sw $t4, 128($t0)		# paint in bottom half of column
	addi $t0, $t0, 12		# increment to next brick
	j jump_back
	
render:
# Initialize the game
	lw $t2, INIT_BALL		# $t2 = ball position
	lw $t3, INIT_PAD		# $t3 = paddle position
	lw $t9, TOP_LEFT_CORNER		# set $t9 in the top left corner
	lw $t8, BOT_RIGHT_CORNER	# set $t8 to be after the last pixel onscreen
	lw $t4, BLACK				# set colour as black for erasing
	addi $t5, $zero, 0		# automatically set ball direction to not move
	addi $t8, $t8, 4
    		
render_rest:
    lw $t1, ADDR_KBRD		# $t1 = base address for keyboard	
	lw $t2, BALL_POS		# $t2 = ball position
	lw $t3, PAD_POS			# $t3 = paddle position
	
paddle:
	addi $t9, $t3, 36		# indicate paddle is 9 squares long
	lw $t4, LIGHT_PURPLE	# change current colour to light purple
	lw $t0, PAD_POS			# move bitmap position to paddle position
	
build_paddle:
	beq $t3, $t9, we_ball	# break after loop
	sw $t4, 0($t3)			# colour in position
	addi $t3, $t3, 4		# increment paddle position one forward
	j build_paddle			# continue loop
	
we_ball:
	addi $t3, $t9, -36		# reset paddle position to beginning of paddle
	lw $t4, WHITE			# change current colour to white
	sw $t4, 0($t2)			# colour in position
	
	lw $t0, ADDR_DSPL		# $t0 = base address for display
	lw $t4, GREY			# colour borders in grey
	addi $t8, $t8, 4	
	lw $t9, TOP_RIGHT_CORNER	# set $t9 to end of divider
	addi $t9, $t9, 132

loop_divider:
	beq $t9, $t0, post_divider	# break out of loop if bitmap position is at the end of divider
	sw $t4, 0($t0)			# colour in current position
	addi $t0, $t0, 4		# move bitmap position forward by one square
	j loop_divider
    
post_divider:
	lw $t9, BOT_LEFT_CORNER	# set $t9 as the first square of first row outside the display
	addi $t9, $t9, 128
	addi $t8, $t9, 124		# set $t8 as the last square of first row outside the display
	
loop_walls:
	beq $t9, $t0, right_wall	# break out of loop if bitmap position is at the end of left wall
	beq $t8, $t0, start_draw_bricks	# break out of loop if bitmap position is at the end of right wall
	sw $t4, 0($t0)			# colour in current position
	addi $t0, $t0, 128		# move bitmap position down by one square
	j loop_walls
	
right_wall:
	lw $t0, TOP_RIGHT_CORNER	# set bitmap position as last square of first raw following divider
	addi $t0, $t0, 128
	j loop_walls			# build right wall
		
start_draw_bricks:
	la $t9, BRICK_POSITIONS
	la $t8, BRICK_COLOURS
	add $t7, $zero, $zero		# j = 0
	addi $t6, $zero, 7			# j < 0
	addi $t1, $zero, -1			# array index
	
	draw_bricks:
		beq $t7, $t6, game_loop
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr (BRICK_COLOURS[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOURS[i])
		jal draw_brick_four
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr (BRICK_COLOURS[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOURS[i])
		jal draw_brick_three
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr (BRICK_COLOURS[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOURS[i])
		jal draw_brick_four
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr (BRICK_COLOURS[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOURS[i])
		jal draw_brick_three
		
		addi $t1, $t1, 1		# update index
		sll $t2, $t1, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr (BRICK_COLOURS[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOURS[i])
		jal draw_brick_four
		
		addi $t7, $t7, 1		# increment counter
		j draw_bricks
		
game_loop:
	lw $t1, ADDR_KBRD	
	lw $t2, BALL_POS
	lw $t3, PAD_POS
	# 1a. Check if key has been pressed
    lw $t7, 0($t1)                  # Load first word from keyboard
    beq $t7, 1, keyboard_input      # If first word 1, key is pressed
	
    # skip keyboard check
    b check_collision
    
    # 1b. Check which key has been pressed
keyboard_input:                     # A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
    beq $a0, 0x61, move_left     	# Check if the key a was pressed
	beq $a0, 0x64, move_right		# Check if the key d was pressed
	beq $a0, 0x71, game_over				# Check if the key q was pressed
	beq $a0, 0x1b, game_over				# Check if esc was pressed
	beq $a0, 0x70, pause			# Check if the key p was pressed
	beq $a0, 0x20, launch			# Check if the spacebar was pressed

	# 2a. Check for collisions
check_collision:
	# check if ball reaches ground
	lw $t8, BOT_RIGHT_CORNER		# save the out of bounds location to compare ball position to
	sltu $t9, $t8, $t2				# check if ground position is less than ball position and save bool in $t9
	beq $t9, 1, lose				# if boolean is true, lose round
		
	# check if paddle and wall are sandwiched
sandwich:
	lw $t9, BOT_LEFT_CORNER			# set $t9 to be left wall adjacent to paddle row
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, 4
	addi $t8, $t3, -128				# make $t8 be the corner the ball must be in
	bne $t8, $t2, check_right_corner
	beq $t9, $t3, harsh_right		# if paddle is touching left wall, go a harsh right
	
	check_right_corner:
	lw $t9, BOT_RIGHT_CORNER			# set $t9 to be right wall adjacent to paddle row
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, -128
	addi $t9, $t9, -4
	addi $t8, $t3, 32				# set $t8 to be the right end of paddle
	addi $t7, $t8, -128				# make $t7 be the corner the ball must be in
	bne $t7, $t2, check_paddle
	beq $t9, $t8, harsh_left		# if paddle is touching left wall, go a harsh left
	
	# check if ball hits paddle
	check_paddle:
	addi $t8, $t3, -128				# set $t8 to left corner of paddle edge
	beq $t2, $t8, edge_collide		# check if ball hits at paddle edge
	addi $t8, $t8, 32				# set $t8 to above right-most edge of paddle
	beq $t2, $t8, edge_collide		# check if ball hits at paddle edge

	addi $t8, $t8, -4				# set $t8 to right-most right side
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, -4				# set $t8 to middle right side
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, -4				# set $t8 to left-most right side$t8)
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, -16				# set $t8 to left-most left side
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, 4				# set $t8 to middle left side
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, 4				# set $t8 to right-most left side
	beq $t2, $t8, mid_collide		# check if ball hits at paddle mid-ish point
	addi $t8, $t8, 4				# set $t8 to middle
	beq $t2, $t8, direct_collide	# check if ball hits at paddle middle
	
	# check if ball hits borders
	lw $t9, TOP_LEFT_CORNER			# set t9 to be the left of the ceiling
	addi $t9, $t9, 260
	lw $t8, TOP_RIGHT_CORNER		# set t8 to be the right of the ceiling
	addi $t8, $t8, 256
	
	check_ceiling:
		beq $t9, $t8, start_left_wall	# iterated through whole ceiling, check left wall
		beq $t9, $t2, bounce_ceiling	# ball hits ceiling, bounce it
		addi $t9, $t9, 4			# increment one pixel right
		j check_ceiling				# loop back up
		
	start_left_wall:
		lw $t9, TOP_LEFT_CORNER			# set t9 to be the top of the wall
		addi $t9, $t9, 260
		lw $t8, BOT_LEFT_CORNER		# set t8 to be the bottom of the wall
		addi $t8, $t8, 260
	
	check_left_wall:
		beq $t9, $t8, start_right_wall	# iterated through whole left wall, check right wall
		beq $t9, $t2, bounce_wall	# ball hits wall, bounce it
		addi $t9, $t9, 128			# increment one pixel down
		j check_left_wall			# loop back up
		
	start_right_wall:
		lw $t9, TOP_RIGHT_CORNER		# set t9 to be the top of the wall
		addi $t9, $t9, 252
		lw $t8, BOT_RIGHT_CORNER		# set t8 to be the bottom of the wall
		addi $t8, $t8, 252
		
	check_right_wall:
		beq $t9, $t8, check_harsh_wall	# iterated through whole right wall, check walls again for harsh angle
		beq $t9, $t2, bounce_wall	# ball hits wall, bounce it
		addi $t9, $t9, 128			# increment one pixel down
		j check_right_wall			# loop back up
		
	check_harsh_wall:
		beq $t5, -68, start_harsh_left_wall		# incoming harsh left up, check next empty column
		beq $t5, -60, start_harsh_right_wall	# incoming harsh right up, check next empty column
		b check_bricks	# else, check bricks
		
		start_harsh_left_wall:
			lw $t9, TOP_LEFT_CORNER			# set t9 to be the top of the wall
			addi $t9, $t9, 264
			lw $t8, BOT_LEFT_CORNER		# set t8 to be the bottom of the wall
			addi $t8, $t8, 264
			j check_left_wall_harsh
	
		check_left_wall_harsh:
			beq $t9, $t8, draw_screen	# iterated through whole left wall, draw screen
			beq $t9, $t2, soften_angle	# ball surpasses wall, soften it
			addi $t9, $t9, 128			# increment one pixel down
			j check_left_wall_harsh			# loop back up
			
		start_harsh_right_wall:
			lw $t9, TOP_RIGHT_CORNER		# set t9 to be the top of the wall
			addi $t9, $t9, 248
			lw $t8, BOT_RIGHT_CORNER		# set t8 to be the bottom of the wall
			addi $t8, $t8, 248
	
		check_right_wall_harsh:
			beq $t9, $t8, draw_screen	# iterated through whole right wall, draw screen
			beq $t9, $t2, soften_angle	# ball surpasses wall, soften it
			addi $t9, $t9, 128			# increment one pixel down
			j check_left_wall_harsh			# loop back up
		
		soften_angle:
			beq $t5, -68, soften_left
			# right angle, minus two to soften
			addi $t5, $t5, -2
			b draw_screen
			
			soften_left:				# left angle, add two to soften
				addi $t5, $t5, 2
				b draw_screen
				
	bounce_wall:
		beq $t5, 60, bounce_soft_incoming_left		# incoming harsh left down
		beq $t5, 68, bounce_soft_incoming_right	# incoming harsh right down
		beq $t5, -68, bounce_soft_incoming_left	# incoming harsh left up
		beq $t5, -60, bounce_soft_incoming_right	# incoming harsh right up
		
		beq $t5, 62, bounce_soft_incoming_left		# incoming soft left down
		beq $t5, 66, bounce_soft_incoming_right		# incoming soft right down
		beq $t5, -66, bounce_soft_incoming_left		# incoming soft left up
		beq $t5, -62, bounce_soft_incoming_right	# incoming soft right up
		
		b draw_screen
		
		bounce_soft_incoming_left:
			addi $t5, $t5, 4		# add 4 to reverse direction
			jal bounce_sound
			b draw_screen
			
		bounce_soft_incoming_right:
			addi $t5, $t5, -4		# add -4 to reverse direction
			jal bounce_sound
			b draw_screen
			
	bounce_ceiling:
		addi $t5, $t5, 128			# add 128 to reverse direction
		jal bounce_sound
		b draw_screen
	
check_bricks:	
	# check if ball hits brick
	# simulate next ball position
	add $t9, $t2, $t5
	add $t9, $t9, $t5
	lw $t7, 0($t9)			# colour of next ball position
	lw $t4, BLACK
	beq $t7, $t4, draw_screen		# if black, skip
	la $t9, BRICK_POSITIONS
	la $t8, BRICK_COLOURS
	addi $t6, $zero, 0			# i = 0
	
	find_brick:
		beq $t6, 35, draw_screen
		
		sll $t2, $t6, 2			# offset
		add $t3, $t9, $t2		# addr(BRICK_POSITIONS[i])
		lw $t0, 0($t3)			# position = BRICK_POSITIONS[i])
		add $t3, $t8, $t2		# addr(BRICK_COLOUR[i])
		lw $t4, 0($t3)			# colour = BRICK_COLOUR[i])
		beq $t7, $t4, brick_hit
		
		addi $t6, $t6, 1		# i++
		j find_brick
	
	j draw_screen
	
brick_hit:
	# figure out direction to bounce
	lw $t2, BALL_POS
	jal bounce_vertical
	# erase brick
	lw $t4, BLACK
	sw $t4, 0($t3)					# BRICK_COLOUR[i] = BLACK
	beq $t6, 1, short_brick
	beq $t6, 3, short_brick
	beq $t6, 6, short_brick
	beq $t6, 8, short_brick
	beq $t6, 11, short_brick
	beq $t6, 13, short_brick
	beq $t6, 16, short_brick
	beq $t6, 18, short_brick
	beq $t6, 21, short_brick
	beq $t6, 23, short_brick
	beq $t6, 26, short_brick
	beq $t6, 28, short_brick
	beq $t6, 31, short_brick
	beq $t6, 33, short_brick
	
	jal draw_brick_four
	jal bounce_sound
	j draw_screen
	
	short_brick:
		jal draw_brick_three
		jal bounce_sound
		j draw_screen
		
	bounce_vertical:
		addi $t2, $t2, -128			# check above the ball
		lw $t1, 0($t2)				# colour above ball
		beq $t1, $t4, flip_down
		lw $t2, BALL_POS
		addi $t2, $t2, -132			# check left corner above the ball
		lw $t1, 0($t2)				# colour above ball
		beq $t1, $t4, flip_down
		lw $t2, BALL_POS
		addi $t2, $t2, -124			# check right corner above the ball
		lw $t1, 0($t2)				# colour above ball
		beq $t1, $t4, flip_down
		lw $t2, BALL_POS
		addi $t2, $t2, 128			# check below the ball
		lw $t1, 0($t2)				# colour below ball
		beq $t1, $t4, flip_up
		lw $t2, BALL_POS
		addi $t2, $t2, 124			# check left corner below the ball
		lw $t1, 0($t2)				# colour above ball
		beq $t1, $t4, flip_up
		lw $t2, BALL_POS
		addi $t2, $t2, 132			# check right corner below the ball
		lw $t1, 0($t2)				# colour above ball
		beq $t1, $t4, flip_up
		
		j bounce_horizontal
		
		bounce_horizontal:
			lw $t2, BALL_POS
			addi $t2, $t2, -4			# check left of ball
			lw $t1, 0($t2)				# colour above ball
			beq $t1, $t4, flip_right
			lw $t2, BALL_POS
			addi $t2, $t2, 4			# check right of ball
			lw $t1, 0($t2)				# colour below ball
			beq $t1, $t4, flip_left
		
	flip_down:
		addi $t5, $t5, 128			# add 128 to reverse direction
		j jump_back
		
	flip_up:
		addi $t5, $t5, -128			# add -128 to reverse direction
		j jump_back
		
	flip_right:
		addi $t5, $t5, 4		# add 4 to reverse direction
		j jump_back
		
	flip_left:
		addi $t5, $t5, -4		# add -4 to reverse direction
		j jump_back
		
	j draw_screen
		
edge_collide:
	beq $t5, 64, check_down_harsh	# change direction of straight down depending on position
	slti $t9, $t5, 64				# save bool of if ball is moving left
	beq $t9, 1, harsh_left			# if ball is moving left, make it move a harsh left
	harsh_right:
		addi $t5, $zero, -60			# make ball move a harsh right
		jal paddle_sound
		b draw_screen
	harsh_left:
		addi $t5, $zero, -68			# make ball move a harsh left
		jal paddle_sound
		b draw_screen
	check_down_harsh:
		addi $t9, $t3, -128				# set $t9 to left-most edge of paddle
		beq $t9, $t8, harsh_left		# check if ball hits at paddle left edge
		addi $t9, $t9, 32				# set $t8 to right corner of paddle edge
		beq $t9, $t8, harsh_right		# check if ball hits at paddle right edge
		
mid_collide:
	beq $t5, 64, check_down_soft	# change direction of straight down depending on position	
	slti $t9, $t5, 64				# save bool of if ball is moving left
	beq $t9, 1, soft_left			# if ball is moving left, make it move a soft left
	soft_right:
	addi $t5, $zero, -62				# make ball move a soft right
	jal paddle_sound
	b draw_screen
	soft_left:
		addi $t5, $zero, -66			# make ball move a soft left
		jal paddle_sound
		b draw_screen
	check_down_soft:
		addi $t9, $t3, -124				# set $t9 to left-most left of paddle
		beq $t9, $t8, soft_left			# check if ball hits at paddle left side
		addi $t9, $t9, 4				# set $t9 to middle of left of paddle
		beq $t9, $t8, soft_left			# check if ball hits at paddle left side
		addi $t9, $t9, 4				# set $t9 to right-most left of paddle
		beq $t9, $t8, soft_left			# check if ball hits at paddle left side
		
		addi $t9, $t9, 8				# set $t9 to left-most right of paddle
		beq $t9, $t8, soft_right		# check if ball hits at paddle right side
		addi $t9, $t9, 4				# set $t9 to middle of right of paddle
		beq $t9, $t8, soft_right		# check if ball hits at paddle right side
		addi $t9, $t9, 4				# set $t9 to right-most right of paddle
		beq $t9, $t8, soft_right		# check if ball hits at paddle right side
		
direct_collide:
	jal paddle_sound
	addi $t5, $zero, -64				# make ball move straight up
	b draw_screen	
	
	# 2b. Update locations (paddle, ball)
move_left:
	lw $t3, PAD_POS
	lw $t9, LEFT_EDGE				# set $t9 to the left boundary of paddle
	beq $t3, $t9, draw_screen		# if paddle cannot move any more left, don't redraw
	lw $t4, BLACK					# change current colour to black for erasing
	sw $t4, 32($t3)					# erase last pixel of paddle
	lw $t4, LIGHT_PURPLE			# change current colour to light purple
	addi $t3, $t3, -4				# move paddle position left by one
	sw $t3, PAD_POS					# mutate pad_pos data
	sw $t4, 0($t3)					# colour in start of paddle
	
	beqz $t5, move_ball_left		# if ball has not been launched, move ball as well
	b draw_screen
	
	move_ball_left:
		addi $t8, $t2, 0				# temporarily save old ball position
		add $t2, $t2, -4				# move ball left
		sw $t2, BALL_POS				# mutate ball_pos data
		lw $t4, WHITE					# change current colour to white
		sw $t4, 0($t2)					# colour in new ball position
		lw $t4, BLACK					# change current colour to black for erasing
		sw $t4, 0($t8)					# erase old ball position
	
		b game_loop
		
move_right:
	lw $t3, PAD_POS
	lw $t9, RIGHT_EDGE				# set $t9 to the right boundary of paddle
	beq $t3, $t9, draw_screen		# if paddle cannot move any more right, don't redraw
	lw $t4, BLACK					# change current colour to black for erasing
	sw $t4, 0($t3)					# erase first pixel of paddle
	lw $t4, LIGHT_PURPLE			# change current colour to light purple
	addi $t3, $t3, 4				# move paddle position right by one
	sw $t3, PAD_POS					# mutate pad_pos data
	sw $t4, 32($t3)					# colour in end of paddle
	beqz $t5, move_ball_right		# if ball has not been launched, move ball as well	
	b draw_screen
	
	move_ball_right:
		addi $t8, $t2, 0				# temporarily save old ball position
		add $t2, $t2, 4					# move ball left
		sw $t2, BALL_POS				# mutate ball_pos data
		lw $t4, WHITE					# change current colour to white
		sw $t4, 0($t2)					# colour in new ball position
		lw $t4, BLACK					# change current colour to black for erasing
		sw $t4, 0($t8)					# erase old ball position
	
		b game_loop

launch:
	bne $t5, $zero, check_collision		# if ball is moving, don't change direction
	jal launch_sound
	addi $t5, $zero, -64			# set direction of ball directly upwards
		
	# 3. Draw the screen
draw_screen:
	lw $t1, ADDR_KBRD
	lw $t2, BALL_POS
	lw $t3, PAD_POS
	beqz $t5, game_loop				# don't redraw ball if ball is not moving
	addi $t8, $t2, 0				# temporarily save old ball position
	add $t2, $t2, $t5				# move ball in direction of $t5 part 1
	add $t2, $t2, $t5				# move ball in direction of $t5 part 2
	sw $t2, BALL_POS				# mutate ball_pos data
	lw $t4, WHITE					# change current colour to white
	sw $t4, 0($t2)					# colour in new ball position
	lw $t4, BLACK					# change current colour to black for erasing
	sw $t4, 0($t8)					# erase old ball position
	
	# 4. Sleep
	li 		$v0, 32
	li 		$a0, 30			# 1 frame per 30ms
	syscall
	
	b game_loop
	
pause:	
	lw $t9, TOP_LEFT_CORNER		# set $t9 in the top left corner
	lw $t8, BOT_RIGHT_CORNER	# set $t8 to be after the last pixel onscreen
	lw $t4, BLACK				# set colour as black for erasing
	addi $t8, $t8, 4
	jal wipe_clean			# black out screen
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of pause symbol
	addi $t9, $zero, 10		# set $t9 to be end of increment
	addi $t8, $zero, 0		# set $t8 to be the counter
	lw $t4, LIGHT_PURPLE	# set colour to light purple
	jal draw_pause
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of second rectangle of pause symbol
	addi $t7, $t7, 24
	addi $t8, $zero, 0		# set $t8 to be the counter
	jal draw_pause

pause_wait:				
	# 4. Sleep
	li 		$v0, 32
	li 		$a0, 30			# 1 frame per 30ms
	syscall
	
	# 1a. Check if key has been pressed
    lw $t7, 0($t1)                  # Load first word from keyboard
    beq $t7, 1, pause_input      # If first word 1, key is pressed
    
    b pause_wait
    
    pause_input:
    	lw $a0, 4($t1)                  # Load second word from keyboard
    	beq $a0, 0x71, game_over		# Check if the key q was pressed
		beq $a0, 0x1b, game_over		# Check if esc was pressed
    	beq $a0, 0x70, unpause			# Check if the key p was pressed
    	li $v0, 1                       # ask system to print $a0
    	syscall
    	
    	b pause_wait					# if other key was pressed, stay paused

unpause:
	lw $t4, BLACK				# set colour as black for erasing
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of pause symbol
	addi $t9, $zero, 10		# set $t9 to be end of increment
	addi $t8, $zero, 0		# set $t8 to be the counter
	jal draw_pause
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of second rectangle of pasue symbol
	addi $t7, $t7, 24
	addi $t8, $zero, 0		# set $t8 to be the counter
	jal draw_pause
	
	j render_rest				# render previous game state
	
lose:
	lw $t9, LIVES			# set $t9 to the number of lives
	addi $t9, $t9, -1		# decrement the lives
	beqz $t9, game_over			# if there are no lives left, game_over game
	sw $t9, LIVES			# else, store the updated lives in the memory address
	j main
		
	jump_back:
		jr $ra
game_over:
	jal over_sound
	lw $t9, TOP_LEFT_CORNER		# set $t9 in the top left corner
	lw $t8, BOT_RIGHT_CORNER	# set $t8 to be after the last pixel onscreen
	lw $t4, BLACK				# set colour as black for erasing
	addi $t8, $t8, 4
	jal wipe_clean
	j draw_sadge
	addi $t7, $zero, 0
	
game_over_loop:
	# 4. Sleep
	li 		$v0, 32
	li 		$a0, 30			# 1 frame per 30ms
	syscall
	
	# 1a. Check if key has been pressed
    lw $t7, 0($t1)                  # Load first word from keyboard
    beq $t7, 1, retry_input      	# If first word 1, key is pressed
    
    b game_over_loop
    
    # 1b. Check which key has been pressed
retry_input:						# A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
	beq $a0, 0x71, quit				# Check if the key q was pressed
	beq $a0, 0x1b, quit				# Check if esc was pressed
	beq $a0, 0x72, main				# Check if the key r was pressed
    li $v0, 1                       # ask system to print $a0
    syscall
    
    b game_over_loop
    
quit:
	li $v0, 10                      # Quit gracefully
	syscall
	
wipe_clean:
	beq $t9, $t8, jump_back	# break loop if entire screen is cleared
	sw $t4, 0($t9)			# erase pixel at $t9
	addi $t9, $t9, 4		# increment $t9
	j wipe_clean			# loop back up
	
draw_pause:
	beq $t9, $t8, jump_back		# break out of loop
	sw $t4, 0($t7)				# colour in position
	sw $t4, 4($t7)				# colour in adjacent position
	addi $t7, $t7, 128			# move position down
	addi $t8, $t8, 1			# increment
	b draw_pause				# loop back up
	
draw_sadge:
	addi $t9, $zero, 10		# set $t9 to be end of increment
	addi $t8, $zero, 0		# set $t8 to be the counter
	lw $t7, PAUSE_POS
	lw $t4, LIGHT_PURPLE
	jal draw_pause
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of second rectangle of pause symbol
	addi $t7, $t7, 24
	addi $t8, $zero, 0		# set $t8 to be the counter
	jal draw_pause
	
	lw $t7, PAUSE_POS		# set $t7 to be the beginning of second rectangle of pause symbol
	addi $t7, $t7, 1280
	addi $t7, $t7, 1280
	addi $t7, $t7, -16
	sw $t4, -380($t7)
	sw $t4, -508($t7)
	sw $t4, -504($t7)
	sw $t4, -632($t7)
	sw $t4, -628($t7)
	sw $t4, -756($t7)
	sw $t4, -752($t7)
	sw $t4, -880($t7)
	sw $t4, -876($t7)
	sw $t4, -872($t7)
	sw $t4, -1000($t7)
	sw $t4, -996($t7)
	sw $t4, -992($t7)
	sw $t4, -988($t7)
	sw $t4, -860($t7)
	sw $t4, -856($t7)
	sw $t4, -852($t7)
	sw $t4, -724($t7)
	sw $t4, -720($t7)
	sw $t4, -592($t7)
	sw $t4, -588($t7)
	sw $t4, -460($t7)
	sw $t4, -456($t7)
	sw $t4, -328($t7)
	j game_over_loop
	
paddle_sound:
	li $v0, 31			# function to play MIDI out
	la $t9, MID_C
	la $t8, LENGTH
	la $t7, SYNTH_HIT
	la $t6, VOLUME
	lbu $a0, 0($t9)
	lbu $a1, 0($t8)
	lbu $a2, 0($t7)
	lbu $a3, 0($t6)
	syscall
	j jump_back
	
over_sound:
	li $v0, 31			# function to play MIDI out
	la $t9, GB_4
	la $t8, LENGTH
	la $t7, VOICE_OOH
	la $t6, VOLUME
	lbu $a0, 0($t9)
	lbu $a1, 0($t8)
	lbu $a2, 0($t7)
	lbu $a3, 0($t6)
	syscall
	la $t9, E_4
	lbu $a0, 0($t9)
	syscall
	la $t9, EB_4
	lbu $a0, 0($t9)
	syscall
	j jump_back
	
break_sound:
	li $v0, 31			# function to play MIDI out
	la $t9, E_4
	la $t8, LENGTH
	la $t7, SYNTH_HIT
	la $t6, VOLUME
	lbu $a0, 0($t9)
	lbu $a1, 0($t8)
	lbu $a2, 0($t7)
	lbu $a3, 0($t6)
	syscall
	j jump_back
	
bounce_sound:
	li $v0, 31			# function to play MIDI out
	la $t9, GB_4
	la $t8, LENGTH
	la $t7, SYNTH_HIT
	la $t6, VOLUME
	lbu $a0, 0($t9)
	lbu $a1, 0($t8)
	lbu $a2, 0($t7)
	lbu $a3, 0($t6)
	syscall
	j jump_back
	
launch_sound:
	li $v0, 31			# function to play MIDI out
	la $t9, E_4
	la $t8, LENGTH
	la $t7, LAUNCH_HIT
	la $t6, VOLUME
	lbu $a0, 0($t9)
	lbu $a1, 0($t8)
	lbu $a2, 0($t7)
	lbu $a3, 0($t6)
	syscall
	j jump_back
