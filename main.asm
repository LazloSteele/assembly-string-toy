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
	newline: .asciiz "\n"
	.align 2
	buffer: .space 100
	output_buffer: .space 100

.include "macros.asm"

.globl main
.text
main:
	print_str (welcome_msg)
	print_str (input_prmpt)
	read_str (buffer, 101)
	
	la $a0, buffer
	jal white_space_wipeout
	
	la $a0, output_buffer
	jal print_condensed

	reset_buffer (output_buffer, 101)	# reset output buffer
	j again_loop
	
again_loop:
	again
	j again_loop

white_space_wipeout:
	move $s0, $ra
	move $t0, $a0
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
	done:
		move $ra, $s0
		jr $ra

print_condensed:
	move $s0, $ra
	move $t0, $a0
	
	print_str (output_msg) # Store the message to format the output
	print_str (output_buffer)			# load the output buffer to be printed
	print_str (newline)
	
	move $ra, $s0
	jr $ra
