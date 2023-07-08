# MIPS Assembly Program for evaluating postfix expressions.

# -----------------------------------------------------
# Data Declarations

.data
	header:	.ascii "\nEvaluation of Postfix expression\n"
	    		.asciiz "Enter the Postfix expression (then press enter to continue): "
		
	answermsg:	.asciiz "The expression evaluates to: "
	
	error1:	.ascii "\nError: Invalid postfix expression.\n"
	    		.asciiz "First two characters of the Postfix expression must be integers [0-9].\n"
	error2:	.ascii "\nError: Invalid postfix expression.\n"
	    		.asciiz "Postfix expressions must contain integers [0-9] and desired operators [+,-,*] only.\n"
	error3:	.ascii "\nError: Invalid postfix expression.\n"
	    		.asciiz "Stack should contain atleast two integers when it encounters an operator.\n"
	error4:	.ascii "\nError: Invalid postfix expression.\n"
	    		.asciiz "Number of integers in postfix expression exceeded.\n"

	errornone:	.ascii "\nError: Invalid postfix expression.\n"
	    		.asciiz "Expression not entered.\n"



# -----------------------------------------------------
# text/code section

.text
.globl	main
.ent	main

main:

	li	$v0, 4
	la	$a0, header
	syscall
	
spaceloop1:
	
	li	$v0, 12
	syscall
	
	beq	$v0, 10, ERRORNONE	#ascii value of "enter"
	beq	$v0, 32, spaceloop1	#ascii value of space
	blt 	$v0, 48, ERROR1	#ascii value of zero
	bgt 	$v0, 57, ERROR1   	#ascii value of 9
  	addi 	$v0, $v0, -48		#converting char to int
	subu 	$sp, $sp, 4		#stack push
	sw 	$v0, ($sp)
	
spaceloop2:

	li	$v0, 12
	syscall

	beq	$v0, 10, ERRORINT
	beq	$v0, 32, spaceloop2	
	blt 	$v0, 48, ERROR1   
	bgt 	$v0, 57, ERROR1   
  	addi 	$v0, $v0, -48
	subu 	$sp, $sp, 4
	sw 	$v0, ($sp)

	li 	$s1, 2 		#length of stack
	
readLoop:

	li	$v0, 12
	syscall
	bgt 	$v0, 57, ERROR2
	beq	$v0, 10, exit
	beq	$v0, 32, readLoop
	beq	$v0, 42, multiply	#ascii value of *  
	beq	$v0, 43, addition	#ascii value of +  
	beq	$v0, 45, subtract	#ascii value of -  
	blt 	$v0, 48, ERROR2
	addi 	$v0, $v0, -48
	subu 	$sp, $sp, 4
	sw 	$v0, ($sp)
	addu	$s1, $s1, 1 		#incrementing size of stack by one
	b 	readLoop

multiply:

	blt 	$s1, 2, ERROR3
	lw	$s2, ($sp)		#multipop from stack
	lw	$s3, 4($sp)
	addu 	$sp, $sp, 8
	mul	$s4, $s3, $s2
	subu 	$sp, $sp, 4
	sw 	$s4, ($sp)		#push after operation
	sub	$s1, $s1, 1		#decrementing size of stack by one, two pops and one push
	b 	readLoop

addition:

	blt 	$s1, 2, ERROR3
	lw	$s2, ($sp)
	lw	$s3, 4($sp)
	addu 	$sp, $sp, 8
	add	$s4, $s3, $s2
	subu 	$sp, $sp, 4
	sw 	$s4, ($sp)
	sub	$s1, $s1, 1
	b 	readLoop

subtract:

	blt 	$s1, 2, ERROR3
	lw	$s2, ($sp)
	lw	$s3, 4($sp)
	addu 	$sp, $sp, 8
	sub	$s4, $s3, $s2
	subu 	$sp, $sp, 4
	sw 	$s4, ($sp)
	sub	$s1, $s1, 1
	b 	readLoop		
	
# -----	
exit:	
	bne	$s1, 1, ERROR4		#stack should contain only one element
	li	$v0, 4
	la	$a0, answermsg
	syscall
	lw 	$a0, ($sp)
	addu 	$sp, $sp, 4
	li	$v0, 1
	syscall
	b	terminate

ERRORINT:
	li	$v0, 4
	la	$a0, answermsg
	syscall
	lw 	$a0, ($sp)
	addu 	$sp, $sp, 4
	li	$v0, 1
	syscall
	b	terminate

ERRORNONE:
	li	$v0, 4
	la	$a0, errornone
	syscall
	b	terminate
	
ERROR1:

	li	$v0, 4
	la	$a0, error1
	syscall
	b	terminate
ERROR2:

	li	$v0, 4
	la	$a0, error2
	syscall
	b	terminate
ERROR3:

	li	$v0, 4
	la	$a0, error3
	syscall
	b	terminate

ERROR4:

	li	$v0, 4
	la	$a0, error4
	syscall
	b	terminate
	
terminate:	

# -----
# Done, terminate program.
	li	$v0, 10
	syscall
	
.end main
