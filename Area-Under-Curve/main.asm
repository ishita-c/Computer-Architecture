# MIPS Assembly Program for obtaining the area under a curve
# formed by joining successive points by a straight line

# -----------------------------------------------------
# Data Declarations

.data
	header:	.ascii "Area Calculation\n"
	    		.asciiz "Enter Number of Points n: "
	promptx:	.asciiz "Enter x: "
	prompty:	.asciiz "Enter y: "
	areamessage:	.asciiz "Area is: "
	errorinn: 	.ascii "Error: Invalid n\n"	
			.asciiz "n should be an integer greater than 1"
	errorinx:	.ascii "Error: Invalid x\n"
			.asciiz "Area is overflowed OR x should be an integer greater than or equal to previous x"
	erroroverflow:	.asciiz "Error: The area has overflowed"    	
	sum:	.double 0.0
	n :	.word 0
	area:	.double 0.0
	zero:	.double 0.0
	two:	.double 2.0

# -----------------------------------------------------
# text/code section

.text
.globl	main
.ent	main

main:

	li	$v0, 4
	la	$a0, header
	syscall
	
	li	$v0, 5
	syscall	
	blt	$v0, 2, errorInn
	sw	$v0, n
	
	li	$v0, 4
	la	$a0, promptx
	syscall
	li	$v0, 5
	syscall
	move	$s3, $v0
	
	li	$v0, 4
	la	$a0, prompty
	syscall
	li	$v0, 5
	syscall
	move	$s4, $v0	
	
	lw	$s0, n
	li	$s1, 1
	li	$s2, 0
	l.d	$f4, zero  # initial double-type area
	l.d	$f2, zero  # store value 0 in register $f2 for comparisions
	
mainLoop:
	
	bne	$s1, 1, iter
	
backFromIter:
	
	li	$v0, 4
	la	$a0, promptx
	syscall
	li	$v0, 5
	syscall
	move	$s5, $v0	
	li	$v0, 4
	la	$a0, prompty
	syscall
	li	$v0, 5
	syscall
	move	$s6, $v0
	
	bgt	$s3, $s5, errorInx # if x1 is less than x2 then print error and exit
	
	mult	$s4, $s6
	mflo	$t0	# 32 least significant bits of mult
	mfhi	$t1	# 32 most significant bits of mult
	mtc1.d	$t0, $f0
	cvt.d.w $f0, $f0
	c.le.d	$f2, $f0 # $f2 <= $f0, result stored in flag
	bc1t	pos	# branch to the label pos if true	
	bc1f	nega	# branch to the label nega if false
	
backFromPosNega:
	
	add	$s1, $s1, 1	
	blt	$s1, $s0, mainLoop
	
	l.d	$f6, two	
	div.d	$f4, $f4, $f6	
	s.d	$f4, area
	b	exit
	
pos:
	sub	$t1, $s5, $s3
	add	$t2, $s4, $s6
	abs	$t3, $t2
	mult	$t1, $t3
	mflo	$t4	# 32 least significant bits of mult
	mfhi	$t5	# 32 most significant bits of mult	
	mtc1.d	$t4, $f6
	cvt.d.w $f6, $f6
	
	c.lt.d	$f6, $f2 # $f6 < $f2 (=0), result stored in flag
	bc1t	errorOverflow	# branch to the label errorOverflow if true
		
	add.d	$f4, $f4, $f6
	
	c.lt.d	$f4, $f2 # $f4 < $f2 (=0), result stored in flag
	bc1t	errorOverflow	# branch to the label errorOverflow if true
	
	b	backFromPosNega	

nega:
	sub	$t1, $s5, $s3
	sub	$t2, $s6, $s4
	abs	$t3, $s6
	abs	$t4, $s4
	mult	$t3, $s6
	mflo	$t6	# 32 least significant bits of mult
	mfhi	$t7	# 32 most significant bits of mult	
	mtc1.d	$t6, $f6
	cvt.d.w $f6, $f6
	mult	$t4, $s4
	mflo	$t8	# 32 least significant bits of mult
	mfhi	$t9	# 32 most significant bits of mult	
	mtc1.d	$t8, $f8
	cvt.d.w $f8, $f8	
	sub.d	$f10, $f6, $f8
	mtc1.d	$t1, $f12
	cvt.d.w $f12, $f12
	mtc1.d	$t2, $f14
	cvt.d.w $f14, $f14	
	mul.d	$f16, $f12, $f10
	div.d	$f18, $f16, $f14
	
	c.lt.d	$f18, $f2 # $f18 < $f2 (=0), result stored in flag
	bc1t	errorOverflow	# branch to the label errorOverflow if true
	
	add.d	$f4, $f4, $f18
	
	c.lt.d	$f4, $f2 # $f4 < $f2 (=0), result stored in flag
	bc1t	errorOverflow	# branch to the label errorOverflow if true
	
	b	backFromPosNega
	
iter:
	
	move	$s3, $s5
	move	$s4, $s6
	b	backFromIter
	
# -----	
exit:	

	li	$v0, 4
	la	$a0, areamessage
	syscall
	li	$v0, 3
	l.d	$f12, area
	syscall
	b	terminate
	
errorInn:

	li	$v0, 4
	la	$a0, errorinn
	syscall
	b	terminate
	
errorInx:

	li	$v0, 4
	la	$a0, errorinx
	syscall
	b	terminate
	
errorOverflow:

	li	$v0, 4
	la	$a0, erroroverflow
	syscall
	
terminate:	

# -----
# Done, terminate program.
	li	$v0, 10
	syscall
	
.end main
