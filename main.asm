# Program #7: String Compressor with Letter Frequency Map
# Author: Lazlo F. Steele
# Due Date : Oct. 19, 2024 Course: CSC2025-2H1
# Created: Oct. 14, 2024
# Last Modified: Oct. 14, 2024
# Functional Description: Remove non-alphabetic characters from user provided string and count frequency of each letter.
# Language/Architecture: MIPS 32 Assembly
####################################################################################################
# Algorithmic Description:
#	Welcome user
#	Accept string input and store it in buffer
#	For each character
#		If character is not alphabetic skip
#		Else add character to output buffer
#		Print output buffer
#	Play again???
#	Toodles!
####################################################################################################
.data
	welcome_msg: .asciiz "Welcome to the String Shortener Emporium! We will take your whitespace and punctuation free of charge!\n"
	input_prmpt: .asciiz "vvv Please enter a string of up to 100 characters on the line below vvv\n"
	repeat_msg: .asciiz "Go again? Y/N > "
	invalid_msg: .asciiz "Invalid input. Try again!\n"
	output_msg: .asciiz "The compressed string is: "
	bye: .asciiz "Toodles! ;)"
	buffer: .space 100
	output_buffer: .space 100
	buffer_size: .word 101

####################################################################################################
# macro: print_str
# purpose: to make printing messages more eloquent
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print
# variables used:
#	%x - message to be printed
####################################################################################################		
.macro print_str (%message)
	li $v0 4
	la $a0, %message
	syscall
.end_macro
####################################################################################################
# macro: read_str
# purpose: to make printing messages more eloquent
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print
# variables used:
#	%x - message to be printed
####################################################################################################		
.macro read_str (%buffer_address, %buffer_size)
	li $v0, 8
	la $a0, %buffer_address
	li $a1, %buffer_size
	syscall
.end_macro

####################################################################################################
# function: again
# purpose: to user to repeat or close the program
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print and buffer storage
#	$t0 - stores the memory address of the buffer and first character of the input received
#	$t1 - ascii 'a', 'Y', and 'N'
####################################################################################################
.macro again				#
	la $a0, buffer			# load buffer for reset
	lw $a1, buffer_size		# load empty value to reset the buffer
	jal reset_buffer		# reset the buffer!
	la $a0, output_buffer	# load buffer for reset
	jal reset_buffer		# reset that buffer

	print_str (repeat_msg) 			# load address of result_msg_m1 into $a0
	read_str (buffer, 4)	# load the address of the buffer

	la $t0, buffer				# load the buffer for string manipulation
	lb $t0, 0($t0)				# load the first character of the input string
	li $t1, 'a'				# check if lower case
	blt $t0, $t1, is_upper			# bypass uppercaserizer if character is already upper case (or invalid)
	to_upper:				#
		subi $t0, $t0, 32		# Convert to uppercase (ASCII difference between 'a' and 'A' is 32)
	is_upper:				#
		li $t1, 'Y'			# store the value of ASCII 'Y' for comparison
		beq $t0, $t1, main		# If yes, go back to the start of main
		li $t1, 'N'			# store the value of ASCII 'N' for comparison
		beq $t0, $t1, end_program		# If no, goodbye!
		print_str (invalid_msg) 		# load address of invalid_msg into $a0
		j invalid				# if invalid try again...
	end_program:
		end
	invalid:
.end_macro
####################################################################################################
# function: end
# purpose: to eloquently terminate the program
# registers used:
#	$v0 - syscall codes
####################################################################################################	
.macro end 					#
	print_str (bye)	 		# load address of bye into $a0
	li $v0, 10				# system call code for returning control to system
	syscall					# GOODBYE!
.end_macro					#
####################################################################################################

.globl main
.text
main:
	print_str (welcome_msg)
	print_str (input_prmpt)
	read_str (buffer, 101)
	la $t0, buffer
white_space_wipeout:
	la $t1, output_buffer			#
	for_char:				#
	    	lb $t2, 0($t0)   		# Load byte from buffer
    		beq $t2, 10, done   		# '\n' or 0a [HEX] or 10 [DEC] denotes end of string, if end of string is reached without error then input is valid!
		blt $t2, 'A', invalid		# If byte is less than ascii 'A' then it's not alphabetic
		bgt $t2, 'Z', mebbe		# If byte is greater than 'Z' then maybe valid as a lower but also maybe punctuation
		j valid				#
		mebbe:				#
			blt $t2, 'a', invalid	# If byte is less than ascii 'a' it is invalid
	       		bgt $t2, 'z', invalid	# If byte is greater than ascii 'z' then it's not alphabetic
	       		j valid
		valid:
			sb $t2, 0($t1)       	# store the character in the output buffer
			addi $t1, $t1, 1	# move the address up one to store the next character
			j iterate		# iterate!
		invalid:			#
			j iterate		# do nothing and iterate!
		iterate:			#
			addi $t0, $t0, 1	# yo dawg I hear you like iterating so we iterate the iterator			
    			j for_char		# so you can iterate... the function...	
done:						#
	li $t2, '\n'				# Load newline
	sb $t2, 0($t1)				# Store newline at end of string!
	print_str (output_msg) # Store the message to format the output
	print_str (output_buffer)			# load the output buffer to be printed
again_loop:
	again
	print_str (invalid_msg)
	j again_loop
###############################################################################
reset_buffer:
	move $s0, $ra			# return address to $s0
	move $t0, $a0			# buffer to $t0
	move $t1, $a1			# buffer_size to $t1
	li $t2, 0				# to reset values in buffer
	li $t3, 0				# initialize iterator
	reset_buffer_loop:		#
		bge $t3, $t1, reset_buffer_return
		sw $t2, 0($t0)		# store a 0
		addi $t0, $t0, 4	# next word in buffer
		addi $t3, $t3, 1	# iterate it!
		j reset_buffer_loop # and loop!
	reset_buffer_return:
	move $ra, $s0			# get ready to return
	jr $ra					# return to caller
	