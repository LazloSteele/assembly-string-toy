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
	repeat_msg: .asciiz "\nGo again? Y/N > "
	invalid_msg: .asciiz "Invalid input. Try again!\n"
	output_msg: .asciiz "The compressed string is: "
	bye: .asciiz "Toodles! ;)"
	letter_map: .asciiz "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
	space: .ascii " "
	newline: .asciiz "\n"
	.align 2
	buffer: .space 100
	.align 2
	frequency_map: .word 0 : 26

.include "macros.asm"

.globl main
.text
main:
	print_str (welcome_msg)
	print_str (input_prmpt)
	read_str (buffer, 101)
	
	la $a0, buffer
	jal condensed_to_stack
	
	reset_buffer (buffer, 101)
	la $a0, buffer
	jal stack_to_buffer
	jal print_condensed

	la $a0, buffer
	jal letter_frequency
	jal print_frequency
	
	again_loop:
		again
		j again_loop
	
#################################
condensed_to_stack:
	move $s0, $ra
	move $t0, $a0
	
	subu $sp, $sp, 100		# free up 100 characters (bytes) on the stack
	move $t1, $sp

	for_char:				#
	   	lb $t2, 0($t0)   		# Load byte from buffer
    	beq $t2, 10, done 		# '\n' or 0a [HEX] or 10 [DEC] denotes end of string, if end of string is reached without error then input is valid!

		alpha ($t2)
		beqz $t8, iterate

		store_char:
			sb $t2, 0($t1)       	# store the character in the stack
			addi $t1, $t1, 1	# move the address up one to store the next character
		iterate:			 #
			addi $t0, $t0, 1	# yo dawg I hear you like iterating so we iterate the iterator			
    		j for_char		# so you can iterate... the function...	
	done:
		move $ra, $s0
		jr $ra
#################################
stack_to_buffer:
	move $s0, $ra
	move $t0, $a0
	move $t1, $sp

	for_char_in_stack:				#
	   	lb $t2, 0($t1)   		# Load byte from buffer
    	beq $t2, 0, stack_done 		# '\n' or 0a [HEX] or 10 [DEC] denotes end of string, if end of string is reached without error then input is valid!

		sb $t2, 0($t0)       	# store the character in the buffer
		addi $t1, $t1, 1	# move the address up one to store the next character
		addi $t0, $t0, 1
    	j for_char_in_stack		# so you can iterate... the function...	

	stack_done:
		move $ra, $s0
		jr $ra

#################################
letter_frequency:
	upper (buffer)

	move $s0, $ra
	move $t0, $a0
	
	li $t1, 'A'
	li $t2, 0
	la $t3, frequency_map
	frequency_loop:
		bgt $t1, 'Z', frequency_done
		lb $t4, 0($t0)
		beq $t4, 0, iterate_letter
		bne $t4, $t1, iterate_char
		addi $t2, $t2, 1
		iterate_char:
			addi $t0, $t0, 1
			j frequency_loop
		iterate_letter:
			sw $t2, 0($t3)
			li $t2, 0
			addi $t3, $t3, 4
			addi $t1, $t1, 1
			move $t0, $a0
			j frequency_loop
	frequency_done:
		move $ra, $s0
		jr $ra

#################################
print_frequency:
	move $s0, $ra
	
	la $t0, frequency_map
	li $t1, 26
	
	print_str (letter_map)
	print_str (newline)
		
	print_frequency_loop:
		beqz $t1, print_frequency_done
		lw $a0, 0($t0)
		li $v0, 1
		syscall
		li $a0, ' '
		li $v0, 11
		syscall
		addi $t1, $t1, -1
		addi $t0, $t0, 4
		
		j print_frequency_loop
		
	print_frequency_done:
		move $ra, $s0
		jr $ra

#################################
print_condensed:
	move $s0, $ra
	
	print_str (output_msg) # Store the message to format the output
	print_str (buffer)			# load the output buffer to be printed
	print_str (newline)
	
	move $ra, $s0
	jr $ra
