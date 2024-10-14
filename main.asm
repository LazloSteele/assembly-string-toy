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
	output_buffer: .space 101
.globl main
.text
main:
	la $a0, welcome_msg
	jal print
	la $a0, input_prmpt
	jal print
	la $a0, buffer
	li $a1, 101
	jal get_string
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
	la $a0, output_msg			# Store the message to format the output
	jal print				# Print that string!
	la $a0, output_buffer			# load the output buffer to be printed
	jal print				# print that string!
####################################################################################################
# function: again
# purpose: to user to repeat or close the program
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print and buffer storage
#	$t0 - stores the memory address of the buffer and first character of the input received
#	$t1 - ascii 'a', 'Y', and 'N'
####################################################################################################
again:						#
	la $a0, repeat_msg 			# load address of result_msg_m1 into $a0
	jal print 				# print the result message
	li $v0, 8				# system call code for read str
	la $a0, buffer				# load the address of the buffer
	li $a1, 5				# only accept characters equal to the buffer size
	syscall 				# get that str!
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
		beq $t0, $t1, end		# If no, goodbye!
		li $v0, 4			# system call code for print_str
		la $a0, invalid_msg 		# load address of invalid_msg into $a0
		syscall 			# print the result message
		j again				# if invalid try again...
####################################################################################################
# function: end
# purpose: to eloquently terminate the program
# registers used:
#	$v0 - syscall codes
#	$a0 - message storage for print
####################################################################################################	
end:						#
	la $a0, bye	 			# load address of bye into $a0
	jal print 				# print the goodbye message
	li $v0, 10				# system call code for returning control to system
	syscall					# GOODBYE!
####################################################################################################
get_string:
	li $v0 8
	syscall
	jr $ra
print:
	li $v0 4
	syscall
	jr $ra
